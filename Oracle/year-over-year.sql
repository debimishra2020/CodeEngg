/*customer*/
cust_id   customer
ABC01     Smith
ABC02     Blake
ABC03     King

/*product*/
product_id    product_name
P01           Security01
P02           Security02
P03           Security03

/*revenue*/
customer_id   product_id   trans_amt  trans_date  region
ABC01         P01          2540       09/07/2020  EAST
ABC01         P02          3500       09/01/2020  WEST
ABC02         P03          4508       08/29/2020  NORTH
ABC04         P04          6510       07/23/2020  SOUTH
ABC02         P07          4400       05/12/2019  SOUTH
ABC07         P10          2345       09/29/2019  SOUTH

/*Write a query to find year over year comparision FY2020 for P01-EAST*/   WIP

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
