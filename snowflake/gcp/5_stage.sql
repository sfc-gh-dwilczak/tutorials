
use sysadmin;
use database raw;
use schema gcp;

-- Stages are synonymous with the idea of folders that can be either internal or external.
create or replace stage gcp
  storage_integration = gcp_integration
  url = 'gcs://snowflake_spins_data/'
  directory = ( enable = true);