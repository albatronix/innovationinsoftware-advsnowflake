--Data Governance
--Lab 4.1

USE ROLE ACCOUNTADMIN;
CREATE ROLE IF NOT EXISTS dq_tutorial_role;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE dq_tutorial_role;
GRANT EXECUTE DATA METRIC FUNCTION ON ACCOUNT TO ROLE dq_tutorial_role;
GRANT APPLICATION ROLE SNOWFLAKE.DATA_QUALITY_MONITORING_VIEWER TO ROLE dq_tutorial_role;
GRANT DATABASE ROLE SNOWFLAKE.USAGE_VIEWER TO ROLE dq_tutorial_role;
GRANT DATABASE ROLE SNOWFLAKE.DATA_METRIC_USER TO ROLE dq_tutorial_role;

CREATE WAREHOUSE IF NOT EXISTS dq_tutorial_wh;
GRANT USAGE ON WAREHOUSE dq_tutorial_wh TO ROLE dq_tutorial_role;

SHOW GRANTS TO ROLE dq_tutorial_role;

GRANT ROLE dq_tutorial_role TO ROLE SYSADMIN;
GRANT ROLE dq_tutorial_role TO USER <admin_user>;

--Lab 4.2

USE ROLE dq_tutorial_role;
CREATE DATABASE IF NOT EXISTS dq_tutorial_db;
CREATE SCHEMA IF NOT EXISTS sch;

CREATE TABLE customers (
  account_number NUMBER(38,0),
  first_name VARCHAR(16777216),
  last_name VARCHAR(16777216),
  email VARCHAR(16777216),
  phone VARCHAR(16777216),
  created_at TIMESTAMP_NTZ(9),
  street VARCHAR(16777216),
  city VARCHAR(16777216),
  state VARCHAR(16777216),
  country VARCHAR(16777216),
  zip_code NUMBER(38,0)
);

USE WAREHOUSE dq_tutorial_wh;

INSERT INTO customers (account_number, city, country, email, first_name, last_name, phone, state, street, zip_code)
  VALUES (1589420, 'san francisco', 'usa', 'john.doe@', 'john', 'doe', 1234567890, null, null, null);

INSERT INTO customers (account_number, city, country, email, first_name, last_name, phone, state, street, zip_code)
  VALUES (8028387, 'san francisco', 'usa', 'bart.simpson@example.com', 'bart', 'simpson', 1012023030, null, 'market st', 94102);

INSERT INTO customers (account_number, city, country, email, first_name, last_name, phone, state, street, zip_code)
  VALUES
    (1589420, 'san francisco', 'usa', 'john.doe@example.com', 'john', 'doe', 1234567890, 'ca', 'concar dr', 94402),
    (2834123, 'san mateo', 'usa', 'jane.doe@example.com', 'jane', 'doe', 3641252911, 'ca', 'concar dr', 94402),
    (4829381, 'san mateo', 'usa', 'jim.doe@example.com', 'jim', 'doe', 3641252912, 'ca', 'concar dr', 94402),
    (9821802, 'san francisco', 'usa', 'susan.smith@example.com', 'susan', 'smith', 1234567891, 'ca', 'geary st', 94121),
    (8028387, 'san francisco', 'usa', 'bart.simpson@example.com', 'bart', 'simpson', 1012023030, 'ca', 'market st', 94102);

--Lab 4.3

CREATE DATA METRIC FUNCTION IF NOT EXISTS
  invalid_email_count (ARG_T table(ARG_C1 STRING))
  RETURNS NUMBER AS
  'SELECT COUNT_IF(FALSE = (
    ARG_C1 REGEXP ''^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$''))
    FROM ARG_T';

ALTER TABLE customers SET DATA_METRIC_SCHEDULE = '5 MINUTE';

ALTER TABLE customers ADD DATA METRIC FUNCTION
  invalid_email_count ON (email);

SELECT * FROM TABLE(INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_REFERENCES(
  REF_ENTITY_NAME => 'dq_tutorial_db.sch.customers',
  REF_ENTITY_DOMAIN => 'TABLE'));

SELECT scheduled_time, measurement_time, table_name, metric_name, value
FROM SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS
WHERE TRUE
AND METRIC_NAME = 'INVALID_EMAIL_COUNT'
AND METRIC_DATABASE = 'DQ_TUTORIAL_DB'
LIMIT 100;

ALTER TABLE customers DROP DATA METRIC FUNCTION
  invalid_email_count ON (email);

--Lab 4.4

USE ROLE dq_tutorial_role;
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_QUALITY_MONITORING_USAGE_HISTORY
WHERE TRUE
AND START_TIME >= CURRENT_TIMESTAMP - INTERVAL '3 days'
LIMIT 100;

--Clean resources
USE ROLE ACCOUNTADMIN;
DROP DATABASE dq_tutorial_db;
DROP WAREHOUSE dq_tutorial_wh;
DROP ROLE dq_tutorial_role;


