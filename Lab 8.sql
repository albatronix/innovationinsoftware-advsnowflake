-- Lab 8.1

USE ROLE ACCOUNTADMIN;

CREATE NOTIFICATION INTEGRATION budgets_notification_integration
  TYPE=EMAIL
  ENABLED=TRUE
  ALLOWED_RECIPIENTS=('<YOUR_EMAIL_ADDRESS>');

GRANT USAGE ON INTEGRATION budgets_notification_integration
  TO APPLICATION snowflake;

  -- Lab 8.2

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE DATABASE budgets_db;

CREATE OR REPLACE  SCHEMA budgets_db.budgets_schema;


USE ROLE ACCOUNTADMIN;

CREATE ROLE account_budget_admin;

GRANT APPLICATION ROLE SNOWFLAKE.BUDGET_ADMIN TO ROLE account_budget_admin;

GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE account_budget_admin;


USE ROLE ACCOUNTADMIN;

CREATE ROLE account_budget_monitor;
 
GRANT APPLICATION ROLE SNOWFLAKE.BUDGET_VIEWER TO ROLE account_budget_monitor;

GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE account_budget_monitor;



USE ROLE ACCOUNTADMIN;
   
CREATE ROLE budget_owner;
  
GRANT USAGE ON DATABASE budgets_db TO ROLE budget_owner;
GRANT USAGE ON SCHEMA budgets_db.budgets_schema TO ROLE budget_owner;

GRANT DATABASE ROLE SNOWFLAKE.BUDGET_CREATOR TO ROLE budget_owner;

GRANT CREATE SNOWFLAKE.CORE.BUDGET ON SCHEMA budgets_db.budgets_schema
  TO ROLE budget_owner;

  

USE ROLE ACCOUNTADMIN;

CREATE ROLE budget_admin;

GRANT USAGE ON DATABASE budgets_db TO ROLE budget_admin;

GRANT USAGE ON SCHEMA budgets_db.budgets_schema TO ROLE budget_admin;

GRANT DATABASE ROLE SNOWFLAKE.USAGE_VIEWER TO ROLE budget_admin;

CREATE ROLE budget_monitor;

GRANT USAGE ON DATABASE budgets_db TO ROLE budget_monitor;

GRANT USAGE ON SCHEMA budgets_db.budgets_schema TO ROLE budget_monitor;

GRANT DATABASE ROLE SNOWFLAKE.USAGE_VIEWER TO ROLE budget_monitor;



GRANT ROLE account_budget_admin
  TO USER <YOUR_USER_NAME>;
GRANT ROLE account_budget_monitor
  TO USER <YOUR_USER_NAME>;
GRANT ROLE budget_owner
  TO USER <YOUR_USER_NAME>;
GRANT ROLE budget_monitor
  TO USER <YOUR_USER_NAME>;

--Lab 8.3

CREATE WAREHOUSE na_finance_wh;
GRANT USAGE ON WAREHOUSE na_finance_wh TO ROLE account_budget_admin;
GRANT USAGE ON WAREHOUSE na_finance_wh TO ROLE account_budget_monitor;
GRANT USAGE ON WAREHOUSE na_finance_wh TO ROLE budget_admin;
GRANT USAGE ON WAREHOUSE na_finance_wh TO ROLE budget_owner;
GRANT USAGE ON WAREHOUSE na_finance_wh TO ROLE budget_monitor;
GRANT APPLYBUDGET ON WAREHOUSE na_finance_wh TO ROLE budget_owner;


CREATE DATABASE na_finance_db;
GRANT APPLYBUDGET ON DATABASE  na_finance_db TO ROLE budget_owner;



-- Lab 8.4
USE ROLE account_budget_admin;

CALL snowflake.local.account_root_budget!ACTIVATE();
CALL snowflake.local.account_root_budget!SET_SPENDING_LIMIT(500);


CALL snowflake.local.account_root_budget!SET_EMAIL_NOTIFICATIONS(
   'budgets_notification_integration',
   '<YOUR_EMAIL_ADDRESS>');




-- Lab 8.5
USE ROLE budget_owner;
USE SCHEMA budgets_db.budgets_schema;
USE WAREHOUSE na_finance_wh;

CREATE SNOWFLAKE.CORE.BUDGET na_finance_budget();



CALL na_finance_budget!SET_SPENDING_LIMIT(500);
CALL na_finance_budget!SET_EMAIL_NOTIFICATIONS('budgets_notification_integration',
                                               '<YOUR_EMAIL_ADDRESS>');
CALL na_finance_budget!ADD_RESOURCE(
  SYSTEM$REFERENCE('database', 'na_finance_db', 'SESSION', 'applybudget'));

CALL na_finance_budget!ADD_RESOURCE(
  SYSTEM$REFERENCE('warehouse', 'na_finance_wh', 'SESSION', 'applybudget'));

  

USE ROLE budget_owner;

GRANT SNOWFLAKE.CORE.BUDGET ROLE budgets_db.budgets_schema.na_finance_budget!ADMIN
  TO ROLE budget_admin;
GRANT SNOWFLAKE.CORE.BUDGET ROLE budgets_db.budgets_schema.na_finance_budget!VIEWER
  TO ROLE budget_monitor;

-- Lab 8.6

USE ROLE account_budget_monitor;

CALL snowflake.local.account_root_budget!GET_SPENDING_HISTORY(
  TIME_LOWER_BOUND => DATEADD('days', -7, CURRENT_TIMESTAMP()),
  TIME_UPPER_BOUND => CURRENT_TIMESTAMP()
);


USE ROLE account_budget_monitor;

CALL snowflake.local.account_root_budget!GET_SERVICE_TYPE_USAGE(
   SERVICE_TYPE => 'SEARCH_OPTIMIZATION',
   TIME_DEPART => 'day',
   USER_TIMEZONE => 'UTC',
   TIME_LOWER_BOUND => DATEADD('day', -7, CURRENT_TIMESTAMP()),
   TIME_UPPER_BOUND => CURRENT_TIMESTAMP()
);


USE ROLE budget_monitor;

CALL budgets_db.budgets_schema.na_finance_budget!GET_SPENDING_HISTORY(
  TIME_LOWER_BOUND => DATEADD('days', -7, CURRENT_TIMESTAMP()),
  TIME_UPPER_BOUND => CURRENT_TIMESTAMP()
);


--Lab 8.7

USE ROLE budget_owner;

DROP SNOWFLAKE.CORE.BUDGET budgets_db.budgets_schema.na_finance_budget;

USE ROLE ACCOUNTADMIN;

DROP DATABASE na_finance_db;
DROP WAREHOUSE na_finance_wh;
DROP DATABASE budgets_db;

USE ROLE ACCOUNTADMIN;

DROP ROLE budget_monitor;
DROP ROLE budget_admin;
DROP ROLE budget_owner;

USE ROLE ACCOUNTADMIN;

DROP ROLE account_budget_monitor;
DROP ROLE account_budget_admin;

USE ROLE ACCOUNTADMIN;

DROP NOTIFICATION INTEGRATION budgets_notification_integration;

