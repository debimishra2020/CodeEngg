select deptno, ename, sal,
sum(sal) over (partition by deptno order by sal,ename asc) cum_dept_total,
sum(sal) over (partition by deptno order by deptno asc) dept_total,
sum(sal) over (order by deptno,sal asc) cum_total,
sum(sal) over () total_sal
from emp order by deptno,sal;

deptno  ename   sal   cum_dept_total    dept_total    cum_total   total_sal
10      Miller  1300  1300              8750          1300        29025
10      Clark   2450  3750              8750          3750        29025
10      King    5000  8750              8750          8750        29025
20      Smith   800   800               10875         9550        29025      
20      Adams   1100  1900              10875         10650       29025
20      Jones   2975  4875              10875         13625       29025
20      Ford    3000  7875              10875         19625       29025
20      Scott   3000  10875             10875         19625       29025
30      James   950   950               9400          20575       29025
30      Martin  1250  2200              9400          23075       29025
30      Ward    1250  3450              9400          23075       29025
30      Turner  1500  4950              9400          24575       29025
30      Allen   1600  6550              9400          26175       29025
30      Blake   2850  9400              9400          29025       29025


/*Write a query to get cummulative shipped quantity months to date*/   
ship_day      qty
01/01/2020    10
01/02/2020    12
01/03/2020    15  
02/01/2020    11
02/02/2020    12
02/03/2020    13
                                                          
/*Output*/
ship_day     qty   cumm_tot_qty
01/01/2020   10    10
01/02/2020   12    22
01/03/2020   15    37  
02/01/2020   11    11
02/02/2020   12    23
02/03/2020   13    36   

SELECT ship_day, QTY,
SUM(QTY) OVER (PARTITION BY TO_CHAR(ship_day,'MON') ORDER BY ship_day ASC) cumm_tot_qty
FROM PRTY_MASTER ORDER BY ship_day ASC;  
