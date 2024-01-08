-- Follow this video tutorial, it was helpful for me (8m:30sec to skip to snowpipe.):
  -- https://www.youtube.com/watch?v=TVMd_MG_vJ8


-- Two ways to create the topic (UI/CLI):
    -- Using the UI:
        -- Go into your project
            -- Type in "pubsub" in the search
            -- Add the topic by clicking "create topic" 
                -- Add topic id "snowpipe".
                -- Then add your file format and bucket location gs://snowflake_spins_data/.

    -- Using the cloud shell:
        -- Set project: 
            -- gcloud config set project spins-405418 (Project id)
        -- Setup the topic:
        -- $ gsutil notification create -t snowpipe -f json gs://snowflake_spins_data/

-- Clicking on the topic and add a subscription "snowpipe_subscription_gcp".
-- Click the subscription and copy the "Subscription name" and add to code below.


use accountadmin;
CREATE OR REPLACE NOTIFICATION INTEGRATION gcp_notification_integration
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = GCP_PUBSUB
  ENABLED = true
  GCP_PUBSUB_SUBSCRIPTION_NAME = 'projects/spins-405418/subscriptions/snowpipe_subscription_gcp';

grant usage on integration gcp_notification_integration to role sysadmin;

use sysadmin;
describe notification integration gcp_notification_integration;
-- Copy "GCP_PUBSUB_SERVICE_ACCOUNT"
  -- geimkrazlq@prod3-f617.iam.gserviceaccount.com

-- Add to principal of the subscription:
  -- geimkrazlq@prod3-f617.iam.gserviceaccount.com
  -- For role use Pub/Sub and Pub/Sub Subscriber.


-- Go back to dashboard and then "IAM & Admin"
  -- Click grant access and put in your principal: geimkrazlq@prod3-f617.iam.gserviceaccount.com
  -- For the role use "Monitoring Viewer".

create or replace pipe gcp_json 
    auto_ingest = true 
    integration = gcp_notification_integration 
    as
    
    copy into
        json_data(file_name,data)
    from (
        select 
            metadata$filename,
            $1
        from
            @gcp/json
            (file_format => json)
    );

-- Refresh the state of the pipe to make sure it's updated with all files.
alter pipe gcp_json refresh;


create or replace pipe gcp_csv 
    auto_ingest = true 
    integration = gcp_notification_integration 
    as

      COPY into
        csv_data
      from
        @gcp/csv/ 
      FILE_FORMAT = (FORMAT_NAME= 'infer_csv')
      MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;

alter pipe gcp_csv refresh;