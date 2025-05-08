# Key Pair Authentication
In this tutorial we will show how to setup a user with key pair authentication. We will then use a python example to connect to our account and run a simple query.

For the official Snowflake documentation this tutorial was based on:
[https://docs.snowflake.com/en/user-guide/key-pair-auth](https://docs.snowflake.com/en/user-guide/key-pair-auth)

## Video
<iframe width="850px" height="478px" src="https://www.youtube.com/embed/WdCLossuS8U?si=06NU0Kv466KnmWu3" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Requirement
This tutorial assumes you have nothing in your Snowflake account ([Trial](https://signup.snowflake.com/)) and no complex security needs.

## Create Key
Lets create the private and public key so that we can apply the public key to our user.

=== ":octicons-image-16: Setup"

    ```bash linenums="1"
    openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
    openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
    ```   

=== ":octicons-image-16: Result"

    ```bash linenums="1"
    Writing RSA key.
    ```

This will create two files in the folder we are currently located.
![Two keys](images/01.png)

## Apply key to user
Lets apply the public key to our user in Snowflake. The public key file will end with ``.pub``.

=== ":octicons-image-16: Code"

    ```sql linenums="1"
    use role accountadmin;

    -- Create the user. Optional add type = 'service' for service accounts.
    create user <username>;

    -- Give the user a role.
    grant role <role_name> to user <username>;

    -- Apply the public key to the user.
    alter user <username> set rsa_public_key='<Public Key>';

    /* (OPTIONAL) Create a network policy and apply it to the user. 
    create network policy <policy_name>  allowed_ip_list = ('<IP ADDRESS>');

    alter user <username> set network_policy = <policy_name> ; /* 
    ```

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    use role accountadmin;

    -- Create the user. Optional add type = 'service' for service accounts.
    create user danielwilczak;

    -- Give the user a role.
    grant role sysadmin to user danielwilczak;

    -- Apply the public key to the user.
    alter user danielwilczak set 
        rsa_public_key='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
    zd7lfIGps+lBXrVCT05l 92rDpYUsXyjtvAu26Q2z0k3/7n7HnZNmKjreIlGQJZl
    Be0Eud4LzqGX9Vbp53G2FoZePQSy46rxXQ9bmCGlF8tGhV7gOgh7D/LGfLHhtVt+
    b4BhPWLgOqOqCDUv+MXlYN+..................bdZJtCalMpjYq0o8aC1qJVv
    +ry9W+8xmfTRUSq6B0de8Y9XBEAhJu/3tJkyDSqs7ZEXR9F02hQ3WlmfQEExaktc
    pIm1l+3beupmCoCliFfoNbdcZegiIdFmGcYRmKba+YpQ3yqpqcqAlCErdqwql8rs
    cJTGx0/AnxyaeX5Qtr86c1wIDAQAB';

    /* (OPTIONAL) Create a network policy and apply it to the user. 
    create network policy my_policy allowed_ip_list = ('34.230.230.9');
    
    alter user danielwilczak set network_policy = my_policy; */
    ```

=== ":octicons-sign-out-16: Result"

    | status                              |
    |-------------------------------------|
    | Statement executed successfully.    |

With our key now set on the user, we might want to test it via local python. [Here is a tutorial to test it](https://sfc-gh-dwilczak.github.io/tutorials/configurations/security/python/).


