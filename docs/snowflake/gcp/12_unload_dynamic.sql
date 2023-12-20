use sysadmin;
use database raw;
use schema gcp;
use warehouse developer;

create or replace stream
    raw.gcp.customer_stream
on table
    SHARE_SPINS.EXAMPLE.CUSTOMERS
    -- Settings
    show_initial_rows=True;

-- This stored procedure will greatly save you time when naming the unloaded data. Example of it's use below.
CREATE OR REPLACE PROCEDURE unload_into_stage(
        stage_path VARCHAR, 
        file_prefix VARCHAR, 
        stream_location VARCHAR)
    RETURNS VARCHAR NOT NULL
    LANGUAGE SQL
AS
$$
    DECLARE
        path VARCHAR DEFAULT stage_path;
        year VARCHAR DEFAULT YEAR(CURRENT_TIMESTAMP());
        month VARCHAR DEFAULT MONTH(CURRENT_TIMESTAMP());
        day VARCHAR DEFAULT DAY(CURRENT_TIMESTAMP());
        
        file_name VARCHAR DEFAULT file_prefix || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYY-MM-DDTHH24:MI:SS.FF');

        copy_into VARCHAR DEFAULT 
                    'COPY INTO ' || path || '/'
                                    || year || '/'
                                    || month || '/'
                                    || day || '/'
                                    || file_name || ' FROM (SELECT * FROM '|| stream_location || ')';
    BEGIN
        EXECUTE IMMEDIATE :copy_into;
        return 'Unloaded:' || copy_into;
    END;
$$;


-- Will create file in /dump/2023/11/20/ccustomers-2023-11-20T22:55:57.855000000_0_0_0.csv.gz
CREATE OR REPLACE TASK unload_customers
    SCHEDULE = '10 minute'
WHEN
    SYSTEM$STREAM_HAS_DATA('customer_stream')
AS
    call unload_into_stage('@gcp/dump','customers-','raw.gcp.customer_stream');

-- If you want to run it right away.
EXECUTE TASK unload_customers;

-- This will turn on the schedule.
ALTER TASK unload_customers RESUME;