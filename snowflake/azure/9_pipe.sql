-- Follow this video tutorial, it was helpful for me:
  -- https://www.youtube.com/watch?v=_xKfJzL_Bz0
use accountadmin;
CREATE NOTIFICATION INTEGRATION azure_snowpipe_integration
  ENABLED = true
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
  AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://dwilczaksyndigo.queue.core.windows.net/snowpipe-queue'
  AZURE_TENANT_ID = '9a2d78cb-73e9-40ee-a558-fc1ac5ef57a7';

-- Give the sysadmin access to use the integration.
grant usage on integration azure_snowpipe_integration to role sysadmin;

describe notification integration azure_snowpipe_integration;

  -- Note the AZURE_CONSENT_URL and AZURE_MULTI_TENANT_APP_NAME.
    
    -- AZURE_CONSENT_URL: (CLICK URL -> ACCEPT)
      -- https://login.microsoftonline.com/9a2d78cb-73e9-40ee-a558-fc1ac5ef57a7/oauth2/authorize?client_id=6a908ded-dac5-4f38-aff0-5f247fa93040&response_type=code

    -- AZURE_MULTI_TENANT_APP_NAME: tzpbnzsnowflakepacint_1700112906001
      -- Follow tutorial to add permission and use "tzpbnzsnowflakepacint" for memeber name search.


use sysadmin;
use database raw;
use schema azure;
use warehouse developer;

create or replace table pepsi (
	file_name varchar,
  data variant
);

create or replace pipe pepsi 
    auto_ingest = true 
    integration = 'AZURE_SNOWPIPE_INTEGRATION' 
    as
    
    copy into
        pepsi(file_name,data)
    from (
        select 
            metadata$filename,
            $1
        from
            @examples/json
            (file_format => json)
    );

-- Refresh the state of the pipe to make sure it's updated with all files.
alter pipe pepsi refresh;