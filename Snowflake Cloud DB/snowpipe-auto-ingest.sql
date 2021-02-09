Configuring a Snowflake Storage Integration to Access Amazon S3 - 
https://docs.snowflake.com/en/user-guide/data-load-s3-config.html
https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration.html

--Use Role SYSADMIN;
--Use Warehouse COMPUTE_WH;
--Use Demo_DB;
--Use Schema Public;
Create Table EMP_RAW (
  EmpNO INT,
  EmpName Varchar(20),
  Salary Number,
  DeptNo INT
);

show Tables;

--/*File Format Creation*/ 
CREATE Or Replace FILE FORMAT EMP_FILE_FORMAT 
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

show FILE FORMATS;

--Only account administrators (users with the ACCOUNTADMIN role)

CREATE STORAGE INTEGRATION sf_s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::XXXX:role/XXXX'
  STORAGE_AWS_OBJECT_ACL = 'bucket-owner-full-control'
  STORAGE_ALLOWED_LOCATIONS = ('s3://XXXX/XXXX/')
;

desc integration sf_s3_int;

--Record the following values From DESC
--STORAGE_AWS_IAM_USER_ARN - arn:aws:iam::XXXX:user/XXXX
--STORAGE_AWS_EXTERNAL_ID  - XXXX

--/*STAGE Creation*/
create or replace stage emp_stage
  storage_integration = sf_s3_int
  url = 's3://XXXX/XXXX/'
  file_format = EMP_FILE_FORMAT;

--show STAGES;

--to see the contents 
--list @emp_stage;

--/*Load Data From STAGE*/
copy into EMP_RAW
from @emp_stage
--pattern='.*EMP.*.csv'
file_format = EMP_FILE_FORMAT
--validation_mode = 'RETURN_ERRORS'
;

--Truncate Table "DEMO_DB"."PUBLIC"."EMP_RAW";
SELECT * FROM "DEMO_DB"."PUBLIC"."EMP_RAW";

--/*Error Handling*/
select * from information_schema.load_history
where schema_name=current_schema() and table_name='EMP_RAW'
--AND last_load_time > 'Fri, 01 Apr 2016 16:00:00 -0800'
;

--/*Loading Continuously Using Snowpipe*/
create or replace pipe emp_snowpipe auto_ingest=true as
copy into emp_raw
from @emp_stage
FILE_FORMAT = (FORMAT_NAME = EMP_FILE_FORMAT);

show PIPES;
--arn:aws:sqs:us-west-1:XXXX:sf-snowpipe-XXXX-XXXX

select system$pipe_status('demo_db.public.emp_snowpipe');

--drop pipe emp_snowpipe;
