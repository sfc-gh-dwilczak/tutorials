-- You would probabaly give your first person account admin or one of these rols based on position.
use accountadmin;
grant role sysadmin to user "sheinz@spins.com";

-- Roles and role hierachy.
use securityadmin;
create role if not exists senior_analyst comment='Same as analyst with more responsibilties. Example being granted to raw data';
create role if not exists analyst comment='Anaylst have access to reports and cleaned raw data.';
grant role analyst to role senior_analyst;
grant role senior_analyst to role sysadmin;

-- Grant roles to users.
grant role analyst to user "sheinz@spins.com";
grant role analyst to user "dnarayanaswamy@spins.com";