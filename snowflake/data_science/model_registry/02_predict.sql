-- Using the default version.
select
    8 as hours_studied,
    
    science.students.predict_test_score!predict(hours_studied) as result,
    
    result:output_feature_0::float as prediction;



-- Selecting a specific model version.
with
    predict_test_score as model science.students.predict_test_score version last

select
    3.5 as hours_studied,
    predict_test_score!predict(hours_studied) as result,
    result:output_feature_0::float as prediction;