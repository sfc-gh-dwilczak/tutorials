use sysadmin;
use database raw;
use schema gcp;
use warehouse developer;


-- Create the file format.
 CREATE or replace FILE FORMAT infer_csv
  TYPE = csv
  PARSE_HEADER = TRUE
  SKIP_BLANK_LINES = true
  FIELD_OPTIONALLY_ENCLOSED_BY ='"'
  trim_space = true
  error_on_column_count_mismatch = false; -- schema evolution

-- Loading CSV folder without having to know columns names.
  -- See the columns names to verify it worked properly.
SELECT *
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@gcp/csv/'
      , FILE_FORMAT=>'infer_csv'
      )
    );

-- Create the table from the csv.
create or replace table csv_data
    using template (
        select array_agg(object_construct(*))
          within group (order by order_id)
        from table(
            infer_schema(        
            LOCATION=>'@gcp/csv/'
        , file_format => 'infer_csv')
        )
    );

-- Load the data into the table.
COPY into csv_data from @gcp/csv/ FILE_FORMAT = (FORMAT_NAME= 'infer_csv') MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
