/*Only DBA can execute below commands or login user should has DBA privileges to run below quries.*/

CREATE USER PTUNING INDENTIFIED BY PTUNING;
GRANT DBA TO PTUNING;

/*Load Data Into Tables*/

SET AUTOTRACE ON EXPLAIN STATISTICS;
SET AUTOTRACE TRACE ONLY;
DESCRIBE PLAN_TABLE;
EXPLAIN PLAN FOR SELECT * FROM ....;
SELECT * FROM PLAN_TABLE;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

                                    

/*Information From Explain Plan*/
1. Join Method For the Table
2. Access Method For the Table
3. Data Operations(Filter, Sort, ..)
                                    
1. Join Method - 
Nested Loop: There are two tables a driving table and a secondary table.  The rows are accessed from driving table, and are compared againest each records from secondary table.
Hash Join:  Here Oracle does a full-scan of the driving table, builds a RAM hash table.  The hash join will execute faster than nested loop, this join uses more RAM resources.  
Sort Merge Join: Performes first Sort Operation then Merge.

2. Access Method - Full Table Scan 
                                    
                                    
INSERT Types 
Conventional Insert 
     Explain Plan For INSERT INTO Employee Values(100,'Smith',78,'23-OCT-1989','California',7890);
Direct Path Insert 
     Explain Plan For INSERT /*+APPEND*/ INTO Employee Values(100,'Smith',78,'23-OCT-1989','California',7890);                            
                             
