/*Write a query to find out the growth percentage for daily record count*/
CYCLE_DT    REC_CNT
01/01/2020  78
01/02/2020  83
01/03/2020  95

/*OutPut*/
CYCLE_DT    REC_CNT   PCT_GROWTH
01/01/2020  78
01/02/2020  83        6.41
01/03/2020  95        14.45  

SELECT CYCLE_DT, COUNT(*) AS REC_CNT,
LAG(COUNT(*)) OVER (ORDER BY CYCLE_DT ASC) AS PREV_CNT,
ROUND((COUNT(*) - (LAG(COUNT(*)) OVER (ORDER BY CYCLE_DT ASC))/(LAG(COUNT(*)) OVER (ORDER BY CYCLE_DT ASC)))*100,3) || '%' AS PCT_GROWTH                                                                                   
FROM PRTY_MASTER 
GROUP BY CYCLE_DT ORDER BY CYCLE_DT ASC;   
