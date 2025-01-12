create or replace table data as
    select 
        TO_VARCHAR(SNOWFLAKE.CORTEX.PARSE_DOCUMENT('@files','example.pdf',{'mode': 'OCR'}):content) AS OCR,
		TO_VARCHAR (SNOWFLAKE.CORTEX.PARSE_DOCUMENT ('@files','example.pdf',{'mode': 'LAYOUT'} ):content) AS LAYOUT;

select * from data;