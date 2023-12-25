# Snowflake - AWS S3 bucket:
This tutorial assumes you have nothing in your snowflake account (Started Trial) but, the tutorial can be started at any step.


## 1. Snowflake Setup:

0. Setup in snowflake before we jump to aws. Lets create a worksheet in snowflake and add the code below with your information and hit run:

![Worksheet](images/0_worksheet.png)

=== ":octicons-image-16: SQL"
    ```sql
    use role sysadmin;
    create database if not exists raw comment='This is only raw data from your source.';

    -- Create the schema. The schema stores all objectss.
    create schema if not exists raw.aws;
    ```

=== ":octicons-sign-out-16: Result"
    ```
    Schema AWS successfully created.
    ```

## 2. S3 Setup (Part 1):
1. Create the bucket you intend to use. In our case we'll call the bucket **danielwilczak**.
![Create S3](images/0_create_bucket.png)

2. Upload the sample data (json/csv) provided in the data folder.
![Upload example data](images/0_upload_data.png)

3. Copy your ARN name. This wil be used in step 7.
![Copy ARN name](images/01_get_arn_name.png)

4. Go to IAM:
![Create S3](images/02_iam.png)

5. Create a policy:
![Policy](images/03_policy.png)

6. Give the policy a name:
![Policy](images/04_create_policy.png)

7. Add the template policy json code below and add your arn we copied from step 3 and click create policy:

=== ":octicons-image-16: Policy"

    ![Add policy json ](images/05_enter_policy.png)
    
=== ":octicons-sign-out-16: Json Template"

    ```json
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                    "s3:GetObject",
                    "s3:GetObjectVersion"
                    ],
                    "Resource": "<COPY ARN HERE>/*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "s3:ListBucket",
                        "s3:GetBucketLocation"
                    ],
                    "Resource": "<COPY ARN HERE>",
                    "Condition": {
                        "StringLike": {
                            "s3:prefix": [
                                "*"
                            ]
                        }
                    }
                }
            ]
        }
    ```

8. Lets create a role! Navigate back to **IAM**:
![Create S3](images/02_iam.png)

9. Lets create a role:
![Navigate to role](images/06_roles.png)

10. Select AWS account, This account(#), Require external ID and enter 0000 for now. We will update this later.
![Trusted entity](images/07_trusted_relationship.png)

11. Add the policy to the role:
![Policy to role](images/08_policy_to_role.png)

12. Add the role name and click "create role":
![Add role name](images/09_role_name.png)

13. Once created click your role:
![Click role](images/10_click_role.png)

14. Copy your role ARN, this will be used in step 15:
![Copy arn](images/11_copy_arn.png)

## 3. Snowflake integration:
15. Create the integration in snowflake by running the code below with your copied role arn and bucket name:



=== ":octicons-image-16: SQL"

    ```sql
    use role ACCOUNTADMIN;

    create or replace storage integration s3_integration
    type = external_stage
    storage_provider = 's3'
    enabled = true
    storage_aws_role_arn = 'arn:aws:iam::484577546576:role/danielwilczak-role'
    storage_allowed_locations = ('s3://danielwilczak/');

    -- Give the sysadmin access to use the integration.
    grant usage on integration s3_integration to role sysadmin;

    -- Note the two below we will put them back into AWS later:
    --   STORAGE_AWS_IAM_USER_ARN
    --   STORAGE_AWS_EXTERNAL_ID 
    desc integration s3_integration;
    ```

=== ":octicons-sign-out-16: Result"

    | property                  | property_type | property_value                                    | property_default |   |
    |---------------------------|---------------|---------------------------------------------------|------------------|---|
    | ENABLED                   | Boolean       | TRUE                                              | FALSE            |   |
    | STORAGE_PROVIDER          | String        | S3                                                |                  |   |
    | STORAGE_ALLOWED_LOCATIONS | List          | s3://danielwilczak/                               | []               |   |
    | STORAGE_BLOCKED_LOCATIONS | List          |                                                   | []               |   |
    | STORAGE_AWS_IAM_USER_ARN  | String        | arn:aws:iam::001782626159:user/8pbb0000-s         |                  |   |
    | STORAGE_AWS_ROLE_ARN      | String        | arn:aws:iam::484577546576:role/danielwilczak-role |                  |   |
    | STORAGE_AWS_EXTERNAL_ID   | String        | GGB82720_SFCRole=2_vcN2MIiC7PW0OMOyA82W5BLJrqY=   |                  |   |
    | COMMENT                   | String        |                                                   |                  |   |

## 4. S3 setup (Part 2):
16. Navigate back to the role:
![Click role](images/10_click_role.png)

17. Click trusted relationship:
![Click trusted relationship](images/12_click_trusted_relationship.png)

18. Click edit trust policy:
![Edit trust policy](images/13_click_edit_trust_policy.png)

19. Copy the policy json template code below and add your "STORAGE_AWS_IAM_USER_ARN" and "STORAGE_AWS_EXTERNAL_ID" from step 15.
![Edit trust policy](images/14_edit_trust_policy.png)

=== ":octicons-image-16: Json"

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
            "AWS": "<STORAGE_AWS_IAM_USER_ARN>"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
            "StringEquals": {
                "sts:ExternalId": "<STORAGE_AWS_EXTERNAL_ID>"
            }
            }
        }
        ]
    }
    ```

## 5. Snowflake Create Stage:
20. FINAL STEP. Lets create a stage, file format, warehouse and table and copy data into it. Copy the code below and run it in a new worksheet.

![Final step](images/15_final_step.png)

=== ":octicons-image-16: SQL"

    ```sql
    use role sysadmin;
    use database raw;
    use schema aws;

    -- Stages are synonymous with the idea of folders that can be either internal or external.
    create or replace stage s3
    storage_integration = s3_integration
    url = 's3://danielwilczak/'
    directory = ( enable = true);

    create or replace file format json
    type = 'json';

    create or replace warehouse developer 
        WAREHOUSE_SIZE=XSMALL
        INITIALLY_SUSPENDED=TRUE;

    -- Load json data
    create or replace table data (
    file_name varchar,
    data variant
    );

    copy into data(file_name,data)
    from (
        select 
            metadata$filename,
            $1
        from
            @s3/json
            (file_format => json)
    );
    ```

=== ":octicons-sign-out-16: Result"

  | file                                | status | rows_parsed | rows_loaded | error_limit | errors_seen |
  |-------------------------------------|--------|-------------|-------------|-------------|-------------|
  | s3://danielwilczak/json/sample.json | LOADED | 1           | 1           | 1           | 0           |


## (Bonus) Snow Pipe:
Lets create a pipe to automate copying data into a table.

1. Create the file format, table and pipe in snowflake. This approach automates the process so you don't have to manually name all the columns.

=== ":octicons-image-16: SQL"

    ```sql
    -- Copy CSV data using a pipe without having to write out the column names.
    create or replace file format infer
    type = csv
    parse_header = true
    skip_blank_lines = true
    field_optionally_enclosed_by ='"'
    trim_space = true
    error_on_column_count_mismatch = false;

    create or replace table csv
        using template (
            select array_agg(object_construct(*))
            within group (order by order_id)
            from table(
                infer_schema(        
                LOCATION=>'@s3/csv'
            , file_format => 'infer')
            )
        );

    create pipe csv auto_ingest=true as
        COPY into
            csv
        from
            @s3/csv
            
        FILE_FORMAT = (FORMAT_NAME= 'infer')
        MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;

    -- Get the arn for the pipe. We will add this to aws in step #5.
    show pipes;
    select "name", "notification_channel" from TABLE(RESULT_SCAN(LAST_QUERY_ID()));
    ```

=== ":octicons-sign-out-16: Result"

    ![Get ARN](images/19_get_arn.png)

2. Navigate to your bucket and click properties:
![Properties](images/16_pipe_properties.png)

3. Scroll down to "Create event notification":
![Create event notification](images/17_create_event.png)

4. Add a name to the notification and select all object create notification:
![Properties](images/18_notification_settings.png)

5. Scroll down and enter your sqs and click "save changes":
![Properties](images/20_enter_sqs.png)

6. Almost done, in snowflake lets refresh the pipe so that we ingest all the current files.
```sql
alter pipe csv refresh;
```

7. Lets add a copy of the sample data into the s3 bucket folder with a new name and see it added in snowflake ~1 minutes later. We can see this by doing a count on our table and see 2k records where the csv only has 1k records.
![Results](images/21_results.png)

