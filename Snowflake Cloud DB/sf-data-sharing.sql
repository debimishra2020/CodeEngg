create database SMEW_PROJECT;
create schema OUTGOING;

create or replace table auto_master_info (
     make	VARCHAR(20)
    ,model	VARCHAR(100)
    ,year	NUMBER(4)
    ,engine_fule_typ	VARCHAR(150)
    ,engine_hp	NUMBER(4)
    ,engine_cylinders	NUMBER(2)
    ,transmission_type	VARCHAR(150)
    ,no_of_doors number(2)
    ,style VARCHAR(20)
    ,highway_MPG number(2)
    ,city_mpg number(2)
);


CREATE or replace FILE FORMAT CSV_FILE_FORMAT 
TYPE = 'csv' 
COMPRESSION = 'AUTO' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1 
FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
TRIM_SPACE = FALSE 
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
ESCAPE = 'NONE' 
;

select make as auto_title, model, year, engine_hp , rating, comments, reviews, hits, likes, votes, city, areacode, zipcode, state, country
from auto_master_info auto
inner join (select make, rating, comments, description , scale, trending_factor from web_srvc_trend) trends on trends.make = auto.make
inner join (select make, reviews, comments scale, factor, hits, likes, votes from web_src_review) reviews on reviews.make = auto.make
inner join (select make, city, areacode, zipcode, state, country) location on location.make = auto.make 
;

select distinct make as auto_title from auto_master_info;

select distinct make as auto_title, model, year, engine_hp
from auto_master_info 
where year >= 2015 and transmission_type = 'AUTOMATIC'
and highway_mpg >= 25 and city_mpg >= 15;