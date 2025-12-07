# Openflow - SFTP
Goal of this tutorial is to load data from SFTP into Snowflake stage via openflow.

## Video
Video still in development

## Requirements 
- You can NOT be on a trial account. ([Link](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview))
- Snowflake account has to be in an AWS region.([Link](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#available-regions))

## Download  :octicons-feed-tag-16:
- Connector ([Link](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/connectors/sftp/files/APItotable.json))

## Snowflake
Lets start the snowflake setup by going into a workspace worksheet (1) and creating the nesseray objects for openflow and the connector.
{ .annotate }

1. ![Worksheet](images/0.png)

??? note "If you don't have a database, schema, or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql linenums="1"
       -- Create a database to store our schemas.
        create database if not exists raw;

        -- Create the schema. The schema stores all objects.
        create schema if not exists raw.api;
        create schema if not exists raw.network;

        /*
            Warehouses are synonymous with the idea of compute
            resources in other systems. We will use this
            warehouse to query our integration and to load data.
        */
        create warehouse if not exists openflow 
            warehouse_size = xsmall
            auto_suspend = 30
            initially_suspended = true;
        ```

!!! warning "Only required if your hosting openflow in Snowflake (SPCS)"
    Lets create the network rule and external access that will allow openflow/snowflake to talk with google sheets.

    === ":octicons-image-16: Code"

        ```sql linenums="1"
        -- create network rule for google apis
        create or replace network rule api_network_rule
            mode = egress
            type = host_port
            value_list = (
                'api.openweathermap.org',
            );

        -- Create one external access integration with all network rules.
        create or replace external access integration openflow_external_access
            allowed_network_rules = (api_network_rule)
            enabled = true;
        ```

    === ":octicons-sign-out-16: Result"

        Integration OPENFLOW_EXTERNAL_ACCESS successfully created.

Now we will need a table to store the contents of our API call.

=== ":octicons-image-16: Code"

    ```sql linenums="1"
    create or replace table weather (
        raw variant
    );
    ```

=== ":octicons-sign-out-16: Result"

    Table WEATHER successfully created.


Next we'll head into openflow to setup our runtime and add the connector.




select * from weather;