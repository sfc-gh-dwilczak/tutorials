In all of my tutorials, I like to use a standard architecture for what I believe will work for 80% of Snowflake users, no matter how much data you have. It is a style guide to your Snowflake environment. As a guide, feel free to deviate. I am constantly updating the architecture as I learn from others.

## Code
If your like me, you hate reading tutorials. Just show me the full code. So here is my full one file code to setup my snowflake architecture in one shot. This does not include integration:

=== ":octicons-image-16: Code"

    ```sql
    -- Long code bloc.
    ```

=== ":octicons-sign-out-16: Result"

    ```
    Update
    ``` 

## Broken down:

### 1. ADMIN!
You must understadn the admin in snowflake or you're snowflake is doomed from the get go and will end up being disorginized.

IMAGE IMAGE IMAGE.

- **UserAdmin** - This is like HR at your company, they are here to onboard users and give them roles.

- **SecurityAdmin** - This is like security at your company. They don't make anything, they just give access to stuff.

- **SysAdmin** - This is like your developer at your company they can make things but not give access to stuff or onboard users.

- **Accountadmin** - This is god. He does whatever he wants but we don't want him to always be doing stuff. Only important things.


### 2. Users:
Creating a new user might be the first think you do on snowflake. The code below shows how to user **useradmin** and how to create a user. In these tutorials I will always use my snowflake email. Please don't add me to your account. I already have plenty of work to do lol.



=== ":octicons-image-16: Code"

    ```sql
    use role useradmin;

    -- Create our first user.
    CREATE USER "daniel.wilczak@snowflake.com"
        PASSWORD='Password12'
        MUST_CHANGE_PASSWORD = True;
    ```

=== ":octicons-sign-out-16: Result"

    ```
    User daniel.wilczak@snowflake.com successfully created.
    ```

### 3. Databases
There should be three primary databases in your Snowflake account. They are **Raw**, **Warehouse**, **Reporting**.

=== ":octicons-image-16: Code"

    ```sql
    Code here
    ```

=== ":octicons-sign-out-16: Result"

    ```
    Result here.
    ```