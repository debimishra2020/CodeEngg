--DATA_RETENTION_TIME_IN_DAYS

Show Parameters;
Show Parameters In Database FINANCE;
Show Parameters In Warehouse COMPUTE_WH;
Show Parameters In ACCOUNT;
Show Parameters Like '%DATA%';
Show Parameters Like '%DATA%' In ACCOUNT;


Use Role ACCOUNTADMIN;
Alter DATABASE FINANCE Set DATA_RETENTION_TIME_IN_DAYS =1;

Alter ACCOUNT Set DATA_RETENTION_TIME_IN_DAYS =1;

Select * From "FINANCE"."STAGE"."CUSTOMER"; --100

Insert Into "FINANCE"."STAGE"."CUSTOMER" values(999,'Test Name','sample@sam.liv','Zurik','16700219 9999','372619208678909','10/03/1989');
Select * From "FINANCE"."STAGE"."CUSTOMER" Where CUSTOMERID = 999;

Select Count(*) From "FINANCE"."STAGE"."CUSTOMER" AT(Offset => -60*5); --100

--Drop Table FINANCE.STAGE.CUSTOMER;
--Restoring Objects
Undrop Table FINANCE.STAGE.CUSTOMER;
Undrop Schema STAGE;
Undrop Database FINANCE;

--Over a Day can be Used
Select * From FINANCE.STAGE.CUSTOMER AT(OFFSET => -60*5);
Select * From FINANCE.STAGE.CUSTOMER AT(timestamp => '2021-02-15 11:50:00'::timestamp);

Select Count(*) From FINANCE.STAGE.CUSTOMER Before(Statement => '019a5314-0497-4f84-0024-d4830002f1be'); --100 Records

Create Table Restored_Table Clone FINANCE.STAGE.CUSTOMER Before(Statement => '019a5314-0497-4f84-0024-d4830002f1be'); 
Select Count(*) From FINANCE.STAGE.Restored_Table; --100 Records

Create Table Restored_Table Clone FINANCE.STAGE.CUSTOMER At(offset == -60*1); 
Create Schema Restored_Schema Clone STAGE At(offset == -60*1); 
Create Database Restored_DB Clone FINANCE Before(Statement =='f098iu-xx-xx-xx'); 
