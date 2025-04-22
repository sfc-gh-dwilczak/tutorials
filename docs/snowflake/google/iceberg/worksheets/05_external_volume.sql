use database raw;
use schema gcp;
use role accountadmin;
use warehouse developer;


create or replace external volume external_volume
  STORAGE_LOCATIONS =
    (
      (
        NAME = 'external_volume'
        STORAGE_PROVIDER = 'GCS'
        STORAGE_BASE_URL = 'gcs://danielwilczak/'
      )
    );
    

-- If your lazy like me.
select 
    "property",
     REPLACE(GET_PATH(PARSE_JSON("property_value"), 'STORAGE_GCP_SERVICE_ACCOUNT')::STRING, '"', '') AS url
from
    table(result_scan(last_query_id()))
where
    "property" = 'STORAGE_LOCATION_1';


-- Grant sysadmin access to the volume.
grant all on external volume external_volume to role sysadmin with grant option;