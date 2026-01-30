Need to update with the use of external tables now.


1. create redshift, snowflake and s3 bucket.
2. Download snowconvert for refshift. 
3. Fill in project name, source, folder path and add key 
Key = aecbfe93-3615-4aae-bd0f-ea6ae1460b1a (Valid through: 08/06/2025)
4. Three options to login (IAM Provision Cluster, IAM Serverless, Standard) I used standard and it work. Need to figure out other two and give them as options.
5. Setup Snowflake account (Image of where to get account identifier)
6. Redshift will create the tables.
7. Data miration service.
8. User will need to use the redhisft iam role, and give that role to the bucket.

# S3 URL - s3://danielwilczak-snowconvert/
# Role - arn:aws:iam::084828565535:role/service-role/AmazonRedshift-CommandsAccessRole-20250506T162039
# User - AKIAR....5HTPS2N (Must have access to the above role in the trusted relationship)
# Secret - 5ZPK0Ktwx9a....NithhHo+QBYBVSs+Q

9. Data will get pushed to the bucket.
10. Probably should talk about logs here.

