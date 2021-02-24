--Snowflake Data Sharing: https://www.youtube.com/watch?v=GcrEK-VFEB8&t=615s
--Snowflake Secure Views: https://www.youtube.com/watch?v=CRZQjxP10G0


--Producer Side create the share
create share s1;

--Grant usage on share
grant usage on database slaes to share s1; 
grant select on table table_name to share s1;
grant usage on schema sales.east to share s1;
grant usage on views sales.east.accts to share s1;

alter share s1 add accouts = a1, a2, a3; 


--On Consumer - Login To Consumer Account
show shares;
create or replace database p1_sales from share account.share_name;
select * from table_name;


--To Share Specific Rows To Specific Accounts - Sharing Custom Views With Each Consumers
Accounts 
ID 	Account_Name
100	A1
200	A2
300	A3

Master_Data
ID	Sales 	Comm
100	2350	0.10
200	4567	0.23
300	8976	0.24

CREATE OR REPLACE SECURE VIEW SHARED_DATA AS 
SELECT * FROM MASTER_DATA MD
JOIN ACCOUNTS AC ON MD.ID =AC.ID
AND AC.ACCT_NAME = CURRENT_ACCOUNT();


--LIST PATIENTS
SELECT * FROM PATIENTS;

CREATE OR REPLACE SECURE VIEW ORG_PATIENTS AS
SELECT * FROM PATIENTS ;

SELECT * FROM ORG_PATIENTS ;

SHOW VIEWS;

SELECT FULLNAME,CITY,USER_ACCESS.ORG_ID,USER_ACCESS.ACCOUNT_ID 
FROM PATIENTS 
INNER JOIN USER_ACCESS ON PATIENTS.ORG_ID=USER_ACCESS.ORG_ID;

Insert Into USER_ACCESS Values ('Baylor Hospital','');
Insert Into USER_ACCESS Values ('Mayo Clinic','');

Create Table USER_ACCESS (
    ORG_ID VARCHAR(50),
    ACCOUNT_ID varchar(50)
);

insert into USER_ACCESS values ('Baylor Hospital','MN30689');
insert into USER_ACCESS values ('Mayo Clinic','PO51568');

SELECT * FROM USER_ACCESS; 

--TRUNCATE  TABLE USER_ACCESS SET ACCOUNT_ID='PO51568' WHERE ORG_ID='Mayo Clinic';

Select CURRENT_ACCOUNT();
Select CURRENT_ROLE ();

--CREATE A SECURE VIEW
CREATE OR REPLACE SECURE VIEW ORG_PATIENTS AS
SELECT FULLNAME,CITY,USER_ACCESS.ORG_ID FROM patients 
INNER JOIN USER_ACCESS ON PATIENTS.ORG_ID=USER_ACCESS.ORG_ID
WHERE ACCOUNT_ID=CURRENT_ACCOUNT();

Select * From ORG_PATIENTS;

SHOW VIEWS;
Describe View ORG_PATIENTS;

Describe View mycustomerview;
Describe View ORG_PATIENTS;

select get_ddl('view', 'ORG_PATIENTS') view_defn;
