use sysadmin;
use database raw;
use schema gcp;

-- Documentation: https://docs.snowflake.com/en/sql-reference/sql/create-file-format#examples
create or replace file format json
  type = 'json';

create or replace file format csv
  type = csv
  field_delimiter = ','
  skip_header = 1
  null_if = ('null', 'null')
  empty_field_as_null = true
  compression = auto
  trim_space = true;

CREATE or replace FILE FORMAT infer_csv
  TYPE = csv
  PARSE_HEADER = TRUE
  SKIP_BLANK_LINES = true
  FIELD_OPTIONALLY_ENCLOSED_BY ='"'
  trim_space = true
  error_on_column_count_mismatch = false; -- schema evolution