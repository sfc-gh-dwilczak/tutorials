use securityadmin;

-- Grant the role "analyst" usage and select to the data_warehouse database. 
grant usage on database data_warehouse to analyst;
grant usage on all schemas in database data_warehouse to analyst;
grant usage on future schemas in database data_warehouse to analyst;
grant select on future tables in database data_warehouse to analyst;
grant select on future views in database data_warehouse to analyst;