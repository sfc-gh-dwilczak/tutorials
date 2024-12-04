# Key Pair Authentication
In this tutorial we will show how to connect to your Snowflake account via python with an authentication token/key.

For the official Snowflake documentation this tutorial was based on:
[https://docs.snowflake.com/en/user-guide/key-pair-auth](https://docs.snowflake.com/en/user-guide/key-pair-auth)

## Video
Video is still in development.

## Requirement
- This tutorial assumes you have nothing in your Snowflake account ([Trial](https://signup.snowflake.com/)) and no complex security needs.
- This tutorial assumes you've already have a private key, [if not here is a tutorial](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/security/key_pair/)


## Download needed files:
- Files ([Link](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/security/python/files.zip))


## Install
Lets start by updating our code to use the stream we setup at the beginning. Inside our ``main.py`` we'll update:

!!! warning "Using the correct account locator."

    If your Snowflake account is in anther region other then US EAST (Oregon). Please append your locator with the region ``xy12345.us-east-1`` read the [Account Identifiers](https://docs.snowflake.com/en/user-guide/admin-account-identifier#non-vps-account-locator-formats-by-cloud-platform-and-region) documentation to learn how to format your account locator based on your region. 

=== ":octicons-image-16: Code"

    ```py linenums="1"
    user='<User Name>',  #(1)! 
    account='<Account Locator>',  #(2)!
    ```
    { .annotate }
    
    1.  Name we gave to the user in our setup section.

    2.  ![Account locator](images/02.png)

=== ":octicons-image-16: Result"

    ```py linenums="1"
    user='danielwilczak',
    account='GGB82720',
    ```

## Run
Here is the code we'll use. Please fill in the two needed areas.

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
    ('DANIELWILCZAK',)
    ```