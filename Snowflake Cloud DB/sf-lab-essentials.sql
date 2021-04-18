select current_account();
select current_region();

USE ROLE ACCOUNTADMIN;
Use Role SYSADMIN;

SHOW SHARES;

--DROP DATABASE "SNOWFLAKE_SAMPLE_DATA";

ALTER DATABASE THAT_COOL_SAMPLE_STUFF RENAME TO THAT_REALLY_COOL_SAMPLE_STUFF;

ALTER DATABASE THAT_REALLY_COOL_SAMPLE_STUFF SET COMMENT = 'Holds TPC sample data for speed testing';


------------------------Assignment------------------------
//LAB 2 - EXERCISE 1 -----------------------------------;
--Attempt to make changes to the SNOWFLAKE database. 
--the SNOWFLAKE database is often referred to as "The Account Usage Share"

Use Role ACCOUNTADMIN;
DROP DATABASE SNOWFLAKE;
Alter DATABASE SNOWFLAKE RENAME TO MY_ACCOUNT_USAGE;

//LAB 2 - EXERCISE 2 -----------------------------------;

USE ROLE ACCOUNTADMIN;

ALTER DATABASE THAT_REALLY_COOL_SAMPLE_STUFF RENAME TO SNOWFLAKE_SAMPLE_DATA;

GRANT IMPORTED PRIVILEGES
ON DATABASE SNOWFLAKE
TO ROLE SYSADMIN;

USE ROLE SYSADMIN;

//LAB 2 - EXERCISE 3 ----------------------------------;

--Check the range of values in the Market Segment Column
SELECT DISTINCT c_mktsegment
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER";

--Find out which Market Segments have the most customers
SELECT c_mktsegment, COUNT(*)
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER"
GROUP BY c_mktsegment
ORDER BY COUNT(*);

--Look at the Nations table
SELECT *
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION";

//LAB 2 - EXERCISE 4 ----------------------------------;

--Join the Customer and Nations table together
SELECT c_mktsegment, n_name
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER" c
JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n
ON c.c_nationkey= n.n_nationkey
ORDER BY c_mktsegment;

--Join Customer and Nation
--Roll up (Aggregate) by Market Segment and Nation;
SELECT c_mktsegment, n_name, count(*)
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER" c
JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n
ON c.c_nationkey= n.n_nationkey
GROUP BY c_mktsegment, n.n_name
ORDER BY c_mktsegment;


//LAB 2 - EXERCISE 5 ----------------------------------

--Run this script to set up a database that holds
--International information like currencies, ISO codes, etc.
USE ROLE SYSADMIN;

CREATE OR REPLACE DATABASE INTL_DB;

USE SCHEMA INTL_DB.PUBLIC;

CREATE WAREHOUSE INTL_WH
WITH WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 600
AUTO_RESUME = TRUE;

USE WAREHOUSE INTL_WH;

--Set your Default Warehouse to the Warehouse you just created
ALTER USER DEBIMIS --*** replace 'FDNEIGE' with your User Name
SET DEFAULT_WAREHOUSE=INTL_WH;

//LAB 2 - EXERCISE 6 ----------------------------------;

CREATE TABLE "INTL_DB"."PUBLIC"."INT_STDS_ORG_3661"
("ISO_COUNTRY_NAME" varchar(100) NOT NULL,
"COUNTRY_NAME_OFFICIAL" varchar(200) NOT NULL,
"SOVEREIGNITY" varchar(40) NOT NULL,
"ALPHA_CODE_2DIGIT" varchar(2) NOT NULL,
"ALPHA_CODE_3DIGIT" varchar(3) NOT NULL,
"NUMERIC_COUNTRY_CODE" integer not null,
"ISO_SUBDIVISION" varchar(15) NOT NULL,
"INTERNET_DOMAIN_CODE" varchar(10) NOT NULL
)
COMMENT = 'ISO 3661 information on countries';


CREATE TABLE "INTL_DB"."PUBLIC"."CURRENCIES"
(
"CURRENCY_ID" INTEGER NOT NULL,
"CURRENCY_CHAR_CODE" varchar(3) NOT NULL,
"CURRENCY_SYMBOL" varchar(4) NOT NULL,
"CURRENCY_DIGITAL_CODE" varchar(3) NOT NULL,
"CURRENCY_DIGITAL_NAME" varchar(30) NOT NULL
)
COMMENT = 'Information about currencies including character codes, symbols, digital codes, etc.';


CREATE TABLE "INTL_DB"."PUBLIC"."COUNTRY_CODE_TO_CURRENCY_CODE"
(
"COUNTRY_CHAR_CODE" Varchar(3) NOT NULL,
"COUNTRY_NUMERIC_CODE" INTEGER NOT NULL,
"COUNTRY_NAME" Varchar(100) NOT NULL,
"CURRENCY_NAME" Varchar(100) NOT NULL,
"CURRENCY_CHAR_CODE" Varchar(3) NOT NULL,
"CURRENCY_NUMERIC_CODE" INTEGER NOT NULL
)
COMMENT = 'Many to many code lookup table';

//LAB 2 - EXERCISE 7 ----------------------------------;

//********************FILE FORMATS******************************
CREATE OR REPLACE FILE FORMAT "INTL_DB"."PUBLIC".PIPE_DBLQUOTE_HEADER_CR
TYPE = 'CSV'
COMPRESSION = 'AUTO'
FIELD_DELIMITER = '|'
RECORD_DELIMITER = '\r'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE'
TRIM_SPACE = FALSE
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
ESCAPE = 'NONE'
ESCAPE_UNENCLOSED_FIELD = '\042'
DATE_FORMAT = 'AUTO'
TIMESTAMP_FORMAT = 'AUTO'
NULL_IF = ('\\N');
           
CREATE Or Replace FILE FORMAT "INTL_DB"."PUBLIC".CSV_COMMA_LF_HEADER
TYPE = 'CSV'
COMPRESSION = 'AUTO'
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE'
TRIM_SPACE = FALSE
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
ESCAPE = 'NONE'
ESCAPE_UNENCLOSED_FIELD = '\134'
DATE_FORMAT = 'AUTO'
TIMESTAMP_FORMAT = 'AUTO'
NULL_IF = ('\\N');

//LAB 2 - EXERCISE 8 ----------------------------------;
-- Load the three tables using the csv files provided. 


//LAB 2 - EXERCISE 9 ----------------------------------;
--Confirm the files are loaded

//LAB 2 - EXERCISE 10 ----------------------------------;
SELECT n_nationkey, n_name, n_regionkey, iso_country_name, country_name_official,alpha_code_2digit
FROM "INTL_DB"."PUBLIC"."INT_STDS_ORG_3661" i
JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n
ON UPPER(i.iso_country_name)=n.n_name;

//LAB 2 - EXERCISE 11, 12 ----------------------------------;
--Use the WebUI to open a Create View window.;
--Paste the code from Exercise 10 into the View Definition.;


//LAB 2 - EXERCISE 13 ----------------------------------;
CREATE VIEW SIMPLE_CURRENCY
AS
SELECT COUNTRY_CHAR_CODE as CTY_CODE
,CURRENCY_CHAR_CODE as CUR_CODE
FROM "INTL_DB"."PUBLIC"."COUNTRY_CODE_TO_CURRENCY_CODE";

//LAB 2 - EXERCISE 14 ----------------------------------;
--Refresh the Navigation tree and preview the data in your views. 

--Lab For Outbound Shares --
ALTER VIEW "INTL_DB"."PUBLIC"."NATIONS_SAMPLE_PLUS_ISO" SET SECURE;

ALTER VIEW "INTL_DB"."PUBLIC"."SIMPLE_CURRENCY" SET SECURE;

--Trial Account AE70090 DebiMis/ Sonusonu@21s
--Reader Accoun ix04790 DemoUser/ Sonusonu@21s
--User  Account         LOTTIE/ Sonusonu@21ss 

--Lab 7 EXERCISE
//LAB 7 - EXERCISE 1--------------------------------------------------------

--Set Worksheet Context
USE DATABASE INTL_DB;
USE WAREHOUSE INTL_WH;
USE SCHEMA PUBLIC;

--Create a table to hold the security mapping
CREATE OR REPLACE TABLE CUSTOMER_COUNTRY_SECURITY_MAPPING
(
 CTY_CODE VARCHAR(3)
,CUSTOMER_ACCOUNT VARCHAR(10)
);

--Load the security mapping table with some rows for your Trial
--and some rows for your Reader Account
INSERT INTO CUSTOMER_COUNTRY_SECURITY_MAPPING
Values 
('CAN','IX04790'), --change FU12106 to YOUR Reader Account
('USA','IX04790'),
('DZA','AE70090'), --change AS78317 to YOUR Trial Account
('BEL','AE70090');

--Only use the truncate statement if you need to remove
--the rows and reload them
--TRUNCATE TABLE CUSTOMER_COUNTRY_SECURITY_MAPPING;

--Check your table to see if you loaded the rows correctly
SELECT *
FROM CUSTOMER_COUNTRY_SECURITY_MAPPING;

//***** End Exercise 1 ************************************************************

//LAB 7 - EXERCISE 2 --------------------------------------------------------------

--Remind yourself what the Simple Currency view data looks like
SELECT cty_code, cur_code
FROM "INTL_DB"."PUBLIC"."SIMPLE_CURRENCY";

--The view with a WHERE clause that restricts data to 
--only the rows Lottie and ACME want to see from OSIRIS
SELECT cty_code, cur_code
FROM "INTL_DB"."PUBLIC"."SIMPLE_CURRENCY"
WHERE cty_code in ('CAN','USA');

-- Join the Simple Currency View with your new mapping table
-- the join restricts the data to just those that appear in 
-- the mapping table
SELECT sc.cty_code, cur_code, customer_account 
FROM "INTL_DB"."PUBLIC"."SIMPLE_CURRENCY" sc
JOIN "INTL_DB"."PUBLIC"."CUSTOMER_COUNTRY_SECURITY_MAPPING" sm
ON sc.cty_code = sm.cty_code;

--A statement that uses both a join and a where clause
--be sure to change FU12106 so that it uses YOUR reader account
SELECT sc.cty_code, cur_code, customer_account 
FROM "INTL_DB"."PUBLIC"."SIMPLE_CURRENCY" sc
JOIN "INTL_DB"."PUBLIC"."CUSTOMER_COUNTRY_SECURITY_MAPPING" sm
ON sc.cty_code = sm.cty_code
WHERE customer_account='IX04790';

//***** End Exercise 2 ************************************************************

//LAB 7 - EXERCISE 3 --------------------------------------------------------------
-- Create a new schema for the new standard listing
CREATE SCHEMA INTL_DB.STD;

-- Use an ALTER statement to move the ISO table from the
-- Public schema to our new STD schema
ALTER TABLE "INTL_DB"."PUBLIC"."INT_STDS_ORG_3661"
RENAME TO "INTL_DB"."STD"."INT_STDS_ORG_3661";

--Create another new schema for the new personalized listing
CREATE SCHEMA INTL_DB.PRZLD;

USE SCHEMA INTL_DB.PRZLD;

-- Create the secure view that you'll use 
-- when you create an outbound share 
-- for WDE's Personalized Listing
CREATE SECURE VIEW PRZLD.CUSTOMER_CURRENCY
AS
SELECT sc.cty_code, cur_code, customer_account 
FROM "INTL_DB"."PUBLIC"."SIMPLE_CURRENCY" sc
JOIN "INTL_DB"."PUBLIC"."CUSTOMER_COUNTRY_SECURITY_MAPPING" sm
ON sc.cty_code = sm.cty_code
WHERE customer_account=CURRENT_ACCOUNT();

//***** End Exercise 3 ************************************************************
