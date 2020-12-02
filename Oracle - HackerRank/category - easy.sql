Que 1 : Revising the Select Query I
Link  : https://www.hackerrank.com/challenges/revising-the-select-query/problem

SELECT * FROM CITY WHERE COUNTRYCODE = 'USA' AND POPULATION > 100000;

Que 2 : Revising the Select Query II
Link  : https://www.hackerrank.com/challenges/revising-the-select-query-2/problem

SELECT NAME FROM CITY WHERE POPULATION > 120000 AND COUNTRYCODE = 'USA';

Que 3 : Select All
Link  : https://www.hackerrank.com/challenges/select-all-sql/problem

SELECT * FROM CITY;

Que 4 : Select By ID
Link  : https://www.hackerrank.com/challenges/select-by-id/problem

SELECT * FROM CITY WHERE ID = 1661;

Que 5 : Japanese Cities' Attributes
Link  : https://www.hackerrank.com/challenges/japanese-cities-attributes/problem

SELECT * FROM CITY WHERE COUNTRYCODE = 'JPN';

Que 6 : Japanese Cities' Names
Link  : https://www.hackerrank.com/challenges/japanese-cities-name/problem

SELECT NAME FROM CITY WHERE COUNTRYCODE = 'JPN';

Que 7 : Weather Observation Station 1
Link  : https://www.hackerrank.com/challenges/weather-observation-station-1/problem

SELECT CITY,STATE FROM STATION;

Que 8 : Weather Observation Station 3
Link  : https://www.hackerrank.com/challenges/weather-observation-station-3/problem

SELECT DISTINCT CITY FROM STATION WHERE MOD(ID,2) = 0;

Que 9 : Weather Observation Station 4
Link  : https://www.hackerrank.com/challenges/weather-observation-station-4/problem

SELECT COUNT(CITY) - COUNT(DISTINCT CITY) FROM STATION;

Que 10 : Weather Observation Station 5
Link   : https://www.hackerrank.com/challenges/weather-observation-station-5/problem

select city_min_len from (
select concat(concat(city,' '),length(city)) as city_min_len,city,length(city) from station 
where length(city) = (select min(length(city)) from station) 
order by city asc) where rownum = 1 ;

select city_max_len from (
select concat(concat(city,' '),length(city)) as city_max_len,city,length(city) from station 
where length(city) = (select max(length(city)) from station) 
order by city asc) where rownum = 1 ;
