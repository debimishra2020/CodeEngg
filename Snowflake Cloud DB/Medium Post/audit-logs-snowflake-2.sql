--Procedure 01
Call snflk_demo.snflk_sch.sp_tbl_Load_EMP_Merge();

CREATE OR REPLACE PROCEDURE snflk_demo.snflk_sch.sp_tbl_Load_EMP_Merge()
    Returns string
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER
    As $$
var result = "";
var sql_cmd  = 'Merge Into snflk_demo.snflk_sch.tbl_LOAD_EMP Tgt Using ('
    sql_cmd += ' Select Src.EMP_ID As JOIN_KEY, Src.* From snflk_demo.snflk_sch.tbl_EMP_RAW Src Union ALL'
	sql_cmd += ' Select NULL, Src.* From snflk_demo.snflk_sch.tbl_EMP_RAW Src'
	sql_cmd += ' Join snflk_demo.snflk_sch.tbl_LOAD_EMP Tgt ON Tgt.EMP_ID = Src.EMP_ID'
    sql_cmd += ' Where ((Tgt.EMP_NAME <> Src.EMP_NAME) AND'
    sql_cmd += ' ACTIVE_IND=\'Y\')) DataSet ON DataSet.JOIN_KEY = Tgt.EMP_ID'
    sql_cmd += ' WHEN MATCHED AND (DataSet.EMP_NAME <> Tgt.EMP_NAME)'
    sql_cmd += ' AND ACTIVE_IND <> \'N\' THEN UPDATE SET'
    sql_cmd += ' ACTIVE_IND = \'N\' WHEN NOT MATCHED THEN INSERT (EMP_ID, EMP_NAME, ACTIVE_IND)'
    sql_cmd += ' Values (DATASET.EMP_ID, DATASET.EMP_NAME, \'Y\');'
try {
    var sqlStmt = snowflake.createStatement({sqlText: sql_cmd});
    rs = sqlStmt.execute();
    sql_cmd = `SELECT "number of rows inserted", "number of rows updated"
        FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))`;
    sqlStmt = snowflake.createStatement( {sqlText: sql_cmd} );
    rs = sqlStmt.execute();
    rs.next();
    result += "Rows inserted: " + rs.getColumnValue(1) + ", Rows updated: " + rs.getColumnValue(2)
  }
catch (err) {
    result =  "Failed: Code: " + err.code + "\n  State: " + err.state;
    result += "\n  Message: " + err.message;
    result += "\nStack Trace:\n" + err.stackTraceTxt;
    }
return result;
    $$
;
--End Of Procedure 01

--Procedure 02
CALL snflk_demo.snflk_sch.sp_Demo();

CREATE OR REPLACE PROCEDURE snflk_demo.snflk_sch.sp_Demo()
    Returns VARIANT
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER
    As $$
var execReport = { runStatus: "Succeeded",
                   statements : [] 
}
var sql_cmd  = 'Merge Into snflk_demo.snflk_sch.tbl_LOAD_EMP Tgt Using ('
    sql_cmd += ' Select Src.EMP_ID As JOIN_KEY, Src.* From snflk_demo.snflk_sch.tbl_EMP_RAW Src'
    sql_cmd += ' Union ALL'
	sql_cmd += ' Select NULL, Src.* From snflk_demo.snflk_sch.tbl_EMP_RAW Src'
	sql_cmd += ' Join snflk_demo.snflk_sch.tbl_LOAD_EMP Tgt ON Tgt.EMP_ID = Src.EMP_ID'
    sql_cmd += ' Where ((Tgt.EMP_NAME <> Src.EMP_NAME) AND'
    sql_cmd += ' ACTIVE_IND=\'Y\')) DataSet ON DataSet.JOIN_KEY = Tgt.EMP_ID'
    sql_cmd += ' WHEN MATCHED AND (DataSet.EMP_NAME <> Tgt.EMP_NAME)'
    sql_cmd += ' AND ACTIVE_IND <> \'N\' THEN UPDATE SET'
    sql_cmd += ' ACTIVE_IND = \'N\' WHEN NOT MATCHED THEN INSERT (EMP_ID, EMP_NAME, ACTIVE_IND)'
    sql_cmd += ' Values (DATASET.EMP_ID, DATASET.EMP_NAME, \'Y\');'
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
                                    errorText: null });
}
catch (err) {
    var result = { Failedcode : err.code, State : err.state,
                  Message : err.message, StackTraceTxt : err.stackTraceTxt
};
    execReport["statements"].push({ runStatus: "Failed",
                                    rowCount: null,
                                    numRowsAffected: null,
                                    numRowsDeleted: null,
                                    numRowsInserted: null,
                                    numRowsUpdated: null,
                                    queryId : sqlStmt.getQueryId(),
                                    sqlText: sqlStmt.getSqlText(),
                                    errorText: result });
    execReport["runStatus"] = "Failed";
};
    return execReport;
    $$
;
--End Of Procedure 02

--Procedure 03
CALL snflk_demo.snflk_sch.sp_Demo_INS();

CREATE OR REPLACE PROCEDURE snflk_demo.snflk_sch.sp_Demo_INS()
    Returns VARIANT
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER
    As $$
var execReport = { runStatus: "Succeeded",
                   statements : [] 
}
var sql_cmd  = 'Insert Into snflk_demo.snflk_sch.tbl_EMP_RAW'
    sql_cmd += ' Values(\'EM20\',\'Robert W\');'
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
    var result = { Failedcode : err.code, State : err.state,
                  Message : err.message, StackTraceTxt : err.stackTraceTxt
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
    return execReport;
    $$
;
--End Of Procedure 03

--Could also create a wrapper stored procedure
CREATE OR REPLACE PROCEDURE EXEC_SQL_SCRIPT (SQL_SCRIPT VARCHAR, STATEMENT_SEPARATOR VARCHAR) 
RETURNS VARIANT
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
var execReport = { status: "Succeeded",
                   statements : [] 
}

var stmtSep = ";"
if (STATEMENT_SEPARATOR != null) {
    stmtSep = STATEMENT_SEPARATOR;
}

var stmts = SQL_SCRIPT.split(stmtSep);

for (var i = 0; i < stmts.length; i++) {
    var stmtText = stmts[i].trim();
    
    if (stmtText.length > 0) {
        try {
            var stmt = snowflake.createStatement( { sqlText : stmtText } );
            var rs = stmt.execute();

            execReport["statements"].push({ statement_no: i + 1, 
                                            status: "Succeeded",
                                            rowCount: stmt.getRowCount(),
                                            numRowsAffected: stmt.getNumRowsAffected(),
                                            numRowsDeleted: stmt.getNumRowsDeleted(),
                                            numRowsInserted: stmt.getNumRowsInserted(),
                                            numRowsUpdated: stmt.getNumRowsUpdated(),
                                            queryId : stmt.getQueryId(),
                                            sqlText: stmt.getSqlText(),
                                            error: null
                                        });
        } catch (err)  {
            var error = { code : err.code,
                          state : err.state,
                          message : err.message,
                          stackTraceTxt : err.stackTraceTxt
            };

            execReport["statements"].push({ statement_no: i + 1, 
                                            status: "Failed",
                                            rowCount: null,
                                            numRowsAffected: null,
                                            numRowsDeleted: null,
                                            numRowsInserted: null,
                                            numRowsUpdated: null,
                                            queryId : stmt.getQueryId(),
                                            sqlText: stmt.getSqlText(),
                                            error: error
                                        });

            execReport["status"] = "Failed";
            return execReport;  
        } 
    }
}
return execReport;
$$
;

