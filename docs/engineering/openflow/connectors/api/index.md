# Openflow - SFTP
Goal of this tutorial is to load data from SFTP into Snowflake stage via openflow.

## Video
Video still in development

## Requirements 
- You can NOT be on a trial account. ([Link](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview))
- Snowflake account has to be in an AWS region.([Link](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#available-regions))

## Download  :octicons-feed-tag-16:
- Connector ([Link](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/connectors/api/files/files.zip))

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
    Lets create the network rule and external access that will allow openflow/snowflake to talk with our API.

    === ":octicons-image-16: Code"

        ```sql linenums="1"
        -- Create network rule for the api
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

## Openflow
Next we'll head into openflow to setup our runtime and add the connector.
![UPDATE](images/01.png)

??? warning "If you get the error 'Invalid consent request' or 'TOTP Invalid'"
    You will have to change your default role to a role that is not an admin role. Example default would be public.
    ![UPDATE](images/00.png)

Click "Launch openflow".
![UPDATE](images/02.png)

### Add the connector
We'll create a new runtime.
![UPDATE](images/03.png)

We'll select our deployment, give the runtime a name, select our snowflake role and if deployed in Snowflake our external access intergration.
![UPDATE](images/04.png)

Now we'll wait 5-10 minutes for our runtime to become usable.
![UPDATE](images/05.png)

??? warning "If you get the error 'Invalid consent request' or 'TOTP Invalid'"
    You will have to change your default role to a role that is not an admin role. Example default would be public.
    ![UPDATE](images/00.png)

Once the runtime is "Active" we can click to go into it.
![UPDATE](images/06.png)

Next we'll drag a process group to the canvas.
![UPDATE](images/07.png)

We'll click "Browse" button and upload our [connector](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/connectors/sftp/files/files.zip) we downloaded at the start of the tutorial.
![UPDATE](images/08.png)



