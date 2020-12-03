#1 - Using Window Function 
Select
   SUM(Profit) over (partition by driver_id,year,month order by day)
   ,driver_id
   ,day  
FROM f_daily_rides;

#2 - Using Self Join
SELECT
   day
   ,driver_id
   ,SUM(Profit)
FROM
(
   Select
      t1.day
      ,t2.day      
      ,t1.driver_id
      ,t2.Profit
   FROM f_daily_rides t1
   JOIN  f_daily_rides t2
On driver_id =driver_id
And t1.Month = t2.Month
And t1.Year = t2.Year
And t1.day >=t2.day
) t3
Group by 
day,
driver_id

#3 - Using Sub Query in the Select Clause
Select
      t1.day
      ,t1.driver_id
      ,(Select sum(profit) from f_daily_rides t2 where t1.day    >=t2.day and t1.driver_id = t2.driver_id)
   FROM f_daily_rides t1
