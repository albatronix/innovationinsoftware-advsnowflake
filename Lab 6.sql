--Database Object Management
-- Lab.6.1

CREATE WAREHOUSE iceberg_tutorial_wh
  WAREHOUSE_TYPE = STANDARD
  WAREHOUSE_SIZE = XSMALL;

USE WAREHOUSE iceberg_tutorial_wh;

CREATE OR REPLACE DATABASE iceberg_tutorial_db;
USE DATABASE iceberg_tutorial_db;

CREATE OR REPLACE EXTERNAL VOLUME iceberg_external_volume
   STORAGE_LOCATIONS =
      (
         (
            NAME = 'my-s3-us-west-2'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 's3://<my_bucket>/'
            STORAGE_AWS_ROLE_ARN = '<arn:aws:iam::123456789012:role/myrole>'
            STORAGE_AWS_EXTERNAL_ID = 'iceberg_table_external_id'
         )
      );

DESC EXTERNAL VOLUME iceberg_external_volume;

CREATE OR REPLACE ICEBERG TABLE customer_iceberg (
    c_custkey INTEGER,
    c_name STRING,
    c_address STRING,
    c_nationkey INTEGER,
    c_phone STRING,
    c_acctbal INTEGER,
    c_mktsegment STRING,
    c_comment STRING
)
    CATALOG = 'SNOWFLAKE'
    EXTERNAL_VOLUME = 'iceberg_external_volume'
    BASE_LOCATION = 'customer_iceberg';

ALTER DATABASE iceberg_tutorial_db SET CATALOG = 'SNOWFLAKE';
ALTER DATABASE iceberg_tutorial_db SET EXTERNAL_VOLUME = 'iceberg_external_volume';

SHOW PARAMETERS IN DATABASE ;

CREATE OR REPLACE ICEBERG TABLE nation_iceberg (
  n_nationkey INTEGER,
  n_name STRING
)
  BASE_LOCATION = 'nation_iceberg'
  AS SELECT
    N_NATIONKEY,
    N_NAME
  FROM snowflake_sample_data.tpch_sf1.nation;

INSERT INTO customer_iceberg
  SELECT * FROM snowflake_sample_data.tpch_sf1.customer;

SELECT
    c.c_name AS customer_name,
    c.c_mktsegment AS market_segment,
    n.n_name AS nation
  FROM customer_iceberg c
  INNER JOIN nation_iceberg n
    ON c.c_nationkey = n.n_nationkey
  LIMIT 15;

  SELECT
    c_name AS customer_name,
    c_mktsegment AS market_segment
  FROM customer_iceberg
  LIMIT 10;

  DELETE FROM customer_iceberg WHERE c_mktsegment = 'AUTOMOBILE';

  SELECT
    c_name AS customer_name,
    c_mktsegment AS market_segment
 FROM customer_iceberg
 WHERE c_mktsegment = 'AUTOMOBILE';

DROP ICEBERG TABLE customer_iceberg;
DROP ICEBERG TABLE nation_iceberg;
DROP EXTERNAL VOLUME iceberg_external_volume;
USE DATABASE <my_other_database>;
DROP DATABASE iceberg_tutorial_db;
USE WAREHOUSE <my_other_warehouse>;
DROP WAREHOUSE iceberg_tutorial_wh;

