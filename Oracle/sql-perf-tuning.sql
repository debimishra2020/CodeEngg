1. How do you update a table with a large number of updates, while maintaining the availability of the table for a large number of users?
2. How to optimize merge statement with millions of rows?

https://www.oratable.com/how-to-lock-a-row-in-oracle/
https://stackoverflow.com/questions/42697818/bulk-update-with-commit-in-oracle

--Oracle provides FOR UPDATE Clause in SELECT Query using Cursor to lock certain Records while DML operation so that other Users can not modify the same data
--Once you open the cursor, Oracle will lock all rows selected by the SELECT ... FOR UPDATE statement in the tables specified in the FROM clause. 
--And these rows will remain locked until the cursor is closed or the transaction is completed with either COMMIT or ROLLBACK.
--Since Oracle locks all rows returned by the SELECT ... FOR UPDATE during the update, therefore, better to use WHERE clause to use only necessary rows.

5. In this case, Oracle only locks rows of the table that has the column name listed in the FOR UPDATE OF clause.
Note that if you use only FOR UPDATE clause and do not include one or more column after the OF keyword, 
Oracle will then lock all selected rows across all tables listed in the FROM clause.
6. If you plan on updating or deleting records that have been referenced by a SELECT FOR UPDATE statement, you can use the WHERE CURRENT OF statement.
The WHERE CURRENT OF statement allows you to update or delete the record that was last fetched by the cursor.
7. In this example we select a student row and nowait up to 15 seconds for another session to release their lock:
select
   student_last_name
from
   student
where
   student_id = 12345
FOR UPDATE nowait 15;
8. In this example we use "for update nowait" and Oracle will immediately fail the transactions if it is waiting on any shared resources (locks or latches):
select
   student_last_name
from
   student
where
   student_id = 12345
FOR UPDATE nowait;
9. In Oracle, FOR UPDATE SKIP LOCKED clause is usually used to select and process tasks from a queue by multiple concurrent sessions. 
It allows a session to query the queue table, skip rows currently locked by other sessions, select the next unlocked row, and lock it for processing.
10. Starting in 11g, using select for update with the skip locked directive will tell the update to skip-over any rows that are already locked. 
This is useful in high DML environments because it removes the locking and concurrency issues, but data cohesion will become an issue.
For example, assume that a select for update requests 1,000 rows and 200 are already locked by other transactions that are updating the credit column:
select
   cust_status
from
   customer
where
   credit='GOOD'
for update skipped locked;
As we see, those 200 rows that were being updated may have experienced a change to credit='BAD', making our update invalid, and 
causing logical data corruption.
11. If your query references a single table then there is no difference between FOR UPDATE and FOR UPDATE OF ..., 
but the latter may still be useful as self-documentation to indicate which columns you intend to update. It doesn''t restrict what you can update though. 
If you have:
CURSOR cur IS SELECT * FROM emp FOR UPDATE OF sal;
Then you can still do:
UPDATE emp SET comm = comm * 1.1 WHERE CURRENT OF cur;
But if there is more than one table then FOR UPDATE OF ... will only lock the rows in the tables that contain the columns you specify in the OF clause.
Contrary to what I think you''re saying in the question. specifying FOR UPDATE OF sal does not only lock the sal column; 
you can never lock a single column, the minimum lock is at row level. (Read more about locks). It locks all rows in the table that contains the SAL column, 
which are selected by the query.
---------------------------------------------------------------------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON;
declare 
cursor c_1 is 
select employee_id, salary from employees 
where commission_pct is null 
for update of commission_pct;

var_comm number(8,2);
rec_count number:=0;
begin
for r_1 in c_1 loop
if r_1.salary < 10000 then var_comm := 0.5;
elsif r_1.salary < 15000 then var_comm := 0.1;
else var_comm := 0.95;
end if;

update employees set commission_pct = var_comm where current of c_1;
rec_count := rec_count+1;
end loop;
--rec_count := SQL%rowcount;
DBMS_OUTPUT.PUT_LINE('Records are Updated - ' || to_char(nvl(rec_count,0)));
commit;
DBMS_OUTPUT.PUT_LINE('Data Commited');
end;
/


 
--Bulk update with commit in oracle

DECLARE
       c_limit PLS_INTEGER := 100;

       CURSOR employees_cur
       IS
          SELECT employee_id
            FROM employees
           WHERE department_id = department_id_in;

       TYPE employee_ids_t IS TABLE OF  employees.employee_id%TYPE;

       l_employee_ids   employee_ids_t;
    BEGIN
       OPEN employees_cur;

       LOOP
          FETCH employees_cur
          BULK COLLECT INTO l_employee_ids
          LIMIT c_limit;      -- This will make sure that every iteration has 100 records selected

          EXIT WHEN l_employee_ids.COUNT = 0;           

        FORALL indx IN 1 .. l_employee_ids.COUNT SAVE EXCEPTIONS
          UPDATE employees emp  -- Updating 100 records at 1 go.
             SET emp.salary =
                    emp.salary + emp.salary * increase_pct_in
           WHERE emp.employee_id = l_employee_ids(indx);
      commit;    
      END LOOP;

    EXCEPTION
       WHEN OTHERS
       THEN
          IF SQLCODE = -24381
          THEN
             FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
             LOOP
                 -- Caputring errors occured during update
                DBMS_OUTPUT.put_line (
                      SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX
                   || ‘: ‘
                   || SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);

                 --<You can inset the error records to a table here>


             END LOOP;
          ELSE
             RAISE;
          END IF;
    END;
