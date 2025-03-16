-- CREATE DATABASE db_orders;
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
-- Find top 5 highest selling products in each region
WITH cte AS
(SELECT region, product_id, SUM(sale_price) AS sales FROM df_orders
GROUP BY 1, 2)
SELECT * FROM
(SELECT *, row_number() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
FROM cte) A
WHERE rn <= 5;
-- Find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
SELECT year(order_date), month(order_date), SUM(sale_price) FROM df_orders
GROUP BY 1, 2;
