use sysadmin;

-- Warehouses are synonymous with the idea of compute resources in other systems.
create or replace warehouse developer 
    WAREHOUSE_SIZE=XSMALL
    INITIALLY_SUSPENDED=TRUE;


create or replace warehouse analyst 
    WAREHOUSE_SIZE=XSMALL
    INITIALLY_SUSPENDED=TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 2;

-- Give our role "analyst" access to use the warehouse.
grant usage on warehouse analyst to role analyst;