select current_role(); //accountadmin
create database sample_database; //creating database
create schema analytics_prv_sch; //creating schema
create or replace table analytics_prv_sch.stg_emp_file_load (
EMP_ID  varchar(10),
EMP_NAME    varchar(50),
NTID	varchar(10),
EMAIL	varchar(50),
TITLE	varchar(70),
DIVISION	varchar(10),
DIVI_NAME	varchar(70),
DEPT_CODE	varchar(10),
DEPT_DESC   varchar(70)
);
select * from analytics_prv_sch.stg_emp_file_load;
insert into analytics_prv_sch.stg_emp_file_load 
values('1290','William Damian','wildami','William.Damian@xxx.xx','Private Banking Officer I',
       '114','Private Banking','45801N',
      'Prvt Bnkg/SF City');

create or replace table analytics_prv_sch.user_role_mapping (
DIVISION	varchar(10),
ROLE_NAME	varchar(70)
);

insert into analytics_prv_sch.user_role_mapping values('114','G_SNW_PRV_BANKING_ANALYST');
insert into analytics_prv_sch.user_role_mapping values('117','G_SNW_PRSNL_BANKING_ANALYST');

select * from analytics_prv_sch.user_role_mapping;

create role G_SNW_PRV_BANKING_ANALYST;
create role G_SNW_PRSNL_BANKING_ANALYST;

use role accountadmin;
grant usage on database sample_database to role G_SNW_PRV_BANKING_ANALYST;
grant usage on schema sample_database.analytics_prv_sch to role G_SNW_PRV_BANKING_ANALYST;

grant usage on database sample_database to role G_SNW_PRSNL_BANKING_ANALYST;
grant usage on schema sample_database.analytics_prv_sch to role G_SNW_PRSNL_BANKING_ANALYST;

grant select on table stg_emp_file_load to role G_SNW_PRV_BANKING_ANALYST; 
grant select on table stg_emp_file_load to role G_SNW_PRSNL_BANKING_ANALYST;

//granting warehouse to the custom roles
grant usage on warehouse compute_wh to role G_SNW_PRV_BANKING_ANALYST;
grant usage on warehouse compute_wh to role G_SNW_PRSNL_BANKING_ANALYST;

//assign role to currently executing user for testing.
select current_user(); //DebiMis
grant role G_SNW_PRV_BANKING_ANALYST to user DebiMis; 
grant role G_SNW_PRSNL_BANKING_ANALYST to user DebiMis;


create or replace row access policy divsion_user_map_plcy as (division_code varchar) 
returns boolean ->
 exists (
 select 1 from analytics_prv_sch.user_role_mapping
 where role_name = current_role()
 and division = division_code
);

alter table analytics_prv_sch.stg_emp_file_load add row access policy 
    divsion_user_map_plcy on (division);

use role accountadmin;
select * from analytics_prv_sch.stg_emp_file_load; //All records

use role G_SNW_PRV_BANKING_ANALYST;
use warehouse compute_wh;
select emp_id, emp_name, division, divi_name, dept_code, dept_desc 
        from analytics_prv_sch.stg_emp_file_load; //3 records

use role G_SNW_PRSNL_BANKING_ANALYST;
use warehouse compute_wh;
select emp_id, emp_name, division, divi_name, dept_code, dept_desc 
        from analytics_prv_sch.stg_emp_file_load; //2 records

insert into analytics_prv_sch.user_role_mapping values('114','ACCOUNTADMIN');
insert into analytics_prv_sch.user_role_mapping values('117','ACCOUNTADMIN');
