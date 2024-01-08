use sysadmin
use database raw;
use schema gcp;

CREATE TASK unload_customers_child
    -- This is the keyword used to schedule depended task
    AFTER unload_customers 
AS
    -- Just an example.
    select * from raw.gcp.customer_stream;
