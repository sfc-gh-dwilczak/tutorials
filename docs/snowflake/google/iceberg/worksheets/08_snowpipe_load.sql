use database raw;
use schema gcp;
use role sysadmin;
use warehouse developer;



create or replace pipe csv 
    auto_ingest = true 
    integration = 'GCP_NOTIFICATION_INTEGRATION' 
    as

    copy into
        csv
    from
        '@gcp/csv/'
    file_format = (type = 'csv' skip_header = 1)
    on_error = 'continue';

/* 
    Refresh the state of the pipe to make
    sure it's updated with all files.
*/
alter pipe csv resume;

alter pipe csv refresh;

-- See the loaded data.
select count(*) from csv;

SELECT parse_json(SYSTEM$PIPE_STATUS('raw.gcp.csv'));