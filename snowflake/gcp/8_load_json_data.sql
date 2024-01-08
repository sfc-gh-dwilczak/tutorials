use sysadmin;
use database raw;
use schema gcp;
use warehouse developer;

-- This can be done using the UI or via code. This depends on the data and prefrence.
create or replace table json_data (
	file_name varchar,
    data variant
);

-- Loading Json folder.
copy into json_data(file_name,data)
  from (
    select 
        metadata$filename,
        $1
    from
        @gcp/json
        (file_format => json)
  );


