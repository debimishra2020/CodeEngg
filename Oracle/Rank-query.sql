create table revenue (
customer_id varchar2(10),
product_id varchar2(10),
trans_amt number,
trans_date date,
region varchar2(10)
);

/*Display Top 10 Customers Based On Trans Amount For Feb-2020*/

select customer_name, rnk from (
select c.customer_name, sum(trans_amt),
dense_rank() over(order by sum(trans_amt) desc) rnk
from revenue r, customer c
where r.customer_id = c.customer_id and to_char(trans_date,'MON-YYYY') = 'FEB-2020'
group by c.customer_name
) where rnk <= 10 order by 2 asc;
