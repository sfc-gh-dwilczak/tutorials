
use sysadmin;
use database raw;
use schema azure;

-- Stages are synonymous with the idea of folders that can be either internal or external.
create or replace stage examples
  storage_integration = azure_integration
  url = 'azure://dwilczaksyndigo.blob.core.windows.net/examples'
  directory = ( enable = true);