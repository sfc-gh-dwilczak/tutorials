

```
-- Create the 'products' table
CREATE OR REPLACE TABLE products (
    product_id INT,
    product_name VARCHAR(100),
    description VARCHAR(500),
    description_vector vector(float, 768)
);

-- Insert sample data into 'products'
INSERT INTO products (product_id, product_name, description) VALUES
    (1, 'Laptop', 'A high-performance laptop with 16GB RAM and 512GB SSD.'),
    (2, 'Smartphone', 'A smartphone with excellent camera quality and battery life.'),
    (3, 'Headphones', 'Noise-cancelling over-ear headphones with superior sound quality.');


update products
  set description_vector = snowflake.cortex.embed_text_768('snowflake-arctic-embed-m', description);


select * from products;
```


```
with
    prompt as (
        select
            'I want to get a new smartphone' as prompt,
            snowflake.cortex.embed_text_768('snowflake-arctic-embed-m', prompt) as prompt_vector
    )

    
select
    * exclude (prompt_vector, description_vector)
from
    prompt, products
order by
    vector_L2_distance(prompt_vector, description_vector)
limit
    2;```