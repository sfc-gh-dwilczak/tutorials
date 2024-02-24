# Container Services - CPU Jupyter Notebook Setup:
Goal of this tutorial is to get a [Jupyter Notebook](https://jupyter.org/) instance running on Snowflake's container services and have the capability to saving files to a stage. This tutorial assumes you have nothing in your Snowflake account ([Trial](https://signup.snowflake.com/)) and no complex security needs.

## Video
Video coming soon.

## Snowflake
Let's start by setting up snowflake before we jump to docker.

### Setup

Create a worksheet in snowflake and add the code below. Please fill in a password and hit run:

=== ":octicons-image-16: Code"

    ```sql
    set role_name       = 'container_jupyter';
    set user_name       = 'container_jupyter';
    set user_password   = '';
    set warehouse_name  = 'jupyter';

    set database_name   = 'container';
    set schema_name     = 'jupyter';

    set pool_name       = 'container_jupyter';
    set repo_name       = 'image_repo';
    set stage_name      = 'image_stage';
    set service_name    = 'jupyter';
    set service_file    = 'service.yaml';

    use role accountadmin; 

    -- Create a user for container services:
    create user if not exists identifier($user_name)
        password = $user_password
        default_warehouse = $warehouse_name
        must_change_password = false
        comment = 'Jupyter notebook in container services.';

    -- Create role for container services and grant the role to sysadmin and our user:
    create role if not exists identifier($role_name);
    grant role identifier($role_name) to role sysadmin;
    grant role identifier($role_name) to user identifier($user_name);
    

    -- Set the default role for the user to our role. (Required or it wont work).
    alter user identifier($user_name) set default_role = $role_name;

    -- Create the compute pool:
    create compute pool identifier($pool_name)
    min_nodes = 1
    max_nodes = 1
    instance_family = standard_1
    comment='Container compute that will be used for juypter notebooks.';

    -- Grant role required services 
    -- (https://docs.snowflake.com/en/sql-reference/sql/create-service#access-control-requirements):
    grant usage   on compute pool identifier($pool_name) to role identifier($role_name);
    grant monitor on compute pool identifier($pool_name) to role identifier($role_name);
    grant bind service endpoint on account to role identifier($role_name);

    -- Create the warehouse. this will be the warehouse used if any snowflake data is queried.
    create warehouse if not exists identifier($warehouse_name)
    warehouse_size = xsmall
    warehouse_type = standard
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;

    -- Grant all warhouse control to our container role.
    grant all on warehouse identifier($warehouse_name) to role identifier($role_name);

    -- create the database were everything will live and give ownership to our container user.
    create database identifier($database_name);
    grant ownership on database identifier($database_name) to role identifier($role_name);

    -- Create a security integration to login to.
    create security integration if not exists snowservices_ingress_oauth
    type=oauth
    oauth_client=snowservices_ingress
    enabled=true;

    -- Setup context for adding schema, image repository and stage.
    use role identifier($role_name);
    use database identifier($database_name);

    -- Adding schema, image repository and stage so it can be used in the notebook.
    create schema identifier($schema_name);  
    use schema identifier($schema_name);
    create or replace image repository identifier($repo_name);
    create or replace stage identifier($stage_name) 
        directory = ( enable = true ) ENCRYPTION = (type = 'SNOWFLAKE_SSE');

    -- Tell us where to upload our docker image to. This will be used later.
    show image repositories;
    select "repository_url" from table(result_scan(last_query_id()));
    ```

=== ":octicons-sign-out-16: Result"
    ```
    | repository_url                                                                                 |
    |------------------------------------------------------------------------------------------------|
    | sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/container/jupyter/image_repo    |
    ```

## Docker

### Download files
Lets [download the files](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/container/cpu/files.zip) we'll need for the docker file and service file later.

### Run Locally 
Our goal is to run the application locally and check it works and then upload the dockerfile / image to our snowflake image repository so it can be hosted on Snowflake container services.

!!! Note
    Please install docker desktop - https://www.docker.com/products/docker-desktop/


Using terminal, navigate to the folder that has the docker file you downloaded. Build and run the docker file locally. Once built, go to [http://localhost:8080/lab](http://localhost:8080/lab) to see the application. You can also see the image was create by going into docker desktop / images tab. Press Ctrl+c to stop the application in terminal.

=== ":octicons-image-16: Build and Run"
    ```bash
    docker build --rm -t jupyter:tutorial . &&
    docker run --rm -p 8080:8888 jupyter:tutorial
    ```

#### Result
![Run locally](images/1.gif)

### Upload

Using terminal and the file / folder from the prior step, tag the image with your repository_url we get from step 1. (1)  Once tagged you can go into docker desktop and see the image that is properly tagged. (2)

1.  | repository_url                                                                                 |
    |------------------------------------------------------------------------------------------------|
    | sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/container/jupyter/image_repo    |

2.  ![Tagged image](images/5.png)


=== ":octicons-image-16: Code"

    ```bash
    docker tag jupyter:tutorial <URL GOES HERE>/jupyter:tutorial
    ```

=== ":octicons-image-16: Example"

    ```bash
    docker tag jupyter:tutorial \
    sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/container/jupyter/image_repo/jupyter:tutorial
    ```

Next docker login to our snowflake image repo and upload the image. We will use the login name **container_jupyter** and the **password you specified at the start** of the tutorial.
=== ":octicons-image-16: Code"

    ```bash
    docker login <FIRST PART OF THE URL> -u container_jupyter
    ```
=== ":octicons-image-16: Example"

    ```bash
    docker login sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/ -u container_jupyter
    ```


Finally push the image to your image repository living on Snowflake.
=== ":octicons-sign-out-16: Code"
    ```bash
    docker push <URL GOES HERE>/jupyter:tutorial
    ```
=== ":octicons-sign-out-16: Example"
    ```bash
    docker push sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/container/jupyter/image_repo/jupyter:tutorial
    ```

#### Result
![Docker Upload](images/4.png)


## Snowflake 

### Upload Service File
Upload the service specification file to the stage. We will use snowflake UI to do this. An example can be seen below.

![Docker Upload](images/3.gif)

### Run the Container
Final step, Create the service from the service specification file and go to the URL given.

=== ":octicons-image-16: SQL"

    ```sql
    set role_name       = 'container_jupyter';

    use role identifier($role_name);

    set pool_name       = 'container_jupyter';
    set stage_name      = 'image_stage';
    set service_name    = 'jupyter';
    set service_file    = 'service.yaml';
        
    CREATE SERVICE identifier($service_name)
        IN COMPUTE POOL identifier($pool_name)
        FROM @image_stage
        SPEC='service.yaml'
        MIN_INSTANCES=1
        MAX_INSTANCES=1;

    show endpoints in service identifier($service_name);
    select "ingress_url" from table(result_scan(last_query_id()));
    ```

=== ":octicons-image-16: Result"
    | ingress_url                                                                                |
    |------------------------------------------------------------------------------------------------|
    | zwxbye-sfsenorthamerica-demo-dwilczak.snowflakecomputing.app    |


!!! Note
    WAIT for public endpoint to **NOT** say: Endpoints provisioning in progress... check back in a few minutes. It will give you a url.

=== ":octicons-sign-out-16: Status"

    ```sql
    show endpoints in service identifier($service_name);
    select "ingress_url" from table(result_scan(last_query_id()));
    ```

### Result
YOUTUBE VIDEO HERE.


