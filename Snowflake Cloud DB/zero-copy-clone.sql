--Must have create database permission on Account in order to Clone
show grants on Account;

--Clone Database
use role accountadmin;
create database demo_db_clone clone demo_db;

--Clone table at specific time
create table demo_db_clone.public.dbt_audit_clone clone demo_db.public.dbt_audit at(timestamp => '2021-02-15 11:50:00'::timestamp);

--Grants are not copied by default to the source object i.e database bit do copy for children like schema/ table 
show grants on databases demo_db;
show grants on databases demo_db_clone;

show grants on schema demo_db.staging;
show grants on schema demo_db_clone.staging;

show grants on table demo_db.staging.Example_my_first_dbt_model;
show grants on table demo_db_clone.staging.Example_my_first_dbt_model;

--Give data base usage permission to another role
--Notice that values are hidden(Analyst didn't have original permission)
grant useage on database DMBO_DB_CLONE to role ANALYST;

--Underlying DDls are inheritted on views
--important to have fully-qualified refernce 
select get_ddl_('view','demo_db.staging.example_my_second_dbt_model')
union all 
select get_ddl_('view','demo_db_clone.staging.example_my_second_dbt_model');
