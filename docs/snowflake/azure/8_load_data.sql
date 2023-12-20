use sysadmin;
use database raw;
use schema azure;
use warehouse developer;

-- This can be done using the UI or via code. This depends on the data and prefrence.
create or replace table delta (
	file_name varchar,
  data variant
);

copy into delta(file_name,data)
  from (
    select 
        metadata$filename,
        $1
    from
        @examples/json
        (file_format => json)
  );