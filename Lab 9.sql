--Lab 9.1
--Creating a weather database

use role accountadmin;
create or replace database weather;

use warehouse compute_wh;
use database weather;
use schema public;

create table json_weather_data (v variant);

create stage nyc_weather
url = 's3://snowflake-workshop-lab/weather-nyc';

list @nyc_weather;

copy into json_weather_data 
from @nyc_weather 
file_format = (type=json);
select * from json_weather_data limit 10;

-- Create table

create or replace table weather_data as
select
  v:time::timestamp as observation_time,
  v:city.id::int as city_id,
  v:city.name::string as city_name,
  v:city.country::string as country,
  v:city.coord.lat::float as city_lat,
  v:city.coord.lon::float as city_lon,
  v:clouds.all::int as clouds,
  (v:main.temp::float)-273.15 as temp_avg,
  (v:main.temp_min::float)-273.15 as temp_min,
  (v:main.temp_max::float)-273.15 as temp_max,
  v:weather[0].main::string as weather,
  v:weather[0].description::string as weather_desc,
  v:weather[0].icon::string as weather_icon,
  v:wind.deg::float as wind_dir,
  v:wind.speed::float as wind_speed
from json_weather_data;

-- Check the data
select * from weather_data limit 10;


--Let's create a view of the unique weather patterns
create or replace view weather_type as
select distinct weather
from weather_data;

-- Check the data
select * from weather_type;

--Let's create a view of the highest temperatures by city
create or replace view weather_max as
select city_name
, max(temp_max) as temperature
from weather_data
group by city_name;

-- Check the data
select * from weather_max;



--Lab 9.2

CREATE DATABASE ROLE weather.r1;
CREATE DATABASE ROLE weather.r2;

GRANT USAGE ON SCHEMA weather.public TO DATABASE ROLE weather.r1;
GRANT SELECT ON VIEW weather.public.weather_type TO DATABASE ROLE weather.r1;

GRANT USAGE ON SCHEMA weather.public TO DATABASE ROLE weather.r2;
GRANT SELECT ON VIEW weather.public.weather_max TO DATABASE ROLE weather.r2;

SHOW GRANTS TO DATABASE ROLE weather.r1;
SHOW GRANTS TO DATABASE ROLE weather.r2;

--Lab 9.3

CREATE SHARE share1;

GRANT USAGE ON DATABASE weather TO SHARE share1;

GRANT DATABASE ROLE weather.r1 TO SHARE share1;
GRANT DATABASE ROLE weather.r2 TO SHARE share1;

ALTER SHARE share1 ADD ACCOUNTS = <org1.consumer1>,<org1.consumer2>;


