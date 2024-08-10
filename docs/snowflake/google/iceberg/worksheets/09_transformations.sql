use database raw;
use schema gcp;
use role sysadmin;
use warehouse developer;

-- Example transofmation step.
create iceberg table transformations with 
    catalog='SNOWFLAKE'
    external_volume='exvol'
    base_location='iceberg'
  as
    -- CTE for transformation.
    with data as (
      select 
        sum(x) as total_x, 
        sum(y) as total_y
      from raw.gcp.csv
    )
    
    -- Select the data to put into the table.
    select * from data;

-- Show me the transformed data living in gcp/iceberg format.
select * from raw.gcp.transformations;