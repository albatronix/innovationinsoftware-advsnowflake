--Replication and Failover
--Lab 10.1

SELECT SYSTEM$DISABLE_DATABASE_REPLICATION('weather');


USE ROLE ACCOUNTADMIN;
CREATE ROLE myrole;
GRANT CREATE FAILOVER GROUP ON ACCOUNT
  TO ROLE myrole;


USE ROLE myrole;

CREATE OR REPLACE FAILOVER GROUP myfg
  OBJECT_TYPES = USERS, ROLES, WAREHOUSES, RESOURCE MONITORS, DATABASES
  ALLOWED_DATABASES = weather
  ALLOWED_ACCOUNTS = eyytunm.demo1
  REPLICATION_SCHEDULE = '10 MINUTE';

--Switch to target account

USE ROLE ACCOUNTADMIN;
CREATE ROLE myrole;
GRANT CREATE FAILOVER GROUP ON ACCOUNT
  TO ROLE myrole;


USE ROLE myrole;

CREATE FAILOVER GROUP myfg
  AS REPLICA OF eyytunm.demo1;


GRANT REPLICATE ON FAILOVER GROUP myfg TO ROLE my_replication_role;
USE ROLE my_replication_role;
ALTER FAILOVER GROUP myfg REFRESH;


GRANT FAILOVER ON FAILOVER GROUP myfg TO ROLE my_failover_role;


--Lab 10.2

USE ROLE ORGADMIN;

-- View the list of the accounts in your organization
-- Note the organization name and account name for each account for which you are enabling replication
SHOW ACCOUNTS;

-- Enable replication by executing this statement for each source and target account in your organization
SELECT SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER('<organization_name>.<account_name>', 'ENABLE_ACCOUNT_DATABASE_REPLICATION', 'true');


USE ROLE ACCOUNTADMIN;

CREATE ROLE myrole;

GRANT CREATE FAILOVER GROUP ON ACCOUNT
    TO ROLE myrole;


SHOW REPLICATION ACCOUNTS;


SHOW FAILOVER GROUPS;
SHOW DATABASES IN FAILOVER GROUP myfg;
SHOW SHARES IN FAILOVER GROUP myfg;


USE ROLE myrole;

CREATE FAILOVER GROUP myfg
    OBJECT_TYPES = USERS, ROLES, WAREHOUSES, RESOURCE MONITORS, DATABASES, INTEGRATIONS, NETWORK POLICIES
    ALLOWED_DATABASES = db1, db2
    ALLOWED_INTEGRATION_TYPES = API INTEGRATIONS
    ALLOWED_ACCOUNTS = myorg.myaccount2
    REPLICATION_SCHEDULE = '10 MINUTE';


USE ROLE ACCOUNTADMIN;

CREATE ROLE myrole;

GRANT CREATE FAILOVER GROUP ON ACCOUNT
    TO ROLE myrole;


USE ROLE myrole;

CREATE FAILOVER GROUP myfg
  AS REPLICA OF myorg.myaccount1.myfg;



GRANT REPLICATE ON FAILOVER GROUP myfg TO ROLE my_replication_role;
GRANT REPLICATE ON FAILOVER GROUP myfg TO ROLE my_replication_role;



USE ROLE my_replication_role;

ALTER FAILOVER GROUP myfg REFRESH;



GRANT FAILOVER ON FAILOVER GROUP myfg TO ROLE my_failover_role;


-- Lab 10.2
-- CDP

--Let's get some data

create database Citibike;


create or replace table trips  
(tripduration integer,
  starttime timestamp,
  stoptime timestamp,
  start_station_id integer,
  start_station_name string,
  start_station_latitude float,
  start_station_longitude float,
  end_station_id integer,
  end_station_name string,
  end_station_latitude float,
  end_station_longitude float,
  bikeid integer,
  membership_type string,
  usertype string,
  birth_year integer,
  gender integer);


use role accountadmin;

use schema public;

use database citibike;

CREATE STAGE "CITIBIKE"."PUBLIC".citibike_trips URL = 's3://snowflake-workshop-lab/citibike-trips';

list @CITIBIKE_TRIPS;

show stages;

CREATE OR REPLACE FILE FORMAT csv
  TYPE = CSV
  FIELD_DELIMITER = ','
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  EMPTY_FIELD_AS_NULL = TRUE
  SKIP_HEADER = 1;
  
copy into trips from @citibike_trips
file_format=CSV
ON_ERROR=CONTINUE
PATTERN='.*[.]csv.gz';

--Let's try undrop

drop table json_weather_data;

Select * from json_weather_data limit 10;

undrop table json_weather_data;



--Let's try Time Travel

use role sysadmin;
use warehouse compute_wh;
use database citibike;
use schema public;

update trips set start_station_name = 'oops';

select 
start_station_name as "station",
count(*) as "rides"
from trips
group by 1
order by 2 desc
limit 20;

set query_id = 
(select query_id from 
table(information_schema.query_history_by_session (result_limit=>5)) 
where query_text like 'update%' order by start_time limit 1);

create or replace table trips as
(select * from trips before (statement => $query_id));
        
select 
start_station_name as "station",
count(*) as "rides"
from trips
group by 1
order by 2 desc
limit 20;

  
