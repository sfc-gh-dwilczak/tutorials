```
SELECT 
    RAW.DOCUMENTS.RESUMES!PREDICT(
        GET_PRESIGNED_URL(
            @resumes,
            'Ex11.pdf'
        ), 1);
```