--Sample Query
SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF100TCL"."CALL_CENTER";
SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF100TCL"."CUSTOMER";

--Database : USDA
SELECT * FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."FD_GROUP_INGEST";
SELECT FDGRP_DESC FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."FD_GROUP_INGEST" WHERE FDGRP_DESC LIKE '%Food%';

//to see the files present in external stage 
list @MY_S3_BUCKET/load/;

Create table "USDA_NUTRIENT_STDREF"."PUBLIC"."FD_GROUP" (
  fdgrp_cd varchar(4)
 ,fdgrp_desc varchar(60));

//LOAD - our target table is the food group table which we load using the insert command
INSERT INTO "USDA_NUTRIENT_STDREF"."PUBLIC"."FD_GROUP"
SELECT
//TRANSFORM - we clean up the data by replacing the tildes in both fields
REPLACE(fdgrp_cd,'~','') as fdgrp_cd,
REPLACE(fdgrp_desc,'~','') as fdgrp_desc
//EXTRACT - source table is the food group ingest table
FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."FD_GROUP_INGEST";

SELECT * FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."FD_GROUP";

//S3 Interaction
CREATE TABLE WEIGHT_INGEST (
    NDB_NO	VARCHAR(7)
    ,SEQ	VARCHAR(4)
    ,AMOUNT	NUMBER(6,3)
    ,MSRE_DESC	VARCHAR(86)
    ,GM_WGT	NUMBER(7,1)
    ,NUM_DATA_PTS	NUMBER(4,0)
    ,STD_DEV	NUMBER(7,3));
  
//File Formt creation 
CREATE FILE FORMAT USDA_FILE_FORMAT 
TYPE = 'CSV' 
COMPRESSION = 'AUTO' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 0 
FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
TRIM_SPACE = FALSE 
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
ESCAPE = 'NONE' 
ESCAPE_UNENCLOSED_FIELD = '\134' 
DATE_FORMAT = 'AUTO' 
TIMESTAMP_FORMAT = 'AUTO' 
NULL_IF = ('\\N');

//Loading Files data present in STAGE into Snowflake
COPY INTO WEIGHT_INGEST
FROM @MY_S3_BUCKET/load/
FILES = ('WEIGHT.txt')
FILE_FORMAT = (FORMAT_NAME = USDA_FILE_FORMAT)
FORCE = TRUE;

SELECT COUNT(*) FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."WEIGHT_INGEST";
--RUNCATE TABLE "USDA_NUTRIENT_STDREF"."PUBLIC"."WEIGHT_INGEST";

CREATE OR REPLACE TABLE WEIGHT (
    NDB_NO	VARCHAR(5)
    ,SEQ	VARCHAR(2)
    ,AMOUNT	NUMBER(6,3)
    ,MSRE_DESC	VARCHAR(84)
    ,GM_WGT	NUMBER(7,1)
    ,NUM_DATA_PTS	NUMBER(4,0)
    ,STD_DEV	NUMBER(7,3));
  
//ETL to move WEIGHT data from WEIGHT_INGEST to WEIGHT 
//LOAD STEP
INSERT INTO WEIGHT(
SELECT //TRANSFORM STEP
    REPLACE(NDB_NO,'~') as NDB_NO
    ,REPLACE(SEQ,'~') as SEQ
    ,AMOUNT
    ,REPLACE(MSRE_DESC,'~') as MSRE_DESC
    ,GM_WGT
    ,NUM_DATA_PTS
    ,STD_DEV
//EXTRACT STEP 
FROM WEIGHT_INGEST);

SELECT COUNT(*) FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."WEIGHT";
//TRUNCATE TABLE "USDA_NUTRIENT_STDREF"."PUBLIC"."WEIGHT";

SELECT * FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."LANGDESC";

COPY INTO LANGDESC(FACTOR_CODE, DESCRIPTION) FROM 
(SELECT REPLACE($1,'~'), REPLACE($2,'~')
FROM @MY_S3_BUCKET/load/LANGDESC.txt)
FILE_FORMAT =  USDA_FILE_FORMAT;

//Semi-structured Data Query Interaction

//XML DDL Scripts
USE LIBRARY_CARD_CATALOG;

//Create an Ingestion Table for XML Data
CREATE TABLE "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR_INGEST_XML" (
  "RAW_AUTHOR" VARIANT);

//Create File Format for XML Data
CREATE FILE FORMAT "LIBRARY_CARD_CATALOG"."PUBLIC".XML_FILE_FORMAT 
TYPE = 'XML' 
COMPRESSION = 'AUTO' 
PRESERVE_SPACE = FALSE 
STRIP_OUTER_ELEMENT = FALSE 
DISABLE_SNOWFLAKE_DATA = FALSE 
DISABLE_AUTO_CONVERT = FALSE 
IGNORE_UTF8_ERRORS = FALSE; 

//Update Statement For File Format
ALTER FILE FORMAT "LIBRARY_CARD_CATALOG"."PUBLIC".XML_FILE_FORMAT
SET STRIP_OUTER_ELEMENT = TRUE;

//2nd Part Of DML Demonstration
// XML DML Scripts
USE LIBRARY_CARD_CATALOG;

//Returns entire record
SELECT raw_author FROM author_ingest_xml;

// Presents a kind of meta-data view of the data
SELECT raw_author:"$" FROM author_ingest_xml; 

//shows the root or top-level object name of each row
SELECT raw_author:"@" FROM author_ingest_xml; 

//returns AUTHOR_UID value from top-level object''s attribute
SELECT raw_author:"@AUTHOR_UID" FROM author_ingest_xml;

//The first row is weird because it has all the data smushed into it. 
//If you want to delete just that row, run this statement
//DELETE FROM author_ingest_xml WHERE raw_author like '%<dataset>%';
SELECT * FROM author_ingest_xml WHERE raw_author like '%<dataset>%';

//returns value of NESTED OBJECT called FIRST_NAME
SELECT XMLGET(raw_author, 'FIRST_NAME'):"$" FROM author_ingest_xml;

//returns the data in a way that makes it look like a normalized table
SELECT 
raw_author:"@AUTHOR_UID" as AUTHOR_ID
,XMLGET(raw_author, 'FIRST_NAME'):"$" as FIRST_NAME
,XMLGET(raw_author, 'MIDDLE_NAME'):"$" as MIDDLE_NAME
,XMLGET(raw_author, 'LAST_NAME'):"$" as LAST_NAME
FROM AUTHOR_INGEST_XML;

//add ::STRING to cast the values into strings and get rid of the quotes
SELECT 
raw_author:"@AUTHOR_UID" as AUTHOR_ID
,XMLGET(raw_author, 'FIRST_NAME'):"$"::STRING as FIRST_NAME
,XMLGET(raw_author, 'MIDDLE_NAME'):"$"::STRING as MIDDLE_NAME
,XMLGET(raw_author, 'LAST_NAME'):"$"::STRING as LAST_NAME
FROM AUTHOR_INGEST_XML;

//STARTS FROM HERE 
// Create a new database and set the context to use the new database
//CREATE DATABASE LIBRARY_CARD_CATALOG COMMENT = 'Essentials Lesson 9 ';
//USE DATABASE LIBRARY_CARD_CATALOG;

// Create and Author table
CREATE OR REPLACE TABLE AUTHOR (
   AUTHOR_UID NUMBER 
  ,FIRST_NAME VARCHAR(50)
  ,MIDDLE_NAME VARCHAR(50)
  ,LAST_NAME VARCHAR(50));

// Insert the first two authors into the Author table
INSERT INTO AUTHOR(AUTHOR_UID,FIRST_NAME,MIDDLE_NAME, LAST_NAME) Values
(1, 'Fiona', '','Macdonald')
,(2, 'Gian','Paulo','Faleschini');

SELECT * FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR";

SELECT SEQ_AUTHOR_UID.nextval;

//Starts From Here 
//Drop and recreate the counter so that it starts at 3 (so we can add the 
//other author records)
CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_AUTHOR_UID" 
START 3 
INCREMENT 1 
COMMENT = 'Use this to fill in the AUTHOR_UID everytime you add a row';

//Add the remaining author records and use the nextval function instead 
//of putting in the numbers
INSERT INTO AUTHOR(AUTHOR_UID,FIRST_NAME,MIDDLE_NAME, LAST_NAME) 
Values
(SEQ_AUTHOR_UID.nextval, 'Laura', 'K','Egendorf')
,(SEQ_AUTHOR_UID.nextval, 'Jan', '','Grover')
,(SEQ_AUTHOR_UID.nextval, 'Jennifer', '','Clapp')
,(SEQ_AUTHOR_UID.nextval, 'Kathleen', '','Petelinsek');

//Starts From Here 
// Create a new sequence, this one will be a counter for the book table
CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_BOOK_UID" 
START 1 
INCREMENT 1 
COMMENT = 'Use this to fill in the BOOK_UID everytime you add a row';

// Create the book table and use the NEXTVAL as the 
// default value each time a row is added to the table
CREATE OR REPLACE TABLE BOOK ( 
  BOOK_UID NUMBER DEFAULT SEQ_BOOK_UID.nextval
 ,TITLE VARCHAR(50)
 ,YEAR_PUBLISHED NUMBER(4,0));

// Insert records into the book table
// You don''t have to list anything for the
// BOOK_UID field because the default setting
// will take care of it for you
INSERT INTO BOOK(TITLE,YEAR_PUBLISHED)
VALUES
 ('Food',2001)
,('Food',2006)
,('Food',2008)
,('Food',2016)
,('Food',2015);

SELECT * FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."BOOK";

//Starts From Here 
//USE DATABASE LIBRARY_CARD_CATALOG;

// Create the relationships table
// this is sometimes called a "Many-to-Many table"
CREATE TABLE BOOK_TO_AUTHOR
(  BOOK_UID NUMBER
  ,AUTHOR_UID NUMBER
);

//Insert rows of the known relationships
INSERT INTO BOOK_TO_AUTHOR(BOOK_UID,AUTHOR_UID)
VALUES
 (1,1) // This row links the 2001 book to Fiona Macdonald
,(1,2) // This row links the 2001 book to Gian Paulo Faleschini
,(2,3) // Links 2006 book to Laura K Egendorf
,(3,4) // Links 2008 book to Jan Grover
,(4,5) // Links 2016 book to Jennifer Clapp
,(5,6);// Links 2015 book to Kathleen Petelinsek

SELECT * FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."BOOK_TO_AUTHOR";

//JSON Data Interaction

// JSON DDL Scripts
USE LIBRARY_CARD_CATALOG;

// Create an Ingestion Table for JSON Data
CREATE TABLE "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR_INGEST_JSON" (
  "RAW_AUTHOR" VARIANT);

//Create File Format for JSON Data
CREATE FILE FORMAT "LIBRARY_CARD_CATALOG"."PUBLIC".JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE 
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE 
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

//2nd Part 
//JSON DML Scripts
USE LIBRARY_CARD_CATALOG;

//returns entire record
select raw_author from author_ingest_json;

//returns AUTHOR_UID value from top-level object''s attribute
select raw_author:AUTHOR_UID as A_ID, raw_author:FIRST_NAME as F_Name from author_ingest_json;

//returns the data in a way that makes it look like a normalized table
SELECT 
 raw_author:AUTHOR_UID
,raw_author:FIRST_NAME::STRING as FIRST_NAME
,raw_author:MIDDLE_NAME::STRING as MIDDLE_NAME
,raw_author:LAST_NAME::STRING as LAST_NAME
FROM AUTHOR_INGEST_JSON;

//Semi-stru Nested Query Interaction

USE DATABASE LIBRARY_CARD_CATALOG;

// Create an Ingestion Table for the NESTED JSON Data
CREATE OR REPLACE TABLE "LIBRARY_CARD_CATALOG"."PUBLIC"."NESTED_INGEST_JSON" (
  "RAW_NESTED_BOOK" VARIANT);

//Navigate to the Database Area, locate your new table
//load the file json_book_author_nested.txt into the NESTED_INGEST_JSON table

//Come back to this worksheet and run the examples shown in the video.
SELECT RAW_NESTED_BOOK FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:year_published FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:book_title FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:authors FROM NESTED_INGEST_JSON;

//try changing the number in the bracketsd to return authors from a different row
SELECT RAW_NESTED_BOOK:authors[0].first_name FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:first_name FROM NESTED_INGEST_JSON; //Will give NULL since it is not present at Entity Level

//Use these example flatten commands to explore flattening the nested book and author data
SELECT value:first_name,RAW_NESTED_BOOK:book_title,RAW_NESTED_BOOK:year_published
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

SELECT value:first_name FROM NESTED_INGEST_JSON,table(flatten(RAW_NESTED_BOOK:authors));

//Add a CAST command to the fields returned
SELECT value:first_name::VARCHAR, value:last_name::VARCHAR 
FROM NESTED_INGEST_JSON ,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

//Assign new column  names to the columns using "AS"
SELECT value:first_name::VARCHAR AS FIRST_NM
, value:last_name::VARCHAR AS LAST_NM
FROM NESTED_INGEST_JSON ,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

//Twitter Data Query Analysis

//Create a new database to hold the Twitter file
CREATE DATABASE SOCIAL_MEDIA_FLOODGATES COMMENT = 'There\'''s so much data from social media - flood warning';

USE DATABASE SOCIAL_MEDIA_FLOODGATES;
USE WAREHOUSE COMPUTE_WH;

//Create a table in the new database
CREATE TABLE "SOCIAL_MEDIA_FLOODGATES"."PUBLIC"."TWEET_INGEST" (
"RAW_STATUS" VARIANT) 
COMMENT = 'Bring in tweets, one row per tweet or status entity';

//Create a JSON file format in the new database
CREATE FILE FORMAT "SOCIAL_MEDIA_FLOODGATES"."PUBLIC".JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE 
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE 
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

//Navigate to the Database Area, locate your new database and table
//load the file nutrition_tweets.json into the NESTED_INGEST_JSON table

//After loading the file, come back to this worksheet and run the 
//select statements as seen in the video
SELECT RAW_STATUS FROM TWEET_INGEST;

SELECT RAW_STATUS:entities FROM TWEET_INGEST;

SELECT RAW_STATUS:entities:hashtags,RAW_STATUS:entities:urls FROM TWEET_INGEST;

//Explore looking at specific hashtags by adding bracketed numbers
//This query returns just the first hashtag in each tweet
SELECT RAW_STATUS:entities:hashtags[0].text FROM TWEET_INGEST;

//This version adds a WHERE clause to get rid of any tweet that 
//doesn''t include any hashtags
SELECT RAW_STATUS:entities:hashtags[0].text FROM TWEET_INGEST WHERE RAW_STATUS:entities:hashtags[0].text is not null;

//Perform a simple CAST on the created_at key
//Add an ORDER BY clause to sort by the tweet''s creation date
SELECT RAW_STATUS:created_at::DATE FROM TWEET_INGEST ORDER BY RAW_STATUS:created_at::DATE;

//Flatten statements that return the whole hashtag entity
SELECT value FROM TWEET_INGEST ,LATERAL FLATTEN (input => RAW_STATUS:entities:hashtags);

SELECT value FROM TWEET_INGEST ,TABLE(FLATTEN(RAW_STATUS:entities:hashtags));

//Flatten statement that restricts the value to just the TEXT of the hashtag
SELECT value:text, value:indices FROM TWEET_INGEST ,LATERAL FLATTEN (input => RAW_STATUS:entities:hashtags);

//Flatten and return just the hashtag text, CAST the text as VARCHAR
SELECT value:text::VARCHAR, value:indices[0] FROM TWEET_INGEST ,LATERAL FLATTEN (input => RAW_STATUS:entities:hashtags);

//Flatten and return just the hashtag text, CAST the text as VARCHAR
// Use the AS command to name the column
SELECT value:text::VARCHAR AS THE_HASHTAG
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

//Add the Tweet ID and User ID to the returned table
SELECT RAW_STATUS:user:id AS USER_ID
,RAW_STATUS:id AS TWEET_ID
,value:text::VARCHAR AS HASHTAG_TEXT
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

SELECT * FROM "SOCIAL_MEDIA_FLOODGATES"."PUBLIC"."HASHTAGS_NORMALIZED";

//alter view "SOCIAL_MEDIA_FLOODGATES"."PUBLIC"."HASHRAGS_NORMALIZED" rename to "SOCIAL_MEDIA_FLOODGATES"."PUBLIC"."HASHTAGS_NORMALIZED";

//Script -1

//check for all 3 databases
//The SNOWFLAKE database will only be visible if your worksheet role context is set to ACCOUNTADMIN 
// or if you have modified privileges to that database

Select  'databases' as category,count(*) as found, '3' as expected
from  SNOWFLAKE.INFORMATION_SCHEMA.DATABASES
where DATABASE_NAME  IN ('USDA_NUTRIENT_STDREF','LIBRARY_CARD_CATALOG','SOCIAL_MEDIA_FLOODGATES') //Fine
UNION
//Check for necessary tables in USDA database
Select  'usda tables' as category,count(*) as found,'5' as expected
FROM USDA_NUTRIENT_STDREF.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('FD_GROUP_INGEST', 'FD_GROUP', 'WEIGHT_INGEST','WEIGHT','LANGDESC') //Fine
AND TABLE_SCHEMA = 'PUBLIC'
UNION
//Check for necessary tables in LIBRARY CARD CATALOG database
Select  'library card catalog tables' as category,count(*) as found, '6' as expected
FROM LIBRARY_CARD_CATALOG.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('BOOK','AUTHOR','BOOK_TO_AUTHOR','AUTHOR_INGEST_XML','AUTHOR_INGEST_JSON','NESTED_INGEST_JSON') //Fine
AND TABLE_SCHEMA = 'PUBLIC'
UNION
Select  'social media floodgates tables' as category,count(*) as found, '1' as expected
FROM SOCIAL_MEDIA_FLOODGATES.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('TWEET_INGEST')AND TABLE_SCHEMA = 'PUBLIC' //Fine
UNION
Select 'stages'  as category, COUNT(*) as found, '1' as expected
From "USDA_NUTRIENT_STDREF"."INFORMATION_SCHEMA"."STAGES"
WHERE STAGE_NAME = 'MY_S3_BUCKET'AND STAGE_SCHEMA = 'PUBLIC' //Fine
UNION
Select 'usda file formats'  as category, COUNT(*) as found, '1' as expected
From"USDA_NUTRIENT_STDREF"."INFORMATION_SCHEMA"."FILE_FORMATS"
WHERE FILE_FORMAT_NAME in ('USDA_FILE_FORMAT')AND FILE_FORMAT_SCHEMA = 'PUBLIC' //Fine
Union
Select 'library file formats'  ascategory, COUNT(*) as found, '2' as expected
From"LIBRARY_CARD_CATALOG"."INFORMATION_SCHEMA"."FILE_FORMATS"
WHERE FILE_FORMAT_NAME in ('JSON_FILE_FORMAT','XML_FILE_FORMAT')AND FILE_FORMAT_SCHEMA = 'PUBLIC' //Fine
Union
Select 'stages'  as category, COUNT(*) as found, '1' as expected
From"USDA_NUTRIENT_STDREF"."INFORMATION_SCHEMA"."STAGES"
WHERE STAGE_NAME ='MY_S3_BUCKET'AND STAGE_SCHEMA = 'PUBLIC' //Fine
UNION
Select 'sequences'  as category, COUNT(*) as found, '2' as expected
From"LIBRARY_CARD_CATALOG"."INFORMATION_SCHEMA"."SEQUENCES"
WHERE SEQUENCE_NAME IN ('SEQ_AUTHOR_UID','SEQ_BOOK_UID')AND SEQUENCE_SCHEMA = 'PUBLIC' //Fine
UNION
Select 'views'  as category, COUNT(*) as found, '1' as expected
From "SOCIAL_MEDIA_FLOODGATES"."INFORMATION_SCHEMA"."VIEWS"
WHERE TABLE_NAME IN ('HASHTAGS_NORMALIZED')AND TABLE_SCHEMA = 'PUBLIC';  //Fine

//Script -2

//CHECKING DATA
SELECT 'Data-FD_GROUP_INGEST' as data_confirmed, COUNT(*) AS ROWS_FOUND, '25' AS ROWS_EXPECTED
FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."FD_GROUP_INGEST"
WHERE FDGRP_DESC like '%~%' //Fine
UNION
SELECT 'Data-WEIGHT' as data_confirmed, COUNT(*) AS FOUND, '14449' AS EXPECTED
FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."WEIGHT"
WHERE NDB_NO not like '%~%' //Fine
UNION
SELECT 'Data-WEIGHT_INGEST' as data_confirmed, COUNT(*) AS FOUND, '14449' AS EXPECTED
FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."WEIGHT_INGEST"
WHERE NDB_NO like '%~%' //Fine
UNION
SELECT 'Data-LANGDESC' as data_confirmed, COUNT(*) AS FOUND, '773' AS EXPECTED
FROM "USDA_NUTRIENT_STDREF"."PUBLIC"."LANGDESC"
WHERE FACTOR_CODE NOT like '%~%' //Fine
UNION
SELECT 'Data-BOOK' as data_confirmed, COUNT(*) AS FOUND, '5' AS EXPECTED
FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."BOOK" //Fine
UNION
SELECT 'Data-AUTHOR' as data_confirmed, COUNT(*) AS FOUND, '6' AS EXPECTED
FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR" //Fine
UNION
SELECT 'Data-BOOK_TO_AUTHOR' as data_confirmed, COUNT(*) AS FOUND, '6' AS EXPECTED
FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."BOOK_TO_AUTHOR" //Fine
UNION
SELECT 'Data-AUTHOR_INGEST_XML' as data_confirmed, COUNT(*) AS FOUND, '12' AS EXPECTED
FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR_INGEST_XML" //Fine
UNION
SELECT 'Data-AUTHOR_INGEST_JSON' as data_confirmed, COUNT(*) AS FOUND, '6' AS EXPECTED
FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR_INGEST_JSON" //Fine
UNION
SELECT 'Data-NESTED_INGEST_JSON' as data_confirmed, COUNT(*) AS FOUND, '5' AS EXPECTED
FROM "LIBRARY_CARD_CATALOG"."PUBLIC"."NESTED_INGEST_JSON" //Fine
UNION
SELECT 'Data-TWEET_INGEST' as data_confirmed, COUNT(*) AS FOUND, '9' AS EXPECTED
FROM "SOCIAL_MEDIA_FLOODGATES"."PUBLIC"."TWEET_INGEST" //Fine
UNION
SELECT 'Data-HASHTAGS_NORMALIZED' as data_confirmed, COUNT(*) AS FOUND, '14' AS EXPECTED
FROM "SOCIAL_MEDIA_FLOODGATES"."PUBLIC"."HASHTAGS_NORMALIZED"; //Fine

//Script -3

// You may want tocheck the “All Queries”box next tothe RUN button for this one

use database usda_nutrient_stdref;
use schema public;
LIST @MY_S3_BUCKET;
