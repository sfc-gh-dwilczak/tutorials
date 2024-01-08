/*
Admin role descriptions:
    UserAdmin - This is like HR at your company, they are here to onboard users and give them roles.
    SysAdmin - This is like your developer at your company they can make things but not give access to stuff or onboard users.
    SecurityAdmin - This is like security at your company. They don't make anything, they just give access to stuff.
    Accountadmin - This is god. He does whatever he wants but we don't want him to always be doing stuff. Only important things.
*/


-- User admin to create users / roles.
use useradmin;

-- Create our first user.
CREATE USER "archana.shah@syndigo.com"
    PASSWORD=''
    MUST_CHANGE_PASSWORD = False;

CREATE USER "vimal.lakhera@syndigo.com"
    PASSWORD=''
    MUST_CHANGE_PASSWORD = False;

