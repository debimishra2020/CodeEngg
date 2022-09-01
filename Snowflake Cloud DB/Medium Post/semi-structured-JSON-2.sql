USE Role <Role_Name>;
USE Warehouse <Warehouse_Name>;
USE Database <Database_Name>;
USE Schema <Schema_Name>;

Create Or Replace Table <Schema_Name>.json_demo (
  raw variant
);

select * from <Schema_Name>.json_demo;


insert into <Schema_Name>.json_demo
select
parse_json(
'{
"FullName": "Smith Jackson",
"Age": 52,
"Gender": "Male",
"PhoneNumber": {
	"AreaCode": "400",
	"SubscriberNumber": "456-7744"
	},
"Education": [
{ "School": "Paradise Secondary School", "Address": "New Jersey", "Year": "2000" },
{ "School": "Oakleaf Charter School", "Address": "California", "Year": "2002" },
{ "School": "River Valley B-School", "address": "Ohio", "Year": "2004" }
	],
"Cities": [
	{ "CityName": "Jersey City",
	"YearsLived": [ "1989", "1993", "1998", "2002" ]
},
	{ "CityName": "San Francisco",
	"YearsLived": [ "1990", "1993", "1998", "2008" ]
},
	{ "CityName": "Columbus",
	"YearsLived": [ "1993", "1998", "2003", "2005" ]
},
	{ "CityName": "Austin",
	"YearsLived": [ "1973", "1998", "2001", "2005" ]
}
	]
}');

select * from metrics_pub_sch.json_demo;

select raw:FullName as Full_Name from <Schema_Name>.json_demo;

select raw:FullName::string as Full_Name, raw:Age::int as Age,
raw:Gender::string as Gender from <Schema_Name>.json_demo;

--Where:raw = the column name in the json_demo table
--FullName = attribute in the JSON schema
--raw:FullName = syntax for which attribute in column raw you are selecting

--CASTE THE DATA
select raw:FullName::string as full_name from metrics_pub_sch.json_demo;

select raw:FullName::string as Full_Name, raw:Age::int as Age,
raw:Gender::string as Gender,raw:PhoneNumber.AreaCode::string as area_code, 
raw:PhoneNumber.SubscriberNumber::string as subscriber_number from <Schema_Name>.json_demo;

select f.value:School::string as school,
f.value:Address::string as address, f.value:Year::string as year
from <Schema_Name>.json_demo, table(flatten(raw:Education)) f;

select raw:FullName::string as full_name, f.value:School::string as school,
f.value:Address::string as address, f.value:Year::string as year
from <Schema_Name>.json_demo, table(flatten(raw:Education)) f;

select raw:FullName::string as Full_Name, raw:Age::int as Age,raw:Gender::string as Gender,
raw:PhoneNumber.AreaCode::string as area_code,raw:PhoneNumber.SubscriberNumber::string as subscriber_number,
to_char(array_size(raw:Education)) as no_of_schools from <Schema_Name>.json_demo;

select raw:FullName::string as full_name, raw:Age::int as Age,raw:Gender::string as Gender,
array_size(raw:Education) as Number_of_Schools, to_char(array_size(raw:Cities)) as Number_of_Cities
from <Schema_Name>.json_demo;

select cl.value:CityName::string as city_name,yl.value::string as year_lived
from <Schema_Name>.json_demo, table(flatten(raw:Cities)) cl, table(flatten(cl.value:YearsLived)) yl;

select raw:FullName::string as full_name, --f.value:School::string as school,
cl.value:CityName::string as city_name, yl.value::string as year_lived
from <Schema_Name>.json_demo,--table(flatten(raw:Education)) f,
table(flatten(raw:Cities)) cl, table(flatten(cl.value:YearsLived)) yl;

select cl.value:CityName::string as city_name, to_char(count(*)) as year_lived
from <Schema_Name>.json_demo, table(flatten(raw:Cities)) cl,
table(flatten(cl.value:YearsLived)) yl group by 1;

select cl.value:CityName::string as city_name, to_char(count(*)) as year_lived
from <Schema_Name>.json_demo, table(flatten(raw:Cities)) cl,
table(flatten(cl.value:YearsLived)) yl where city_name='San Francisco' group by 1;