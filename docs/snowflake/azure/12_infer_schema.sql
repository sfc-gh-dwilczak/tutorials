use sysadmin;
use database raw;
use schema azure;
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
create or replace table entities
    using template (
        select array_agg(object_construct(*))
          within group (order by order_id)
        from table(
            infer_schema(        
            LOCATION=>'@examples/csv/entities/'
        , file_format => 'infer_csv')
        )
    );

create or replace table relationship
    using template (
        select array_agg(object_construct(*))
          within group (order by order_id)
        from table(
            infer_schema(        
            LOCATION=>'@examples/csv/relationship/'
        , file_format => 'infer_csv')
        )
    );

-- Load the data into the table.
COPY into entities from @examples/csv/entities/ FILE_FORMAT = (FORMAT_NAME= 'infer_csv') MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY into relationship from @examples/csv/relationship/ FILE_FORMAT = (FORMAT_NAME= 'infer_csv') MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
