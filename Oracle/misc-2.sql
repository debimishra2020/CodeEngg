Table Schema
ORDERS
order_id varchar(30) composite primary key
customer_id numeric(38,0)
order_datetime timestamp
item_id varchar(10) composite primary key
order_quantity numeric(38,0)
Sample extract from ORDERS
order_id | customer_id | order_datetime | item_id | order_quantity
A-001 | 32483 | 2018-12-15 09:15:22 | B000 | 3
A-005 | 21456 | 2019-01-12 09:28:35 | B001 | 1
A-005 | 21456 | 2019-01-12 09:28:35 | B005 | 1
A-006 | 42491 | 2019-01-16 02:52:07 | B008 | 2

ITEMS
item_id varchar(10) primary key
item_category varchar(20)
Sample extract from ITEMS
item_id | item_category
B000 | Outdoors
B001 | Outdoors
B002 | Outdoors
B003 | Kitchen
B004 | Kitchen

/* Questions */
-- Q1: How many UNITS have been ordered yesterday? UNITS is the total quantity ordered.
-- Output as: Units

-- Q2: How many UNITS have been ordered in the last 7 days (including today) in EACH and EVERY category? Please consider SEVEN calendar days in total, including today.
-- Please consider ALL categories, even those which have zero orders.
-- Output as: Category | Units

-- Q3: How many UNITS in EACH and EVERY category have been ordered on each day of the week in the last 7 days (including today)?
-- Output as: Category | Sunday_units | Monday_units | Tuesday_units | Wednesday_units | Thursday_units | Friday_units | Saturday_units

-- Q4: It is possible for customers to place multiple orders on a single date.
-- For ALL customers, write a query to get the earliest ORDER_ID for each customer for each date they placed an order.
-- Output as: Customer_id | Order_date | First_order_id

-- Q5: Write a query to get the second earliest ORDER_ID for each customer for each date they placed AT LEAST two orders.
-- Output as: Customer_id | Order_date | Second_order_id


Q1: 
SELECT COUNT(order_quantity) AS Units
FROM Orders 
WHERE CAST(order_datetime AS DATE) = CAST(DATEADD(DD, -1 GETDATE()) AS DATE)

Q2:
SELECT item_category, COUNT(CASE WHEN order_quantity IS NULL THEN 0 ELSE order_quantity END) AS Units
FROM Items i
LEFT JOIN Orders o
  ON o.item_id = i.item_id
WHERE CAST(order_datetime AS DATE) >= CAST(DATEADD(DD, -7, GETDATE()) AS DATE)
GROUP BY item_category

Q3:
/** CREATE CTE OR TEMP TABLE USING Q2 ABOVE AND ADD WeekDay***/
; WITH orders_per_category AS(
    SELECT FORMAT(order_datetime, 'dddd') + '_units' AS WeekDay,
        item_category, 
        CASE WHEN order_quantity IS NULL THEN 0 ELSE order_quantity END AS Units
    FROM Items i
    LEFT JOIN Orders o
       ON o.item_id = i.item_id
    WHERE CAST(order_datetime AS DATE) >= CAST(DATEADD(DD, -7, GETDATE()) AS DATE)
)

SELECT *
FROM orders_per_category
PIVOT (
  SUM(Units)
  FOR WeekDay IN ([Sunday_units], [Monday_units], [Tuesday_units], [Wednesday_units], [Thursday_units], [Friday_units], [Saturday_units])
)B

Q4: 
SELECT o.Customer_Id, s.Order_Date, MIN(o.Order_id) as First_order_id
FROM Orders o
JOIN(
     SELECT Customer_Id, MIN(Order_Date)
     FROM Orders
    GROUP BY Customer_Id
)S
  ON o.Customer_Id = s.Customer_Id
  AND o.Order_Date = s.Order_Date
GROUP BY o.Customer_Id, s.Order_Date

Q5:
SELECT Customer_Id, Order_Date, Order_Id AS Second_Order_Id
FROM(
   SELECT Customer_Id, Order_Date, Order_Id, ROW_NUMBER() OVER(PARTITION BY Customer_Id ORDER BY Order_Id ASC) AS rn
   FROM Orders
   WHERE EXISTS(
     SELECT Customer_Id, COUNT(Order_Id) AS cnt
     FROM Orders
     GROUP BY Customer_Id
     HAVING COUNT(Order_Id) >= 2
   )S
WHERE S.rn = 2



https://leetcode.com/discuss/interview-question/456001/amazon-data-scientist-tech-interview-sql-coding-questions

