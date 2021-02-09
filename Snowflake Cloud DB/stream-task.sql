use role sysadmin;
use warehouse compute_wh;
use schema demo_db.public;

create or replace table demo_db.public.product_master(
  product_id int,
  product_desc varchar(20),
  category varchar(10),
  segment varchar(20),
  manufacture_id int,
  manufacture varchar(50)
);

create or replace table demo_db.public.sales_raw(
  product_id int,
  purchase_date date,
  zip varchar(10),
  units int,
  revenue decimal(10,2)
);

-- Sales Transaction Table
insert into demo_db.public.sales_raw values (101,'2020-01-01',10001,1,111.11 );
insert into demo_db.public.sales_raw values (102,'2020-01-02',10002,2,222.22 );
insert into demo_db.public.sales_raw values (103,'2020-01-03',10003,3,333.33 );
insert into demo_db.public.sales_raw values (104,'2020-01-04',10004,4,444.44 ); 
insert into demo_db.public.sales_raw values (105,'2020-01-05',10005,5,555.55 );

insert into demo_db.public.sales_raw values (155,'2020-01-25',10005,0,555.55 ); -- will be modified later
insert into demo_db.public.sales_raw values (166,'2020-01-26',10006,0,600.06 ); -- will be modified later
insert into demo_db.public.sales_raw values (177,'2020-01-27',10007,0,777.77 ); -- will be modidfied later

insert into demo_db.public.sales_raw values (200,'2020-01-28',10008,3,0.11 );   -- will be deleted later
insert into demo_db.public.sales_raw values (200,'2020-01-29',10009,3,0.11 );   -- will be deleted later
insert into demo_db.public.sales_raw values (200,'2020-01-30',10010,3,0.11 );   -- will be deleted later

-- Product Master Data
insert into demo_db.public.product_master values (101,'Abbas MA-01','Mix','All Season','1','Abbas');
insert into demo_db.public.product_master values (102,'Fama UE-85','Urban','All Extreme','1','Fama');
insert into demo_db.public.product_master values (103,'Abbas MA-03','Mix','All Season','1','Abbas');
insert into demo_db.public.product_master values (104,'Abbas MA-04','Mix','All Season','1','Abbas');
insert into demo_db.public.product_master values (105,'Abbas MA-05','Mix','All Season','1','Abbas');
insert into demo_db.public.product_master values (106,'Abbas MA-06','Mix','All Season','1','Abbas');
insert into demo_db.public.product_master values (107,'Abbas MA-07','Mix','All Season','1','Abbas');
insert into demo_db.public.product_master values (108,'Abbas MA-08','Mix','All Season','1','Abbas');
insert into demo_db.public.product_master values (109,'Abbas MA-09','Mix','All Season','1','Abbas');

-- For a Sequence Key 
create or replace sequence demo_db.public.sales_sequence start = 1 increment = 1;

show sequences;

create or replace table demo_db.public.sales_consumption(
  tx_key number  default demo_db.public.sales_sequence.nextval,
  product_id int ,
  product_desc varchar(),
  category varchar(10),
  segment varchar(20),
  manufacture varchar(50),
  purchase_date date,
  zip varchar(),
  units int,
  revenue decimal(10,2)
);

select * from demo_db.public.sales_raw;
--delete from demo_db.public.sales_raw;

select * from demo_db.public.product_master;
--delete from demo_db.public.product_master;

-- insert as select sql
insert into demo_db.public.sales_consumption 
(product_id,product_desc,category,segment,manufacture,purchase_date, zip, units, revenue)
select s.product_id, pm.product_desc, pm.category, pm.segment, pm.manufacture, s.purchase_date, s.zip, s.units, s.revenue
from demo_db.public.sales_raw s join demo_db.public.product_master pm
on s.product_id  = pm.product_id and pm.product_id = 104;

select * from demo_db.public.sales_consumption;
--delete from demo_db.public.sales_consumption;

-- insert only stream
create or replace stream demo_db.public.sales_raw_stream
  on table demo_db.public.sales_raw 
  append_only=true
  comment = 'Insert only stream on sales raw  table';
  
show streams;
--drop stream sales_raw_stream;

desc stream demo_db.public.sales_raw_stream;

-- insert a record into sales_raw & product_master

-- to check if captured in stream table
select * from demo_db.public.sales_raw_stream;

-- insert into sales_consumption via stream table
insert into demo_db.public.sales_consumption 
(product_id,product_desc,category,segment,manufacture,purchase_date, zip, units, revenue)
select s.product_id, pm.product_desc, pm.category, pm.segment, pm.manufacture, s.purchase_date, s.zip, s.units, s.revenue
from demo_db.public.sales_raw_stream s join demo_db.public.product_master pm
on s.product_id  = pm.product_id;

select * from demo_db.public.sales_consumption;

-- task creation
create or replace task demo_db.public.sales_task
    warehouse = compute_wh 
    schedule  = '1 minute'
  when
    system$stream_has_data('demo_db.public.sales_raw_stream')
  as
    insert into demo_db.public.sales_consumption 
    (product_id,product_desc,category,segment,manufacture,purchase_date, zip, units, revenue)
    select s.product_id, pm.product_desc, pm.category, pm.segment, pm.manufacture, s.purchase_date, s.zip, s.units, s.revenue
    from demo_db.public.sales_raw_stream s join demo_db.public.product_master pm
    on s.product_id  = pm.product_id;
    
show tasks;
--drop task sales_task;

use role accountadmin;
alter task sales_task resume;

grant execute task on account to role sysadmin;
show roles;

-- how to see how it works
select * from table(information_schema.task_history()) order by scheduled_time;

-- you can see only the schedule items
select * from table(information_schema.task_history()) where state in ('SCHEDULED','SUCCEEDED') order by scheduled_time;

merge into t_emp_tgt as t
using (select *,md5(nvl(first_name,'')||nvl(last_name,'')) as etl_checksum
       from stream) as s 
on t.id = s.id
when matched
    and s.metadata$action = 'INSERT'
    and s.metadata$isupdate then 
    update set t.first_name = s.first_name,
               t.last_name = s.last_name
when matched 
    and s.metadata$action = 'DELETE' then DELETE
when not matched 
    and s.metadata$action = 'INSERT' then 
    insert (id, first_name, last_name) 
    values (s.id, s.first_name, s.last_name)
;
