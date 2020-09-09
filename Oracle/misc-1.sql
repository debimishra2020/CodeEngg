/*How to write sql query for the below scenario: Input - DEBI*/
O/p:
D
E
B
I
Select Substr(‘ORACLE’,Level,1) From Dual Connect By Level<= Length(‘ORACLE’);

/*How to display 1 to 100 Numbers with query*/
select level from dual connect by level <=100;

/*Display first 50% records from Employee table*/
select rownum, e.* from emp e where rownum<=(select count(*)/2 from emp);

/*Display last 50% records from Employee table*/
Select rownum,E.* from Employee E minus
Select rownum,E.* from Employee E where rownum<=(Select count(*)/2) from Employee);
