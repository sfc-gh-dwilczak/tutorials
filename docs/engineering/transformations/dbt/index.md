# Transformations - DBT in Snowflake
Goal of this tutorial is to show how you can setup development and production dbt in Snowflake.

## Video
Video still in development.

## Requirements 
- Snowflake account, you can use a [free trial](https://signup.snowflake.com/). We also assume no complex security needs.

## Workspace
To start using dbt in a share development space we will need a shared workspace to allow others to see our code.

??? note "If you don't have a database, schema or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql linenums="1"
        -- Create a database to store our schemas.
        create database if not exists demo;

        -- Create the schema. The schema stores all objects.
        create schema if not exists demo.code;
        create schema if not exists demo.production;

        /*
            Warehouses are synonymous with the idea of compute
            resources in other systems. We will use this
            warehouse to query our integration and to load data.
        */
        create warehouse if not exists development 
            warehouse_size = xsmall
            auto_suspend = 30
            initially_suspended = true;

        create warehouse if not exists production 
            warehouse_size = xsmall
            auto_suspend = 30
            initially_suspended = true;
        ```
