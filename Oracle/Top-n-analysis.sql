/*Find Maximum Salary From EMP*/
SELECT MAX(SAL) FROM EMP; 

/*Find Maximum Salary From EMP Based on DEPT wise*/
SELECT DEPT_NO, MAX(SAL) FROM EMP GROUP BY DEPT_NO; 

/*Find the EMP Details earning the Maximum Salary Based on DEPT wise*/
SELECT * FROM EMP WHERE (DEPT_NO,SAL) IN (
SELECT DEPT_NO, MAX(SAL) FROM EMP GROUP BY DEPT_NO 
);
