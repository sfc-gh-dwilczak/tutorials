# Tableau - Snowflake OAuth Authentication
In this tutorial we will show how to connect to snowflake via tableau with OAuth as the authenitcation method. Snowflake official documentation can be found here: 

## Video
Video is still in development.

## Requirement
This tutorial assumes you have nothing in your Snowflake account ([Trial](https://signup.snowflake.com/)) and no complex security needs.

!!! warning
    You can not use the ACCOUNTADMIN or SECURITYADMIN role by default. [Documentation on this block.](https://docs.snowflake.com/en/user-guide/oauth-partner#blocking-specific-roles-from-using-the-integration)

!!! Note
    If you do want to use ACCOUNTADMIN or SECURITYADMIN roles please submit a support ticket allowing it with the integration name created below.

## Snowflake :octicons-feed-tag-16:
Lets start in Snowflake first.

### Intergration
Start a worksheet and add either or both security integrations below.

=== ":octicons-image-16: Code"

    ```sql linenums="1"
    use role accountadmin;

    -- For tableau desktop
    create security integration tableau_desktop_oauth
        type = oauth
        enabled = true
        oauth_client = tableau_desktop;

    -- For tableau cloud
    create security integration tableau_cloud_oauth
        type = oauth
        enabled = true
        oauth_client = tableau_server;
    ```

### Account URL
Before we leave Snowflake we'll want to copy our account url to later add to tableau.
![account indo](images/01.png)

Next you'll see the url
![account url](images/02.png)

## Tableau Desktop :octicons-feed-tag-16:
Lets start by adding Snowflake as a source. Search for Snowflake in "Connect to Server".
![UPDATE](images/03.png)

!!! warning
    You can not use the ACCOUNTADMIN or SECURITYADMIN role by default. [Documentation on this block.](https://docs.snowflake.com/en/user-guide/oauth-partner#blocking-specific-roles-from-using-the-integration)

!!! Note
    If you do want to use ACCOUNTADMIN or SECURITYADMIN roles please submit a support ticket allowing it with the integration name created below.

Once Snowflake is selected you'll want to enter your Snowflake account URL, role, warehouse and select sign in using OAuth.
![credentials](images/04.png)

Once you click "Sign in" a browser will appear for login/approval.
![sign in](images/05.png)

Login with your user.
![login](images/06.png)

Click allow for tableau to connect to your Snowflake user.
![allow](images/07.png)

Success your OAuth is setup.
![success](images/08.png)

## Tableau Cloud :octicons-feed-tag-16:
Go to "My account settings" on the top right.
![account sesstings](images/09.png)

Select Snowflake as a source.
![select source](images/10.png)

Select "OAuth Credential" as authentication and click Add.
![select euthentication](images/11.png)

!!! warning
    You can not use the ACCOUNTADMIN or SECURITYADMIN role by default. [Documentation on this block.](https://docs.snowflake.com/en/user-guide/oauth-partner#blocking-specific-roles-from-using-the-integration)

!!! Note
    If you do want to use ACCOUNTADMIN or SECURITYADMIN roles please submit a support ticket allowing it with the integration name created below.

Enter your account URL we copied earlier and the role to be used once authenticated
![enter account information](images/12.png)

Login to your user.
![login](images/13.png)

Allow tableau to use your user/role.
![allow access](images/14.png)

Click test to validate the source works, and we're finished!
![success](images/15.png)
