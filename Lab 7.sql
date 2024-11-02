--Query Acceleration Service
--Lab 7.1

USE ACCOUNTADMIN;

SELECT query_id,
       query_text,
       start_time,
       end_time,
       warehouse_name,
       warehouse_size,
       eligible_query_acceleration_time,
       upper_limit_scale_factor,
       DATEDIFF(second, start_time, end_time) AS total_duration,
       eligible_query_acceleration_time / NULLIF(DATEDIFF(second, start_time, end_time), 0) AS eligible_time_ratio
FROM
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_ACCELERATION_ELIGIBLE
WHERE
    start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
    AND eligible_time_ratio <= 1.0
    AND total_duration BETWEEN 3 * 60 and 5 * 60
ORDER BY (eligible_time_ratio, upper_limit_scale_factor) DESC NULLS LAST
LIMIT 100;

-- Or use this query to create an eligible query



SELECT d.d_year as "Year",
       i.i_brand_id as "Brand ID",
       i.i_brand as "Brand",
       SUM(ss_net_profit) as "Profit"
FROM   snowflake_sample_data.tpcds_sf10tcl.date_dim    d,
       snowflake_sample_data.tpcds_sf10tcl.store_sales s,
       snowflake_sample_data.tpcds_sf10tcl.item        i
WHERE  d.d_date_sk = s.ss_sold_date_sk
  AND s.ss_item_sk = i.i_item_sk
  AND i.i_manufact_id = 939
  AND d.d_moy = 12
GROUP BY d.d_year,
         i.i_brand,
         i.i_brand_id
ORDER BY 1, 4, 2
LIMIT 301;

--Lab 7.2
CREATE WAREHOUSE noqas_wh WITH
  WAREHOUSE_SIZE='X-SMALL'
  ENABLE_QUERY_ACCELERATION = false
  INITIALLY_SUSPENDED = true
  AUTO_SUSPEND = 60;

CREATE WAREHOUSE qas_wh WITH
  WAREHOUSE_SIZE='X-SMALL'
  ENABLE_QUERY_ACCELERATION = true
  QUERY_ACCELERATION_MAX_SCALE_FACTOR = 14
  INITIALLY_SUSPENDED = true
  AUTO_SUSPEND = 60;

-- Lab 7.3 w/o QAS

USE SCHEMA snowflake_sample_data.tpcds_sf10tcl;

USE WAREHOUSE noqas_wh;

SELECT LAST_QUERY_ID();

-- Keep the last ID (example):  01b819b4-0102-2a50-0006-c26a0002105e

-- Lab 7.4 w/ QAS
USE WAREHOUSE qas_wh;

SELECT LAST_QUERY_ID();

-- Keep the last ID (example): 01b819bf-0102-2a4c-0006-c26a0001e082

-- Lab 7.5

SELECT query_id,
       query_text,
       warehouse_name,
       total_elapsed_time
FROM TABLE(snowflake.information_schema.query_history())
WHERE query_id IN ('<non_accelerated_query_id>', '<accelerated_query_id>')
ORDER BY start_time;

SELECT start_time,
       end_time,
       warehouse_name,
       credits_used,
       credits_used_compute,
       credits_used_cloud_services,
       (credits_used + credits_used_compute + credits_used_cloud_services) AS credits_used_total
  FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY(
    DATE_RANGE_START => DATEADD('days', -1, CURRENT_DATE()),
    WAREHOUSE_NAME => 'NOQAS_WH'
  ));

SELECT start_time,
       end_time,
       warehouse_name,
       credits_used,
       credits_used_compute,
       credits_used_cloud_services,
       (credits_used + credits_used_compute + credits_used_cloud_services) AS credits_used_total
  FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY(
    DATE_RANGE_START => DATEADD('days', -1, CURRENT_DATE()),
    WAREHOUSE_NAME => 'QAS_WH'
  ));


SELECT start_time,
         end_time,
         warehouse_name,
         credits_used,
         num_files_scanned,
         num_bytes_scanned
    FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.QUERY_ACCELERATION_HISTORY(
      DATE_RANGE_START => DATEADD('days', -1, CURRENT_DATE()),
      WAREHOUSE_NAME => 'QAS_WH'
));


-- Lab 7.6

SELECT warehouse_name, count(query_id) as num_eligible_queries, MAX(upper_limit_scale_factor)
  FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_ACCELERATION_ELIGIBLE
  WHERE start_time > DATEADD(month, -1, CURRENT_TIMESTAMP())
  GROUP BY warehouse_name
  ORDER BY num_eligible_queries DESC;

SELECT warehouse_name, SUM(eligible_query_acceleration_time) AS total_eligible_time, MAX(upper_limit_scale_factor)
  FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_ACCELERATION_ELIGIBLE
  WHERE start_time > DATEADD(month, -1, CURRENT_TIMESTAMP())
  GROUP BY warehouse_name
  ORDER BY total_eligible_time DESC;

ALTER WAREHOUSE <warehouse_name> SET
  enable_query_acceleration = TRUE;

DROP WAREHOUSE noqas_wh;

DROP WAREHOUSE qas_wh;
  
