--https://app.snowflake.com/west-us-2.azure/nr64328/w4Zjyy81SNMd/query
select current_role(); --AccountAdmin
select current_region(); --AZURE_WESTUS2
select current_account(); --NR64328
select current_user(); --DebiMishra

use role accountadmin;
create database Metric_DB; //Database Creation
create schema Metric_DB.Sch; //Schema Creation
CREATE TABLE Metric_DB.Sch.Customers (
  customer_nbr varchar(20),
  Last_Name varchar(50),
  First_Name varchar(50),
  phone varchar(50),
  address_Line1 varchar(50),
  address_Line2 varchar(50),
  city varchar(50),
  state varchar(50),
  postal_code varchar(15),
  country varchar(50)
);

Insert Into Metric_DB.Sch.Customers(customer_nbr,Last_Name,First_Name,phone,address_Line1,address_Line2,
                    city,state,postal_Code,country) values 
('C00103','Schmitt','Carine','401-322-2555','54 Rue Royale',NULL,'Nantes',NULL,'44000','France'),
('C00112','King','Jean','702-555-1838','8489 Strong St.',NULL,'Las Vegas','NV','83030','USA'),
('C00114','Ferguson','Peter','039-520-4555','636 St Kilda Road','Level 3','Melbourne','Victoria','3004','Australia'),
('C00119','Labrune','Janine','406-785-5512','67 Rue des Cinquante Otages',NULL,'Nantes',NULL,'44000','France'),
('C00121','Bergulfsen','Jonas','079-955-0985','Erling Skakkes Gate 78',NULL,'Stavern',NULL,'4110','Norway');

select * from Metric_DB.Sch.Customers;

CREATE TABLE Metric_DB.Sch.Products (
  product_code varchar(15),
  product_name varchar(70),
  stock_quantity int,
  buying_price decimal(10,2),
  MSRP decimal(10,2)
);

Insert Into Metric_DB.Sch.Products(product_Code,product_Name,stock_quantity,buying_Price,MSRP) values
('S10-1678','1969 Harley Davidson Ultimate Chopper',107,48.81,95.70),
('S10-1949','1952 Alpine Renault 1300',01,98.58,214.30),
('S10-2016','1996 Moto Guzzi 1100i',6625,68.99,118.94),
('S10-4698','2003 Harley-Davidson Eagle Drag Bike',5582,91.02,193.66),
('S10-4757','1972 Alfa Romeo GTA',3252,85.68,136.00);

select * from Metric_DB.Sch.Products;

CREATE TABLE Metric_DB.Sch.Orders (
  order_nbr varchar(10),
  order_date date,
  required_date date,
  shipped_date date,
  status varchar(15),
  customer_nbr varchar(20)
);

insert into orders(order_nbr,order_Date,required_date,shipped_date,status,customer_nbr) values
('OD10100','2003-01-06','2003-01-13','2003-01-10','Shipped','C00103'),
('OD10101','2003-01-09','2003-01-18','2003-01-11','Shipped','C00112'),
('OD10102','2003-01-10','2003-01-18','2003-01-14','Shipped','C00114');

select * from Metric_DB.Sch.Orders;

CREATE TABLE Metric_DB.Sch.Orderdetails (
  order_nbr varchar(10),
  product_code varchar(15),
  quantity int,
  each_price decimal(10,2),
  order_line_nbr int
);

insert into orderdetails(order_nbr,product_code,quantity,each_price,order_line_nbr) values 
('OD10100','S10-1678',50,95.70,2),
('OD10100','S10-1949',49,214.30,1),
('OD10101','S10-2016',25,118.94,1),
('OD10102','S10-4757',41,136.00,1);

select * from Metric_DB.Sch.Orderdetails;

create or replace view Metric_DB.Sch.view_OrderDetails_All as
select od.order_nbr, od.order_line_nbr, od.quantity, od.each_price, o.order_Date, o.status, 
od.product_code, p.product_Name, c.customer_nbr, c.Last_Name||' '||c.First_Name as customer_name
from Metric_DB.Sch.Orderdetails od
inner join Metric_DB.Sch.Orders o on od.order_nbr=o.order_nbr
inner join Metric_DB.Sch.Products p on p.product_code=od.product_code
inner join Metric_DB.Sch.Customers c on c.customer_nbr=o.customer_nbr
order by 1, 2 asc;

select * from Metric_DB.Sch.view_OrderDetails_All;

use role accountadmin;
--Assign OrgAdmin role to Source/Local account 
--Grant the ORGADMIN role to a User
grant role orgadmin to user DebiMishra;

--Enable ORGANIZATION 
--Viewing the Name of Your Organization and Its Accounts
use role orgadmin;
show organization accounts;

--Create a new database in the source account and enable replication
use role accountadmin;

--In your local/ current account, create a new database with a subset of data
create database Metric_Data_Mart; //Database Creation
create schema Metric_Data_Mart.Sch; //Schema Creation
create table Metric_Data_Mart.Sch.Customers_Mart As Select customer_nbr, Last_Name, First_Name 
        from Metric_DB.Sch.Customers;
--select * from Metric_Data_Mart.Sch.Customers_Mart;

--Set up a Stream to record changes made to the source table
use role accountadmin;
create stream customer_ins_strm on table Metric_DB.Sch.Customers 
        append_only = true;

--Set up a Task to lift the changes from the Source DB to insert 
--them to the Primary DB 
create task load_customer_tsk
  WAREHOUSE = compute_wh
  SCHEDULE = '5 minute'
WHEN
  SYSTEM$STREAM_HAS_DATA('customer_ins_strm')
AS
  insert into Metric_Data_Mart.Sch.Customers_Mart(customer_nbr, Last_Name, First_Name) 
    select customer_nbr, Last_Name, First_Name from customer_ins_strm 
    where METADATA$ACTION = 'INSERT';

show tasks;
alter task load_customer_tsk Resume;
--alter task load_customer_tsk suspend;
select * from table(information_schema.task_history())
  order by scheduled_time;

Insert Into Metric_DB.Sch.Customers(customer_nbr,Last_Name,First_Name,phone,address_Line1,address_Line2,
                    city,state,postal_Code,country) values 
('C00149','Blake','Smith','402-342-2789','583 San Ramon Blvd',NULL,'San Ramon','CA','94583','US');

select * from Metric_DB.Sch.Customers;
select * from Metric_Data_Mart.Sch.Customers_Mart;


--Create one Account in Target Region(AWS canada-central as per design flow diagram)
--Before configuring data replication, you must create an account in a region where 
--you wish to share data and link it to your local account. Let's create an account.
use role orgadmin;
show organization accounts;
show regions; --AWS_CA_CENTRAL_1/ca-central-1/Canada (Central)

create account JS97236_Replica
  admin_name = DebiMishra
  admin_password = 'TestPassword@23'
  first_name = Debi
  last_name = Mishra
  email = 'DebiPrasad.Mishra06@gmail.com'
  edition = BUSINESS_CRITICAL
  region = AWS_CA_CENTRAL_1;
--Output as below:
--{"accountLocator":"AZ37442","accountLocatorUrl":"https://az37442.ca-central-1.aws.snowflakecomputing.com",
--"accountName":"JS97236_REPLICA","url":"https://svrsrqcjs97236_replica.snowflakecomputing.com",
--"edition":"BUSINESS_CRITICAL","regionGroup":"PUBLIC","cloud":"AWS","region":"AWS_CA_CENTRAL_1"}

--Enable ORGANIZATION - Viewing the Name of Your Organization and Its Accounts
use role orgadmin;
show organization accounts;

--Promote the new database as primary: [Org_Name:Account_Name]
select system$global_account_set_parameter('SVRSRQC.JS97236', 
            'ENABLE_ACCOUNT_DATABASE_REPLICATION', 'true');
select system$global_account_set_parameter('SVRSRQC.JS97236_REPLICA', 
            'ENABLE_ACCOUNT_DATABASE_REPLICATION', 'true');

use role accountadmin;
use database Metric_Data_Mart;
use schema Sch;
--Promoting a Local Database to Serve as a Primary Database
alter database Metric_Data_Mart enable replication to accounts SVRSRQC.JS97236;
alter database Metric_Data_Mart enable replication to accounts SVRSRQC.JS97236_REPLICA;

show replication databases; //Output: METRIC_DATA_MART
show replication accounts;  //Output: JS97236, JS97236_REPLICA

--Separately Log in using Another Account to create replicated database
--Get the account_url from show organization accounts command output

--https://svrsrqc-js97236_replica.snowflakecomputing.com/console/login#/
use role accountadmin;

--Replicate the existing database to a db as replicated db in the other region
create or replace database Metric_Data_Mart
  as replica of SVRSRQC.JS97236.METRIC_DATA_MART;

alter database Metric_Data_Mart refresh;

Create Warehouse compute_wh WITH Warehouse_Size='X-SMALL';
use warehouse compute_wh;
use database Metric_Data_Mart;
use schema SCH;
Select * From Metric_Data_Mart.Sch.Customers_Mart;

use role accountadmin;
show replication databases; //Output: METRIC_DATA_MART
show replication accounts;  //Output: JS97236, JS97236_REPLICA

-- Schedule refresh of the replicated database
use role accountadmin;
create task refresh_Metric_Data_Mart_tsk
  warehouse = compute_wh
  schedule = '50 minute'
as
  alter database Metric_Data_Mart refresh;

alter task refresh_SecondaryDB_task resume;

--Create a share in Replicated DB
use role accountadmin;
create share Metric_Data_Mart_s; 

show shares;
-- Add objects to the share:
show grants to share Metric_Data_Mart_s;
grant usage on database Metric_Data_Mart to share Metric_Data_Mart_s;
grant usage on schema Metric_Data_Mart.Sch to share Metric_Data_Mart_s;
grant select on table Metric_Data_Mart.Sch.Customers_Mart to share Metric_Data_Mart_s;

--Add one or more consumer accounts to the share
alter share Metric_Data_Mart_s add accounts=XIOBDEP.DU61376;

--https://app.snowflake.com/ca-central-1.aws/xf35582/w4UEJbRD1vk2#query
select current_role(); --AccountAdmin
select current_region(); --AWS_CA_CENTRAL_1
select current_account(); --XF35582
select current_user(); --DebiPMishra

use role accountadmin;
use role OrgAdmin;
show organization accounts;

show shares;
create database stg_metric_data_mart from 
		share SVRSRQC.JS97236_REPLICA.METRIC_DATA_MART_S;

use database stg_metric_data_mart;
show tables;
select * from Sch.CUSTOMERS_MART;
