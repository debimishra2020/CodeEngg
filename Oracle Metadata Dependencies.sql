SET SERVEROUTPUT ON ;

DECLARE
   nCnt_Table_1 NUMBER := 0;
   

   nTotalRows NUMBER := 0; 
   nTableSize NUMBER(10,4) :=1.0;
   
   nColumnCount NUMBER := 0;
   nCol NUMBER:= 0;
   nCol_Cons NUMBER:= 0;
   nCol_Idx NUMBER:= 0;
   nCol_DepObj NUMBER := 0;
   nCol_Privlg NUMBER := 0;
   nErrorCode NUMBER:= 0;
   
   varTableName Varchar2(100) := 'IQP_ORDER_BOOKING_FACT';  --IQP_ORDER_BOOKING_FACT --IQP_IDS_ORDERS_FACT
   varTablespace Varchar2(100) := 'Dummy';
   varTableOwner Varchar2(100) := 'Dummy';
   varTableAnalyzed Varchar2(100) := 'Dummy';
   varTableStat Varchar2(100) := 'Dummy';
   varErrorMsg VARCHAR2(32000):= 'Error';
   
   CURSOR crsFetch IS SELECT column_name,data_type FROM all_tab_columns WHERE table_name = varTableName Order by column_id ;
   
   CURSOR crsFetch_01 IS Select ac.constraint_name, 
                                DECODE(ac.constraint_type, 'C' , 'CHECK/NOT NULL', 
                                                            'P', 'PRIMARY KEY' , 
                                                            'U', 'UNIQUE' ,
                                                            'R', 'Referential Integrity', 
                                                            'O', 'With read only, on a view', 
                                                            'V', 'With check option, on a view', 
                                                            'F','Constraint that involves a REF column' ) constraint_type,
                                acc.column_name,
                                ac.search_condition
                                From all_constraints ac
                                INNER JOIN all_cons_columns acc ON acc.constraint_name = ac.constraint_name
                                WHERE ac.table_name = varTableName ;
   
   CURSOR crsFetch_02 IS SELECT all_ind_columns.column_name, all_indexes.index_name
                          FROM all_tables JOIN all_indexes on all_indexes.table_name = all_tables.table_name
                          JOIN all_ind_columns ON all_indexes.index_name = all_ind_columns.index_name
                          Where all_tables.table_name = varTableName
                          Order By all_ind_columns.column_name ;
                          
   CURSOR crsFetch_03 IS SELECT REFERENCED_NAME BASE_TABLE, REFERENCED_TYPE OF_TYPE, NAME LINKED_OBJECT_NAME , TYPE LINKED_OBJECT_TYPE
                                FROM ALL_DEPENDENCIES WHERE --OWNER = 'IQP'
                                REFERENCED_NAME = varTableName ;                  
    
   CURSOR crsFetch_04 IS SELECT GRANTOR, GRANTEE, SELECT_PRIV,INSERT_PRIV, UPDATE_PRIV, DELETE_PRIV, ALTER_PRIV
                                FROM TABLE_PRIVILEGES WHERE table_name = varTableName ;
   
   
BEGIN
  DBMS_OUTPUT.PUT_LINE('-----------Master Information-----------');
  --Display Table Name
  DBMS_OUTPUT.PUT_LINE('Table Name :' || varTableName);
   
  --Display Table Owner
  Select OWNER,TABLESPACE_NAME,NUM_ROWS,LAST_ANALYZED,USER_STATS 
         Into varTableOwner,varTablespace,nTotalRows,varTableAnalyzed,varTableStat 
  From ALL_Tables Where TABLE_NAME = UPPER(varTableName);
  
  DBMS_OUTPUT.PUT_LINE('Table Owner Name :' || varTableOwner);
  DBMS_OUTPUT.PUT_LINE('Tablespace Name :' || varTablespace);
  DBMS_OUTPUT.PUT_LINE('Total Number Of Rows :' || nTotalRows);
  DBMS_OUTPUT.PUT_LINE('Last Analyzed Date :' || varTableAnalyzed);
  DBMS_OUTPUT.PUT_LINE('User Statistic (Y/N):' || varTableStat);
  
  Select (Bytes/1024/1024) Into nTableSize From DBA_SEGMENTS Where Segment_Name = UPPER(varTableName);
  DBMS_OUTPUT.PUT_LINE('Total Table Size :' || nTableSize || ' MB');
  DBMS_OUTPUT.PUT_LINE(' ');
  
  --##DROP TABLE TABLE_1;
  SELECT COUNT(*) Into nCnt_Table_1 FROM ALL_TABLES WHERE TABLE_NAME = 'TABLE_1'; 

  IF nCnt_Table_1 = 0 THEN
     EXECUTE IMMEDIATE 'CREATE TABLE TABLE_1 (TABLE_NAME VARCHAR2(30),OWNER VARCHAR2(30),TABLESPACE VARCHAR2(30),
                                              TOT_ROWS NUMBER,ANALYZED_DATE DATE,USER_STAT VARCHAR2(2),TOT_SIZE NUMBER(10,4))';
  ELSE 
     EXECUTE IMMEDIATE 'TRUNCATE TABLE TABLE_1';
  END IF;
  
  INSERT INTO TABLE_1 VALUES (varTableName,varTableOwner,varTablespace,nTotalRows,varTableAnalyzed,varTableStat,nTableSize);  
  
  DBMS_OUTPUT.PUT_LINE('---------------Column Details---------------');
  --Find Column Count
  SELECT  Count(*) Into nColumnCount
  FROM    all_tab_columns 
  WHERE   table_name = varTableName
  Order by column_id ;
  DBMS_OUTPUT.PUT_LINE('Total Columns Count :' || To_Char(nColumnCount));
  DBMS_OUTPUT.PUT_LINE(' ');
  
  --Display Column Name
  FOR crsFetch_Rec IN crsFetch LOOP
    nCol:= nCol+1;
    DBMS_OUTPUT.PUT_LINE('Col-'||nCol||' '||crsFetch_Rec.column_name||'::'||crsFetch_Rec.data_type);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ');
  
  
  --Display All Constraint Name
  DBMS_OUTPUT.PUT_LINE('---------------Constraint Details---------------');
  For crsFetch_Rec_01 IN crsFetch_01 LOOP
    nCol_Cons:= nCol_Cons+1;
    DBMS_OUTPUT.PUT_LINE('SlNo-'||nCol_Cons||' '||crsFetch_Rec_01.constraint_name||'::'||crsFetch_Rec_01.constraint_type||'::'
                                                ||crsFetch_Rec_01.column_name||'::'
                                                ||NVL(crsFetch_Rec_01.search_condition,'No Search Condition')
                        );
  END LOOP;  
  DBMS_OUTPUT.PUT_LINE(' ');
  
  
  --Display All Indexes With Column Names
  DBMS_OUTPUT.PUT_LINE('-----------------Index Details-----------------');
  For crsFetch_Rec_02 IN crsFetch_02 LOOP
    nCol_Idx:= nCol_Idx+1;
    DBMS_OUTPUT.PUT_LINE('SlNo-'||nCol_Idx||' '||crsFetch_Rec_02.column_name||'::'||crsFetch_Rec_02.index_name);
  END LOOP;  
  DBMS_OUTPUT.PUT_LINE(' ');
  
  
    --Display All Associated Objects
  DBMS_OUTPUT.PUT_LINE('-----------------Associated Objects-----------------');
  For crsFetch_Rec_03 IN crsFetch_03 LOOP
    nCol_DepObj:= nCol_DepObj+1;
    DBMS_OUTPUT.PUT_LINE('SlNo-'||nCol_DepObj||' '||crsFetch_Rec_03.LINKED_OBJECT_NAME||'::'||crsFetch_Rec_03.LINKED_OBJECT_TYPE);
  END LOOP;  
  DBMS_OUTPUT.PUT_LINE(' ');
  
  
  --Display All PRIVILEGES On Objects
  DBMS_OUTPUT.PUT_LINE('-----------------All PRIVILEGES-----------------');
  DBMS_OUTPUT.PUT_LINE('SlNo::GRANTOR::GRANTEE::SELECT_PRIV::INSERT_PRIV::UPDATE_PRIV::DELETE_PRIV::ALTER_PRIV');
  For crsFetch_Rec_04 IN crsFetch_04 LOOP
    nCol_Privlg:= nCol_Privlg+1;
    DBMS_OUTPUT.PUT_LINE('SlNo-'||nCol_Privlg||' '||crsFetch_Rec_04.GRANTOR||'::'||crsFetch_Rec_04.GRANTEE||'::'
                         ||crsFetch_Rec_04.SELECT_PRIV||'::'||crsFetch_Rec_04.INSERT_PRIV||'::'
                         ||crsFetch_Rec_04.UPDATE_PRIV||'::'||crsFetch_Rec_04.DELETE_PRIV||'::'||crsFetch_Rec_04.ALTER_PRIV
                        );
  END LOOP;  
  DBMS_OUTPUT.PUT_LINE(' ');
  
  
EXCEPTION
   WHEN OTHERS THEN
         nErrorCode := SQLCODE;
         varErrorMsg := SQLERRM;
         DBMS_OUTPUT.PUT_LINE('Error code ' || nErrorCode || ': ' || varErrorMsg);
   --DBMS_OUTPUT.PUT_LINE ('ERROR OCCURED !!!');   
   --raise_application_error (-20002,'An error occurred');
END;
/