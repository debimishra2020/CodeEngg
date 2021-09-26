----Source JSON Structure----
{                                                                                 
   "device_type": "sensor",                                                        
   "events": [                                                                     
     {                                                                             
       "x1": 183,                                                                    
       "x2": "1521.64,790.63,4898.48,679.52",                                                        
       "x3": {                                                                      
         "y1": 564,                                                            
         "y2": 709,                                                            
         "y3": 232,                                                               
         "y4": 687                                                                                                                             
       },                                                                          
       "x4": 5489                                                                                                                            
     },                                                                            
     {                                                                             
       "x1": 100,                                                               
       "x2": "80708.52,5454470.71,857331.27,97.10",                                                         
       "x3": {                                                                      
         "y1": 6990,                                                             
         "y2": 3467,                                                            
         "y3": 2501,                                                               
         "y4": 4606                                                                                                                           
       },                                                                          
       "x4": 6264                                                          
     }                                                                             
   ],                                                                              
   "version": 1,
   "time_stamp": "2021-09-21 21:58:47.038"   
 }

----Account Setup----
USE Role ACCOUNTADMIN;
USE Warehouse COMPUTE_WH;
USE Database DEMO_DB;
USE Schema Public;

----STG Table----
CREATE OR REPLACE TABLE SENSOR_RAW (
    RAW_DATA VARIANT
);

Select * From SENSOR_RAW;
--Truncate Table SENSOR_RAW;
 
----File Format----
CREATE FILE FORMAT JSON_DATA_LOAD
TYPE = 'JSON'
COMPRESSION = 'AUTO'
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE
STRIP_OUTER_ARRAY = TRUE
STRIP_NULL_VALUES = FALSE
IGNORE_UTF8_ERRORS = FALSE;

----Internal STAGE----
CREATE STAGE IF NOT EXISTS 
    JSON_STAGE FILE_FORMAT = JSON_DATA_LOAD; 

--To verify the satge has been created
SHOW STAGES; 

--To see the files if stored in the location
LIST @JSON_STAGE; 

--PUT file://C:\tmp\sensor_data.json @JSON_STAGE;

--Copy Command
COPY INTO SENSOR_RAW From @json_stage/sensor_data.json.gz 
      FILE_FORMAT = (FORMAT_NAME = 'JSON_DATA_LOAD' )
ON_ERROR='CONTINUE';

Select RAW_DATA:device_type::String As DEVICE_TYPE, RAW_DATA:events::String As EVENT_DATA,
RAW_DATA:time_stamp::String As TIME_STAMP, RAW_DATA:version::integer As VERSION
From SENSOR_RAW;

Select value:x1::Number As X1, value:x2::String as X2,
value:x3::String as X3, value:x4::Number as X4
From SENSOR_RAW
    ,Lateral Flatten(input => RAW_DATA:events);

Select value:x1::Number As X1, value:x2::String As X2,
value:x3.y1::Number As Y1, value:x3.y2::Number As Y2, value:x3.y3::Number As Y3, value:x3.y4::Number As Y4, value:x4::Number As X4
From SENSOR_RAW
    ,Lateral Flatten(input => RAW_DATA:events);

Select RAW_DATA:device_type::String As DEVICE_TYPE, value:x1::Number As X1, value:x2::String As X2,
value:x3.y1::Number As Y1, value:x3.y2::Number As Y2, value:x3.y3::Number As Y3, value:x3.y4::Number As Y4, value:x4::Number As X4,
RAW_DATA:time_stamp::String As TIME_STAMP, RAW_DATA:version::Integer As VERSION
From SENSOR_RAW
    ,Lateral Flatten(input => RAW_DATA:events);
