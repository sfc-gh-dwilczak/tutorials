Begin; 
    -- create variables for user / password / role / warehouse / database (needs to be uppercase for objects)
    set role_name = 'service_syndigo';
    set user_name = 'service_syndigo';
    set user_password = 'Password12';
    set warehouse_name = 'service_syndigo';
    set database_name = 'syndigo';

    -- change role to securityadmin for user / role steps
    use role securityadmin;

    -- create role for syndigo
    create role if not exists identifier($role_name);
    grant role identifier($role_name) to role SYSADMIN;

    -- create a user for syndigo
    create user if not exists identifier($user_name)
    password = $user_password
    default_role = $role_name
    default_warehouse = $warehouse_name;

    grant role identifier($role_name) to user identifier($user_name);

    -- change role to sysadmin for warehouse / database steps
    use role sysadmin;

    -- create a warehouse for syndigo
    create warehouse if not exists identifier($warehouse_name)
    warehouse_size = xsmall
    warehouse_type = standard
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;

    -- create database for syndigo
    create database if not exists identifier($database_name);

    -- grant syndigo role access to warehouse
    grant USAGE
    on warehouse identifier($warehouse_name)
    to role identifier($role_name);

    -- grant syndigo access to database
    use role ACCOUNTADMIN;
    grant CREATE SCHEMA, MONITOR, USAGE
    on database identifier($database_name)
    to role identifier($role_name);
commit;