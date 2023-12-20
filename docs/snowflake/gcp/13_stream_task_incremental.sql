use sysadmin;
use database raw;
use schema gcp;
use warehouse developer;

/* 
This used an example customer table I created yesterday with a share. Feel free adapt
it to a table in your snowflake account.
*/
create or replace table customers (
    id number,
    customer_name varchar,
    contact_name varchar,
    address varchar,
    city varchar,
    postal_code varchar,
    country varchar
);

-- Inset some data so we can see the changes.
INSERT INTO customers (id,customer_name, contact_name, address, city, postal_code, country)
VALUES
(1,'Cardinal', 'Tom B. Erichsen', 'Skagen 21', 'Stavanger', '4006', 'Norway'),
(2,'Greasy Burger', 'Per Olsen', 'Gateveien 15', 'Sandnes', '4306', 'Norway'),
(3,'Tasty Tee', 'Finn Egan', 'Streetroad 19B', 'Liverpool', 'L1 0AA', 'UK');

-- (If your using a share) The table will have to allow change tracking.
ALTER TABLE customers SET CHANGE_TRACKING = TRUE;

-- Create the stream on our customers table.
create or replace stream
    raw.gcp.customer_stream
on table
    customers
    -- Settings
    show_initial_rows=True;

-- Lets see the changes.
select * from customer_stream;

-- Lets create the incremental table.
create or replace table merged_customers (
    id number,
    customer_name varchar,
    contact_name varchar,
    address varchar,
    city varchar,
    postal_code varchar,
    country varchar,
    snowflake_row_id varchar
);

-- You'll see no data is in the table.
select * from merged_customers;

-- Lets write the task and incremental logic to load the data into our new table.
CREATE OR REPLACE TASK customer_incremental
    SCHEDULE = '10 minute'
WHEN
    SYSTEM$STREAM_HAS_DATA('customer_stream')
AS
    MERGE INTO 
        merged_customers as destination
    USING (
        SELECT 
            metadata$action as stream_action,
            metadata$isupdate as stream_update,
            id,
            customer_name,
            contact_name,
            address,
            city,
            postal_code,
            country,
            metadata$row_id as snowflake_row_id 
        FROM 
            customer_stream
        where
            -- This is to avoid the condition of something being deleted and updated at the same time.
            -- You would never want to update and delete, it doesnt make logical sense.
            not (stream_action = 'DELETE' and stream_update = true)
    ) as stream_delta
        ON 
            destination.id = stream_delta.id
                WHEN MATCHED AND stream_action = 'DELETE' 
                    THEN DELETE
                WHEN MATCHED AND stream_action = 'INSERT' 
                    THEN UPDATE SET
                        destination.id               = stream_delta.id,
                        destination.customer_name    = stream_delta.customer_name,
                        destination.contact_name     = stream_delta.contact_name,
                        destination.address          = stream_delta.address,
                        destination.city             = stream_delta.city,
                        destination.postal_code      = stream_delta.postal_code,
                        destination.country          = stream_delta.country,
                        destination.snowflake_row_id = stream_delta.snowflake_row_id
                WHEN NOT MATCHED AND stream_action = 'INSERT' 
                    THEN INSERT (
                        id,
                        customer_name,
                        contact_name,
                        address,
                        city,
                        postal_code,
                        country,
                        snowflake_row_id
                    )
                    VALUES (
                        stream_delta.id,
                        stream_delta.customer_name,
                        stream_delta.contact_name,
                        stream_delta.address,
                        stream_delta.city,
                        stream_delta.postal_code,
                        stream_delta.country,
                        stream_delta.snowflake_row_id
                    );

/* Lets run the task now and not on a schedule. 
    - If you want to start the task on a schedule: 
        ALTER TASK customer_incremental RESUME;
*/
EXECUTE TASK customer_incremental;

-- Now we'll see the steam is empty because we've copied the data.
select * from customer_stream;

-- Add the data move into our merged table.
select * from merged_customers;

-- Lets update some more data with an update to our first row / primary key item.
Update
    customers
set
    customer_name = 'Cardinal V2'
where 
    id = 1;

-- See our new row in the stream. This will have the delete and update.
select * from customer_stream;

-- Lets add it to our incremental customers table.
EXECUTE TASK customer_incremental;

-- Lets see the result in our table
select * from merged_customers;


