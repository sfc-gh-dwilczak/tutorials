# Openflow - Google Sheets
Goal of this tutorial is to setup openflow in Snowflake container services and then add the google sheets connector to load in a sheet on a schedule.

## Video
Video still in development

## Requirements 
- You can NOT be on a trial account. ([Link](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview))
- Snowflake account has to be in an AWS region.([Link](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#available-regions))
- Google cloud account, you can setup a [free account](https://cloud.google.com/) to get started.

## Snowflake
Lets start the snowflake setup by going into a worksheet (1) and creating the nesseray objects for openflow and the connector.
{ .annotate }

1. ![Worksheet](images/0.png)

??? note "If you don't have a database, schema or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql linenums="1"
        use role sysadmin;

        -- Create a database to store our schemas.
        create database if not exists raw;

        -- Create the schema. The schema stores all objects.
        create schema if not exists raw.google;
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


Lets create the network rule and external access that will allow openflow/snowflake to talk with google sheets.

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    -- create network rule for google apis
    create or replace network rule google_api_network_rule
        mode = egress
        type = host_port
        value_list = (
            'admin.googleapis.com',
            'oauth2.googleapis.com',
            'www.googleapis.com',
            'sheets.googleapis.com'
        );

    -- Create one external access integration with all network rules.
    create or replace external access integration openflow_external_access
        allowed_network_rules = (raw.network.google_api_network_rule)
        enabled = true;
    ```

=== ":octicons-sign-out-16: Result"

    Statement executed successfully.


## Openflow
Now that we have the nessery objects lets create our deployment and runtime for openflow. Navigate to openflow in the navbar.
![UPDATE](images/01.png)

??? warning "If you get the error 'Invalid consent request'"
    You will have to change your default role to a role that is not an admin role. Example default would be public.
    ![UPDATE](images/00.png)


Launch openflow and login.
![UPDATE](images/02.png)

Once logged in lets click "create deployment".
![UPDATE](images/03.png)

Click next.
![UPDATE](images/04.png)

Now we'll want to select Snowflake as the deployment envirement. Give it a name and click next.
![UPDATE](images/05.png)

Click next.
![UPDATE](images/06.png)

Now your deployment will start creating. It will take between 5-15 minutes.
![UPDATE](images/07.png)

Now that your deployment is active we can move on to our runtime.
![UPDATE](images/08.png)

Click runtimes.
![UPDATE](images/09.png)

Click "+ Create runtime".
![UPDATE](images/10.png)

Select your deployment, next give your runtime a name, and select accountadmin as the role. Scroll down to extrnal acess.
![UPDATE](images/11.png)

select the external access we create in our worksheet and finally click "Create".
![UPDATE](images/12.png)

Now your runtime will start being created. Lets head to the connectors
![UPDATE](images/13.png)

On the connectors list, install the google sheets connector.
![UPDATE](images/14.png)

Select your runtime to install, you may have to wait for the runtime to finilize.
![UPDATE](images/15.png)

Once selected click "add". The connector will be added and you'll be required to login to get into the underliying container.
![UPDATE](images/16.png)


??? warning "If you get the error 'Invalid consent request'"
    You will have to change your default role to a role that is not an admin role. Example default would be public.
    ![UPDATE](images/00.png)

Click allow.
![UPDATE](images/17.png)

Now you should see the openflow canvas with the google sheets connector block. We will switch to Google sheets here to get some information to setup our connector.
![UPDATE](images/18.png)

## Google Sheets
!!! note
    To setup google make sure you have [Super Admin](https://support.google.com/a/answer/2405986?hl=en&src=supportwidget0&authuser=0) permissions, we will need this to create a service account. 

Ensure that you are in the project associated with your organization, not the project in your organization.
![UPDATE](images/20.png)

### Orginization Policy
Search "Orginization Policies", next click in the fliter box and search "Disable service account key creation". Select the managed constraint.
![UPDATE](images/21.png)

Click Mange policy.
![UPDATE](images/22.png)

Click "Override parent policy", edit rule and select off for enforcement. Next click done and set policy. 
![UPDATE](images/23.png)

Set the policy.
![UPDATE](images/24.png)

### Service account

Search "Service account" and once on the page click "+ Create service account".
![UPDATE](images/25.png)
 
Give your service account a name and description and click done.
![UPDATE](images/26.png)

Now copy your email, we will use this later. Once copied click the service account.
![UPDATE](images/27.png)

Go to keys, add key and create a new key.
![UPDATE](images/28.png)

We'll want the JSON key. This key will be added to openflow later. Click Create. 
![UPDATE](images/29.png)

It will download a JSON file.
![UPDATE](images/30.png)

### Enable Goofle Sheets API

Next we'll want to enable the API so that Snowflake can talk with the API. Search "google sheets api".
![UPDATE](images/31.png)

Once on the API page, click enable.
![UPDATE](images/32.png)

Once enabled you will be able to see usage metrics.
![UPDATE](images/33.png)

### Share sheet with service account

Next we'll share the google sheet with the service account email (1) we copied earlier. Click the share button.
{ .annotate }
    
1. ![service account email](images/27.png)

![UPDATE](images/34.png)

Insert the email and click send.
![UPDATE](images/35.png)

Click share anyway.
![UPDATE](images/36.png)


## Connector Configuration

Lets head back to openflow and right click the google sheet connector and then parameters.
![UPDATE](images/37.png)

Here we will see three sections where we will have to enter in our configiration paramaters into.
![UPDATE](images/38.png)

### Destination Parameters
Lets click the three dots on the right side of the destination paramters.
![UPDATE](images/39.png)

As an example we'll click the three dots and click edit. We'll put the database, schema, role and warehouse.
![UPDATE](images/40.png)

One special paramter is the "Snowflake Authentication Strategy" with container service you can put in "SNOWFLAKE_SESSION_TOKEN" and it will not require a key_pair.
![UPDATE](images/41.png)

This is an example input if you used the configurations given at the beginning of the tutorial.
![UPDATE](images/42.png)

### Ingestion Parameters
Next for the "Ingestion Parameters" we'll need the sheet name and the sheet range. You'll select the range you want and copy it and the sheet name. 
![UPDATE](images/43.png)

Next we'll want to copy the Spreadsheet ID from the URL.
![UPDATE](images/44.png)

Now we'll enter in what we want the table name to be. The sheet name and range (1) in the format "Sheet_name!range" and finally the speadsheet ID (2) we got from the URL. Click Apply.
{ .annotate }
    
1. ![Range and sheet name](images/43.png)

2. ![Speadsheet ID](images/44.png)

![UPDATE](images/45.png)

### Source Parameters
Next we'll want to copy the contents of our service account JSON file. I opened my file by dragging it to the browser.
![UPDATE](images/46.png)

We'll enter that in to our service account json form. Once entered it will show as "Sensitive value set".
![UPDATE](images/47.png)

Now we're done with the paramaters. We can go back to the process group to get it started.
![UPDATE](images/48.png)

### Run the connector
Lets right click the connector, enable "All controller services" and then start the connector. Now since the data is small it will load into Snowflake in seconds.
![UPDATE](images/49.png)

And we're done, once loaded you will be able to see it in your database/schema with the table name we set prior.
![UPDATE](images/50.png)

## Multiple Spreadsheets / Sheets
Most users will want to ingest multiple spreedsheets with potentially multiple sheets in a spreadsheet. To accomplish this you'll want to go back and add anther Google sheet connector to the runtime.
![UPDATE](images/14.png)

You'll want to right click your new connector. Click configure.
![UPDATE](images/51.png)

This is where you can rename both to give them unique names to differentiate them.
![UPDATE](images/52.png)

After we've named them we'll want to go into our new connector and go to paramaters.
![UPDATE](images/53.png)

We'll select "Inheritance" in the top menu and select the destination and google source parameters because these are going to be the same for all our google sheets connectors.
![UPDATE](images/54.png)

Next we'll go back to our "parameters" and add our next google spreadsheet which has two sheets so we'll add both names with both ranges by seperating them with a comma.
![UPDATE](images/55.png)

Finally we'll start the second connector by right click start and then we'll be able to see the result in our Snowflake table.
![UPDATE](images/56.png)