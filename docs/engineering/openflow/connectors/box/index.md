# Openflow - Box
Goal of this tutorial is to load data from Box into Snowflake via openflow. This tutorial will not cover how to setup a deployment in [Snowflake](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/deployments/snowflake/) or [AWS](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/deployments/aws).

## Video
Still in development

## Requirements 
- You can NOT be on a trial account. ([Link](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview))
- Snowflake account has to be in an AWS region.([Link](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#available-regions))
- Box account must be at minimum a [busniess account](https://www.box.com/pricing). This is a requirements from [Box](https://box.com/). 

## Downloads
- Sample data - [Link](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/connectors/box/files/files.zip)

## Box
This tutorial will use a Box Sandbox to prevent production security complications. 

### Sanbox Creation
Lets login to our box account and go to "Admin Console".
![UPDATE](images/01.png)

Now we'll go to platform, select sandbox and click "Create Sandbox". This will allow us to have full access to an account.
![UPDATE](images/02.png)

We'll give our sandbox a name and select our email as the admin. Click "Create".
![UPDATE](images/03.png)

Now that the sandbox is created we will login to it.
![UPDATE](images/04.png)

### Development App
Once we are in the accoount or sandbox account, we'll go to [https://app.box.com/developers/console](https://app.box.com/developers/console)
![UPDATE](images/05.png)

We'll need to create an app so that our Openflow can connected to the account via the app. Click "Create Platform App".
![UPDATE](images/06.png)

We'll give our app a name and select "Server Auth -JWT" as app type.
![UPDATE](images/07.png)

### App Configuration
Once created we'll be launched into Configurations were we'll need to make changes. To start lets update "App Access Level" to App + Enterprise Access.
![UPDATE](images/08.png)

Make sure your application scope [follows Snowflake requirements](https://docs.snowflake.com/en/user-guide/data-integration/openflow/connectors/box/setup#get-the-credentials). 
![UPDATE](images/09.png)

Next we'll generate a Public / Private Key. Click this button will require you to enter your duo auth code or sign up for one.
![UPDATE](images/10.png)

Enter duo auth information.
![UPDATE](images/11.png)

Once duo auth you'll have to click the button again.
![UPDATE](images/12.png)

Once click it will download a .json file. We will use this file in openflow later.
![UPDATE](images/13.png)

Now lets submit our app for authorization so that our box can use it later.
![UPDATE](images/14.png)

Copy your Client ID and submit it to your enterprise, this removes and uneeded steep later.
![UPDATE](images/15.png)

!!! Note "Only needed when using a sandbox"

    Next lets head to general setting and copy our Service Account ID. This is only if you are using a Sandbox as the description explains.
    ![UPDATE](images/16.png)

Head back to your account.
![UPDATE](images/17.png)

Go to "Admin Console".
![UPDATE](images/18.png)

Navigate to integration select "Server Authentication Apps" and view your application.
![UPDATE](images/19.png)

Click "Authorize".
![UPDATE](images/20.png)

Click "Authorize" again.
![UPDATE](images/21.png)

Now your app and account is ready. Lets go add data and share it to our service account.
![UPDATE](images/22.png)

### Sample Data / Share
Now lets upload our [sample PDF files](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/connectors/box/files/files.zip) and share it with our service account because were in a sandbox. Create a new folder.
![UPDATE](images/23.png)

Give the folder a name and paste the service account email in the "Invite Additional People" box. Click create.
![UPDATE](images/24.png)

Open your folder.
![UPDATE](images/25.png)

Upload the [example PDF files](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/connectors/box/files/files.zip).
![UPDATE](images/26.png)

Next copy your "Folder ID" from the URL. This will be used in Openflow later.
![UPDATE](images/27.png)

## Snowflake
Lets start the snowflake setup by going into a workspace sql file (1) and creating the necessary objects for openflow and the connector.
{ .annotate }

1. ![Worksheet](images/0.png)

??? note "If you don't have a database, schema, or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql linenums="1"
        -- Create a database to store our schemas.
        create database if not exists raw;

        -- Create the schema. The schema stores all objects.
        create schema if not exists raw.box;
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
    Lets create the network rule and external access that will allow openflow/snowflake to talk with our SFTP.

    === ":octicons-image-16: Code"

        ```sql linenums="1"
        -- Create network rule for box endpoints
        create or replace network rule box_network_rule
            mode = egress
            type = host_port
            value_list = (
                'api.box.com',
                'boxcdn.net',
                'boxcloud.com',
                'dl.boxcloud.com',
                'public.boxcloud.com'
            );

        -- Create one external access integration with all network rules.
        create or replace external access integration openflow_external_access
            allowed_network_rules = (box_network_rule)
            enabled = true;
        ```

    === ":octicons-sign-out-16: Result"

        Integration OPENFLOW_EXTERNAL_ACCESS successfully created.

## Openflow
Now that we have our objects lets add the postgres connector to our deployment. Navigate to openflow in the navbar.
![UPDATE](images/28.png)

??? warning "If you get the error 'Invalid consent request' or 'TOTP Invalid'"
    You will have to change your default role to a role that is not an admin role. Example default would be public.
    ![UPDATE](images/29.png)

Launch openflow and login.
![UPDATE](images/30.png)

From there we can switch to the deployment where we can see our deployment and that it's active. If you don't have a deployment use either [SPCS](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/deployments/spcs/) or [AWS](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/deployments/aws_snowflake_vpc/) to deploy your Opeflow instance.
![UPDATE](images/31.png)

Next we'll head to runtime and click " + Create Runtime".
![UPDATE](images/32.png)

!!! note
    External access will only show up if your on a [SPCS deployment](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/deployments/spcs/).

We'll then select our runtime, give it a name, select accountadmin as the role and if your on [SPCS](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/deployments/spcs/) your external access integration.
![UPDATE](images/33.png)

Once your runtime is active and ready to go. We can head to overview and add the connector.
![UPDATE](images/34.png)

Click install on the "Box (Cortex Connect)" version to have Snowflake search and all needed tables setup by the connector. There are other connectors for box that are very similar but used in different way.
![UPDATE](images/35.png)

Select our runtime.
![UPDATE](images/36.png)


### Paramaters
Now that the connector is installed we'll want to input our Box and Snowflake paramaters.
![UPDATE](images/37.png)

Now that we are in paramaters we can break it into 3 sections those being destination, Ingestion and Source.


#### Destination
Lets click the three dots of our destination and click edit.
![UPDATE](images/38.png)

Now we can select either note option below based on our deployment.

??? note "If your using SPCS deployment"

    As an example we'll click the three dots and click edit. We'll put the database, schema, role and warehouse.
    ![UPDATE](images/39.png)

    One special paramter is the "Snowflake Authentication Strategy" with container service you can put in "SNOWFLAKE_SESSION_TOKEN" and it will not require a key_pair.
    ![UPDATE](images/40.png)

    This is an example input if you used the configurations given at the beginning of the tutorial.
    ![UPDATE](images/41.png)


??? note "If your using AWS deployemnt"

    These are the paramaters you'll need to be filled out. We will see how to get them below.
    ![UPDATE](images/42.png)

    To get the Snowflake Account Identifier, you'll go to the bottom left of the homepage and click account details.
    ![UPDATE](images/43.png)

    You'll copy your account identifier and paste it in openflow.
    ![UPDATE](images/44.png)

    Next to get your key we'll have to generate a public and private key and apply it to our user. To generate the key run this bash script.
    
    === ":octicons-image-16: Code"

        ```bash linenums="1"
        openssl genrsa 2048 > rsa_key_pkcs1.pem
        openssl pkcs8 -topk8 -inform PEM -in rsa_key_pkcs1.pem -out rsa_key.p8 -nocrypt
        openssl rsa -in rsa_key_pkcs1.pem -pubout -out rsa_key.pub
        ```

    === ":octicons-sign-out-16: Result"

        ```
        rsa_key_pkcs1.pem
        rsa_key.p8
        rsa_key.pub
        ```
    
    This will generate three file. We will apply the content of the .pub file to our Snowflake user using the alter user command.
    === ":octicons-image-16: Code"

        ```sql linenums="1"
        alter user danielwilczak set rsa_public_key='PUBLIC KEY';
        ```

    === ":octicons-image-16: Example"

        ```sql linenums="1"
        alter user danielwilczak set rsa_public_key='MIIBIjANBgkqhki...6VIhVnTviwDXXcm558uMrJQIDAQAB';
        ```

    === ":octicons-sign-out-16: Result"

        Statement executed successfully.

    Now that we have our public key on our user we'll move to uploading the .pem file to openflow.
    ![UPDATE](images/45.png)

    Click the upload button.
    ![UPDATE](images/46.png)

    Click the upload button again and select your .pem file.
    ![UPDATE](images/47.png)

    Once uploaded select the key and click "ok". Then fill out the remaing fields and click apply.
    ![UPDATE](images/48.png)

#### Source
Next lets head to source. Click edit on the "Run App Config FIle".
![UPDATE](images/49.png)

Select "Reference assists" and then the upload button.
![UPDATE](images/50.png)

Click upload again.
![UPDATE](images/51.png)

Upload your json public/private key we go from box earlier (1).
{ .annotate }

1. ![UPDATE](images/12.png)

Once uploaded, we'll click "Close".
![UPDATE](images/52.png)

We'll select our key and click "ok".
![UPDATE](images/53.png)

Finally click "apply".
![UPDATE](images/54.png)


#### Ingestion
Now we'll move to the final section ingestion. We'll first edit our folder ID, the reason we don't use 0 in this tutorial because Sandbox's don't allow it. Click edit.
![UPDATE](images/55.png)

We'll put in our "Folder ID" we got from Box (1).
{ .annotate }

1. ![UPDATE](images/27.png)

![UPDATE](images/56.png)

Next we'll edit the role that will have access to the search service. 
![UPDATE](images/57.png)

Since we do everthing in this tutorial with AccountAdmin we'll keep using it.
![UPDATE](images/58.png)

Click "Apply".
![UPDATE](images/59.png)


## Run
Finally we can run our connector. Head back to the process group.
![UPDATE](images/60.png)

Right click the process group again and click "Enable all controller services" and click start.
![UPDATE](images/61.png)

Next we'll right click "Enable" the connector.
![UPDATE](images/62.png)

!!! note
    If you get an error here, I would let the connector run one more time, sometimes the connector has race connedition problems where it doesn't know objects have been created yet and fails. It will fix itself on the next run.

Then we'll right click and hit "Start". This will kick off the ingestion. 
![UPDATE](images/63.png)

### Stage
Now if you don't get any errors you can go back to Snowflake and find our box schema with everything int it. Letts start with seeing that the files have been replicated.
![UPDATE](images/64.png)

### Cortex Search
Now that we have the files loaded and in Cortex Search automaticly lets use the playground to search through the files.
![UPDATE](images/65.png)

Now we can search in the playground to get relevent chunks of information.
![UPDATE](images/66.png)


### Snowflake Inetllegence
Now lets allow Snowflake Inetllegence to use our cortex search service to use it during it's questions answering. Lets start by going to agents.
![UPDATE](images/67.png)

Next put our agents into the same schema and give it a object name and diplay name. Click "Create Agent".
![UPDATE](images/68.png)

Next in our agent we'll go tools and a Cortex Search.
![UPDATE](images/69.png)

Select the location of the search service, select the service. For ID column selet web_url and title column will be full_name. Finally we'll give the tool a name and description and click "Add".
![UPDATE](images/70.png)

Click "Save".
![UPDATE](images/71.png)

Lets navigate to Snowflake Inetllegence.
![UPDATE](images/72.png)

We'll ask a question similar to "How much of a fee do we charge for International cellular plans in africa?".
![UPDATE](images/73.png)

We can see that it was able to answer the question with our documents. Also we can click the document to see it in box.
![UPDATE](images/74.png)

We can see that it pulled it from our international plan section.
![UPDATE](images/75.png)
