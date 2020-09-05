select deptno,ename,sal,
row_number() over (partition by deptno order by sal asc) as sal_rn,
rank() over (partition by deptno order by sal asc) as sal_rank_on_dept,
dense_rank() over (partition by deptno order by sal asc) as sal_drank_on_dept,
dense_rank() over (order by sal asc) as overall_sal_drank
from emp;

/*Output*/
deptno  ename   sal   sal_rn  sal_rank_on_dept  sal_drank_on_dept overall_sal_drank
10      Miller  1300  1       1                 1                 8
10      Clark   2450  2       2                 2                 5
10      King    5000  3       3                 3                 1
20      Smith   800   1       1                 1                 12
20      Adams   1100  2       2                 2                 10
20      Jones   2975  3       3                 3                 3
20      Scott   3000  4       4                 4                 2
20      Ford    3000  5       4                 4                 2
30      James   950   1       1                 1                 11
30      Martin  1250  2       2                 2                 9
30      Ward    1250  3       2                 2                 9
30      Turner  1500  4       4                 3                 7
30      Allen   1600  5       5                 4                 6
30      Blake   2850  6       6                 5                 4


create table revenue (
customer_id varchar2(10),
product_id varchar2(10),
trans_amt number,
trans_date date,
region varchar2(10));

customer_id   product_id    trans_amt   trans_date    region
C01           P81           $20         09-FEB-20     EAST
C02           P82           $22         10-DEC-19     NORTH
C03           P80           $18.97      09-JUN-20     EAST
C01           P89           $2.89       23-FEB-20     SOUTH

/*Display Top 10 Customers Based On Trans Amount For Feb-2020*/

select customer_name, rnk from (
select c.customer_name, sum(trans_amt) as trans_amt,
dense_rank() over(order by sum(trans_amt) desc) rnk
from revenue r, customer c
where r.customer_id = c.customer_id and to_char(r.trans_date,'MON-YYYY') = 'FEB-2020'
group by c.customer_name
) where rnk <= 10 order by 2 asc;
