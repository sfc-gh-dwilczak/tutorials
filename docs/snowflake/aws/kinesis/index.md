# AWS Kinesis to Snowflake
In this tutorial we will show how you can setup Kinesis stream and firehose to load data into Snowflake. We will use a local python script of taxi data to act as our source.

## Video
<iframe width="850px" height="478px" src="https://www.youtube.com/embed/AzebPF5PuDA?si=shmV1gOGtpCeVS1S" style="display:block;" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## Requirement
This tutorial assumes you have nothing in your Snowflake account ([Trial](https://signup.snowflake.com/)) and no complex security needs.

## Download needed files:
- Data generator code ([Link](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/aws/kinesis/files/files.zip))

## Snowflake Setup :octicons-feed-tag-16:
For the Snowflake setup we'll want to create the service user with an ssh key and the table to load data into.

### Generate an ssh key
Lets create the private and public key so that we can apply the public key to our user.

=== ":octicons-image-16: Setup"

    ```bash linenums="1"
    openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out private_key.p8 -nocrypt
    sed '/-----/d' private_key.p8 | tr -d '\n' > private_key_kinesis.txt
    openssl rsa -in private_key.p8 -pubout -out public_key.pub
    ```

=== ":octicons-image-16: Result"

    ```bash linenums="1"
    Writing RSA key.
    ```

This will create three files files in the folder we are currently located.
![Two keys](images/01.png)

### User
Lets create the usser and apply the public key to our user in Snowflake. The public key file will end with ``.pub``.

=== ":octicons-image-16: Setup"

    ```sql linenums="1"
    use role accountadmin;

    create user danielwilczak type = 'service';

    alter user danielwilczak set 
        rsa_public_key='<Public Key>';  /* (1)! */

    grant role sysadmin to user danielwilczak;
    ```   
    { .annotate }

    1.  The public key file will end with ``.pub``. We got this from our "Generate an ssh key step".

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    use role accountadmin;

    create user danielwilczak type = 'service';

    alter user danielwilczak set 
        rsa_public_key='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsLiIQpJ0SkB0KgyN/Cj5
            O+3W3zIN5HvjBwsQnVbXAGpu920fohXRQAFc5hZpMNZOGNsLvl1YY1HtQ15j4K7o
            Ip3Eo2.............................................EUnH8sGWDvH+U
            g5ha+Sa6KD5864ajlkylKFiu9T++GQaItyLNsOVx8AGi8J4oDtv02a6MlG7oDyOo
            ArBubofdmM+8exWL7NfYNfV04Wjnpz5itGNq9CM718Fx910mom4sIUPBGQC0Dnio
            Wr9cvDxXmfWdRUjgeKDGAwrvXP9+PtCMoLlo+eYjWhz9Gii2lxdHqfLgY67ZCa1t
            ZQIDAQAB';
    
    grant role sysadmin to user danielwilczak;
    ```

=== ":octicons-image-16: Result"

    ``` linenums="1"
    Statement executed successfully.
    ```

### Table
Lets create the table in Snowflake to load data into.

??? note "If you don't have a database, schema or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql linenums="1"
        use role sysadmin;
        
        -- Create a database to store our schemas.
        create database if not exists raw;

        -- Create the schema. The schema stores all our objectss.
        create schema if not exists raw.kinesis;

        /*
            Warehouses are synonymous with the idea of compute
            resources in other systems. We will use this
            warehouse to call our user defined function.
        */
        create warehouse if not exists development 
            warehouse_size = xsmall
            initially_suspended = true;

        use database raw;
        use schema kinesis;
        use warehouse development;
        ```


=== ":octicons-image-16: Table"

    ```sql linenums="1"
    use role sysadmin; 

    create or replace table taxi_data (
        vendor_id NUMBER, 
        tpep_pickup_datetime VARCHAR, 
        tpep_dropoff_datetime VARCHAR, 
        passenger_count NUMBER, 
        trip_distance FLOAT, 
        ratecode_id NUMBER, 
        store_and_fwd_flag TEXT, 
        pu_location_id NUMBER, 
        do_location_id NUMBER, 
        payment_type NUMBER, 
        fare_amount FLOAT, 
        extra FLOAT, 
        mta_tax FLOAT, 
        tip_amount FLOAT, 
        tolls_amount FLOAT, 
        improvement_surcharge FLOAT, 
        total_amount FLOAT,
        congestion_surcharge FLOAT
    );
    ```

=== ":octicons-image-16: Result"

    ``` linenums="1"
    Table TAXI_DATA successfully created.
    ```


## AWS Setup :octicons-feed-tag-16:
Lets setup AWS to recieve data via a stream and the move it to Snowflake via firehose. In the process we will create a user and credentials.

### Stream
Lets start by heading into aws and going to Kinesis.
![start](images/02.png)

Create a data stream.
![create](images/03.png)

Lets give it a name and select on-demand as we only want to be changed as we use it.
![Name and demand](images/04.png)

Click create stream.
![click create](images/05.png)

Once it's created we'll want to copy the region. In this case us-east-1. We will use this later in our data generator.
![Two keys](images/06.png)

### Firehouse
Next we'll want to search for kinesis firehose. Firehose will be the tool that moves our stream to Snowflake.
![search firehose](images/07.png)

Click create firehouse stream. 
![click create](images/08.png)

We'll wanted to select kinesis data stream as a source and destination being Snowflake. Next give it a name and click "browse" to find our stream we setup earlier.
![starting inputs](images/09.png)

Select our stream.
![select stream](images/10.png)

Next we'll want to copy our Account url from Snowflake.
![Account URL](images/11.png)

First, paste your Snowflake URL. Next, select "Private Key" and enter your Snowflake username along with the kinesis private key we generated earlier. For the role, choose "Customer Snowflake Role" and specify ``SYSADMIN``.
![configurations part 1](images/12.png)

For the database configuration we'll enter ``RAW`` for the database, ``KINESIS`` for the schema name and ``TAXI_DATA`` for the table. We'll also want it to use the keys as column names when it's dropped into Snowflake.
![configurations part 2](images/13.png)

For the backup settings we'll create a new bucket.
![backup bucket](images/14.png)

We'll give the bucket a name and then scroll down and click create.
![create bucket](images/15.png)

We'll go back and select our bucket we just created. If it does not show up right away, try clicking the refresh button in the top right.
![select bucket](images/16.png)

Finish by clicking create firehose.
![click create](images/17.png)

Finished our firehouse setup and ready to have data moved to Snowflake.
![finished firehose setup](images/18.png)

### AWS User / Access Key
Now for our data generator to be able to connect we'll need a AWS user, credentials to work with kinesis and an access key/secret. In this setup we will set that up.

#### User
Lets start by searching ``IAM`` and the going to users.
![Users](images/19.png)

Click create a new user.
![create user](images/20.png)

Give your user a name and click next.
![name](images/21.png)

We need to attach a policy directly. Search for "Kinesis" and select ``AmazonKinesisFullAccess``. This policy grants the permissions needed to push data to the stream. Once selected, click Next to proceed.
![policy](images/22.png)

Click create user.
![create](images/23.png)

#### Access Key
After the user is created we'll select it by clicking on it's name.
![select user](images/24.png)

We'll want to create a access key by clicking "Create access key".
![select create key](images/25.png)

The key will be used for the CLI.
![CLI](images/26.png)

Click create access key.
![click access key](images/27.png)

Now we'll want to copy our access key and secret access key, so we can put it into our CLI configuration in the next step.
![start](images/28.png)


## AWS CLI Setup  :octicons-feed-tag-16:
In this section we'll setup the AWS SLI to be able to connect to our stream via python. I suggest using the GUI installer for this example.

[https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Click, download the cli and install it. It's pretty straight forward.
![Two keys](images/29.png)


Once installed well want to call and fill in the questions:
=== ":octicons-image-16: Code"

    ```bash linenums="1"
    aws configure
    ```

=== ":octicons-image-16: Result"

    ``` linenums="1"
    dwilczak /snowflake/aws/kinesis/files:aws configure
        AWS Access Key ID [None]: AKIAUZES76LQB6ZQHYEM
        AWS Secret Access Key [None]: MbxsSKg4voO+c773.....cxwlYHWxB/Vsjdc
        Default region name [None]: us-east-1
        Default output format [None]: 
    ```

![Two keys](images/30.png)

## Python data generator  :octicons-feed-tag-16:
Now we are ready to start generating the data that will be passed to kinesis and then loaded into our Snowflake table. We'll want to open the folder of the files we downloaded at the start of the tutorial.

Lets start by updating our code to use the stream we setup at the beginning. Inside our ``main.py`` we'll update:

=== ":octicons-image-16: Code"

    ```py linenums="1"
    StreamName="<YOUR KINESIS STREAM NAME>",  # Name of the Kinesis stream
    ```

=== ":octicons-image-16: Result"

    ```py linenums="1"
    StreamName="danielwilczak_stream",  # Name of the Kinesis stream
    ```


Next we'll want to run that code to start generating the data which will be moved to Snowflake.
=== ":octicons-image-16: Code"

    ```bash linenums="1"
    python -m venv venv 
    source venv/bin/activate
    pip install -r requirements.txt
    python main.py
    ```

=== ":octicons-image-16: Result"

    ``` linenums="1"
    Message sent #1
    Message sent #2
    Message sent #3
    Message sent #4
    ...
    ```

We will be able to see the messages being sent to kinesis. Now we should start seeing our data being move to Snowflake. If you don't check your firehose logs. You might have a connection issue.
![Two keys](images/31.png)

## Result  :octicons-feed-tag-16:
Now we should see our data being loaded into Snowflake.
![Two keys](images/32.png)

If we refresh our page we'll see new records being streamed into our table.
![Two keys](images/33.png)