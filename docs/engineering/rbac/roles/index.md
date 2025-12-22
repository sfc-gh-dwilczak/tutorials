# RBAC - Database roles and orginization
Goal of this tutorial is to explain how I would setup Snowflake from a governance perspective for commercial customers. The scope of this tutorial is basic and I do not want to go too deep into any one topic but show how best to orginize everthing to start successfully.

## Video
Video still in development.

## Requirements 
- Snowflake account, you can use a [free trial](https://signup.snowflake.com/). We also assume no complex security needs.

## Complete Setup  :octicons-feed-tag-16:
- Connector ([Link](https://sfc-gh-dwilczak.github.io/tutorials/engineering/openflow/connectors/sftp/files/files.zip))

## Overview


### Database Objects
- Raw
- Bronze
- Silver
- Gold

### Database Roles
- Read 
- Write

### High level Roles
- Engineer
- Analyst
- Service_<Application>

### Grants
- 


### Warehouses
- Match name of role