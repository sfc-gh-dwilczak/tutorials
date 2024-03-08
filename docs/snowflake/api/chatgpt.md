# Chatgpt in Snowflake
In this tutorial we will show you how to integrate chatgpt "Open.ai" into a user defined function in Snowflake, so it can be used anywhere.

## Video
Video still in development.

## Requirement
This tutorial assume you have an account with [openai.com](openai.com). You will need to get an api token from it.

## Setup
In this section we will do the setup to create our user-defined function by:

- Creating a database and schema.
- Allowing snowflake to talk with openai's api.
- Add our api key secret.
- Granting access to the integration to our sysadmin role.

=== ":octicons-image-16: Setup"

    ```sql linenums="1"
    use role accountadmin;

    create database api;
    create schema functions;

    create or replace network rule chatgpt_network_rule
        mode = egress
        type = host_port
        value_list = ('api.openai.com');

    create or replace secret chatgpt_api_key
        type = generic_string
        secret_string='OPENAI API KEY HERE';

    create or replace external access integration openai_integration
        allowed_network_rules = (chatgpt_network_rule)
        allowed_authentication_secrets = (chatgpt_api_key)
        enabled=true;
    ```


## Example

Let's create the user defined function and then use it.

=== ":octicons-image-16: Function"

    ```python linenums="1"

    create or replace function raw.api.chatgpt("question" varchar(16777216))
        returns varchar(16777216)
        language python
        runtime_version = '3.8'
        packages = ('requests','openai')
        handler = 'ask_chatgpt'
        external_access_integrations = (openai_integration)
        secrets = ('cred'=chatgpt_api_key)
    as
    $$
    import _snowflake
    import requests

    from openai import OpenAI

    session = requests.Session()

    def ask_chatGPT(question):
        openai_api_key = _snowflake.get_generic_secret_string('cred')

        client = OpenAI(api_key=openai_api_key)
        completion = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": question}]
        )    
        return completion.choices[0].message.content
    $$;

=== ":octicons-image-16: Use"

    ```sql linenums="1"
    select chatGPT('Can you tell me how amazing daniel's tutorials are?'); 
    ```

=== ":octicons-image-16: Result"
    TABLE
