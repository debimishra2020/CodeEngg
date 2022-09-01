//g_snw_metrics_dev_dba      - complete view on data elements such as test@test.com
//g_snw_metrics_dev_dvlpr    - partial view on data elements such as test@testxxx
//g_snw_metrics_dev_analyst  - partial view on data elements such as testxxx
//g_snw_metrics_dev_rptr     - partial view on data elements such as xxx

use role g_snw_metrics_dev_dba;
use warehouse metrics_dev_wh;
use database metrics_dev_db;
use schema metrics_pub_sch;
create or replace table sample01_data_mask (
first_nm varchar(10),
last_nm varchar(10),
email_id varchar(20)
);

drop table sample01_data_mask;
select * from sample01_data_mask;
//insert into sample01_data_mask values ('Debi','Mishra','Debi.Mishra@Test.Com');
//insert into sample01_data_mask values ('Deb1','Mis1','Deb1.Mis1@Test.Com');
//insert into sample01_data_mask values ('Deb2','Mis2','Deb2.Mis2@Test.Com');

select current_role();
select 'Debi.Mishra@Test.Com' as DBA_ROLE,
       regexp_replace('Debi.Mishra@Test.Com','.+\@','*****@') as Developer, 
       regexp_replace('Debi.Mishra@Test.Com','.+\.C','*****.C') as Analyst,
       '**Email Masked**' as "Report User";

Grant Create Masking Policy On Schema metrics_pub_sch To Role g_snw_metrics_dev_dba; //Should be executed by Account Admin Role
--Grant Apply Masking Policy on Account To Role g_snw_metrics_dev_dba;
Grant Apply Masking Policy On Schema To Role g_snw_metrics_dev_dba;

CREATE OR REPLACE MASKING POLICY email_masking AS (val string) //Should be executed by Account Admin Role
RETURNS string ->
    CASE
        WHEN CURRENT_ROLE() IN ('G_SNW_METRICS_DEV_DBA') THEN val
        WHEN CURRENT_ROLE() IN ('G_SNW_METRICS_DEV_DVLPR') THEN regexp_replace(val,'.+\@','*****@')
        WHEN CURRENT_ROLE() IN ('G_SNW_METRICS_DEV_ANALYST') THEN regexp_replace(val,'.+\C','*****C')
        ELSE '**Email Masked**'
    END;
    
ALTER TABLE sample01_data_mask MODIFY COLUMN email_id SET MASKING POLICY email_masking;


use role g_snw_metrics_dev_dba;
select * from sample01_data_mask;
use role g_snw_metrics_dev_dvlpr;
select * from sample01_data_mask;
use role g_snw_metrics_dev_analyst; //select current_role();
select * from sample01_data_mask;
//use role g_snw_metrics_dev_rptr;
//select * from sample01_data_mask;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

use role g_snw_metrics_dev_dba;
use warehouse metrics_dev_wh;
use database metrics_dev_db;
use schema metrics_pub_sch;

create or replace table metrics_dev_db.metrics_pub_sch.customer (
customer_id	INTEGER Primary Key,
FullNAME	VARCHAR(50),
Email VARCHAR(30),
Address	VARCHAR(100)
);


--Source Table Structure
select * from metrics_dev_db.metrics_pub_sch.customer;
--truncate table metrics_dev_db.metrics_pub_sch.customer;
--insert into demo_db.public.customer values(880,'Steven King', 'Steven.K@biz.com','2017 Shinjuku-ku, Tokyo, JP, 5670');
--insert into demo_db.public.customer values(881,'Neena Kochhar', 'Neena.K@biz.com','2014 Jabberwocky Rd, Texas, US, 26192');
--insert into demo_db.public.customer values(882,'Lex De Haan', 'LexDe.H@biz.com','2011 Interiors Blvd, California, US, 99236');
--insert into demo_db.public.customer values(883,'Alexander Hunold', 'Alexan.H@biz.com','Magdalen Centre, The Oxford Science Park, Oxford, UK, OX9 9ZB');
--insert into demo_db.public.customer values(884,'Bruce Ernst', 'Bruce.E@biz,com','9702 Chester Road, Manchester, UK, 0962');
--insert into metrics_dev_db.metrics_pub_sch.customer values(885,'Bruce Est', 'Bruce.Est@biz,com','1000 Chester Rd, Manchester, UK, 0962');
--Update metrics_dev_db.metrics_pub_sch.customer SET ADDRESS = '1010 Chester Rd, Manchester, UK, 0962' Where CUSTOMER_ID = 885;
--insert into metrics_dev_db.metrics_pub_sch.customer select * from demo_db.public.customer;
--delete from  metrics_dev_db.metrics_pub_sch.customer where customer_id in (100,101,102,103);

--Target Table Structure 
CREATE OR REPLACE TABLE metrics_dev_db.metrics_pub_sch.DIM_CUSTOMER (
CUSTOMER_KEY    INTEGER NOT NULL IDENTITY(1,1),  --Surrogate Key
CUSTOMER_ID	    INTEGER,              --Natural Key
FULLNAME	    VARCHAR(50),
EMAIL           VARCHAR(30),
ADDRESS	        VARCHAR(100),
ACTIVE_FLAG     VARCHAR(1),           --Active Flag 
START_DATE      DATE,                 --Effictive Start Date
END_DATE        DATE,                 --Effictive End Date
PRIMARY KEY(CUSTOMER_KEY)
);

select * from metrics_dev_db.metrics_pub_sch.dim_customer order by 1 asc;
--delete from metrics_dev_db.metrics_pub_sch.dim_customer where CUSTOMER_KEY in (5,6);
--truncate table metrics_dev_db.metrics_pub_sch.dim_customer;

--create or replace sequence metrics_dev_db.metrics_pub_sch.seq_dim_cust_key start = 1 increment = 1;

merge
into metrics_dev_db.metrics_pub_sch.dim_customer rpt using (
select stg.customer_ID as join_key, stg.*
from metrics_dev_db.metrics_pub_sch.customer stg
union all
select null, stg.*
from metrics_dev_db.metrics_pub_sch.customer stg
join metrics_dev_db.metrics_pub_sch.dim_customer rpt 
on rpt.customer_ID = stg.customer_ID 
where (
	(rpt.email <> stg.email or rpt.address <> stg.address)
    and rpt.END_DATE is null
)) sub
on sub.join_key = rpt.customer_ID
when matched
and (sub.email <> rpt.email or sub.address <> rpt.address)
then update
set end_date = current_date() , ACTIVE_FLAG = 'N'
when not matched then insert
( 
CUSTOMER_ID,
FULLNAME,
EMAIL,
ADDRESS,
ACTIVE_FLAG,
START_DATE
)
values (
sub.CUSTOMER_ID,
sub.FULLNAME,
sub.email,
sub.address,
'Y',
current_date()
);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
use role g_snw_metrics_dev_dba;
use warehouse metrics_dev_wh;
use database demo_db;
use schema public;

create or replace table nation (
     n_nationkey number,
     n_name varchar(25),
     n_regionkey number,
     n_comment varchar(152),
     country_code varchar(2),
     update_timestamp timestamp_ntz);
     
create or replace table nation_history (
    n_nationkey number,
    n_name varchar(25),
    n_regionkey number,
    n_comment varchar(152),
    country_code varchar(2),
    start_time timestamp_ntz,
    end_time timestamp_ntz,
    current_flag int);
    
create or replace stream nation_table_changes on table nation;

select * from nation;
select * from nation_history;

show streams;
select * from nation_table_changes;
--drop stream nation_table_changes;

create or replace view nation_change_data as
-- This subquery figures out what to do when data is inserted into the NATION table
-- An insert to the NATION table results in an INSERT to the NATION_HISTORY table
select n_nationkey, n_name, n_regionkey, n_comment, country_code, start_time, end_time, current_flag, 'I' as dml_type from 
(select n_nationkey, n_name, n_regionkey, n_comment, country_code,
             update_timestamp as start_time,
             lag(update_timestamp) over (partition by 
n_nationkey order by update_timestamp desc) as end_time_raw,
             case when end_time_raw is null then 
'9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
             case when end_time_raw is null then 1 else 0 end as 
current_flag
      from (select n_nationkey, n_name, n_regionkey, n_comment, 
country_code, update_timestamp
            from nation_table_changes
            where metadata$action = 'INSERT'
            and metadata$isupdate = 'FALSE'))
union
-- This subquery figures out what to do when data is updated in the NATION table
-- An update to the NATION table results in an update AND an insert to the NATION_HISTORY table
-- The subquery below generates two records, each with a different dml_type
select n_nationkey, n_name, n_regionkey, n_comment, country_code, start_time, end_time, current_flag, dml_type
from (select n_nationkey, n_name, n_regionkey, n_comment, country_code,
             update_timestamp as start_time,
             lag(update_timestamp) over (partition by n_nationkey order by update_timestamp desc) as end_time_raw,
             case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
             case when end_time_raw is null then 1 else 0 end as current_flag,
             dml_type
      from (-- Identify data to insert into nation_history table
            select n_nationkey, n_name, n_regionkey, n_comment, country_code, update_timestamp, 'I' as dml_type
            from nation_table_changes
            where metadata$action = 'INSERT'
            and metadata$isupdate = 'TRUE'
            union
            -- Identify data in NATION_HISTORY table that needs to be updated
            select n_nationkey, null, null, null, null, start_time, 'U' as dml_type
            from nation_history
            where n_nationkey in (select distinct n_nationkey 
                                  from nation_table_changes
                                  where metadata$action = 'INSERT'
                                  and metadata$isupdate = 'TRUE'
                                 ) and current_flag = 1
            )
     )
union
-- This subquery figures out what to do when data is deleted from the NATION table
-- A deletion from the NATION table results in an update to the NATION_HISTORY table
select nms.n_nationkey, null, null, null, null, nh.start_time, current_timestamp()::timestamp_ntz, null, 'D'
from nation_history nh
inner join nation_table_changes nms on nh.n_nationkey = nms.n_nationkey
where nms.metadata$action = 'DELETE'
and   nms.metadata$isupdate = 'FALSE'
and   nh.current_flag = 1;

select * from nation_change_data;

merge into nation_history nh -- Target table to merge changes from NATION into
using nation_change_data m -- nation_change_data is a view that holds the logic that determines what to insert/update into the NATION_HISTORY table.
   on  nh.n_nationkey = m.n_nationkey -- n_nationkey and start_time determine whether there is a unique record in the NATION_HISTORY table
   and nh.start_time = m.start_time
when matched and m.dml_type = 'U' then update -- Indicates the record has been updated and is no longer current and the end_time needs to be stamped
    set nh.end_time = m.end_time,
        nh.current_flag = 0
when matched and m.dml_type = 'D' then update -- Deletes are essentially logical deletes. The record is stamped and no newer version is inserted
    set nh.end_time = m.end_time,
        nh.current_flag = 0
when not matched and m.dml_type = 'I' then insert -- Inserting a new n_nationkey and updating an existing one both result in an insert
           (n_nationkey, n_name, n_regionkey, n_comment, country_code, start_time, end_time, current_flag)
    values (m.n_nationkey, m.n_name, m.n_regionkey, m.n_comment, m.country_code, m.start_time, m.end_time, m.current_flag);
    
set update_timestamp = current_timestamp()::timestamp_ntz;
begin;
--insert into nation values(0,'ALGERIA',0,' haggle. carefully final deposits detect slyly again','DZ',$update_timestamp);
insert into nation values(1,'ARGENTINA',1,'al foxes promise slyly according to the regular accounts. bold requests alon','AR',$update_timestamp);
commit;


begin;
update nation
set n_comment = 'New comment', update_timestamp = current_timestamp()::timestamp_ntz where n_nationkey = 1;
commit;

delete from nation where n_nationkey in (1);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

use role g_snw_metrics_dev_dba;
use warehouse metrics_dev_wh;
use database demo_db;
use schema public;

create or replace table customer (
     customer_id number,
     full_name varchar(25),
     address varchar(152),
     update_timestamp timestamp_ntz);
     
create or replace table customer_history (
    customer_id number,
    full_name varchar(25),
    address varchar(152),
    start_time timestamp_ntz,
    end_time timestamp_ntz,
    current_flag int);

select * from customer;
select * from customer_history;

--truncate table customer;
--truncate table customer_history;

set update_timestamp = current_timestamp()::timestamp_ntz;
begin;
insert into demo_db.public.customer values(880,'Steven King','2017 Shinjuku-ku, Tokyo, JP, 5670',$update_timestamp);
insert into demo_db.public.customer values(881,'Neena Kochhar','2014 Jabberwocky Rd, TX, US, 26192',$update_timestamp);
insert into demo_db.public.customer values(882,'Lex De Haan','2011 Interiors Blvd, CA, US, 99236',$update_timestamp);
insert into demo_db.public.customer values(883,'Alex Hunold','The Oxford Science Park, Oxford, UK, OX9 9ZB',$update_timestamp);
commit;
    
create or replace stream customer_table_changes on table customer;
show streams;
select * from customer_table_changes order by 1;
--drop stream customer_table_changes;

create or replace view customer_change_data as
-- This subquery figures out what to do when data is inserted into the customer table
-- An insert to the customer table results in an INSERT to the customer_HISTORY table
select customer_id, full_name, address, start_time, end_time, current_flag, 'I' as dml_type from 
(select customer_id, full_name, address, update_timestamp as start_time,
             lag(update_timestamp) over (partition by customer_id order by update_timestamp desc) as end_time_raw,
             case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
             case when end_time_raw is null then 1 else 0 end as current_flag
      from (select customer_id, full_name, address, update_timestamp
            from customer_table_changes
            where metadata$action = 'INSERT' and metadata$isupdate = 'FALSE'))
union
-- This subquery figures out what to do when data is updated in the NATION table
-- An update to the NATION table results in an update AND an insert to the NATION_HISTORY table
-- The subquery below generates two records, each with a different dml_type
select customer_id, full_name, address, start_time, end_time, current_flag, dml_type
from (select customer_id, full_name, address,
             update_timestamp as start_time,
             lag(update_timestamp) over (partition by customer_id order by update_timestamp desc) as end_time_raw,
             case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
             case when end_time_raw is null then 1 else 0 end as current_flag,
             dml_type
      from (-- Identify data to insert into nation_history table
            select customer_id, full_name, address, update_timestamp, 'I' as dml_type
            from customer_table_changes
            where metadata$action = 'INSERT'
            and metadata$isupdate = 'TRUE'
            union
            -- Identify data in NATION_HISTORY table that needs to be updated
            select customer_id, null, null, start_time, 'U' as dml_type
            from customer_history
            where customer_id in (select distinct customer_id 
                                  from customer_table_changes
                                  where metadata$action = 'INSERT'
                                  and metadata$isupdate = 'TRUE'
                                 ) and current_flag = 1
            )
     )
union
-- This subquery figures out what to do when data is deleted from the NATION table
-- A deletion from the NATION table results in an update to the NATION_HISTORY table
select nms.customer_id, null, null, nh.start_time, current_timestamp()::timestamp_ntz, null, 'D'
from customer_history nh
inner join customer_table_changes nms on nh.customer_id = nms.customer_id
where nms.metadata$action = 'DELETE'
and   nms.metadata$isupdate = 'FALSE'
and   nh.current_flag = 1;

select * from customer_change_data;

merge into customer_history nh -- Target table to merge changes from NATION into
using customer_change_data m -- customer_change_data is a view that holds the logic that determines what to insert/update into the customer_HISTORY table.
   on  nh.customer_id = m.customer_id -- customer_id and start_time determine whether there is a unique record in the customer_HISTORY table
   and nh.start_time = m.start_time
when matched and m.dml_type = 'U' then update -- Indicates the record has been updated and is no longer current and the end_time needs to be stamped
    set nh.end_time = m.end_time,
        nh.current_flag = 0
when matched and m.dml_type = 'D' then update -- Deletes are essentially logical deletes. The record is stamped and no newer version is inserted
    set nh.end_time = m.end_time,
        nh.current_flag = 0
when not matched and m.dml_type = 'I' then insert -- Inserting a new customer_id and updating an existing one both result in an insert
           (customer_id, full_name, address, start_time, end_time, current_flag)
    values (m.customer_id, m.full_name, m.address, m.start_time, m.end_time, m.current_flag);




create table demo_db.public.load_data(
  raw varchar2(10)
);
select * from demo_db.public.load_data;
--truncate table demo_db.public.load_data;

call demo_db.public.load_data();

CREATE OR REPLACE PROCEDURE demo_db.public.load_data()
  Returns string NOT Null
  LANGUAGE JAVASCRIPT
  AS     
  $$  
var result = "";
var raw_data = null;
try {
    snowflake.execute({
      sqlText: `Insert Into demo_db.public.load_data(raw) Values (:1)`
      ,binds: [raw_data].map(function(x)
                      {return x === undefined ? null : x
                      })
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

--Create Table metrics_prv_sch.STG_PPM_STATUS_DAILY_SRC AS
--Select INVESTMENT_ID, INVESTMENT_NAME, INVESTMENT_MANAGER, STATUS, STAGE, PROGRESS From metrics_prv_sch.STG_PPM_STATUS_DAILY; 

Select * From metrics_prv_sch.STG_PPM_STATUS_DAILY_SRC;

Update metrics_prv_sch.STG_PPM_STATUS_DAILY_SRC Set STATUS = 'Approved' Where INVESTMENT_ID = 'PR0001';

--Create Table metrics_prv_sch.RPT_PPM_STATUS_DAILY_TGT AS
--Select INVESTMENT_ID, INVESTMENT_NAME, INVESTMENT_MANAGER, STATUS, STAGE, PROGRESS, NULL AS SRC_UPD, NULL AS UPD_DTTM From metrics_prv_sch.STG_PPM_STATUS_DAILY
--Where 1=2; 

Select * From metrics_prv_sch.RPT_PPM_STATUS_DAILY_TGT Where INVESTMENT_ID = 'PR0001';


Merge Into metrics_prv_sch.RPT_PPM_STATUS_DAILY_TGT Tgt Using (
	Select Src.INVESTMENT_ID As JOIN_KEY, Src.* From metrics_prv_sch.STG_PPM_STATUS_DAILY_SRC Src
	Union ALL
	Select NULL, Src.* From metrics_prv_sch.STG_PPM_STATUS_DAILY_SRC Src
	Join metrics_prv_sch.RPT_PPM_STATUS_DAILY_TGT Tgt 
		ON Tgt.INVESTMENT_ID = Src.INVESTMENT_ID 
	Where (
			    Tgt.STATUS <> Src.STATUS OR Tgt.STAGE <> Src.STAGE OR Tgt.PROGRESS <> Src.PROGRESS
                --And Tgt.END_DATE IS NULL
	      )
) DataSet
	ON DataSet.JOIN_KEY = Tgt.INVESTMENT_ID

WHEN MATCHED --AND (Tgt.STATUS <> DataSet.STATUS OR Tgt.STAGE <> DataSet.STAGE OR Tgt.PROGRESS <> DataSet.PROGRESS)
    THEN UPDATE
	    SET Tgt.STATUS = DataSet.STATUS,
            Tgt.STAGE = DataSet.STAGE,
            Tgt.PROGRESS = DataSet.PROGRESS,
            SRC_UPD = 'Source Side Update',
            UPD_DTTM = CURRENT_DATE()

WHEN NOT MATCHED THEN INSERT ( 
	INVESTMENT_ID,
	INVESTMENT_NAME,
	INVESTMENT_MANAGER,
	STATUS,
	STAGE,
	PROGRESS
)
Values (
	DATASET.INVESTMENT_ID,
	DATASET.INVESTMENT_NAME,
	DATASET.INVESTMENT_MANAGER,
	DATASET.STATUS,
	DATASET.STAGE,
	DATASET.PROGRESS
);

----------------------------------------------------------------------------------------------------