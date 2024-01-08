/*
  Integrations are on of those important features that account admins
  should do because it's allowing outside snowflake connections to your data.
*/

use role accountadmin;

-- Follow this tutorial to setup your integration:
  --  https://docs.snowflake.com/en/user-guide/data-load-azure-config

CREATE OR REPLACE STORAGE INTEGRATION azure_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'AZURE'
  ENABLED = TRUE
  AZURE_TENANT_ID = '9a2d78cb-73e9-40ee-a558-fc1ac5ef57a7'
    STORAGE_ALLOWED_LOCATIONS = (
      'azure://dwilczaksyndigo.blob.core.windows.net/examples'
    );

-- Give the sysadmin access to use the integration.
grant usage on integration azure_integration to role sysadmin;

DESC STORAGE INTEGRATION azure_integration;

  -- Note the AZURE_CONSENT_URL and AZURE_MULTI_TENANT_APP_NAME.
    
    -- AZURE_CONSENT_URL: (CLICK URL -> ACCEPT)
      -- https://login.microsoftonline.com/9a2d78cb-73e9-40ee-a558-fc1ac5ef57a7/oauth2/authorize?client_id=bfbfc814-0111-40ee-bbba-a5f6891b47c0&response_type=code

    -- AZURE_MULTI_TENANT_APP_NAME: c9pnugsnowflakepacint_1700096201187
      -- Follow tutorial to add permission and use "c9pnugsnowflakepacint" for memeber name search.

