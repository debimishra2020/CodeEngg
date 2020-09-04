create table customer (
customer_id varchar2(10),
customer_name varchar2(10)
);

insert into customer values('ABC01','Smith');
insert into customer values('ABC02','Blake');
insert into customer values('ABC03','King');
insert into customer values('ABC04','Jones');
insert into customer values('ABC05','James');
insert into customer values('ABC06','Scott');
insert into customer values('ABC07','Turner');

commit;

select * from customer;

create table product (
product_id varchar2(10),
product_name varchar2(10)
);


insert into product values('P01','Security01');
insert into product values('P02','Security02');
insert into product values('P03','Security03');
insert into product values('P04','Security04');
insert into product values('P05','Security05');
insert into product values('P06','Security06');
insert into product values('P07','Security07');

commit;

select * from product;

create table revenue (
customer_id varchar2(10),
product_id varchar2(10),
trans_amt number,
trans_date date,
region varchar2(10)
);


insert into revenue values('ABC01','P01',2500,sysdate,'EAST');
insert into revenue values('ABC01','P02',3500,sysdate-10,'WEST');
insert into revenue values('ABC02','P03',4500,sysdate,'NORTH');
insert into revenue values('ABC04','P04',6500,sysdate-15,'SOUTH');
insert into revenue values('ABC05','P03',2300,sysdate-3,'NORTH');
insert into revenue values('ABC06','P04',5600,sysdate-20,'SOUTH');
insert into revenue values('ABC07','P01',4400,sysdate-13,'SOUTH');
insert into revenue values('ABC03','P02',2500,sysdate,'EAST');
insert into revenue values('ABC04','P03',3500,sysdate-12,'WEST');
insert into revenue values('ABC05','P03',4500,sysdate,'NORTH');
insert into revenue values('ABC06','P01',6500,sysdate-19,'SOUTH');
insert into revenue values('ABC07','P05',2300,sysdate-3,'NORTH');
insert into revenue values('ABC01','P06',5600,sysdate-22,'SOUTH');
insert into revenue values('ABC02','P07',4400,sysdate-18,'SOUTH');
insert into revenue values('ABC02','P01',6500,sysdate-23,'SOUTH');
insert into revenue values('ABC03','P01',2800,sysdate-34,'SOUTH');
insert into revenue values('ABC04','P01',3100,sysdate-45,'SOUTH');
insert into revenue values('ABC05','P01',4380,sysdate-32,'SOUTH');
insert into revenue values('ABC01','P01',2500,sysdate-65,'EAST');
insert into revenue values('ABC01','P02',3500,sysdate-70,'WEST');
insert into revenue values('ABC02','P03',4500,sysdate-75,'NORTH');
insert into revenue values('ABC04','P04',6500,sysdate-80,'SOUTH');
insert into revenue values('ABC05','P03',2300,sysdate-100,'NORTH');
insert into revenue values('ABC06','P04',5600,sysdate-120,'SOUTH');
insert into revenue values('ABC07','P01',4400,sysdate-130,'SOUTH');
insert into revenue values('ABC03','P02',2500,sysdate-133,'EAST');
insert into revenue values('ABC04','P03',3500,sysdate-124,'WEST');
insert into revenue values('ABC05','P03',4500,sysdate-137,'NORTH');
insert into revenue values('ABC06','P01',6500,sysdate-190,'SOUTH');
insert into revenue values('ABC07','P05',2300,sysdate-200,'NORTH');
insert into revenue values('ABC01','P06',5600,sysdate-226,'SOUTH');
insert into revenue values('ABC02','P07',4400,sysdate-178,'EAST');
insert into revenue values('ABC02','P01',6500,sysdate-230,'NORTH');
insert into revenue values('ABC03','P01',2800,sysdate-324,'EAST');
insert into revenue values('ABC04','P01',3100,sysdate-123,'SOUTH');
insert into revenue values('ABC05','P01',4380,sysdate-111,'EAST');

commit;

select * from revenue;

/*Display Top 10 Customers Based On Trans Amount*/

select customer_name, rnk from (
select c.customer_name, sum(trans_amt),
dense_rank() over(order by sum(trans_amt) desc) rnk
from revenue r, customer c, product p
where r.customer_id = c.customer_id and r.product_id = p.product_id
and product_name = 'Security01'
and to_char(trans_date,'MON-YYYY') = 'FEB-2020'
group by c.customer_name
) where rnk <= 10 order by 2 asc;

/*Display Year over Year comparision FY 2020*/

EAST,2020,$200
EAST,2019,$198
.....
.....

WITH REV_2020 AS (
select REGION,SUM(TRANS_AMT) REV_2020_TRNS_AMT from revenue
WHERE to_char(trans_date,'YYYY') = '2020'
GROUP BY REGION
), REV_2019 AS (
select REGION,SUM(TRANS_AMT) REV_2019_TRNS_AMT from revenue
WHERE to_char(trans_date,'YYYY') = '2019'
GROUP BY REGION
)
SELECT REV_2020_TRNS_AMT,REV_2019_TRNS_AMT,REV_2020.REGION
ROUND(((REV_2020_TRNS_AMT-REV_2019_TRNS_AMT)/REV_2019_TRNS_AMT)*100,5) AS YOY_PCT
FROM REV_2020, REV_2019
WHERE REV_2020.REGION = REV_2019.REGION
;

/*Another Approach using Oracle Analytics Functions*/ --WIP

SELECT REGION, to_char(trans_date,'YYYY') REV_YEAR, SUM(TRANS_AMT) TRANS_AMT,
LAG(SUM(TRANS_AMT)) OVER (ORDER BY to_char(trans_date,'YYYY')),
Round((SUM(TRANS_AMT) - LAG(SUM(TRANS_AMT)) OVER (ORDER BY to_char(trans_date,'YYYY')))/LAG(SUM(TRANS_AMT)) OVER (ORDER BY to_char(trans_date,'YYYY')))* 100),3) || '%' AS PCT
FROM revenue
WHERE to_char(trans_date,'YYYY') IN ('2019','2020')
GROUP BY REGION, to_char(trans_date,'YYYY')
ORDER BY 1 ASC, 2 ASC;

/*Daily wise Record Count: Growth Percentage*/
CYCLE_DT, REC_CNT
01/01/2020, 78
01/02/2020, 83
01/03/2020, 95  
01/04/2020, 90
01/05/2020, 92
01/06/2020, 97

OutPut:
CYCLE_DT, REC_CNT, PCT_GROWTH
01/01/2020, 78
01/02/2020, 83, 6.345
01/03/2020, 95, 15.567  

SELECT CYCLE_DT, REC_CNT,
LAG(REC_CNT) OVER (ORDER BY CYCLE_DT) AS PREV_CNT,
ROUND((REC_CNT - (LAG(REC_CNT) OVER (ORDER BY CYCLE_DT))/(LAG(REC_CNT) OVER (ORDER BY CYCLE_DT)))*100,3) || '%' AS PCT_GROWTH                                                                                   
FROM PRTY_MASTER
ORDER BY 1 ASC;                                                                                               

/*Cummulative Total Calculation*/   
CYCLE_DT, QTY
01/01/2020, 10
01/02/2020, 12
01/03/2020, 15  
02/01/2020, 11
02/02/2020, 12
02/03/2020, 13
                                                          
/*Output*/
CYCLE_DT, QTY, CUMM_TOT_QTY
01/01/2020, 10, 10
01/02/2020, 12, 22
01/03/2020, 15, 37  
02/01/2020, 11, 11
02/02/2020, 12, 23
02/03/2020, 13, 36                                                          
SELECT CYCLE_DT, QTY,SUM(QTY) OVER (PARTITION BY TO_CHAR(CYCLE_DT,'MON') ORDER BY CYCLE_DT ASC) CUMM_TOT_QTY
FROM PRTY_MASTER  
ORDER BY CYCLE_DT ASC;                                                                                                                
