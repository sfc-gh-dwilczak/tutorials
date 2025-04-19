# External Tables - Google Cloud Storage
Goal of this tutorial is to setup a Snowflake [external table](#) on files that are stored in an external google cloud storage bucket.

## Video
Video in development.

## Requirements
- Snowflake account, you can use a [free trial](https://signup.snowflake.com/). We also assume no complex security needs.
- Google cloud account, you can setup a [free account](https://cloud.google.com/) to get started.

## Download
- [Sample Data](#)


## Setup :octicons-feed-tag-16:
!!! warning 

    This tutorial assumes you have already setup a stage with read/write privligies and Snowpipe that is conencted to GCP cloud storage. If you have not [please follow this tutorial](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/google/cloud_storage/).
    
In this section we will upload the example code to gcp and then setup Snowflake.


## External Table :octicons-feed-tag-16:
Lets create the table on top of the [sample files](#) we have stored in the bucket / stage.

=== ":octicons-image-16: Template"

    ```sql linenums="1"
    use database raw;
    use schema gcp;
    use role sysadmin;
    use warehouse development;

    create or replace external table ads_b_kapa_ext (
        file_name varchar as (metadata$filename::varchar),
        x number as (metadata$file_row_number::number)
        y number as (metadata$file_row_number::number)
        partition by (x)
        location = @gcp/csv
        auto_refresh=true
        file_format = (type = csv);

    ```

=== ":octicons-image-16: Example"

    ```sql linenums="1"
    use database raw;
    use schema gcp;
    use role sysadmin;
    use warehouse development;

    UPDATE
    ```

=== ":octicons-sign-out-16: Result"

    UPDATE