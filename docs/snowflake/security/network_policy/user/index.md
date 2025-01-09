# Network Policy - User level
In this tutorial we will show how you can create a network policy that is only applied to an individual user.

## Video
Video in development

## Requirement
- Snowflake account, you can use a [free trial](https://signup.snowflake.com/). We also assume no complex security needs.

## Walk Through :octicons-feed-tag-16:
Lets start the network setup prcoess in Snowflake. 

??? note "If you don't have a database, schema or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql
        use role sysadmin;
        
        -- Create a database to store our schemas.
        create database if not exists raw;

        -- Create the schema. The schema stores all our objectss.
        create schema if not exists raw.policy;

        /*
            Warehouses are synonymous with the idea of compute
            resources in other systems. We will use this
            warehouse to call our user defined function.
        */
        create warehouse if not exists development 
            warehouse_size = xsmall
            initially_suspended = true;

        use database raw;
        use schema policy;
        use warehouse development;
        ```


We'll need a user to apply the policy to. Typically this is applied to a service user with an [Key Pair](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/security/key_pair/) but you can apply it to who ever you want. You'll also want to update your I.P addresses since these are just for an example.
=== ":octicons-image-16: Code"

    ```sql linenums="1"
    use role accountadmin;

    -- Create the user.
    create user <username> type = 'service';

    -- OPTIONAL: Instead of using a password we can use an Key Pair.
    -- alter user danielwilczak set rsa_public_key='';

    -- Give the user a role.
    grant role <role_name> to user <username>;

    -- Create the policy and add the I.P's that are allowed.
    create network policy <policy_name> 
        allowed_ip_list = ('<IP ADDRESS>','<SECOND IP ADDRESS IF NEEDED>');

    
    alter user <username> set network_policy = <policy_name> ;
    ```

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    use role accountadmin;

    -- Create the user.
    create user danielwilczak type = 'service';

    -- Give the user a role.
    grant role sysadmin to user danielwilczak;

    -- OPTIONAL: Instead of using a password we will use an Key Pair.
    /* 
    alter user danielwilczak set 
        rsa_public_key='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzd7lfIGps+lBXrVCT05l
    92rDpYUsXyjtvAu26Q2z0k3/7n7HnZNmKjreIlGQJZlBe0Eud4LzqGX9Vbp53G2F
    oZePQSy46rxXQ9bmCGlF8tGhV7gOgh7D/LGfLHhtVt+b4BhPWLgOqOqCDUv+MXlY
    N+JgeOqpEHPstfqGc7XsbdZJtCalMpjYq0o8aC1qJVv+ry9W+8xmfTRUSq6B0de8
    Y9XBEAhJu/3tJkyDSqs7ZEXR9F02hQ3WlmfQEExaktcpIm1l+3beupmCoCliFfoN
    bdcZegiIdFmGcYRmKba+YpQ3yqpqcqAlCErdqwql8rscJTGx0/AnxyaeX5Qtr86c
    1wIDAQAB'; */

    -- Create the policy and add the I.P's that are allowed.
    create network policy my_policy 
        allowed_ip_list = ('18.210.29.198','34.230.230.9');
    
    -- Apply the policy to just the user.
    alter user danielwilczak set network_policy = my_policy;
    ```

=== ":octicons-sign-out-16: Result"

    | status                              |
    |-------------------------------------|
    | Statement executed successfully.    |


Now the network policy has been applied to your user.