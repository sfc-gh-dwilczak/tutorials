# DBT Development and Production:
In this tutorial, we will guide you through setting up dbt Cloud with Snowflake. Along the way, we'll demonstrate how to configure both your development and production environments.

## Video
<iframe width="850px" height="478px" src="https://www.youtube.com/embed/TnTOl9ayL3Y?si=23hTTYwBhjoFoGHV" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Requirement
- At least a free Snowflake ([trial account](https://signup.snowflake.com/)) and no complex security needs.
- At least a free DBT [developer account](https://www.getdbt.com/signup) and no complex security needs.
- A git repository. I suggest [github](https://github.com/).

## Snowflake :octicons-feed-tag-16:
First lets start in Snowflake by setting up some resources. We'll create one database, two warehouses and one new users using [sysadmin role](https://docs.snowflake.com/en/user-guide/security-access-control-overview).

??? Warning "If your user is using MFA - Please enable token caching before uploading"
    If your planned development user is using MFA. Please enable token caching or else it will ask you for authentication everytime you run anything in dbt.

    ```sql
    alter account set allow_client_mfa_caching = TRUE;
    ```

=== ":octicons-image-16: Setup"

    ```sql linenums="1"
    use role sysadmin;

    -- Create a database to store our schemas.
    create database if not exists dbt;

    -- We'll remove the default schema to keep things clean.
    drop schema dbt.public;

    /*
        Warehouses are synonymous with the idea of compute
        resources in other systems.
    */
    create warehouse if not exists development 
        warehouse_size = xsmall
        auto_suspend = 30
        initially_suspended = true;

    create warehouse if not exists production 
        warehouse_size = xsmall
        auto_suspend = 30
        initially_suspended = true;

    -- User/login used during our production prcoess.
    use role accountadmin;

    create user service_dbt password = '<USER PASSWORD>';

    -- Lets keep the RBAC simple and use sysadmin for everything. 
    grant role sysadmin to user service_dbt;
    ```   

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    use role sysadmin;

    -- Create a database to store our schemas.
    create database if not exists dbt;

    -- We'll remove the default schema to keep things clean.
    drop schema dbt.public;

    /*
        Warehouses are synonymous with the idea of compute
        resources in other systems.
    */
    create warehouse if not exists development 
        warehouse_size = xsmall
        auto_suspend = 30
        initially_suspended = true;

    create warehouse if not exists production 
        warehouse_size = xsmall
        auto_suspend = 30
        initially_suspended = true;

    -- User/login used during our production prcoess.
    use role accountadmin;

    create user service_dbt password = 'Password1234';

    -- Lets keep the RBAC simple and use sysadmin for everything. 
    grant role sysadmin to user service_dbt;
    ```   

=== ":octicons-image-16: Result"

    ``` linenums="1"
    Statement executed successfully.
    ```

## Development :octicons-feed-tag-16:
Lets walk through the development environment setup in dbt. 

### Project
As soon on you login you'll be asked to start a project and give it a name.
![project](images/01.png)

We'll want to add our development environment connection to Snowflake.
![add connection](images/02.png)

### Snowflake
To add our development environment we'll want to get our account identifier. Once copied we'll make sure we replace the ``.`` with a ``-`` otherwise it won't find the account.
![account identifier](images/03.png)

We'll select snowflake and give the connection a name. For the connection settings you'll want to add your account identifier as the account. Please remember to swap ``.`` with a ``-`` otherwise it won't find the account. For the database we'll use ``DBT``, warehouse = ``development`` and role = ``SYSADMIN``.
![Connection setup](images/04.png)

Once saved, dbt will not redirect you to the setup so please click ``Credentials`` and then the project. This will prompt you to click a link that will take you back to the setup page.
![Back to setup](images/05.png)

Select your connection.
![select connection](images/06.png)

!!! Warning "If your user is using MFA"
    If your planned development user is using MFA. This connection test will ask for MFA authentication.

Now we'll want to enter our own development credentials and then select ``test connection`` to validate everything.
![dev credentials](images/07.png)

Once tested you will see a ``complete`` status. From there we'll click save.
![testing dev creds](images/08.png)

### Git
Next we'll want to add our git reposity. If you have not created one yet, this would be a great time before we connect to it. I named mine ``dbt``.
![select git](images/09.png)

Once you authenticate with your git provider, a list of git repos will show. Select the one you want to use.
![select repo](images/10.png)

### Run first models
Great our development environment connection is setup. Lets build our first models and see them in Snowflake.
![start dev](images/11.png)

Lets initialize the project code.
![initialize project](images/12.png)

We can see a sample project has been added to our branch.
![show code](images/13.png)

Before we build these models lets remove some code so that everything builds successfully. DBT has setup up this code for learning but we are more intrested in getting everything working.
![Remove code](images/14.png)

??? Warning "If your user is using MFA - Please enable token caching before uploading"
    If your development user is using MFA. Please enable token caching or else it will ask you for authentication everytime you run each dbt model. In this case will we ask at least 6-7 times.

    ```sql
    alter account set allow_client_mfa_caching = TRUE;
    ```

Now lets build our code by going to the bottom of the page and entering ``dbt build`` and hitting enter. This will build all our models.
![build](images/15.png)

We can see now that all our current branches models have built successfully.
![look at build](images/16.png)

We can view those built models in our Snowflake account.
![Models in Snowflake.](images/17.png)

Finally we will commit those changes to our branch.
![commit to branch](images/18.png)


## Production :octicons-feed-tag-16:
Great now that we have our development environment setup we can start adding new users and all they will have to do is add thier development credientials. Lets setup our product environment that will curate our models on a regular bases based on our ``main`` branch.

### Environment
Lets start by committing our changes to the branch.
![commit](images/19.png)

Once commit DBT will give us the option to create a pull request. Lets commit our branch to main branch.
![start pull request](images/20.png)

Click create pull request.
![click create PR](images/21.png)

Give the PR a description and click "create pull request".
![create the PR](images/23.png)

After it's created lets merge the code changes.
![merge](images/23.png)

Confirm the merge.
![confirm merge](images/24.png)

After it's merged lets delete the branch to keep our git clean.
![delete branch](images/25.png)

Next lets go back to DBT to setup the environment.
![select environment](images/26.png)

Lets create a new environment.
![new environment](images/27.png)

Lets give our environment a name, select deplyment type of ``production`` and connection of Snowflake we created earlier.
![environment setup 1](images/28.png)

Lets add our connection variables. The image shows what everything should be if you used our setup code. The password comes from that setup code. If your want to use key-pair instead of username/password, check our [key-pair tutorial](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/security/key_pair/).
![environment setup 2](images/29.png)

Once finished head back to the top and click save.
![save](images/30.png)

### Job
Jobs run dbt code in our environment on a regular bases. Lets use the left navbar to go to deploy and then jobs.
![navigate jobs](images/31.png)

Create a new deploy job.
![create job](images/32.png)

We'll give our job a name. The environment should be production and we want to run the command ``dbt build`` similar to when we were in development. Next we'll select to generate docs and run on a schedule. Click save when finished.
![job setup](images/33.png)

Now that we created the job, lets run it.
![Run job](images/34.png)

We can see the job is now running, lets click in and see what it's doing.
![view running job](images/35.png)

You can see the steps dbt will take to run this job. It may take 20 seconds for it to finish.
![job complete](images/36.png)

### Result
Once the job is completed we can go to Snowflake to see our production jobs result in our production schema.
![Snowflake results](images/37.png)

Now we can go back to the dashboard to see all the metadata of our job and run history.
![dashboard](images/38.png)

## Documentation :octicons-feed-tag-16:
Now that our production job has run lets see our documentation. This has a little setup to know which job the docs should look at when displaying results.

Lets start by going to account settings in the bottom left of the page.
![account settings](images/39.png)

We'll go to project, select the project and finally edit the project.
![navigate to edit project](images/40.png)

We'll want to update the description, and the job we want to associate the documentation to. Finally click save.
![Update to selected job](images/41.png)

Great, lets click documentation on the left side navbar.
![navigate to docs](images/42.png)

Now we can see our documentation.
![see documentation](images/43.png)