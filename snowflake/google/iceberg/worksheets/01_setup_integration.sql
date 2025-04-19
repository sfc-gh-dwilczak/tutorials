/*
    We switch to "sysadmin" to create an object
    because it will be owned by that role.
*/
use role sysadmin;

--- Create a database to store our schemas.
create database if not exists raw 
    comment='This is only raw data from your source.';

-- Create the schema. The schema stores all objects.
create schema if not exists raw.gcp;

/*
    Warehouses are synonymous with the idea of compute
    resources in other systems. We will use this
    warehouse to query our integration and to load data.
*/
create warehouse developer 
    warehouse_size = xsmall
    initially_suspended = true;

/*
    Integrations are on of those important features that
    account admins should do because it's allowing outside 
    snowflake connections to your data.
*/



use role accountadmin;
use warehouse developer;

-- GCP integration. Steps can be found in tutorial.
create or replace storage integration gcp_integration
    type = external_stage
    storage_provider = 'gcs'
    enabled = true
    storage_allowed_locations = ('gcs://pycon2024'); 

-- Give the sysadmin access to use the integration.
grant usage on integration gcp_integration to role sysadmin;

desc storage integration gcp_integration;
select "property", "property_value" as principal from table(result_scan(last_query_id()))
where "property" = 'STORAGE_GCP_SERVICE_ACCOUNT';