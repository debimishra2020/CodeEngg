USE ROLE <RL_NAME>;
USE WAREHOUSE <WH_NAME>;
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

--Source Table Structure
CREATE OR REPLACE TABLE CUSTOMER (
     CUSTOMER_ID NUMBER,
     FULL_NAME VARCHAR(25),
     ADDRESS VARCHAR(152),
     UPDATE_TIMESTAMP TIMESTAMP_NTZ);
 
--Target Table Structure holds History  
CREATE OR REPLACE TABLE CUSTOMER_HISTORY (
    CUSTOMER_ID NUMBER,
    FULL_NAME VARCHAR(25),
    ADDRESS VARCHAR(152),
    START_TIME TIMESTAMP_NTZ,
    END_TIME TIMESTAMP_NTZ,
    CURRENT_FLAG INT);

SELECT * FROM CUSTOMER;
SELECT * FROM CUSTOMER_HISTORY;
    
--Stream Creation	
CREATE OR REPLACE STREAM CUSTOMER_TABLE_CHANGES ON TABLE CUSTOMER;
SHOW STREAMS;
SELECT * FROM CUSTOMER_TABLE_CHANGES;
--DROP STREAM CUSTOMER_TABLE_CHANGES;


CREATE OR REPLACE VIEW CUSTOMER_CHANGE_DATA AS
--Below SELECT Query helps in INS Operation To Source Table
--Any Insert To CUSTOMER Table Results Inserting To CUSTOMER_HISTORY
SELECT CUSTOMER_ID, FULL_NAME, ADDRESS, START_TIME, END_TIME, CURRENT_FLAG, 'I' AS DML_TYPE FROM 
(SELECT CUSTOMER_ID, FULL_NAME, ADDRESS, UPDATE_TIMESTAMP AS START_TIME,
             LAG(UPDATE_TIMESTAMP) OVER (PARTITION BY CUSTOMER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS END_TIME_RAW,
             CASE WHEN END_TIME_RAW IS NULL THEN '9999-12-31'::TIMESTAMP_NTZ ELSE END_TIME_RAW END AS END_TIME,
             CASE WHEN END_TIME_RAW IS NULL THEN 1 ELSE 0 END AS CURRENT_FLAG
      FROM (SELECT CUSTOMER_ID, FULL_NAME, ADDRESS, UPDATE_TIMESTAMP
            FROM CUSTOMER_TABLE_CHANGES
            WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = 'FALSE'))
UNION
--Below SELECT Query helps in UPD Operation To Source Table
--An Update To CUSTOMER Table Results Updating & Insertign To CUSTOMER_HISTORY
SELECT CUSTOMER_ID, FULL_NAME, ADDRESS, START_TIME, END_TIME, CURRENT_FLAG, DML_TYPE
FROM (SELECT CUSTOMER_ID, FULL_NAME, ADDRESS,
             UPDATE_TIMESTAMP AS START_TIME,
             LAG(UPDATE_TIMESTAMP) OVER (PARTITION BY CUSTOMER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS END_TIME_RAW,
             CASE WHEN END_TIME_RAW IS NULL THEN '9999-12-31'::TIMESTAMP_NTZ ELSE END_TIME_RAW END AS END_TIME,
             CASE WHEN END_TIME_RAW IS NULL THEN 1 ELSE 0 END AS CURRENT_FLAG,
             DML_TYPE
      FROM (--To Fetch Data TO Insert Into CUSTOMER_HISTORY
            SELECT CUSTOMER_ID, FULL_NAME, ADDRESS, UPDATE_TIMESTAMP, 'I' AS DML_TYPE
            FROM CUSTOMER_TABLE_CHANGES
            WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = 'TRUE'
            UNION
            --To Fetch Data In CUSTOMER_HISTORY Table Needs To Be Updated
            SELECT CUSTOMER_ID, NULL, NULL, START_TIME, 'U' AS DML_TYPE
            FROM CUSTOMER_HISTORY
            WHERE CUSTOMER_ID IN (SELECT DISTINCT CUSTOMER_ID 
                                  FROM CUSTOMER_TABLE_CHANGES
                                  WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = 'TRUE'
                                 ) AND CURRENT_FLAG = 1
            )
     )
UNION
--Below SELECT Query helps Finding When Data Deleted From CUSTOMER
--Any Deletion In CUSTOMER Results Deactivating The Same Entry in CUSTOMER_HISTORY
--By Updating END_TIME & Flag
SELECT CC.CUSTOMER_ID, NULL, NULL, CH.START_TIME, CURRENT_TIMESTAMP()::TIMESTAMP_NTZ, NULL, 'D'
FROM CUSTOMER_HISTORY CH
INNER JOIN CUSTOMER_TABLE_CHANGES CC ON CH.CUSTOMER_ID = CC.CUSTOMER_ID
WHERE CC.METADATA$ACTION = 'DELETE' AND CC.METADATA$ISUPDATE = 'FALSE'
AND   CH.CURRENT_FLAG = 1;

SELECT * FROM CUSTOMER_CHANGE_DATA;

MERGE INTO CUSTOMER_HISTORY CH --Target Table To Merge The Changes
USING CUSTOMER_CHANGE_DATA C   --This VIEW Holds The Logic For INSERT/UPDATE/DELETE
   --CUSTOMER_ID AND START_TIME To Find An UNIQUE Record In CUSTOMER_HISTORY
   ON  CH.CUSTOMER_ID = C.CUSTOMER_ID AND CH.START_TIME = C.START_TIME

WHEN MATCHED AND C.DML_TYPE = 'U' THEN UPDATE --Update Operation
    SET CH.END_TIME = C.END_TIME,
        CH.CURRENT_FLAG = 0

WHEN MATCHED AND C.DML_TYPE = 'D' THEN UPDATE --Delete Operation
    SET CH.END_TIME = C.END_TIME,
        CH.CURRENT_FLAG = 0

WHEN NOT MATCHED AND C.DML_TYPE = 'I' THEN INSERT --Insert Operation
           (CUSTOMER_ID, FULL_NAME, ADDRESS, START_TIME, END_TIME, CURRENT_FLAG)
    VALUES (C.CUSTOMER_ID, C.FULL_NAME, C.ADDRESS, C.START_TIME, C.END_TIME, C.CURRENT_FLAG);

-------------------------------------------------------------------------
set update_timestamp = current_timestamp()::timestamp_ntz;
begin;
insert into demo_db.public.customer values(880,'Steven King','2017 Shinjuku-ku, Tokyo, JP, 5670',$update_timestamp);
insert into demo_db.public.customer values(881,'Neena Kochhar','2014 Jabberwocky Rd, TX, US, 26192',$update_timestamp);
insert into demo_db.public.customer values(882,'Lex De Haan','2011 Interiors Blvd, CA, US, 99236',$update_timestamp);
insert into demo_db.public.customer values(883,'Alex Hunold','The Oxford Science Park, Oxford, UK, OX9 9ZB',$update_timestamp);
commit;

begin;
update demo_db.public.customer set 
	address = '2000 Jabberwocky Rd, TX, US, 26192', update_timestamp = current_timestamp()::timestamp_ntz 
where customer_id = 881;
commit;

delete from customer where customer_id in (1);
-------------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE IF NOT EXISTS T_WH_XSMAL 
	WITH WAREHOUSE_SIZE = 'XSMALL' 
	AUTO_SUSPEND = 180;

Create OR Replace Task Customer_History_Run 
	Warehouse = T_WH_XSMAL 
	Schedule = '1 minute' 
	When system$stream_has_data('CUSTOMER_TABLE_CHANGES')
As   
MERGE INTO CUSTOMER_HISTORY CH 
USING CUSTOMER_CHANGE_DATA C   
   ON  CH.CUSTOMER_ID = C.CUSTOMER_ID AND CH.START_TIME = C.START_TIME

WHEN MATCHED AND C.DML_TYPE = 'U' THEN UPDATE 
    SET CH.END_TIME = C.END_TIME,
        CH.CURRENT_FLAG = 0

WHEN MATCHED AND C.DML_TYPE = 'D' THEN UPDATE
    SET CH.END_TIME = C.END_TIME,
        CH.CURRENT_FLAG = 0

WHEN NOT MATCHED AND C.DML_TYPE = 'I' THEN INSERT
           (CUSTOMER_ID, FULL_NAME, ADDRESS, START_TIME, END_TIME, CURRENT_FLAG)
    VALUES (C.CUSTOMER_ID, C.FULL_NAME, C.ADDRESS, C.START_TIME, C.END_TIME, C.CURRENT_FLAG);
	

--After you have created the task, you can check its status using the following command:
SHOW TASKS;

--Below shows the task is suspended. By default, a task is suspended when it is created. Resume the task
ALTER TASK CUSTOMER_HISTORY_RUN RESUME;
SHOW TASKS;

Set update_timestamp = current_timestamp()::timestamp_ntz;
BEGIN;
Insert Into demo_db.public.customer Values(884,'Linda Paul',
	   '1498 Church Street, Brooklyn, NY, US, 11213',$update_timestamp);
COMMIT;
