/*Only DBA can execute below commands or login user should has DBA privileges to run below quries.*/

CREATE USER PTUNING INDENTIFIED BY PTUNING;
GRANT DBA TO PTUNING;

/*Load Data Into Tables to see Explain Plan or the Query Execution Path*/

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
             
2. Access Method - 
Table Access Methods:
            Full Table Scan
            Table Access by ROW-ID 
Index Access Methods:
             Index Range Scan - Method for accessing multiple column values. 
            Index Unique Scan - Method for looking up a single key value via a Unique Index. Always returns a Single Value
            Index Full Scan
            Index Fast Full Scan 
            Index Skip Scan
        
Hash Access, Cluster Acess, Bit Map Index 
 
/*INSERT Types Followed by Oracle Optimizer*/
1.Conventional Insert 
     Explain Plan For INSERT INTO Employee Values(100,'Smith',78,'23-OCT-1989','California',7890);
2.Direct Path Insert - Fastest
     Explain Plan For INSERT /*+APPEND*/ INTO Employee Values(100,'Smith',78,'23-OCT-1989','California',7890);                            
                             
Oracle Hints: For improving performance using APPEND, PARALLEL, JOIN, INDEX, NO_INDEX..etc.

SELECT /*+ FIRST_ROWS(10) */ * FROM emp WHERE deptno = 10;
  - Only to display First 10 Rows from the Selected Table

SELECT /*+ ALL_ROWS */ * FROM emp WHERE deptno = 10;
  - Returns ALL Rows from the Selected Table
  
SELECT /*+ NO_INDEX(emp emp_dept_idx) */ * FROM emp, dept WHERE emp.deptno = dept.deptno;
  - Query won't use the mentioned Index duing execution. Basically used for Index Disabling approaches.

SELECT /*+ INDEX(e,emp_dept_idx) */ * FROM emp e WHERE e.deptno = 10; 
   - Query will use mentioned Index duing execution, if interested for a specefic Index to be used
     /*Don't Use schema name*/ --SELECT /*+ INDEX(scott.emp,emp_dept_idx) */ * FROM scott.emp; 
 
SELECT /*+ AND_EQUAL(e,emp_dept_idx) */ * FROM emp e; 
  - Query can be used Multiple Indexes

SELECT /*+ INDEX_JOIN(e,emp_dept_idx) */ e.empno,d.deptno FROM emp e, dept d where e.deptno=d.deptno; 
  - Query will be used based on Index Joins & Sorted

SELECT /*+ USE_CONCAT */ * FROM emp e WHERE e.sal > 1500 or e.sal < 2000; 

SELECT /*+ PARALLEL_INDEX(e,emp_dept_idx , 8) */ * FROM emp e; 
  - Query will be used for Parallel 8 Cores using the Indexes

SELECT /*+ LEADING (dept) */ * FROM emp, dept WHERE emp.deptno = dept.deptno;
  - Query will determine the Master & Detail Table. Based on Join Criteria will go for executions. Leading tells Master Table.

SELECT /*+ ORDERED (dept) */ * FROM emp, dept WHERE emp.deptno = dept.deptno;

SELECT /*+ PARALLEL(8) CACHE (e) FULL (e) */  * FROM emp e ;
  - Query for Full execution from recent History

SELECT /*+  PARALLEL FULL (e) */  * FROM emp e ;
  - Query for Multiple Hints via Full

SELECT /*+ PARALLEL USE_MERGE (emp dept) */ * FROM emp, dept WHERE emp.deptno = dept.deptno;
-- SORT Merge Join

SELECT /*+ PARALLEL USE_HASH (emp dept) */ * FROM emp, dept WHERE emp.deptno = dept.deptno;
-- Hash  Join

SELECT /*+ PARALLEL  */  * FROM emp e ;

INSERT /*+ APPEND */ INTO mytmp select /*+ CACHE (e) */ *from emp e;
commit;
