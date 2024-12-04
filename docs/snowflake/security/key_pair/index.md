# Key Pair Authentication
In this tutorial we will show how to setup a user with key pair authentication. We will then use a python example to connect to our account and run a simple query.

For the official Snowflake documentation this tutorial was based on:
[https://docs.snowflake.com/en/user-guide/key-pair-auth](https://docs.snowflake.com/en/user-guide/key-pair-auth)

## Video
Video is still in development.

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

=== ":octicons-image-16: Setup"

    ```sql linenums="1"
    use role useradmin;

    create user danielwilczak
        default_role = sysadmin;

    alter user danielwilczak set 
        rsa_public_key='<Public Key>';  /* (1)! */
    ```   
    { .annotate }

    1.  The public key file will end with ``.pub``. We got this from our "create key step".

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    use role useradmin;

    create user danielwilczak
        default_role = sysadmin;

    alter user danielwilczak set 
        rsa_public_key='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsLiIQpJ0SkB0KgyN/Cj5
            O+3W3zIN5HvjBwsQnVbXAGpu920fohXRQAFc5hZpMNZOGNsLvl1YY1HtQ15j4K7o
            Ip3Eo2.............................................EUnH8sGWDvH+U
            g5ha+Sa6KD5864ajlkylKFiu9T++GQaItyLNsOVx8AGi8J4oDtv02a6MlG7oDyOo
            ArBubofdmM+8exWL7NfYNfV04Wjnpz5itGNq9CM718Fx910mom4sIUPBGQC0Dnio
            Wr9cvDxXmfWdRUjgeKDGAwrvXP9+PtCMoLlo+eYjWhz9Gii2lxdHqfLgY67ZCa1t
            ZQIDAQAB';
    ```

=== ":octicons-image-16: Result"

    ``` linenums="1"
    Statement executed successfully.
    ```

With our key now set on the user, we might want to test it via local python. [Here is a tutorial to test it](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/security/python/).


