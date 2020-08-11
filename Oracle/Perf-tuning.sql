/*Only DBA can execute below commands or login user should has DBA privileges to run below quries.*/

CREATE USER PTUNING INDENTIFIED BY PTUNING;
GRANT DBA TO PTUNING;

/*Load Data Into Tables*/

SET AUTOTRACE ON EXPLAIN STATISTICS;
SET AUTOTRACE TRACE ONLY;
DESCRIBE PLAN_TABLE;
EXPLAIN PLAN FOR SELECT * FROM EMPLOYEES;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY()); OR SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
SELECT * FROM PLAN_TABLE WHERE PLAN_ID = <>;


                                    

/*Information From Explain Plan Followed by Oracle Optimizer*/
1. Join Method For the Table
2. Access Method For the Table
3. Data Operations(Filter, Sort, Aggregation, Count..)
                                    
1. Join Method - 
Nested Loop: Every rows from Inner Table are accessed, and are getting compared with each records from Outer Table.
             Condition: Select Query having muttiple Tables & Joins, Index shoud have on the Table.
Hash Join: Oracle does a full-scan of the table, builds a RAM hash table. The hash join will execute faster than nested loop, this join uses more RAM resources.
             Condition: Select Query having Equality operator & No Index(s), should go for Full Table Access.
Sort Merge Join: Performes first Sort Operation then Merge.
             Condition: Select Query having muttiple Tables and Join performed by ">" or "<" Operators not "=". When In-equality operations Optimizer goes for this approach.
             
2. Access Method - Full Table Scan, Table Access by ROW-ID, Index Unique Scan, Index Range Scan, Index Skip Scan, Full Index Scan, Fast Full Index Scans, Index Joins,
   Hash Access, Cluster Acess, Bit Map Index 
 
 
INSERT Types Followed by Oracle Optimizer
1.Conventional Insert 
     Explain Plan For INSERT INTO Employee Values(100,'Smith',78,'23-OCT-1989','California',7890);
2.Direct Path Insert - Fastest
     Explain Plan For INSERT /*+APPEND*/ INTO Employee Values(100,'Smith',78,'23-OCT-1989','California',7890);                            
                             
