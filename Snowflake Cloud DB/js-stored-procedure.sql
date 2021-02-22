use role sysadmin;
use warehouse compute_wh;
use Database Demo_DB;
use Schema Demo_DB.PUBLIC;

show tables;
select * from snowflake.account_usage.load_history order by last_load_time desc limit 100;

select * from information_schema.tables;

select table_catalog as schema_name, table_schema, table_name, created as create_date, last_altered as modify_date
from information_schema.tables 
where table_type = 'BASE TABLE'
order by table_schema, table_name;

create or replace procedure sp_pi()
returns float not null
language javascript
as
$$
  return 3.1415926;
$$
;

CALL sp_pi();

CREATE TABLE stproc_test_table1 (num_col1 numeric(14,7));

create or replace procedure stproc1(FLOAT_PARAM1 FLOAT)
    returns string
    language javascript
    strict
    execute as owner
    as
    $$
    var sql_command = 
     "INSERT INTO stproc_test_table1 (num_col1) VALUES (" + FLOAT_PARAM1 + ")";
    try {
        snowflake.execute (
            {sqlText: sql_command}
            );
        return "Succeeded.";   // Return a success/error indicator.
        }
    catch (err)  {
          result =  "Failed: Code: " + err.code + "\n  State: " + err.state;
          result += "\n  Message: " + err.message;
          result += "\nStack Trace:\n" + err.stackTraceTxt; 
        return "Error Happened : " + result;
          }
    $$
    ;
call stproc1(10000000000000000000000000);

select * from stproc_test_table1;

create or replace procedure table_display()
  returns string 
  language javascript
  as     
  $$  
    var my_sql_command = "select * from emp_raw";
    var statement1 = snowflake.createStatement( {sqlText: my_sql_command} );
    var result_set1 = statement1.execute();
    while (result_set1.next())  {
       var column1 = result_set1.getColumnValue(1);
       var column2 = result_set1.getColumnValue(2);
       }
  return "Column : " + column1 + " "+ column2;
  $$
  ;
 
 call table_display();
 
 
 create or replace procedure get_row_count(table_name VARCHAR)
  returns float not null
  language javascript
  as
  $$
  var row_count = 0;
  var sql_command = "select count(*) from " + TABLE_NAME;
  var stmt = snowflake.createStatement(
         {
         sqlText: sql_command
         }
      );
  var res = stmt.execute();
  res.next();
  row_count = res.getColumnValue(1);
  return row_count;
  $$
  ;

call get_row_count('EMP_RAW');
call get_row_count('stproc_test_table1');


create procedure broken()
      returns varchar not null
      language javascript
      as
      $$
      var result = "";
      try {
          snowflake.execute( {sqlText: "Invalid Command!;"} );
          result = "Succeeded";
          }
      catch (err)  {
          result =  "Failed: Code: " + err.code + "\n  State: " + err.state;
          result += "\n  Message: " + err.message;
          result += "\nStack Trace:\n" + err.stackTraceTxt; 
          }
      return result;
      $$
      ;
 
 call broken();
 
 CREATE OR REPLACE PROCEDURE validate_age (age float)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS $$
    try {
        if (AGE < 0) {
            throw "Age cannot be negative!";
        } else {
            return "Age validated.";
        }
    } catch (err) {
        return "Error: " + err;
    }
$$;

call validate_age('23.2');


CREATE OR REPLACE TABLE error_log (error_code number, error_state string, error_message string, stack_trace string);

CREATE OR REPLACE PROCEDURE broken() 
RETURNS varchar 
NOT NULL 
LANGUAGE javascript 
AS $$
var result;
try {
    snowflake.execute({ sqlText: "Invalid Command!;" });
    result = "Succeeded";
} catch (err) {
    result = "Failed";
    snowflake.execute({
      sqlText: `insert into error_log VALUES (?,?,?,?)`
      ,binds: [err.code, err.state, err.message, err.stackTraceTxt]
      });
}
return result;
$$;

call broken();
select * from error_log;


CREATE OR REPLACE PROCEDURE read_emp_raw()
  RETURNS VARCHAR NOT NULL
  LANGUAGE JAVASCRIPT
  AS
  $$
  var return_value = "";
  try {
      var command = "SELECT * FROM emp_raw;"
      var stmt = snowflake.createStatement( {sqlText: command } );
      var rs = stmt.execute();
      if (rs.next())  {
          return_value += rs.getColumnValue(1) + "\n";
          return_value += ", " + rs.getColumnValue(2) + "\n";
          }
      while (rs.next())  {
          return_value += "\n";
          return_value += rs.getColumnValue(1) + "\n";
          return_value += ", " + rs.getColumnValue(2) + "\n";
          
          //insert into emp_raw_t values(rs.getColumnValue(1),rs.getColumnValue(2));
          
          snowflake.execute({
          sqlText: `insert into emp_raw_t VALUES (?,?)`
          ,binds: [rs.getColumnValue(1), rs.getColumnValue(2)]
          });    
          }
      }
  catch (err)  {
      result =  "Failed: Code: " + err.code + "\n  State: " + err.state;
      result += "\n  Message: " + err.message;
      result += "\nStack Trace:\n" + err.stackTraceTxt;
      }
  return return_value;
  $$
  ;
  
call read_emp_raw();

create table emp_raw_t as select empno, empname from emp_raw where 1<>2;
select * from emp_raw_t;
--delete from emp_raw_t;
--commit;


create table reviews (customer_ID VARCHAR, review VARCHAR);
create table purchase_history (customer_ID VARCHAR, price FLOAT, paid FLOAT,
                               product_ID VARCHAR, purchase_date DATE);
                               
insert into purchase_history (customer_ID, price, paid, product_ID, purchase_date) values 
    (1, 19.99, 19.99, 'chocolate', '2018-06-17'::date),
    (2, 19.99,  0.00, 'chocolate', '2017-02-14'::date),
    (3, 19.99,  19.99, 'chocolate', '2017-03-19'::date);

insert into reviews (customer_ID, review) values (1, 'Loved the milk chocolate!');
insert into reviews (customer_ID, review) values (2, 'Loved the dark chocolate!');



create or replace procedure delete_nonessential_customer_data(customer_ID varchar)
    returns varchar not null
    language javascript
    as
    $$

    // If the customer posted reviews of products, delete those reviews.
    var sql_cmd = "DELETE FROM reviews WHERE customer_ID = " + CUSTOMER_ID;
    snowflake.execute( {sqlText: sql_cmd} );

    // Delete any other records not needed for warranty or payment info.
    // ...

    var result = "Deleted non-financial, non-warranty data for customer " + CUSTOMER_ID;

    // Find out if the customer has any net unpaid balance (or surplus/prepayment).
    sql_cmd = "SELECT SUM(price) - SUM(paid) FROM purchase_history WHERE customer_ID = " + CUSTOMER_ID;
    var stmt = snowflake.createStatement( {sqlText: sql_cmd} );
    var rs = stmt.execute();
    // There should be only one row, so should not need to iterate.
    rs.next();
    var net_amount_owed = rs.getColumnValue(1);

    // Look up the number of purchases still under warranty...
    var number_purchases_under_warranty = 0;
    // Assuming a 1-year warranty...
    sql_cmd = "SELECT COUNT(*) FROM purchase_history ";
    sql_cmd += "WHERE customer_ID = " + CUSTOMER_ID;
    // Can't use CURRENT_DATE() because that changes. So assume that today is 
    // always June 15, 2019.
    sql_cmd += "AND PURCHASE_DATE > dateadd(year, -1, '2019-06-15'::DATE)";
    var stmt = snowflake.createStatement( {sqlText: sql_cmd} );
    var rs = stmt.execute();
    // There should be only one row, so should not need to iterate.
    rs.next();
    number_purchases_under_warranty = rs.getColumnValue(1);

    // Check whether need to keep some purchase history data; if not, then delete the data.
    if (net_amount_owed == 0.0 && number_purchases_under_warranty == 0)  {
        // Delete the purchase history of this customer ...
        sql_cmd = "DELETE FROM purchase_history WHERE customer_ID = " + CUSTOMER_ID;
        snowflake.execute( {sqlText: sql_cmd} );
        // ... and delete anything else that that should be deleted.
        // ...
        result = "Deleted all data, including financial and warranty data, for customer " + CUSTOMER_ID;
        }
    return result;
    $$
    ;

SELECT * FROM reviews;
SELECT * FROM purchase_history;
call delete_nonessential_customer_data(1);
