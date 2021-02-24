Role hierrchy Access contol designed to inherit permission

-- Custom roles
--Analyst :dev_wh usage, read only on Demo_DB.STAGING
--DEVELOPER : [Analysts] + Read only Sales_DB.CSV_UPOAD
--CI: {Analyst] + [DEVELOPER] + INS?UPD on DEMO_DB

--Low to high (Analysts -> Deve -> CI -> AccountAdmin)

---Analyst Role ---

use role accountadmin;
--creae role 
create role analyst;
--verify no grants
show grants to role analyst;

--Grant role to mu user
grant role analyst to user MJKAHAN;
use role analyst;

--Grant warehouse uase on DEV_WH
use role accountadminl
grant useage on warehouse dev_wh to role analyst;

--add read access to demo_db
use roele accountadmin;
grant uasge on schema debmo_db.stagging to role analyst;
grant select on all tables in schema demo_db.stagging to role analyst;

--confirm the access controls
select * from demo_db.satagging.example_test_users;

--Copare roles 
use role analyst;
use role accountadmin;
show grants to role analyst;

--Developer Role : 5:33
https://www.youtube.com/watch?v=b-YRXJgjDC8&t=437s

--Create Role
use role accountadmin;
create role developer;

--verufy no grants
show grants to role developer;

--Grant role to my user
grant rol deveoper to user mkhana;
use role developer;

--Inherit Analyst permission
use role accountadmin;
grant role analyst to role developer;

--Give permission to Fuvetrans_database
grant uasge on database Fuvetrans_database to role developer;
grant uasge on schema Fuvetrans_database.stagging to role developer;
grant select on Fuvetrans_database.stagging.Product to role developer; 

--Compare roles
use role developers;
use role analyst;
use role accountadmin;

show grants to role developer;
show grants to role analyst;


--CI Role 

use role accountadmin;
create role CI;

--verufy no grants
show grants to role CI

--grant role to my user
grant role ci to user mjkanna;
use role ci;

--Inherit Developer (& Analyst) permission
use role accountadmin;
grant role developer to role ci;

--give permission to my_first_db
grant usuage on database my_first_db to role CI;
grant useage on schema my_first_db.demo_scheam to role ci;

--give inert/updte permission on demo_db.staging
grant inrert on all tables in schema demo_db.staging to role ci;
grant update on all tables in schema demo_db.staging to role ci;


--Compare roles
use role ci;
use role developer;
use role analyst;
use role accountadmin;


show grants to role ci;
show grants to role developer;
show grants to role analyst;
