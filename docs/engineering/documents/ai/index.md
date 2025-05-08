
# Document AI - Introduction
In this tutorial we will show how setup, train and use document AI in Snowflake.

## Video
Video is still in development.

## Requirement
This tutorial assumes you have nothing in your Snowflake account ([Trial](https://signup.snowflake.com/)) and no complex security needs.

## Downloads
* [Training data](https://sfc-gh-dwilczak.github.io/tutorials/engineering/documents/ai/files/training.zip)
* [Testing data](https://sfc-gh-dwilczak.github.io/tutorials/engineering/documents/ai/files/testing.zip)

??? note "If you don't have a database, schema or warehouse yet."

    === ":octicons-image-16: Database, schema and warehouse"

        ```sql
        use role sysadmin;
        
        -- Create a database to store our schemas.
        create database if not exists raw;

        -- Create the schema. The schema stores all our objectss.
        create schema if not exists raw.documents;

        /*
            Warehouses are synonymous with the idea of compute
            resources in other systems. We will use this
            warehouse to call our user defined function.
        */
        create warehouse if not exists development 
            warehouse_size = xsmall
            initially_suspended = true;

        ```

## Snowflake :octicons-feed-tag-16:
Lets start in the AI & ML under Document AI and we'll build our first model.
![UPDATE](images/0.png)  

### Training
Lets give the model a name and location to be stored. Once done, click "create".
![UPDATE](images/01.png)  

Now that it's created lets upload our [training resumes](https://sfc-gh-dwilczak.github.io/tutorials/engineering/documents/ai/files/training.zip). Click upload documents.
![UPDATE](images/02.png)  

Browse and upload the [training pdf](https://sfc-gh-dwilczak.github.io/tutorials/engineering/documents/ai/files/training.zip) files.
![UPDATE](images/03.png)  

Once all have been uploaded click done.
![UPDATE](images/04.png)  

Now they are uploaded to the dataset lets define our question / values we want to pull.
![UPDATE](images/05.png)  

Click "+ value" to start asking questions.
![UPDATE](images/06.png)  

On the left will be it's title/key and right will be the question we want to ask to retrieve from the resumes. Once you click enter on it, it will pull the value and give you an accuracy number.
![UPDATE](images/07.png)  

I asked it a four questions and one that pulls multiple responses/items. When I'm happy with the responses I can click the check box or correct the model.
![UPDATE](images/08.png)

After we accept all and review next we'll get a new example which we'll want to validate or correct. We'll follow this process until we have reviewed all training resumes.
![UPDATE](images/09.png)  

Once all resumes are reviewed we'll be able to see the status of all training resumes.
![UPDATE](images/10.png)  

If we are not happy with the accuracy we can train the model to make our accuracy better.
![UPDATE](images/11.png)  

Once we are happy with the accuracy we can publish the model so it can be used on our testing resumes.
![UPDATE](images/12.png)  

Click publish.
![UPDATE](images/13.png)  

### Parsing new documents
Now we'll notice that two examples are provided for parsing new documents using our published model. We can copy either the folder or single files example, we will use this later.
![UPDATE](images/14.png)  

#### Upload Testing Data
Lets create a new stage in our schema for our testing pdf documents.
![UPDATE](images/15.png)  

Lets call it resumes, encrypt it using "Server-side encreption", and click create.
![UPDATE](images/16.png)  

Lets upload our [testing resumes](https://sfc-gh-dwilczak.github.io/tutorials/engineering/documents/ai/files/testing.zip).
![UPDATE](images/17.png)  

Browse, upload all three pdf's, and click "upload".
![UPDATE](images/18.png)  

#### Parse new documents
Once upload lets open a worksheet and run one of our two example codes pointed at our stage.

=== ":octicons-image-16: Single"

    ```sql linenums="1"
    use schema raw.documents;

    select resumes!predict(get_presigned_url(@resumes,'Ex11.pdf', 1);
    ```

=== ":octicons-image-16: Directory"

    ```sql linenums="1"
    use schema raw.documents;
    
    select 
        resumes!predict(get_presigned_url(@resumes,relative_path, 1)
    from
        directory(@resumes);
    ```

Now we can see our JSON response, if you do an entire directory you can also put it in a CTE and flatten it after be parsed.
![UPDATE](images/19.png)