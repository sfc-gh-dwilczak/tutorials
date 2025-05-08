# Sharing - Listing
In this tutorial, we’ll walk through how to share data with another Snowflake account using a listing, even if the account is on a different cloud provider than your own.

## Video
Video still in development.

## Requirements
- Snowflake account, you can use a [free trial](https://signup.snowflake.com/). We also assume no complex security needs.

## Setup  :octicons-feed-tag-16:
Lets start by setting up our second account in our Snowflake orginization so that we can go through the process of sharing with a real life account.

### Second Account
To create anther account please follow this [tutorial](https://sfc-gh-dwilczak.github.io/configurations/account/add/) (3 minutes). In this tutorial we will setup the second account in Azure while our primary account is in AWS.

Now that we have our second account we'll need that account's ``Data Sharing Account Identifier``. Lets start by going to our account details.
![account details](images/01.png)

Copy the ``Data Sharing Account Identifier``, we'll need this for later.
![copy account locator](images/02.png)


### Data
Lets now create some data to be shared with our second account. Lets start a sql worksheet and add the code below.

??? note "If you don't have a database, schema or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql linenums="1"
        use role sysadmin;
        
        -- Create a database to store our schemas.
        create database if not exists sharing;

        -- Create the schema. The schema stores all our objectss.
        create schema if not exists sharing.data;

        /*
            Warehouses are synonymous with the idea of compute
            resources in other systems. We will use this
            warehouse to call our user defined function.
        */
        create warehouse if not exists development 
            warehouse_size = xsmall
            auto_suspend = 30
            initially_suspended = true;

        use database sharing;
        use schema data;
        use warehouse development;
        ```


=== ":octicons-image-16: Table"

    ```sql linenums="1"  
    create or replace table customers (
        id number autoincrement primary key,
        name string,
        email string
    );

    insert into customers (name, email)
        values
        ('john doe', 'john@example.com'),
        ('jane smith', 'jane@example.com'),
        ('carlos mendez', 'carlos@example.com');
    ```

=== ":octicons-sign-out-16: Result"

    | number of rows inserted |
    |-------------------------|
    | 3                       |

### Data Share

!!! note

    You must be using accountadmin or the button/dropdown won't show up. 

Now that we have our table, lets create a data share listing by going to private sharing and then in the top right click the dropdown to "Publish to Specified Consumer".
![navigate](images/03.png)

We'll give the listing a name, select "Only specified consumers" and click next.
![create listing](images/04.png)

We'll start with selecting our data.
![UPDATE](images/05.png)

Select our table.
![UPDATE](images/06.png)


!!! note "If you get error: This product can be shared only in the local region"

    If you see this error:
    ![Error](images/07.png)
    
    You will need to use the main orginizational account to enable the primary account your working in to share with other providers/region.

    === ":octicons-image-16: Code"

        ```sql linenums="1"  
        CALL SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT('<account_name>');
        ```

    === ":octicons-sign-out-16: Example"

        ```sql linenums="1"  
        CALL SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT('tutorials_aws');
        ```

    === ":octicons-sign-out-16: Result"

        | SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT |
        |-----------------------------------------------|
        | Statement executed successfully.              |

We'll give our share object a name, description and then we'll enter the ``Data Sharing Account Identifier``.
![UPDATE](images/08.png)

Once we enter our ``Data Sharing Account Identifier`` we'll see new options show up to allow us to set the data replication refresh internal. This will be how often the dat will be refreshed.
![UPDATE](images/09.png)

Now our listing is live and shared with our second account. Once it's added to the second account it will replicate the data and the second account will have access to the shared data.
![UPDATE](images/10.png)

### Second Account
Now that we have our data shared, lets add it to the second account. Lets go into our Azure account and add the data. You must use the accountadmin role.
![UPDATE](images/11.png)

!!! note

    You might have to validate your email before you can add the data share. Also keep in mind your must use the ``accountadmin`` role to add the data share.

Now that you have added it, it will start to replicate the data from AWS to Azure, this may take a fiew minutes depending on the volume of data. You'll recieve an email once the data is avaliable.
![UPDATE](images/12.png)

Now that the data is avaliable lets add it again. We'll give it a name and add it to the account.
![UPDATE](images/13.png)

Your data is now added.
![UPDATE](images/14.png)

We can see the new shared database in our accont with our table.
![UPDATE](images/15.png)

### Bonus - Sharing filtered data
We might want to only share specific data to anther account without that account knowing how we filtered the data. To do this we will create a [secure view](https://docs.snowflake.com/en/user-guide/views-secure) on top of our table to filter only to rows with the name "john doe".

=== ":octicons-image-16: View"

    ```sql linenums="1"  
    create or replace secure view filtered_customers as
        select
            *
        from
            customers
        where
            name = 'john doe';
    ```

=== ":octicons-sign-out-16: Result"

    | status                                        |
    |-----------------------------------------------|
    | View FILTERED_CUSTOMERS successfully created. |

Now this secure view can be selected instead of our table in the data share.
![update data share](images/16.png)

Lets edit our data share.
![edit](images/17.png)

Lets uncheck our original table and select our secure view.
![add secure view](images/18.png)

Click save.
![save](images/19.png)

Now we can go to our second account and see that now the secure view object has been added and only the one row is now avaliable.
![vew secure view data](images/120.png)