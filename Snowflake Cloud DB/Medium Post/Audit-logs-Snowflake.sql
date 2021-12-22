Use Role SYSADMIN;
Use Warehouse Compute_WH;
USE Database SNOWFLAKE_SAMPLE_DATA;
USE Schema tpcds_sf100tcl;

--Update snflk_DEMO.snflk_sch.CALL_CENTER SET CC_REC_END_DATE = sysdate() Where CC_CALL_CENTER_SK = 3;
Insert Into snflk_DEMO.snflk_sch.CALL_CENTER 
       Values(4,SYSDATE(), SYSDATE(), 'Mid Atlantic','Mark Hightower','Julius Durham',4, 'spin');
Update snflk_DEMO.snflk_sch.CALL_CENTER SET CC_REC_START_DATE = to_date(sysdate())-20 Where CC_CALL_CENTER_SK = 4;

select to_date(sysdate())-20;

Show Tables;
CREATE TABLE snflk_DEMO.snflk_sch.CALL_CENTER AS 
Select CC_CALL_CENTER_SK,CC_REC_START_DATE,CC_REC_END_DATE,
CC_NAME,CC_MANAGER,CC_MARKET_MANAGER,CC_DIVISION,CC_DIVISION_NAME
From snowflake_sample_data.tpcds_sf100tcl.CALL_CENTER Where cc_name='Mid Atlantic';

Select * From snflk_DEMO.snflk_sch.CALL_CENTER;

Use Role SYSADMIN;
Use Warehouse Compute_WH;
Create Database snflk_DEMO;
Create Schema snflk_sch;

Use Database snflk_DEMO;
Use Schema snflk_sch;

Create Or Replace Table tbl_GET_SESSION (
SESSION_ID VARCHAR(50)
); 

SELECT * From tbl_GET_SESSION;

--Use Role as Account Admin to create an USER
USE ROLE ACCOUNTADMIN;
CREATE USER detl1 password = 'abc123' must_change_password = true;

--Grant the Role as SYS Admin to the User
GRANT ROLE SYSADMIN TO USER detl1;

USE ROLE SYSADMIN;
USE WAREHOUSE Compute_WH;
CREATE DATABASE snflk_DEMO;
CREATE SCHEMA snflk_sch;

USE DATABASE snflk_DEMO;
USE SCHEMA snflk_sch;

--Source Table 
CREATE OR REPLACE TABLE tbl_EMP_RAW (
EMP_ID VARCHAR(10),
EMP_NAME VARCHAR(50)
); 

Select * From tbl_EMP_RAW;
--Truncate Table tbl_EMP_RAW;

--Target Table
CREATE OR REPLACE TABLE tbl_LOAD_EMP (
EMP_ID VARCHAR(10),
EMP_NAME VARCHAR(50),
ACTIVE_IND VARCHAR(1)
); 

Select * From snflk_demo.snflk_sch.tbl_LOAD_EMP;
--Truncate Table tbl_LOAD_EMP;


--Update tbl_EMP_RAW Set EMP_NAME = 'Steven King' WHERE EMP_ID = 'EM01';

Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM01','Steven King');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM02','St Black');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM03','Turner Smith');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM04','King Jr');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM05','Blake Sr');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM06','St Paul');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM07','Agu Jose');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM08','Mat P');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM09','Scott Johnson');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM10','Michele K');
Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW Values('EM11','Stephen R');


Merge Into snflk_demo.snflk_sch.tbl_LOAD_EMP Tgt Using (
	Select Src.EMP_ID As JOIN_KEY, Src.* From snflk_demo.snflk_sch.tbl_EMP_RAW Src
	Union ALL
	Select NULL, Src.* From snflk_demo.snflk_sch.tbl_EMP_RAW Src
	Join snflk_demo.snflk_sch.tbl_LOAD_EMP Tgt ON Tgt.EMP_ID = Src.EMP_ID 
    Where ((Tgt.EMP_NAME <> Src.EMP_NAME) AND 
ACTIVE_IND = 'Y')) DataSet ON DataSet.JOIN_KEY = Tgt.EMP_ID
WHEN MATCHED AND (DataSet.EMP_NAME <> Tgt.EMP_NAME) 
AND ACTIVE_IND <> 'N' THEN UPDATE SET 
ACTIVE_IND = 'N' WHEN NOT MATCHED THEN INSERT (EMP_ID, EMP_NAME, ACTIVE_IND)
Values (DATASET.EMP_ID, DATASET.EMP_NAME, 'Y');

call snflk_demo.snflk_sch.sp_tbl_Load_EMP();

CREATE OR REPLACE PROCEDURE snflk_demo.snflk_sch.sp_tbl_Load_EMP()
    Returns string
    LANGUAGE JAVASCRIPT
    As
    $$
var result = "";
var sql_cmd  = 'Merge Into snflk_demo.snflk_sch.tbl_LOAD_EMP Tgt Using ('
    sql_cmd += ' Select Src.EMP_ID As JOIN_KEY, Src.* From snflk_demo.snflk_sch.tbl_EMP_RAW Src'
    sql_cmd += ' Union ALL'
	sql_cmd += ' Select NULL, Src.* From snflk_demo.snflk_sch.tbl_EMP_RAW Src'
	sql_cmd += ' Join snflk_demo.snflk_sch.tbl_LOAD_EMP Tgt ON Tgt.EMP_ID = Src.EMP_ID'
    sql_cmd += ' Where ((Tgt.EMP_NAME <> Src.EMP_NAME) AND'
    sql_cmd += ' ACTIVE_IND=\'Y\')) DataSet ON DataSet.JOIN_KEY = Tgt.EMP_ID'
    sql_cmd += ' WHEN MATCHED AND (DataSet.EMP_NAME <> Tgt.EMP_NAME)'
    sql_cmd += ' AND ACTIVE_IND <> \'N\' THEN UPDATE SET'
    sql_cmd += ' ACTIVE_IND = \'N\' WHEN NOT MATCHED THEN INSERT (EMP_ID, EMP_NAME, ACTIVE_IND)'
    sql_cmd += ' Values (DATASET.EMP_ID, DATASET.EMP_NAME, \'Y\');'
try {
    snowflake.execute ({sqlText: sql_cmd});
    return "Succeeded";
    }
catch (err) {
    result =  "Failed: Code: " + err.code + "\n  State: " + err.state;
    result += "\n  Message: " + err.message;
    result += "\nStack Trace:\n" + err.stackTraceTxt;
    }
return result;
    $$
;


Select CURRENT_SESSION();

select * from table(snflk_demo.information_schema.query_history_by_session()) order by start_time;
select * from table(snflk_demo.information_schema.query_history_by_session(329244729353));

select * from table(snflk_demo.information_schema.QUERY_HISTORY_BY_USER());

SELECT * FROM table(RESULT_SCAN('01a10424-0600-f4ef-0000-004ca883cc09'));
select last_query_id();

SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

select * from snflk_demo.information_schema.load_history;

select get_ddl('table','snflk_demo.snflk_sch.AUDIT_LOG');

Create Table snflk_demo.snflk_sch.AUDIT_LOG AS 
SELECT session_id, query_id, query_text, database_name, schema_name, query_type, user_name, role_name, 
EXECUTION_STATUS, ERROR_CODE, ERROR_MESSAGE, START_TIME, END_TIME, ROWS_PRODUCED 
FROM TABLE(snflk_demo.information_schema.QUERY_HISTORY()) WHERE Session_ID =329244729353;
--QUERY_ID = '01a0f3b5-0c02-5788-0000-6ce5064ffc0e'

Select SESSION_ID, QUERY_ID, QUERY_TEXT, QUERY_TYPE, USER_NAME, EXECUTION_STATUS From snflk_demo.snflk_sch.AUDIT_LOG;


Insert Into TEST_ETL(KEY_ID_ATTR_0)
Select CURRENT_SESSION();

Select session_id From snflk_demo.snflk_sch.tbl_get_session;
--Truncate Table snflk_demo.snflk_sch.tbl_get_session;


call snflk_demo.snflk_sch.SP_GET_SESSION();

CREATE OR REPLACE PROCEDURE snflk_demo.snflk_sch.SP_GET_SESSION()
  Returns string NOT Null
  LANGUAGE JAVASCRIPT
  AS     
  $$  
var result = "";
try {
    var my_sql_command = "Select CURRENT_SESSION()";
    var statement1 = snowflake.createStatement( {sqlText: my_sql_command} );
    var result_set1 = statement1.execute();
    result_set1.next();
    var sess_id = result_set1.getColumnValue(1);
    snowflake.execute({
      sqlText: `Insert Into snflk_sch.tbl_get_session(SESSION_ID) Values (?)`
      ,binds: [sess_id]
      });
    result = "Succeeded";
  }
catch (err)  {
    result =  "Failed: Code: " + err.code + "\n  State: " + err.state;
    result += "\n  Message: " + err.message;
    result += "\nStack Trace:\n" + err.stackTraceTxt; 
  }
return result;
  $$
;
  

Select
(Select TO_CHAR(Count(*)) From snflk_demo.snflk_sch.tbl_EMP_RAW) AS EMP_RAW_COUNT, 
(Select TO_CHAR(Count(*)) From snflk_demo.snflk_sch.tbl_Load_EMP)  As LOAD_EMP_COUNT, 
(Select TO_CHAR(Count(*)) From snflk_demo.snflk_sch.tbl_Get_SESSION) AS SESSION_TBL_COUNT, 
(Select TO_CHAR(Count(*)) From snflk_demo.snflk_sch.AUDIT_LOG) AS AUDIT_LOG_COUNT
;

--Truncate Table snflk_demo.snflk_sch.AUDIT_LOG;

--call snflk_demo.snflk_sch.SP_GET_SESSION();


Begin;
Call snflk_demo.snflk_sch.sp_tbl_Load_EMP(); 
Truncate Table snflk_demo.snflk_sch.tbl_get_session;
Call snflk_demo.snflk_sch.SP_GET_SESSION();
Call system$wait(20);
Commit;

Begin;
Truncate Table snflk_demo.snflk_sch.AUDIT_LOG; 
Insert Into snflk_demo.snflk_sch.AUDIT_LOG
    (SESSION_ID, QUERY_ID, QUERY_TEXT, DATABASE_NAME, SCHEMA_NAME, QUERY_TYPE, USER_NAME,  
ROLE_NAME, EXECUTION_STATUS, ERROR_CODE, ERROR_MESSAGE, START_TIME, END_TIME, ROWS_PRODUCED) 
SELECT SESSION_ID, QUERY_ID, QUERY_TEXT, DATABASE_NAME, SCHEMA_NAME, QUERY_TYPE, USER_NAME,  
ROLE_NAME, EXECUTION_STATUS, ERROR_CODE, ERROR_MESSAGE, START_TIME, END_TIME, ROWS_PRODUCED 
FROM TABLE(snflk_demo.information_schema.QUERY_HISTORY()) WHERE Session_ID = 
            (Select SESSION_ID From snflk_demo.snflk_sch.tbl_GET_SESSION);
Call system$wait(20);
Commit;


SELECT * FROM table(RESULT_SCAN('01a10c9b-0600-f4ef-004c-a883000152c6'));
select last_query_id();

SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

Begin;
Insert Into snflk_DEMO.snflk_sch.CALL_CENTER 
       Values(4,SYSDATE(), SYSDATE(), 'Mid Atlantic','Mark Hightower','Julius Durham',4, 'spin');
Call system$wait(10);
Update snflk_DEMO.snflk_sch.CALL_CENTER 
    SET CC_REC_START_DATE = to_date(sysdate())-20 Where CC_CALL_CENTER_SK = 4;
Update snflk_DEMO.snflk_sch.CALL_CENTER 
    SET CC_REC_END_DATE = to_date(sysdate()) Where CC_CALL_CENTER_SK = 3;
Truncate Table snflk_demo.snflk_sch.tbl_get_session;
Call snflk_demo.snflk_sch.SP_GET_SESSION();
Call system$wait(10);
Commit;

Begin;
Truncate Table snflk_demo.snflk_sch.AUDIT_LOG; 
Insert Into snflk_demo.snflk_sch.AUDIT_LOG
    (SESSION_ID, QUERY_ID, QUERY_TEXT, DATABASE_NAME, SCHEMA_NAME, QUERY_TYPE, USER_NAME,  
ROLE_NAME, EXECUTION_STATUS, ERROR_CODE, ERROR_MESSAGE, START_TIME, END_TIME, ROWS_PRODUCED) 
SELECT SESSION_ID, QUERY_ID, QUERY_TEXT, DATABASE_NAME, SCHEMA_NAME, QUERY_TYPE, USER_NAME,  
ROLE_NAME, EXECUTION_STATUS, ERROR_CODE, ERROR_MESSAGE, START_TIME, END_TIME, ROWS_PRODUCED 
FROM TABLE(snflk_demo.information_schema.QUERY_HISTORY()) WHERE Session_ID = 
            (Select SESSION_ID From snflk_demo.snflk_sch.tbl_GET_SESSION);
Call system$wait(20);
Commit;