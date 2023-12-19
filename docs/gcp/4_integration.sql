/*
  Integrations are on of those important features that account admins
  should do because it's allowing outside snowflake connections to your data.
*/

use role accountadmin;

-- Follow this tutorial to setup your integration:
  --  https://docs.snowflake.com/en/user-guide/data-load-gcs-config

CREATE STORAGE INTEGRATION gcp_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'GCS'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://snowflake_spins_data');

-- Give the sysadmin access to use the integration.
grant usage on integration gcp_integration to role sysadmin;

use sysadmin;
DESC STORAGE INTEGRATION gcp_integration;

  -- Note the STORAGE_GCP_SERVICE_ACCOUNT.
    -- rbnxkdkujw@prod3-f617.iam.gserviceaccount.com
    
    