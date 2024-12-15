use database raw;
use schema gcp;
use role sysadmin;
use warehouse developer;

/* 
    Create a file format so the "copy into"
    command knows how to copy the data.
*/
create or replace file format json
    type = 'json';


-- Create the table to load into.
create or replace table json (
    file_name varchar,
    data variant
);

-- Load the json file from the json folder.
copy into json(file_name,data)
from (
    select 
        metadata$filename,
        $1
    from
        @gcp/json
        (file_format => json)
);

-- View the data, in the next worksheet we will flatten it.
select * from raw.gcp.json;

