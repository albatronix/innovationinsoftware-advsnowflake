--Security
--Lab 3.1

--A user with the ACCOUNTADMIN role can use the ENABLE_IDENTIFIER_FIRST_LOGIN parameter to enable the identifier-first login flow for an account.

USE ROLE ACCOUNTADMIN;

ALTER ACCOUNT SET ENABLE_IDENTIFIER_FIRST_LOGIN = true;

--Lab 3.2

--To create an authentication policy

CREATE AUTHENTICATION POLICY require_mfa_authentication_policy
  AUTHENTICATION_METHODS = ('PASSWORD')
  CLIENT_TYPES = ('SNOWFLAKE_UI', 'SNOWSQL', 'DRIVERS')
  MFA_AUTHENTICATION_METHODS = ('PASSWORD')
  MFA_ENROLLMENT = REQUIRED;

--Apply to an account
ALTER ACCOUNT SET AUTHENTICATION POLICY require_mfa_authentication_policy;

--Apply to a user
ALTER USER test_user1 SET AUTHENTICATION POLICY require_mfa_authentication_policy;

--Ideally, you want a seperate policy for administrators to prevent lockout. This one SHOULD allow passwords as an authenitcation method
CREATE AUTHENTICATION POLICY admin_authentication_policy
  AUTHENTICATION_METHODS = ('PASSWORD')
  CLIENT_TYPES = ('SNOWFLAKE_UI', 'SNOWSQL', 'DRIVERS');

--Make sure you replace <administrator_name> with your admin user
ALTER USER <administrator_name> SET AUTHENTICATION POLICY admin_authentication_policy;

SHOW AUTHENTICATION POLICIES;

--Lab 3.3
--First create a network rules

CREATE NETWORK RULE my_ip_address
  TYPE = IPV4
  VALUE_LIST = (<enter ip address>,current_ip_address)
  COMMENT ='ip range';

--Then we create the network policy
CREATE NETWORK POLICY mypolicy1 ALLOWED_IP_LIST=(my_ip_address)
                                BLOCKED_IP_LIST=(<block_list>);

DESC NETWORK POLICY mypolicy1;


--Lab 3.4

--Create permissions for adding packages
USE ROLE ACCOUNTADMIN;

CREATE ROLE trust_center_admin_role;
GRANT APPLICATION ROLE SNOWFLAKE.TRUST_CENTER_ADMIN TO ROLE trust_center_admin_role;

CREATE ROLE trust_center_viewer_role;
GRANT APPLICATION ROLE SNOWFLAKE.TRUST_CENTER_VIEWER TO ROLE trust_center_viewer_role;

GRANT ROLE trust_center_admin_role TO USER <Example_admin_user>;

GRANT ROLE trust_center_viewer_role TO USER <example_nonadmin_user>;
