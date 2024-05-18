# Managed Iceberg on GCP via Snowflake
In this tutorial we will show you how to use iceberg tables inside of Snowflake. We will be using an [external volume](https://docs.snowflake.com/en/sql-reference/sql/create-external-volume) to make the integration to GCP.  This tutorial assumes you have nothing in your Snowflake account ([Trial](https://signup.snowflake.com/)) and no complex security needs.

## Video
Video is in development.

## Download
- [Sample Data](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/data/data.zip)

!!! warning 

    This tutorial assumes you have already setup a stage with read/write privligies that is conencted to GCP cloud storage. If you have not [please follow this tutorial](https://sfc-gh-dwilczak.github.io/tutorials/snowflake/google/cloud_storage/).


## Setup :octicons-feed-tag-16:
In this section we will upload the example code to gcp and then setup Snowflake.

### Volume
Update