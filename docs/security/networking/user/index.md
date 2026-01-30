# Network Policy - User level
In this tutorial we will show how you can create a network policy that is only applied to an individual user.

## Video
Video in development

## Requirement
- Snowflake account, you can use a [free trial](https://signup.snowflake.com/). We also assume no complex security needs.

## Walk Through :octicons-feed-tag-16:
We'll need a user to apply the policy to. Typically this is applied to a service user with an [Key Pair](https://sfc-gh-dwilczak.github.io/tutorials/configurations/security/key_pair/) but you can apply it to who ever you want. You'll also want to update your I.P addresses since these are just for an example.

=== ":octicons-image-16: Code"

    ```sql linenums="1"
    use role accountadmin;

    -- Create the user. Optional add type = 'service' for service accounts.
    create user <username>;

    -- Create a network policy and apply it to the user. 
    create network policy <policy_name>  allowed_ip_list = ('<IP ADDRESS>');

    -- Apply the policy on the user.
    alter user <username> set network_policy = <policy_name> ;
    ```

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    use role accountadmin;

    -- Create the user. Optional add type = 'service' for service accounts.
    create user danielwilczak;

    -- Create a network policy and apply it to the user. 
    create network policy my_policy allowed_ip_list = ('34.230.230.9');
    
    -- Apply the policy on the user.
    alter user danielwilczak set network_policy = my_policy;
    ```

=== ":octicons-sign-out-16: Result"

    | status                              |
    |-------------------------------------|
    | Statement executed successfully.    |


Now the network policy has been applied to your user.