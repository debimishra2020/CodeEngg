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
