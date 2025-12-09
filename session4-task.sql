-- For the same database as we used in the previous [e-commerce] do the following 
-- * Write a SQL query to search for all products with the word "camera" in either the product name or description.
SELECT *
FROM products p
WHERE p.name LIKE '%camera%' OR p.description LIKE '%camera%'

-- create index on name column for fast retrieval
CREATE INDEX idx_product_name ON product(name)
CREATE INDEX idx_product_desc ON product(description)
/*
chatgpt review

Indexes

Your idea is correct: creating indexes helps, but LIKE '%camera%' does NOT use normal B-tree indexes in PostgreSQL.

To optimize this search, you must use a GIN trigram index:

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_products_name_trgm 
    ON products USING gin (name gin_trgm_ops);

CREATE INDEX idx_products_desc_trgm 
    ON products USING gin (description gin_trgm_ops);


✔ This makes LIKE '%...%' fast (Postgres uses trigram similarity).
*/




-- * Can you design a query to suggest popular products in the same category for the same author, 
--   excluding the Purchsed product from the recommendations?
SELECT COUNT(od.product_id) as product_count, prod.name as product_name
FROM order_details od
INNER JOIN products prod ON od.product_id = prod.id
INNER JOIN categories cat ON prod.category_id = cat.id
INNER JOIN orders o ON od.order_id = o.id
WHERE cat.name = 'recommended Category' 
	-- AND o.customer_id <> 'customerId' 
	    AND od.product_id NOT IN (   
        SELECT od2.product_id
        FROM order_details od2
        JOIN orders o2 ON od2.order_id = o2.id
        WHERE o2.customer_id = 'customerId'
    )
GROUP BY od.product_id, prod.name 
ORDER BY product_count desc








