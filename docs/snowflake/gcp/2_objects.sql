/*
Create the objects needed to store the data. This is the database and schema.
*/
-- Databases
    -- The reason we switch to system admin is so that everything we create is owned by it.
use sysadmin;
create database if not exists raw comment='This is only raw data from your source.';
create database if not exists data_warehouse comment='This is only cleaned and standardized raw data for people to use.';

-- Create the schema. The schema stores all objectss.
create schema if not exists raw.gcp;
create schema if not exists data_warehouse.gcp;