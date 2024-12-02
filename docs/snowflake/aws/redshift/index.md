Unload script that will take the sales table and dump it into a folder in S3.

```
UNLOAD ('select * from sample_data_dev.tickit.sales')
TO 's3://danielwilcak/sales/'
IAM_ROLE 'arn:aws:iam::084828565535:role/service-role/AmazonRedshift-CommandsAccessRole-20241201T210134'
HEADER
MAXFILESIZE AS 100 MB
FORMAT AS CSV;
```

Using the UI I would load one file and set all of the data type for the columns. Truncate the table and then use the command below to load all the data.
```
copy into
    example
from 
    @redshift
        FILE_FORMAT = (
            TYPE = CSV
            SKIP_HEADER = 1
        );
```