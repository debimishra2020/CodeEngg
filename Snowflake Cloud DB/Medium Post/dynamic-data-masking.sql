--Let's login with AccountAdmin Role
use role accountadmin;
use warehouse compute_wh;
create or replace database finance;
create schema sch_stg_finance;

--use database finance;
--use schema sch_stg_finance;

create or replace table sch_stg_finance.stg_fin_customer_extract_daily (
    CUSTOMER_ID INTEGER NOT NULL,
    FULL_NAME  VARCHAR(255) NULL,
    EMAIL_ID VARCHAR(255) NULL,
    CITY VARCHAR(255) NULL,
    SSN VARCHAR(13) NULL,
    PRIMARY_CARD VARCHAR(255) NULL,
    DATE_OF_BIRTH VARCHAR(255)
);

--Truncate Table sch_stg_finance.stg_fin_customer_extract_daily;
INSERT INTO sch_stg_finance.stg_fin_customer_extract_daily(CUSTOMER_ID,FULL_NAME,EMAIL_ID,CITY,SSN,PRIMARY_CARD,DATE_OF_BIRTH) 
VALUES(889,'Chadwick Long','libero@vel.org','Bontang','167002192','3726-1920-8674-8500','10-03-1959'),
(890,'Barry White','ultrices.iaculis.odio@atvelitPellentesque.org','Gravelbourg','166310198','3414-5232-1269-0970','11-28-1982'),
(891,'Neros Johnston','molestie@dictumeleifend.net','Villa Verde','169305022','3727-7025-0004-0239','04-22-1933'),
(892,'Thaddeus Hood','diam.dictum@Etiam.org','Habra','162203259','3481-4584-5891-6872','12-25-1994'),
(893,'Keegan Page','per.conubia.nostra@mi.org','Puerto Guzmán','166510180','3776-4368-4865-0746','02-15-1997'),
(894,'Jordan Gibson','inceptos@tellusSuspendissesed.org','Gudivada','163304236','3750-2770-0854-5249','11-01-1992'),
(895,'Gage Mcmillan','in.consequat.enim@congueelitsed.com','Edmonton','160207222','3403-8734-9377-0002','06-03-1957'),
(896,'Andrew Leblanc','semper@placerat.co.uk','Herk-de-Stad','165512049','3444-2764-1456-2852','11-30-1989'),
(897,'Brent Clements','tempor@ipsumportaelit.co.uk','Lochristi','164303093','3775-7562-3111-9156','10-11-2001'),
(898,'Steven Hooper','imperdiet.dictum.magna@cursus.org','South Burlington','162311085','3429-6659-9048-0390','06-22-1992');

--Create Masking Admin User & Role
create user u_debipmis password='struser@22#1' must_change_password=true;
create role if not exists masking_admin;     
grant role masking_admin to user u_debipmis;

grant all privileges on database finance to role masking_admin;
grant all privileges on database finance to role sysadmin;
grant all privileges on database finance to role accountadmin;
grant all privileges on warehouse compute_wh to role masking_admin;
grant all on all schemas in database finance to role masking_admin;
grant all on all schemas in database finance to role sysadmin;
grant all on all tables in database finance to role masking_admin;
grant all on all tables in database finance to role sysadmin;

grant apply masking policy on account to role masking_admin;
grant create masking policy on schema sch_stg_finance to role masking_admin;

--Create Analyst User & Role
Create USER u_debipmis_anlyst Password='StrUser@22#2' MUST_CHANGE_PASSWORD = TRUE;
Create Role g_snw_fin_anlyst;
Grant Role g_snw_fin_anlyst To User u_debipmis_anlyst;
Grant All Privileges On DATABASE Finance To Role g_snw_fin_anlyst;
Grant All Privileges On Warehouse compute_wh To Role g_snw_fin_anlyst;
Grant All On All Schemas In DATABASE Finance To Role g_snw_fin_anlyst;
Grant All On All TABLES In DATABASE Finance To Role g_snw_fin_anlyst;

--Create Reporter User & Role
Create USER u_debipmis_rptr Password='StrUser@22#3' MUST_CHANGE_PASSWORD = TRUE;
Create Role g_snw_fin_rptr;
Grant Role g_snw_fin_rptr To User u_debipmis_rptr;
Grant All Privileges On DATABASE Finance To Role g_snw_fin_rptr;
Grant All Privileges On Warehouse compute_wh To Role g_snw_fin_rptr;
Grant All On All Schemas In DATABASE Finance To Role g_snw_fin_rptr;
Grant All On All TABLES In DATABASE Finance To Role g_snw_fin_rptr;

--Let's login with Masking User having Masking Role

use role masking_admin;
use warehouse compute_wh;
use database finance;
use schema sch_stg_finance;

SELECT ssn, regexp_replace(ssn,substring(ssn,1,5),'xxxx-') as anlyst_role, 
regexp_replace(ssn,substring(ssn,1,7),'xxxx-') as rptr_role
FROM sch_stg_finance.stg_fin_customer_extract_daily;

SELECT customer_id,full_name,email_id,ssn,primary_card,date_of_birth
FROM sch_stg_finance.stg_fin_customer_extract_daily;

Create Or Replace Masking Policy sch_stg_finance.ssn_plcy As (SSN  string) Returns string -> 
Case When Current_Role() In ('MASKING_ADMIN') Then SSN
When current_role() In ('G_SNW_FIN_ANLYST') Then regexp_replace(ssn,substring(ssn,1,5),'xxxx-')
When current_role() In ('G_SNW_FIN_RPTR') Then regexp_replace(ssn,substring(ssn,1,7),'xxxx-')
ELSE '**SSN Masked**'
END;
 
Alter Table sch_stg_finance.stg_fin_customer_extract_daily 
    Modify Column SSN Set Masking Policy sch_stg_finance.ssn_plcy;

--alter table sch_stg_finance.stg_fin_customer_extract_daily modify column SSN unset masking policy;
--drop Masking policy sch_stg_finance.ssn_plcy;
--------------------------End OF SSN Masking Policy-------------------------- 

SELECT email_id, regexp_replace(email_id,'.+\@','xxxx@') as anlyst_role, 
substring(email_id, 0, charindex('@',email_id, 0))||'xxxx' as rptr_role
FROM sch_stg_finance.stg_fin_customer_extract_daily;

Create Or Replace Masking Policy sch_stg_finance.email_plcy AS (email string) Returns string ->
Case When Current_Role() IN ('MASKING_ADMIN') THEN email
When Current_Role() IN ('G_SNW_FIN_ANLYST') THEN regexp_replace(email,'.+\@','xxxx@')
When Current_Role() IN ('G_SNW_FIN_RPTR') THEN substring(email, 0, charindex('@',email, 0))||'xxxx'
ELSE '**Email Masked**'
END;

Alter Table sch_stg_finance.stg_fin_customer_extract_daily 
    Modify Column email_id Set Masking Policy sch_stg_finance.email_plcy;

--alter table sch_stg_finance.stg_fin_customer_extract_daily modify column email_id unset masking policy;
--drop Masking policy sch_stg_finance.email_plcy;
--------------------------End OF Email Masking Policy--------------------------

select primary_card, regexp_replace(primary_card,substring(primary_card,1,10),'xxxx-') as anlyst_role, 
regexp_replace(primary_card,substring(primary_card,1,15),'xxxx-') as rptr_role 
from sch_stg_finance.stg_fin_customer_extract_daily;

Create Or Replace Masking Policy sch_stg_finance.prmycard_plcy AS (card string) Returns string ->
Case When Current_Role() IN ('MASKING_ADMIN') THEN card
When Current_Role() IN ('G_SNW_FIN_ANLYST') THEN regexp_replace(card,substring(card,1,10),'xxxx-')
When Current_Role() IN ('G_SNW_FIN_RPTR') THEN regexp_replace(card,substring(card,1,15),'xxxx-')
ELSE '**Primary Card Masked**'
END;

Alter Table sch_stg_finance.stg_fin_customer_extract_daily 
    Modify Column primary_card Set Masking Policy sch_stg_finance.prmycard_plcy;

--alter table sch_stg_finance.stg_fin_customer_extract_daily modify column primary_card unset masking policy;
--drop Masking policy sch_stg_finance.prmycard_plcy;
--------------------------End OF Primary Card Masking Policy--------------------------

select date_of_birth, regexp_replace(date_of_birth,substring(date_of_birth,1,3),'xxxx-') as anlyst_role ,
regexp_replace(date_of_birth,substring(date_of_birth,1,6),'xxxx-') as rptr_role
from sch_stg_finance.stg_fin_customer_extract_daily;

create or replace masking policy sch_stg_finance.birthdate_plcy as (dob_txt string) returns string ->
Case When Current_Role() IN ('MASKING_ADMIN') THEN dob_txt
When Current_Role() IN ('G_SNW_FIN_ANLYST') THEN regexp_replace(dob_txt,substring(dob_txt,1,3),'xxxx-')
When Current_Role() IN ('G_SNW_FIN_RPTR') THEN regexp_replace(dob_txt,substring(dob_txt,1,6),'xxxx-')
ELSE '**Birth Date Masked**'
END;

Alter Table sch_stg_finance.stg_fin_customer_extract_daily 
    Modify Column date_of_birth Set Masking Policy sch_stg_finance.birthdate_plcy;

--alter table sch_stg_finance.stg_fin_customer_extract_daily modify column date_of_birth unset masking policy;
--drop Masking policy sch_stg_finance.birthdate_plcy;
