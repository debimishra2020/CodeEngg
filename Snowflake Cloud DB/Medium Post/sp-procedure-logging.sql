use role AccountAdmin;
use warehouse compute_wh;
use database metric_db;
use schema sch;

select * from sch.t_snw_s10_products;
create or replace TABLE sch.T_SNW_S10_PRODUCTS (
	PRODUCT_CODE VARCHAR(15),
	PRODUCT_NAME VARCHAR(70),
	STOCK_QUANTITY NUMBER(38,0),
	BUYING_PRICE NUMBER(10,2),
	MSRP NUMBER(10,2)
);
create or replace TABLE sch.T_SNW_S10_PRODUCT_DIM (
	PRODUCT_CD VARCHAR(15),
	PRODUCT_NAME VARCHAR(70),
	STOCK_QTY NUMBER(38,0),
	BUYING_PRICE NUMBER(10,2),
	MSRP NUMBER(10,2),
    Product_Key VARCHAR(40),
    ACTV_IND_FLG VARCHAR(15),
    EFFCT_STRT_DT Date,
    EFFCT_END_DT Date,
    RECORD_INS_DTTM VARCHAR(30)
);

select * from sch.t_snw_s10_products;
select * from sch.T_SNW_S10_PRODUCT_DIM;
--truncate table sch.T_SNW_S10_PRODUCT_DIM;

create or replace TABLE sch.T_SNW_PRODUCT_LOAD_Log (
    log_ins_dttm VARCHAR(50),
	log_description variant
);
select * from sch.T_SNW_PRODUCT_LOAD_Log;
--truncate table sch.T_SNW_PRODUCT_LOAD_Log;

Create Or Replace Procedure sp_snw_capture_log(P_FILTERS VARIANT) 
RETURNS String 
Language Javascript As $$
try {
var sqlCommand = "select substring(to_timestamp(current_timestamp()),0,30) as curr_time";
var createStmt = snowflake.createStatement({sqlText: sqlCommand});
var rsValue = createStmt.execute();
rsValue.next();
var curr_TS= rsValue.getColumnValue(1);

var query="INSERT INTO sch.T_SNW_PRODUCT_LOAD_Log (log_ins_dttm, log_description) select :1, parse_json(:2);"
var sql = snowflake.createStatement({
    sqlText: query
    , binds:[curr_TS, JSON.stringify(P_FILTERS)]
});
var resultSet = sql.execute();
return "Success";
}
catch(error) {
	return error;
}
$$;

--call sp_snw_capture_log(parse_json('{"Status":"Failed"}'));

/*CREATE Or Replace Function f_snw_call_capture_log(msg)
{
  var my_sql_command = "call captureLog('"+msg+"')";
  var statement1 = snowflake.createStatement( {sqlText: my_sql_command} );
  var result_set1 = statement1.execute();
}*/


Create Or Replace Procedure sp_load_T_SNW_S10_PRODUCT_DIM_INS()
Returns VARIANT
LANGUAGE JAVASCRIPT --EXECUTE AS CALLER
As $$

var execReport={ runStatus: "Succeeded",
                   statements: [] 
}
var sql_cmd  = 'Insert Into sch.T_SNW_S10_PRODUCT_DIM (PRODUCT_CD)'
    sql_cmd += ' select PRODUCT_CODE from sch.t_snw_s10_products;'
try {
    var sqlStmt = snowflake.createStatement({sqlText: sql_cmd});
    rs = sqlStmt.execute();
    execReport["statements"].push({ runStatus: "Succeeded",
              rowCount: sqlStmt.getRowCount(),
              numRowsAffected: sqlStmt.getNumRowsAffected(),
              numRowsDeleted: sqlStmt.getNumRowsDeleted(),
              numRowsInserted: sqlStmt.getNumRowsInserted(),
              numRowsUpdated: sqlStmt.getNumRowsUpdated(),
              queryId : sqlStmt.getQueryId(),
              sqlText: sqlStmt.getSqlText(),
              errorText: null
    }); 
}
catch (err) {
    var result = { Failedcode: err.code, State: err.state,
              Message: err.message, StackTraceTxt: err.stackTraceTxt
    };
    execReport["statements"].push({ runStatus: "Failed",
              rowCount: null,
              numRowsAffected: null,
              numRowsDeleted: null,
              numRowsInserted: null,
              numRowsUpdated: null,
              queryId : sqlStmt.getQueryId(),
              sqlText: sqlStmt.getSqlText(),
              errorText: result
    });
execReport["runStatus"] = "Failed";
};

var my_sql_command = "CALL sp_snw_capture_log(parse_json(:1))";
var statement1 = snowflake.createStatement({
          sqlText: my_sql_command,
          binds:[JSON.stringify(execReport)]
          });
var result_set1 = statement1.execute();

return execReport;
$$
;

call sp_load_T_SNW_S10_PRODUCT_DIM_INS();

Insert Into sch.T_SNW_S10_PRODUCT_DIM (PRODUCT_CD)
select PRODUCT_CODE from sch.t_snw_s10_products;

var query="INSERT INTO sch.T_SNW_PRODUCT_LOAD_Log (log_ins_dttm, log_description) select :1, parse_json(:2);"
var sql = snowflake.createStatement({
    sqlText: query
    , binds:['2023-03-07 17:20:20:879', JSON.stringify(execReport)]
});
var resultSet = sql.execute();

var my_sql_command = "CALL sp_snw_capture_log(parse_json(:1))";
var statement1 = snowflake.createStatement({
          sqlText: my_sql_command,
          binds:[JSON.stringify(execReport)]
          });
var result_set1 = statement1.execute();


Create Or Replace Procedure sp_load_T_SNW_S10_PRODUCT_DIM_UPSERT()
Returns VARIANT
LANGUAGE JAVASCRIPT --EXECUTE AS CALLER
As $$
    
var execReport = { runStatus: "Succeeded",
                   statements : [] 
}
var sql_cmd  = 'Merge Into sch.T_SNW_S10_PRODUCT_DIM Tgt Using ('
    sql_cmd += ' Select Src.Product_Code As JOIN_KEY, Src.* From sch.t_snw_s10_products Src'
    sql_cmd += ' Union ALL Select NULL, Src.* From sch.t_snw_s10_products Src'
	sql_cmd += ' Join sch.T_SNW_S10_PRODUCT_DIM Tgt ON Tgt.Product_CD = Src.Product_Code'
    sql_cmd += ' Where ((Tgt.Product_NAME <> Src.Product_NAME) AND'
    sql_cmd += ' ACTV_IND_FLG=\'Y\')) ds ON ds.JOIN_KEY = Tgt.Product_CD'
    sql_cmd += ' WHEN MATCHED AND (ds.Product_NAME <> Tgt.Product_NAME)'
    sql_cmd += ' AND ACTV_IND_FLG <> \'N\' THEN UPDATE SET'
    sql_cmd += ' ACTV_IND_FLG = \'N\', EFFCT_END_DT=to_date(sysdate())'
    sql_cmd += ' WHEN NOT MATCHED THEN INSERT (Product_CD, Product_Name, STOCK_QTY, BUYING_PRICE, MSRP,' 
    sql_cmd += ' Product_Key, ACTV_IND_FLG, EFFCT_STRT_DT, RECORD_INS_DTTM)'
    sql_cmd += ' Values (ds.Product_Code, ds.Product_Name, ds.STOCK_QUANTITY, ds.BUYING_PRICE, ds.MSRP,' 
    sql_cmd += ' UUID_STRING(), \'Y\', to_date(sysdate()), to_char(sysdate(),\'YYYY-MM-DD HH12:MI:SS AM\'));'
try {
    var sqlStmt = snowflake.createStatement({sqlText: sql_cmd});
    rs = sqlStmt.execute();
    execReport["statements"].push({ runStatus: "Succeeded",
               rowCount: sqlStmt.getRowCount(),
               numRowsAffected: sqlStmt.getNumRowsAffected(),
               numRowsDeleted: sqlStmt.getNumRowsDeleted(),
               numRowsInserted: sqlStmt.getNumRowsInserted(),
               numRowsUpdated: sqlStmt.getNumRowsUpdated(),
               queryId: sqlStmt.getQueryId(),
               sqlText: sqlStmt.getSqlText(),
               errorText: null });
}
catch (err) {
    var result = { Failedcode: err.code, State: err.state,
                  Message: err.message, StackTraceTxt: err.stackTraceTxt
};
    execReport["statements"].push({ runStatus: "Failed",
               rowCount: null,
               numRowsAffected: null,
               numRowsDeleted: null,
               numRowsInserted: null,
               numRowsUpdated: null,
               queryId: sqlStmt.getQueryId(),
               sqlText: sqlStmt.getSqlText(),
               errorText: result });
execReport["runStatus"] = "Failed";
};

var my_sql_command = "CALL sp_snw_capture_log(parse_json(:1))";
var statement1 = snowflake.createStatement({
          sqlText: my_sql_command,
          binds:[JSON.stringify(execReport)]
          });
var result_set1 = statement1.execute();

return execReport;
$$
;

call sp_load_T_SNW_S10_PRODUCT_DIM_UPSERT();

select * from sch.t_snw_s10_products;
select * from sch.T_SNW_S10_PRODUCT_DIM;
--truncate table sch.T_SNW_S10_PRODUCT_DIM;
--update sch.T_SNW_S10_PRODUCT_DIM set EFFCT_STRT_DT=to_date(sysdate())-1 where product_cd='S10-1678';
--update sch.t_snw_s10_products set product_name='1969 Harley Davidson Ultimate Choppers' where product_code='S10-1678';


select * from sch.T_SNW_PRODUCT_LOAD_Log;
--truncate table sch.T_SNW_PRODUCT_LOAD_Log;

select to_char(sysdate(),'YYYY-MM-DD HH12:MI:SS AM');
select length(UUID_STRING());

select log_ins_dttm, --substring(value:sqlText,0,15), 
case when substring(value:sqlText,0,15) like 'Insert%' then 'Insert' 
     when substring(value:sqlText,0,15) like 'Merge%' then 'Merge' 
     when substring(value:sqlText,0,15) like 'Update%' then 'Update'
     when substring(value:sqlText,0,15) like 'Delete%' then 'Delete'
else 'Misc.' end as operation_type, value:queryId::string as query_id,
log_description:runStatus::string as run_status, 
--nvl(value:errorText,'N/A') as error_details, 
value:numRowsAffected as rows_affected, value:numRowsDeleted as rows_deleted, 
value:numRowsInserted as rows_inserted, value:numRowsUpdated as rows_updated 
from sch.T_SNW_PRODUCT_LOAD_Log l, 
lateral flatten (input => log_description:statements)
where log_description:runStatus='Succeeded';


select log_ins_dttm, 
case when substring(value:sqlText,0,15) like 'Insert%' then 'Insert' 
     when substring(value:sqlText,0,15) like 'Merge%' then 'Merge' 
     when substring(value:sqlText,0,15) like 'Update%' then 'Update'
     when substring(value:sqlText,0,15) like 'Delete%' then 'Delete'
else 'Misc.' end as operation_type, value:queryId::string as query_id,
log_description:runStatus::string as run_status, --value:errorText.Failedcode,
value:errorText.Message::string as error_message, 
value:errorText.StackTraceTxt::string as error_information
--value:numRowsAffected, value:numRowsDeleted, value:numRowsInserted, value:numRowsUpdated, 
--value:queryId, value:sqlText, value:errorText, value:errorText.State
from sch.T_SNW_PRODUCT_LOAD_Log l, 
lateral flatten (input => log_description:statements)
--lateral flatten (input => log_description:statements.errorText)
where log_description:runStatus='Failed';
