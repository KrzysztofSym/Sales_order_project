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
 (
    SELECT 
        region, 
        product_id, 
        SUM(sale_price) AS price,  
        ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(sale_price) DESC) AS RANKING  
    FROM df_orders  
    GROUP BY region, product_id
)
SELECT * FROM cte
WHERE RANKING <= 5;

-- Find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
WITH cte AS (SELECT year(order_date) AS order_year, month(order_date) AS order_month, SUM(sale_price) as sales FROM df_orders
GROUP BY 1, 2
)
SELECT order_month
, SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022
, SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month
;

-- for each category which month had highest sales
WITH cte AS (SELECT category, SUM(sale_price) AS sales, DATE_FORMAT(order_date, '%Y-%m') AS year__month,
RANK() OVER(PARTITION BY category ORDER BY SUM(sale_price) DESC) AS ranking  FROM df_orders
GROUP BY 1, 3
ORDER BY sales DESC
)
SELECT * FROM cte
WHERE ranking = 1;

-- which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (SELECT sub_category, year(order_date) AS order_year, SUM(sale_price) AS sales
FROM df_orders
GROUP BY 1, 2) , 
cte_years AS (SELECT sub_category,
 SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2023,
 SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2022
FROM cte
GROUP BY sub_category)
SELECT *, (sales_2023-sales_2022) AS absolute_change,
ROUND((sales_2023-sales_2022)*100/sales_2022, 2) AS percentage_change FROM cte_years
ORDER BY percentage_change DESC;


WITH cte_2022 AS (
    SELECT sub_category, SUM(sale_price) AS sales_2022
    FROM df_orders
    WHERE YEAR(order_date) = 2022
    GROUP BY sub_category
),
cte_2023 AS (
    SELECT sub_category, SUM(sale_price) AS sales_2023
    FROM df_orders
    WHERE YEAR(order_date) = 2023
    GROUP BY sub_category
)
SELECT 
    c2022.sub_category,
    COALESCE(c2022.sales_2022, 0) AS sales_2022,
    COALESCE(c2023.sales_2023, 0) AS sales_2023,
    COALESCE(c2023.sales_2023, 0) - COALESCE(c2022.sales_2022, 0) AS absolute_change,
    ROUND(
        (COALESCE(c2023.sales_2023, 0) - COALESCE(c2022.sales_2022, 0)) / NULLIF(c2022.sales_2022, 0) * 100, 2
    ) AS percentage_change
FROM cte_2022 c2022
LEFT JOIN cte_2023 c2023 ON c2022.sub_category = c2023.sub_category
UNION
SELECT 
    c2023.sub_category,
    COALESCE(c2022.sales_2022, 0) AS sales_2022,
    COALESCE(c2023.sales_2023, 0) AS sales_2023,
    COALESCE(c2023.sales_2023, 0) - COALESCE(c2022.sales_2022, 0) AS absolute_change,
    ROUND(
        (COALESCE(c2023.sales_2023, 0) - COALESCE(c2022.sales_2022, 0)) / NULLIF(c2022.sales_2022, 0) * 100, 2
    ) AS percentage_change
FROM cte_2023 c2023
LEFT JOIN cte_2022 c2022 ON c2023.sub_category = c2022.sub_category;




