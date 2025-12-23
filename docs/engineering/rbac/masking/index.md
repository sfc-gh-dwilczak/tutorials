# RBAC - Database roles and orginization
Goal of this tutorial is to show examples of both column level masking and row level masking in Snowflake.

## Video
Video still in development.

## Requirements 
- Snowflake account, you can use a [free trial](https://signup.snowflake.com/). We also assume no complex security needs.
- Snowflake account needs to Enterprise Edition or higher.

## Sample data
Please Update the "<YOUR_USER_EMAIL>" section for row level masking to work.
```sql
-- Create and use a dedicated schema
create or replace schema security_demo;
use schema security_demo;

-- 1. Create the unified table
create or replace table sales_performance (
  order_id number,
  employee_name string,
  employee_email string, -- Column to be masked
  sales_region string,    -- Column for row filtering
  sale_amount float
);

-- 2. Create the mapping table for Row Access
create or replace table user_region_map (
  user_email string, 
  allowed_region string
);

-- 3. Insert sample data
insert into sales_performance (order_id, employee_name, employee_email, sales_region, sale_amount) values
(1001, 'Jane Doe', 'jane.doe@example.com', 'West', 1500.00),
(1002, 'Mike Smith', 'mike.smith@example.com', 'East', 2200.50),
(1003, 'Sara Lee', 'sara.lee@example.com', 'Central', 950.00),
(1004, 'Admin User', 'admin@example.com', 'West', 3100.25);

-- 4. Insert mapping data (Update '<YOUR_USER_EMAIL>' with your actual Snowflake login)
insert into user_region_map (user_email, allowed_region) values
('<YOUR_USER_EMAIL>', 'West'), 
('mike.smith@example.com', 'East'),    
('sara.lee@example.com', 'Central');
```


### Column Level Masking
We want only the ENGINEER or ACCOUNTADMIN role to see the full email addresses. Everyone else will see asterisks.
```sql
-- Create the masking policy
create or replace masking policy email_mask
as (val string)
returns string ->
  case
    when current_role() in ('ENGINEER', 'ACCOUNTADMIN') then val
    else '*********'
  end;

-- Apply the policy to the email column
alter table sales_performance 
  modify column employee_email 
  set masking policy email_mask;
```

Lets see the results. Try changing your role in the sheet by using "use role sysadmin"
```sql
-- Test your results
select * from sales_performance;
```


# Row Level Masking
We want users to only see rows belonging to their assigned region based on the user_region_map.
```sql
-- Create the row access policy
create or replace row access policy region_access_policy
  as (sales_region varchar) returns boolean ->
    current_role() = 'ACCOUNTADMIN'
    or exists (
        select 1 from user_region_map
        where user_email = current_user()
        and allowed_region = sales_region
    );

-- Apply the policy to the table
alter table sales_performance 
  add row access policy region_access_policy on (sales_region);
```

Lets see the results. Try changing your role in the sheet by using "use role sysadmin"
```sql
-- Test your results
select * from sales_performance;
```


