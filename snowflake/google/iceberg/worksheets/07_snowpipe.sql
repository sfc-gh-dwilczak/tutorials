use database raw;
use schema gcp;
use role accountadmin;
use warehouse developer;

create or replace notification integration gcp_notification_integration
    type = queue
    notification_provider = gcp_pubsub
    enabled = true
    gcp_pubsub_subscription_name = 'projects/danielwilczak/subscriptions/pycon2024_subscription'; 

grant usage on integration gcp_notification_integration to role sysadmin;

desc notification integration gcp_notification_integration;
select "property", "property_value" as principal from table(result_scan(last_query_id()))
where "property" = 'GCP_PUBSUB_SERVICE_ACCOUNT';