use database raw;
use schema gcp;
use role accountadmin;
use warehouse developer;


CREATE or replace EXTERNAL VOLUME exvol
  STORAGE_LOCATIONS =
    (
      (
        NAME = 'exvol'
        STORAGE_PROVIDER = 'GCS'
        STORAGE_BASE_URL = 'gcs://pycon2024/'
      )
    );
    
-- Get the url.
describe external volume exvol;

-- If your lazy like me.
select 
    "property",
     REPLACE(GET_PATH(PARSE_JSON("property_value"), 'STORAGE_GCP_SERVICE_ACCOUNT')::STRING, '"', '') AS url
from
    table(result_scan(last_query_id()))
where
    "property" = 'STORAGE_LOCATION_1';


-- Grant sysadmin access to the volume.
GRANT ALL ON EXTERNAL VOLUME exvol TO ROLE sysadmin WITH GRANT OPTION;