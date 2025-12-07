# Openflow - API
Goal of this tutorial is to load data from an API into Snowflake table via openflow.

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
                'api.openweathermap.org'
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

We'll click "Browse" button and upload our [connector](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/connectors/api/files/files.zip) we downloaded at the start of the tutorial.
![UPDATE](images/08.png)

Click "Add".
![UPDATE](images/09.png)

### Paramaters
Next we'll want to go into our connectors paramaters. Right click the connector and go into paramaters.
![UPDATE](images/10.png)

Click cancel.
![UPDATE](images/11.png)

#### API Credentials
From here we can see the two or three sections we need. We'll start by clicking edit on the api paramaters.
![UPDATE](images/12.png)

Here we can see our only paramater. This is to keep the tutorial simple. I have already add the weather data api and it's key.
![UPDATE](images/13.png)

#### Snowflake Credentials
Next we'll go back and edit our Snowflake configurations.
![UPDATE](images/14.png)


Now you only have to do the third paramater if your openflow is hosted on AWS.
![UPDATE](images/15.png)

#### (Optional) Snowflake for AWS
We'll want to enable our control service so that we can connect to Snowflake.
![UPDATE](images/16.png)

### Running the connector
To look into our connector we can double click it.
![UPDATE](images/17.png)

To see how we plan on hitting our endpoint we can right click and select configure.
![UPDATE](images/18.png)

Here we can see the configuration for how to hit the API and return a response. In this case we keep it simple and just put in the URL.
![UPDATE](images/19.png)

If we head back we can run the connector once to validate it works.
![UPDATE](images/20.png)

Now that it has been sucessfull we can list the queue of responses by right clicking and go into the queue.
![UPDATE](images/21.png)

Now we can view the contents of our api call.
![UPDATE](images/22.png)

We can see the json that has responded, we'll copy this so we can manipulate it in the next step.
![UPDATE](images/23.png)

We'll look into the configuration of the transformation.
![UPDATE](images/24.png)

Here we can see in the transformation the code used to manipulate the JSON so it fits into our single column varient column.
![UPDATE](images/25.png)

Now if we want a better view of the transformation or to play with it we can right click the transform processor and go into advanced.
![UPDATE](images/26.png)

Now we get a nice UI to paste our JSON into and click transform. This will allow us to see how the data will change after this step.
![UPDATE](images/27.png)

Lets head back and run it once.
![UPDATE](images/28.png)

We can right click and look at the queue.
![UPDATE](images/29.png)

View the contents
![UPDATE](images/30.png)

Here we can see we add the RAW header key to the data to make sure it goes into our RAW column in our weather table.
![UPDATE](images/31.png)

Now lets head back and run the final step once to get it into the table.
![UPDATE](images/32.png)

We can see it's been successful so we will go look at our table in Snowflake.
![UPDATE](images/33.png)

Now we can select our table and click the column to view the results in a nice way.
=== ":octicons-image-16: Code"

    ```sql linenums="1"
    select * from weather;
    ```

![UPDATE](images/34.png)