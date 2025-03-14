USE db_orders;
-- CREATE TABLE df_orders (
--   order_id INT PRIMARY KEY,
--   order_date DATE,
--   ship_mode VARCHAR(20),
--   segment VARCHAR(20),
--   country VARCHAR(20),
--   city VARCHAR(20),
--   state VARCHAR(20),
--   postal_code VARCHAR(20),
--   region VARCHAR(20),
--   category VARCHAR(20),
--   sub_category VARCHAR(20),
--   product_id VARCHAR(50),
--   quantity INT,
--   discount DECIMAL(7,2),
--   sale_price DECIMAL(7,2),
--   profit DECIMAL(7,2)
-- );

SELECT * FROM df_orders
LIMIT 10;
-- Find top 10 highest revenue generating products
SELECT product_id, SUM(sale_price * quantity) AS revenue FROM df_orders
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10;

