# Container Services - Introduction
Goal of this tutorial is to get a introduction to Snowflake Container services.

## Video
Video coming soon.

## Requirements 
- Be in a [container services enabled region](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#available-regions).  
- You [CAN NOT be on a trial account](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview).

## Download
- [Flask Application and Docker File](#)

## Setup :octicons-feed-tag-16:
Let's start by setting up Snowflake before we jump to docker. Create a worksheet in snowflake and add / run the code below.

??? note "If you don't have a database, schema or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql
        use role sysadmin;
        
        -- Create a database to store our schemas.
        create database raw;

        -- Create the schema. The schema stores all our objectss.
        create schema raw.container;

        /*
            Warehouses are synonymous with the idea of compute
            resources in other systems. We will use this
            warehouse to call our user defined function.
        */
        create warehouse if not exists developer 
            warehouse_size = xsmall
            initially_suspended = true;

        use database raw;
        use schema container;
        use warehouse developer;
        ```

=== ":octicons-image-16: Setup"

    ```sql linenums="1"
    -- You can not use Account Admin for containers.
    use role sysadmin

    -- This enables us to login to our application via a website url.
    create or replace security integration snowservices_ingress_oauth
        type=oauth
        oauth_client=snowservices_ingress
        enabled=true;

    -- Compute pool to run containers on.
    create compute pool cpu_x64_xs instance_family = cpu_x64_xs;

    -- Image registry to store our application code.
    create or replace image repository images;

    -- Give us the url to upload our docker container to.
    show image repositories;
    select "repository_url" from table(result_scan(last_query_id()));
    ```

=== ":octicons-image-16: Result"

    MARKDOWN TABLE HERE



### Snowflake

### Build Application
Our goal is to run the application locally and check if it works and then upload the dockerfile / image to our snowflake image repository so it can be hosted on Snowflake container services.

!!! Note
    Please install docker desktop - [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)


Using terminal, navigate to the folder that has the docker file you downloaded. For those not familiar with terminal you can right click the folder on MAC and click "New Terminal at folder". (1)
{ .annotate }

1.  ![Terminal](images/6.png)

=== ":octicons-image-16: Build and Run"

    ```bash linenums="1"
    docker build --rm -t flask:website .
    docker run --rm -p 8080:8080 flask:website
    ```

Now you can go to [ADD URL HERE](). To see what the website will look like.

### Upload

Now that we have our image created. Lets upload it to Snowflake. We will need our Snowflake image url (1) that we got from our Snowflake setup.
{ .annotate }

1.  | repository_url                                                                    |
    |-----------------------------------------------------------------------------------|
    | sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/llm/llama/image    |



=== ":octicons-image-16: Code"

    ```bash linenums="1"
    docker tag flask:website <URL GOES HERE>/flask:website
    ```

=== ":octicons-image-16: Example"

    ```bash linenums="1"
    docker tag flask:website \
    sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/llm/llama/image/flask:website
    ```

Next docker login to our snowflake image repo and upload the image. We will use the login name that has access to **sysadmin** role.
=== ":octicons-image-16: Code"

    ```bash linenums="1"
    docker login <FIRST PART OF THE URL> -u danielwilczak
    ```
=== ":octicons-image-16: Example"

    ```bash linenums="1"
    docker login sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/ -u danielwilczak
    ```


Finally push the image to your image repository living on Snowflake.
=== ":octicons-sign-out-16: Code"

    ```bash linenums="1"
    docker push <URL GOES HERE>/flask:website
    ```
=== ":octicons-sign-out-16: Example"

    ```bash linenums="1"
    docker push sfsenorthamerica-demo-dwilczak.registry.snowflakecomputing.com/llm/llama/image/flask:website
    ```

## Snowflake :octicons-feed-tag-16:
Lets switch back to snowflake to start our container.

### Run the container service
Create the service with our inline service specification and go to the URL given.

=== ":octicons-image-16: SQL"

    ```sql linenums="1"
    use role sysadmin

    -- Create the service that will host our containerized application.
    create service website
        in compute pool cpu_x64_xs
        from specification $$
        spec:
            container:  
            - name: website
            image: /raw/container/image/flask:website
            
            endpoint:
            - name: llama
            port: 8080
            public: true
        $$;

    -- Give us a URL to see our application.
    show endpoints in service website;
    select "ingress_url" from table(result_scan(last_query_id()));
    ```

=== ":octicons-image-16: Result"
    | ingress_url                                                        |
    |--------------------------------------------------------------------|
    | zwxbzi-sfsenorthamerica-demo-dwilczak.snowflakecomputing.app       |

## Clean up script :octicons-feed-tag-16:
If you don't plan to keep this running. Which I don't reccomend considering it's using .11 credits per hour. Here is a clean up script.

=== ":octicons-image-16: SQL"

    ```sql linenums="1"
    use role sysadmin;

    drop service website;
    drop compute pool cpu_x64_xs;
    drop warehouse developer;
    drop database container;
    ```

=== ":octicons-image-16: Result"
    | status                              |
    |-------------------------------------|
    | CONTAINER successfully dropped.     |


