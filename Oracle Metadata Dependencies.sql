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



----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------Rough Work Testing Queries----------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
SELECT  *
--owner,column_name,data_type
FROM    all_tab_columns
WHERE   table_name = 'IQP_GEOGRAPHY_DIM'
Order by column_id
;

Select * From ALL_Tables Where TABLE_NAME = 'IQP_GEOGRAPHY_DIM';

--Finding Table Size
select segment_name,segment_type,(bytes/1024/1024) MB
from dba_segments
where segment_name='IQP_GEOGRAPHY_DIM';

SELECT DS.TABLESPACE_NAME, SEGMENT_NAME, ROUND(SUM(DS.BYTES) / (1024 * 1024)) AS MB FROM DBA_SEGMENTS DS
WHERE SEGMENT_NAME ='IQP_GEOGRAPHY_DIM' GROUP BY DS.TABLESPACE_NAME, SEGMENT_NAME;

select bytes/1024/1024 MB from user_segments where segment_name='IQP_GEOGRAPHY_DIM';



set serveroutput on;

DECLARE
   CURSOR c1 IS SELECT column_name,data_type FROM all_tab_columns WHERE table_name = 'IQP_GEOGRAPHY_DIM' Order by column_id ;
   i NUMBER:= 0;
BEGIN
--dbms_output.put_line(i);
--dbms_output.put_line('Dummy');
  FOR e_rec IN c1 LOOP
  i:= i+1;
    --dbms_output.put_line(i);
    --dbms_output.put_line(i||chr(9)||e_rec.column_name||'::'||e_rec.data_type);
    dbms_output.put_line('Col-'||i||' '||e_rec.column_name||'::'||e_rec.data_type);
  END LOOP;
END;
/


SELECT *
FROM all_cons_columns
WHERE table_name = 'IQP_GEOGRAPHY_DIM'
;

Select * from ALL_TAB_COLUMNS
WHERE TABLE_NAME = 'IQP_GEOGRAPHY_DIM'
;


select *
--owner,constraint_name,constraint_type,table_name,r_owner,r_constraint_name
from all_constraints 
where table_name='IQP_GEOGRAPHY_DIM'
;

SELECT * FROM all_indexes --,all_constraints
WHERE all_indexes.table_name='IQP_GEOGRAPHY_DIM' --AND all_indexes.INDEX_NAME = all_constraints.INDEX_NAME
;

SELECT * FROM all_ind_columns WHERE table_name='IQP_ORDER_BOOKING_FACT';


--U P C O 
Select *
From all_constraints ac
WHERE --ac.table_name = 'IQP_HR_ALL_ORG_UNITS_STG' AND
constraint_type = 'O'
;

Select 
ac.constraint_name, 
--ac.constraint_type, 
DECODE(ac.constraint_type, 'C' , 'CHECK/NOT NULL', 
                           'P' , 'PRIMARY KEY' , 
                           'U', 'UNIQUE' ,
                           'R', 'Referential Integrity', 
                           'O', 'With read only, on a view', 
                           'V', 'With check option, on a view', 
                           'F' , 'Constraint that involves a REF column' ) constraint_type,
acc.column_name,
ac.search_condition
From all_constraints ac
INNER JOIN all_cons_columns acc ON acc.constraint_name = ac.constraint_name
WHERE ac.table_name = 'IQP_GEOGRAPHY_DIM'
;

Select * 
From ALL_INDEXES
Where TABLE_NAME = 'IQP_ORDER_BOOKING_FACT'
;

SELECT all_tables.table_name, all_indexes.index_name
FROM all_tables JOIN all_indexes on all_indexes.table_name = all_tables.table_name
Where all_tables.table_name = 'IQP_ORDER_BOOKING_FACT'
--ORDER by user_tables.table_name,user_indexes.index_name
;

Select * From all_ind_columns where table_name = 'IQP_ORDER_BOOKING_FACT';

SELECT --all_tables.table_name, 
all_ind_columns.column_name,
all_indexes.index_name
--all_indexes.uniqueness ,
FROM all_tables JOIN all_indexes on all_indexes.table_name = all_tables.table_name
JOIN all_ind_columns ON all_indexes.index_name = all_ind_columns.index_name
Where all_tables.table_name = 'IQP_ORDER_BOOKING_FACT'
Order By all_ind_columns.column_name
;

select * from all_IND_EXPRESSIONS where table_name = 'IQP_ORDER_BOOKING_FACT';

select i.index_name, i.uniqueness, c.column_name, f.column_expression
from all_ind_columns c, all_indexes i, all_IND_EXPRESSIONS f
where i.table_owner = 'IQP'
and i.table_name = 'IQP_GEOGRAPHY_DIM'
and i.index_name = c.index_name
and i.owner = c.indeX_owner
and c.index_owner = f.index_owner(+)
and c.index_name = f.index_name(+)
and c.table_owner = f.table_owner(+)
and c.table_name = f.table_name(+)
and c.column_position = f.column_position(+)
order by i.index_name, c.column_position
;

select * from ALL_TAB_STATISTICS WHERE table_name = 'IQP_ORDER_BOOKING_FACT';
select * from ALL_TAB_COL_STATISTICS WHERE table_name = 'IQP_ORDER_BOOKING_FACT';

--DBA_TABLES
select * from DBA_TAB_STATISTICS where table_name = 'IQP_ORDER_BOOKING_FACT';
select * from DBA_TAB_PARTITIONS where table_name = 'IQP_ORDER_BOOKING_FACT';
--DBA_TAB_SUB_PARTITIONS
--DBA_TAB_COLUMNS
select * from DBA_TAB_COL_STATISTICS where table_name = 'IQP_ORDER_BOOKING_FACT';


--------------------------------------------------------------------------------------------------------------------
select referenced_name Base_Table, referenced_type Of_Type, owner,
name Linked_Object_Name , type Linked_Object_Type
from all_dependencies
where --owner = 'IQP' AND
referenced_name = 'IQP_ORDER_BOOKING_FACT'
;

select * from user_cons_columns where table_name = 'IQP_GEOGRAPHY_DIM';
select * from user_constraints where table_name = 'IQP_ORDER_BOOKING_FACT';

select GRANTOR, grantee, select_priv,insert_priv, update_priv, delete_priv, alter_priv
from TABLE_PRIVILEGES where table_name = 'IQP_GEOGRAPHY_DIM'
;

select dbms_metadata.get_ddl('TABLE','IQP_GEOGRAPHY_DIM') from dual;


SELECT * FROM all_indexes WHERE table_name = 'IQP_GEOGRAPHY_DIM';

SELECT all_ind_columns.column_name, all_indexes.index_name
                          FROM all_tables JOIN all_indexes on all_indexes.table_name = all_tables.table_name
                          JOIN all_ind_columns ON all_indexes.index_name = all_ind_columns.index_name
                          Where all_tables.table_name = 'IQP_GEOGRAPHY_DIM'
                          Order By all_ind_columns.column_name ;



DECLARE      
nCnt_Table_1 NUMBER := 1;
BEGIN 
  SELECT COUNT(*) Into nCnt_Table_1 FROM ALL_TABLES WHERE TABLE_NAME = 'TABLE_1'; 
IF nCnt_Table_1 = 0 THEN
     EXECUTE IMMEDIATE 'CREATE TABLE TABLE_1 (TABLE_NAME VARCHAR2(30),OWNER VARCHAR2(30),TABLESPACE VARCHAR2(30),TOT_ROWS NUMBER,ANALYZED_DATE DATE,USER_STAT VARCHAR2(2),TOT_SIZE NUMBER(10,4))';
  ELSE 
     BEGIN 
          EXECUTE IMMEDIATE 'TRUNCATE TABLE TABLE_1';
          INSERT INTO TABLE_1 VALUES ('A','A','A',2,SYSDATE,'A',1.8);  
     END;
  END IF;  
END;
/

SELECT * FROM TABLE_1;

SELECT COUNT(*) FROM ALL_TABLES WHERE TABLE_NAME = 'TABLE_1';

DROP TABLE TABLE_1;