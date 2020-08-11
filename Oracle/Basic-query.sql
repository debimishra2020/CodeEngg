/* Assuming below Table structure as 
Sales (sales_id, date , customer_id, Product_id , purchase_amount) 
Product (Product_id, P_Name, Brand_id,B_name)  
List of customers who bought both brands "X" & "Y" and at-least 2 products in each brand. */

select t.customer_id AS Customer_ID
from (
  select s.customer_id,
    count(distinct p.brand_id) over (partition by s.customer_id) brands_counter,
    count(distinct p.product_id) over (partition by s.customer_id, p.brand_id) products_counter
  from sales s 
  inner join product p
  on p.product_id = s.product_id
  where p.brand_name in ('X', 'Y')
) t
where t.brands_counter = 2
group by t.customer_id
having min(t.products_counter) = 2;
