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
