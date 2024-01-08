use sysadmin;
use database raw;
use schema gcp;
use warehouse developer;

COPY INTO 
    @gcp/dump/
from 
    csv_data
FILE_FORMAT = (
    FORMAT_NAME = 'csv'
    COMPRESSION = NONE
);

-- Documentation:
  -- https://docs.snowflake.com/en/user-guide/data-unload-considerations 

-- Considerations:
  -- 1. File formats.
  -- 2. To compress or not compress.
  -- 3. Single or multiple.
    -- Required to be compressed for single.
  -- 4. Max file size, this will depend on GCP or your application.
