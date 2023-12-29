/*
    ------------ Setup ------------
*/

use role sysadmin;

-- Create the raw database for our data and a science database for our models.
create database if not exists 
    raw comment='This is only raw data from your source.';
create database if not exists 
    science comment='This is only for data science use cases.';

-- Create the schema. The schema stores all objects that we will need later.
create schema if not exists raw.training;
create schema if not exists science.linear;

-- Create a stage (folder) to store our model in.
use schema science.linear;
create stage if not exists models
    directory = ( enable = true);

-- Create some fake x,y data for our model.
use schema raw.training;
CREATE TABLE xy (
    x INT,
    y INT
);

-- Insert 15 rows of fake data
INSERT INTO xy (x, y)
    VALUES
    (1, 10),
    (2, 15),
    (3, 23),
    (4, 25),
    (5, 32),
    (6, 35),
    (7, 40),
    (8, 43),
    (9, 50),
    (10, 52);

-- Create a warehouse to do the training
create or replace warehouse scientist 
    WAREHOUSE_SIZE=XSMALL
    INITIALLY_SUSPENDED=TRUE;

/*
    ------------ Train ------------
*/

use database science;
use schema linear;
use warehouse scientist;

create or replace procedure train()
  returns variant
  language python
  runtime_version = 3.8
  packages = ('snowflake-snowpark-python', 'scikit-learn', 'joblib')
  handler = 'main'
  as 
$$

import snowflake.snowpark

from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from joblib import dump

import numpy as np
import os


def main(session):
    
    # Select the raw data from our table.
    dataframe = session.table(
    'raw.training.xy'
    ).to_pandas()

    X = np.array(dataframe['X']).reshape(-1, 1)
    y = np.array(dataframe['Y']).reshape(-1, 1)
        
    # Splitting the data into  training and test datasets.
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.25)
        
    # Training the model.
    model = LinearRegression() 
    model.fit(X_train, y_train)

    # Save the model to a temp folder.
    file = os.path.join('/tmp', 'model.joblib')
    dump(model,file)
    # Save the model file to a stage.
    session.file.put(file, "@models",overwrite=True)

    
    prediction = model.predict(np.array([1]).reshape(-1, 1))[0][0]
    # Return model R2 score on train and test data and what it predicted(1)
    return {
        "R2 score on Train": model.score(X_train, y_train),
        "R2 score on Test": model.score(X_test, y_test),
        "Prediction(1)=": prediction
    }
$$;

/*
    ------------ Run / Schedule Training Model ------------
*/

use warehouse scientist;

-- Train the model and save it to our stage(folder) we created during setup.
call science.linear.train();

-- Training the model every 24 hours.
CREATE TASK train_model_24h
    schedule = 'USING CRON 0 2 * * * UTC' -- Run every night at 2 AM. UTC time zone.
    warehouse = scientist
AS
    call science.linear.train();

-- Execute it immediately. 
execute task train_model_24h;

/*
    ------------ SQL Function ------------
*/

use database science;
use schema linear;

-- User definded function to be used anywhere.
create or replace function predict(value int)
    returns int
    language python
    runtime_version = '3.8'
    packages = ('snowflake-snowpark-python', 'joblib', 'scikit-learn')
    imports=('@models/model.joblib.gz')
    handler = 'main'
as
$$
from joblib import load
import numpy as np
import sklearn
import sys
import os


def main(value):
    # Get the directory stimpulated above.
    import_directory = sys._xoptions["snowflake_import_directory"]
    
    # Load the model.
    model = load(import_directory + 'model.joblib.gz')

    # Make the pediction using our saved model.
    prediction = model.predict(np.array([value]).reshape(-1, 1))[0][0] 

    return prediction
$$;

/*
    ------------ Use Model ------------
*/

-- Can be run from any tool since it's just sql.
select science.linear.predict(15) as prediction;