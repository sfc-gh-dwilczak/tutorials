use database raw;
use schema gcp;
use role sysadmin;
use warehouse developer;

-- Create table.
create or replace iceberg table csv
    ( x INTEGER , y INTEGER )  
    CATALOG='SNOWFLAKE'
    EXTERNAL_VOLUME='exvol'
    BASE_LOCATION='iceberg';

select * from csv;
    
-- Load data into the table.
copy into
    csv
from
    '@gcp/csv/sample_1.csv'
file_format = (type = 'csv' skip_header = 1)
on_error = 'continue';

-- Show data
select * from csv;


/*

Iceberg Metadaa file.

{
  "format-version" : 2,
  "table-uuid" : "d28b014a-48f4-4f5d-ae90-9dddafd90273",
  "location" : "gs://flumehealth/iceberg/",
  "last-sequence-number" : 0,
  "last-updated-ms" : 1713392603906,
  "last-column-id" : 2,
  "current-schema-id" : 0,
  "schemas" : [ {
    "type" : "struct",
    "schema-id" : 0,
    "fields" : [ {
      "id" : 1,
      "name" : "X",
      "required" : false,
      "type" : "int"
    }, {
      "id" : 2,
      "name" : "Y",
      "required" : false,
      "type" : "int"
    } ]
  } ],
  "default-spec-id" : 0,
  "partition-specs" : [ {
    "spec-id" : 0,
    "fields" : [ ]
  } ],
  "last-partition-id" : 999,
  "default-sort-order-id" : 0,
  "sort-orders" : [ {
    "order-id" : 0,
    "fields" : [ ]
  } ],
  "properties" : {
    "format-version" : "2"
  },
  "current-snapshot-id" : -1,
  "snapshots" : [ ]
} */