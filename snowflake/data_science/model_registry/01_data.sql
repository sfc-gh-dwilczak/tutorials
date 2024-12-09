use role sysadmin;

-- For orginization
create database if not exists science;
create database if not exists raw;

create schema if not exists science.students;
create schema if not exists raw.data;

-- Sample Data
create or replace table raw.data.student_test_scores as
    select
        $1 as hours_studied,
        $2 as test_score
    from values
        (1.0, 3.5),
        (2.0, 9.2),
        (3.0, 13.1),
        (4.0, 24.7),
        (5.0, 28.5),
        (6.0, 41.0),
        (7.0, 50.3),
        (8.0, 63.5),
        (9.0, 82.1),
        (10.0, 95.0);