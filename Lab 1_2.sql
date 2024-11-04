--Organization Management
--Review contact

--Account Management
--Lab 2.1

USE ROLE orgadmin;

--Create a regular Snowflake account
CREATE ACCOUNT DEMOSNOWSIGHT2
  ADMIN_NAME = admin
  ADMIN_PASSWORD = 'TestPassword1'
  FIRST_NAME = Jane
  LAST_NAME = Smith
  EMAIL = 'myemail43G5G45@demo.com'
  EDITION = enterprise
  REGION = aws_us_west_2;

--Lab 1.1

USE ROLE orgadmin;

ALTER ACCOUNT DEMOSNOWSIGHT2 SET IS_ORG_ADMIN = TRUE;

--Lab 1.2

ALTER ACCOUNT DEMOSNOWSIGHT2 SET IS_ORG_ADMIN = FALSE;

--Create an open catalog Snowflake account
CREATE ACCOUNT DEMOSNOWSIGHT3
  ADMIN_NAME = admin
  ADMIN_PASSWORD = 'TestPassword1'
  FIRST_NAME = Jane
  LAST_NAME = Smith
  EMAIL = 'myemail43G5G45@demo.com'
  EDITION = enterprise
  REGION = aws_us_west_2
  POLARIS = true;


--View all accounts
SHOW ACCOUNTS;

--Lab 2.2
USE ROLE orgadmin;

ALTER ACCOUNT DEMOSNOWSIGHT2 RENAME TO DEMOSNOWSIGHT4;

--View all accounts
SHOW ACCOUNTS;


--Lab 2.3
USE ROLE orgadmin;

DROP ACCOUNT DEMOSNOWSIGHT4 GRACE_PERIOD_IN_DAYS = 14;

--To restore, use undrop
UNDROP ACCOUNT DEMOSNOWSIGHT4;


--Lab 2.4
--Let's create an organization accountusing DEMOSNOWSIGHT3

USE ROLE ORGADMIN;

CREATE ORGANIZATION ACCOUNT myorgaccount
    ADMIN_NAME = admin
    ADMIN_PASSWORD = 'TestPassword1'
    EMAIL = 'myemail@myorg.org'
    MUST_CHANGE_PASSWORD = true
    EDITION = enterprise;

--Lab 2.5
--Now we are going to create a password policy

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE DATABASE SECURITY;
CREATE OR REPLACE SCHEMA SECURITY.POLICIES;

--Now we can create the password policy

USE SCHEMA SECURITY.POLICIES;

CREATE PASSWORD POLICY PASSWORD_POLICY_PROD_1
    PASSWORD_MIN_LENGTH = 12
    PASSWORD_MAX_LENGTH = 24
    PASSWORD_MIN_UPPER_CASE_CHARS = 2
    PASSWORD_MIN_LOWER_CASE_CHARS = 2
    PASSWORD_MIN_NUMERIC_CHARS = 2
    PASSWORD_MIN_SPECIAL_CHARS = 2
    PASSWORD_MIN_AGE_DAYS = 1
    PASSWORD_MAX_AGE_DAYS = 999
    PASSWORD_MAX_RETRIES = 3
    PASSWORD_LOCKOUT_TIME_MINS = 30
    PASSWORD_HISTORY = 5
    COMMENT = 'production account password policy';

--Apply the policy to an account

ALTER ACCOUNT SET PASSWORD POLICY security.policies.password_policy_prod_1;

--Apply the policy to a user

CREATE USER test_user1;

ALTER USER test_user1 SET PASSWORD POLICY security.policies.password_policy_user;

--To reset a password policy, use UNSET 

ALTER ACCOUNT UNSET PASSWORD POLICY;
