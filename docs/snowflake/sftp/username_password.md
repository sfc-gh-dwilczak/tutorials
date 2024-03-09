# SFTP - Using Username and Password
In this tutorial we will show how to:
 
 - Unload a table from snowflake to sftp server.
 - Load a csv file from sftp server and land it in a snowflake table.
 - Takes a file from an SFTP Server and writes it to a Snowflake Internal Stage.

Credit for the code goes to [brockcooper](https://github.com/brockcooper/snowflake_sftp/blob/main/README.md). Thank you!

## Video
Video coming soon.

## Requirements
This tutorial assumes you have a snowflake warehouse, database, schema and table that you want to export to the sftp server.

## Setup :octicons-feed-tag-16:
Lets open a worksheet and run the following code with your SFTP username, password and SFTP host url.

=== ":octicons-image-16: Setup Code"

    ```sql linenums="1"
    use role accountadmin;

    create secret sftp_pw
        type = password
        username = 'your_username'
        password = 'your_password';

    create network rule sftp_external_access_rule
        type = host_port
        value_list = ('your-sftp-server.com', 'your-sftp-server.com:22') -- port 22 is the default for sftp
        mode= egress;

    create or replace external access integration sftp_access_integration
        allowed_network_rules = (sftp_external_access_rule)
        allowed_authentication_secrets = (sftp_pw)
        enabled = true;
    ```


### Table to SFTP
In this section we will show how to dump a table from snowflake into sftp. Lets create a user-defined function so we can refrence it with a smaller script. Lets call that function and see the result. 

=== ":octicons-image-16: Function"

    ```python linenums="1"
    CREATE OR REPLACE PROCEDURE table_to_sftp(database_name string
                                            ,schema_name string
                                            ,table_name string
                                            ,output_file_name string
                                            ,remote_dir_path string
                                            ,sftp_server string
                                            ,port INT
                                            ,append_timestamp BOOLEAN)
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = 3.8
    HANDLER = 'upload_file_to_sftp'
    EXTERNAL_ACCESS_INTEGRATIONS = (sftp_access_integration)
    PACKAGES = ('snowflake-snowpark-python','pysftp')
    SECRETS = ('cred' = sftp_pw)
    AS
    $$
    import _snowflake
    import pysftp
    from datetime import datetime

    def upload_file_to_sftp(session, database_name, schema_name, table_name, output_file_name, remote_dir_path, sftp_server, port, append_timestamp):

        # Read the origin table into a Snowflake dataframe
        df = session.table([database_name, schema_name, table_name])

        # Convert the Snowflake dataframe into a Pandas dataframe
        df = df.to_pandas()

        # Make the temp file
        if append_timestamp:
            now = datetime.now()
            epoch_time = str(int(now.timestamp() * 1000))  # Multiplied by 1000 to include milliseconds
            local_file_path = '/tmp/' + output_file_name + '_' + epoch_time + '.csv'
        else:
            local_file_path = '/tmp/' + output_file_name + '.csv'

        df.to_csv(local_file_path, header=True, index=False)

        username_password_object = _snowflake.get_username_password('cred');

        cnopts = pysftp.CnOpts()
        cnopts.hostkeys = None  # Disable host key checking. Use carefully.

        # Your SFTP credentials
        sftp_host = sftp_server
        sftp_port = port
        sftp_username = username_password_object.username
        sftp_password = username_password_object.password

        # Remote directory to upload the file
        remote_directory = remote_dir_path

        # Establish SFTP connection
        try:
            with pysftp.Connection(host=sftp_host, username=sftp_username, password=sftp_password, port=sftp_port, cnopts=cnopts) as sftp:
                try:
                    # Change to the remote directory where the file will be uploaded
                    sftp.chdir(remote_directory)
                except IOError:
                    print(f"Remote directory {remote_directory} does not exist.")
                    return

                # Upload the file
                sftp.put(local_file_path)

                message = f'Successfully uploaded {local_file_path} to {remote_directory}'
        except Exception as e:
            message = f"An error occurred: {e}"

        return message
    $$;
    ```

=== ":octicons-image-16: Call"

    ```sql linenums="1"
    CALL table_to_sftp('DATABASE_NAME'
                    , 'SCHEMA_NAME'
                    , 'TABLE_NAME'
                    , 'OUTPUT_FILE_NAME'
                    ,'/example_folder/' -- Example remote dir path
                    , 'YOUR-SFTP-SERVER.com'
                    , 22 -- Port 22 is the default for SFTP, change if your port is different.
                    , TRUE -- Appends an EPOCH timestamp to the file name to make it unique.
    );
    ```

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    CALL table_to_sftp('RAW'
                    , 'AWS'
                    , 'CSV'
                    , 'data'
                    ,'/examples/' -- Example remote dir path
                    , 'danielwilczakv2.blob.core.windows.net'
                    , 22 -- Port 22 is the default for SFTP, change if your port is different
                    , TRUE -- Appends an EPOCH timestamp to the file name
    );
    ```


=== ":octicons-image-16: Result"
    | TABLE_TO_SFTP                                                   |
    |-----------------------------------------------------------------|
    | Successfully uploaded /tmp/data_1709882914875.csv to /examples/ |


### SFTP file to table
In this section we will show how to load a csv file from sftp into a snowflake table. Lets create a user-defined function so we can refrence it with a smaller script. Lets call that function and see the result. 

=== ":octicons-image-16: Code"

    ```python linenums="1"
    CREATE OR REPLACE PROCEDURE sftp_to_table(database_name string
                                         ,schema_name string
                                         ,table_name string
                                         ,remote_file_path string
                                         ,sftp_server string
                                         ,port INT
                                         ,write_mode string)
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = 3.8
    HANDLER = 'download_csv_from_sftp'
    EXTERNAL_ACCESS_INTEGRATIONS = (sftp_access_integration)
    PACKAGES = ('snowflake-snowpark-python','pysftp', 'pandas')
    SECRETS = ('cred' = sftp_pw)
    AS
    $$
    import _snowflake
    import pysftp
    import pandas as pd

    def download_csv_from_sftp(session, database_name, schema_name, table_name, remote_file_path, sftp_server, port, write_mode):

        cnopts = pysftp.CnOpts()
        cnopts.hostkeys = None  # Disable host key checking. Use carefully.

        username_password_object = _snowflake.get_username_password('cred');
        # Your SFTP credentials
        sftp_host = sftp_server
        sftp_port = port
        sftp_username = username_password_object.username
        sftp_password = username_password_object.password

        full_table_name = f'"{database_name.upper()}"."{schema_name.upper()}"."{table_name.upper()}"'

        try:
            with pysftp.Connection(host=sftp_host, username=sftp_username, password=sftp_password, port=sftp_port, cnopts=cnopts) as sftp:
                # Check if the remote file exists
                if sftp.exists(remote_file_path):
                    # Download the file
                    sftp.get(remote_file_path, '/tmp/file.csv')

                    # Turn File into Pandas DF (reads CSV files better than Snowpark)
                    df = pd.read_csv('/tmp/file.csv')

                    # Turn Pandas to Snowpark
                    df = session.create_dataframe(df)

                    # Save DF as Table
                    df.write.mode(write_mode).save_as_table(full_table_name, table_type="")
                    message = f"{remote_file_path} successfully saved to {full_table_name}"

                else:
                    message = f"Remote file {remote_file_path} does not exist."

        except Exception as e:
            message = f"An error occurred: {e}"

        return message
    $$;
    ```

=== ":octicons-image-16: Template"

    ```sql linenums="1"
    CALL sftp_to_table('EXAMPLE'
                 , 'DEMO'
                 , 'FROM_SFTP_EXAMPLE'
                 ,'/example_folder/example.csv' -- Example remote dir path
                 , 'YOUR-SFTP-SERVER.com'
                 , 22 -- Port 22 is the default for SFTP, change if your port is different
                 , 'append'
    );
    ```

=== ":octicons-image-16: Result"
    Still working on running.


### SFTP to internal stage
In this section we will show how to load a file from sftp into a snowflake stage. Lets create a user-defined function so we can refrence it with a smaller script. Lets call that function and see the result. 

=== ":octicons-image-16: Code"

    ```python linenums="1"
    CREATE OR REPLACE PROCEDURE sftp_to_internal_stage(stage_name string
                                                  ,stage_path string
                                                  ,stage_file_name string
                                                  ,append_timestamp BOOLEAN
                                                  ,remote_file_path string
                                                  ,sftp_server string
                                                  ,port INT)
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = 3.8
    HANDLER = 'download_csv_from_sftp'
    EXTERNAL_ACCESS_INTEGRATIONS = (sftp_access_integration)
    PACKAGES = ('snowflake-snowpark-python','pysftp')
    SECRETS = ('cred' = sftp_pw)
    AS
    $$
    import _snowflake
    import pysftp
    from datetime import datetime

    def download_csv_from_sftp(session, stage_name, stage_path, stage_file_name, append_timestamp, remote_file_path, sftp_server, port):

        cnopts = pysftp.CnOpts()
        cnopts.hostkeys = None  # Disable host key checking. Use carefully.

        username_password_object = _snowflake.get_username_password('cred');
        # Your SFTP credentials
        sftp_host = sftp_server
        sftp_port = port
        sftp_username = username_password_object.username
        sftp_password = username_password_object.password

        full_path_name = f'{stage_name}{stage_path}'

        # Name the staged file
        if append_timestamp:
            now = datetime.now()
            epoch_time = str(int(now.timestamp() * 1000))  # Multiplied by 1000 to include milliseconds
            stage_file_name = f'{stage_file_name}_{epoch_time}'

        try:
            with pysftp.Connection(host=sftp_host, username=sftp_username, password=sftp_password, port=sftp_port, cnopts=cnopts) as sftp:
                # Check if the remote file exists
                if sftp.exists(remote_file_path):
                    # Download the file
                    sftp.get(remote_file_path, f'/tmp/{stage_file_name}.csv')

                    # Save File to Stage
                    session.file.put(f'/tmp/{stage_file_name}.csv', full_path_name)

                    message = f"{remote_file_path} successfully saved to {full_path_name}"

                else:
                    message = f"Remote file {remote_file_path} does not exist."

        except Exception as e:
            message = f"An error occurred: {e}"

        return message
    $$;
    ```

=== ":octicons-image-16: Template"

    ```sql linenums="1"
    CALL sftp_to_internal_stage(
          '@example.public.example_internal_stage' -- Include the stage name
        , '/example/' -- Always include at least the first forward-slash
        , 'example_file' -- Name of the file (without the file extension)
        , True -- Appends an EPOCH timestamp to the file name
        ,'/example_folder/example.csv' -- Example remote dir path
        , 'YOUR-SFTP-SERVER.com'
        , 22 -- Port 22 is the default for SFTP, change if your port is different
    );
    ```

=== ":octicons-image-16: Result"
    Still working on running.
