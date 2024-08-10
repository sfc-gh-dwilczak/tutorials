use database raw;
use schema gcp;
use role sysadmin;

/*
   Stages are synonymous with the idea of folders
   that can be either internal or external.
*/
create or replace stage raw.gcp.gcp
    storage_integration = gcp_integration
    url = 'gcs://pycon2024/' 
    directory = ( enable = true);

