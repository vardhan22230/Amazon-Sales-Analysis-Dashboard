-- ============================================================
-- Amazon Sales Analysis — SQL Queries
-- Dataset: Amazon_Combined_Data.xlsx
-- Columns: Product Category, Product Description, Price(Dollar),
--          Number of reviews, Shipment, Order Date
-- Period: Jan 2019 – Dec 2022 | Total Records: 89,082
-- ============================================================


-- ------------------------------------------------------------
-- Q1. Total products and average price per category
--     Business use: Identify which categories dominate the catalog
-- ------------------------------------------------------------
SELECT
    [Product Category],
    COUNT(*)                          AS total_products,
    ROUND(AVG([Price(Dollar)]), 2)    AS avg_price,
    MIN([Price(Dollar)])              AS min_price,
    MAX([Price(Dollar)])              AS max_price
FROM amazon_data
GROUP BY [Product Category]
ORDER BY total_products DESC;


-- ------------------------------------------------------------
-- Q2. Total review volume per category (demand signal)
--     Business use: High reviews = high customer engagement
-- ------------------------------------------------------------
SELECT
    [Product Category],
    SUM([Number of reviews])          AS total_reviews,
    ROUND(AVG([Number of reviews]), 0) AS avg_reviews_per_product,
    MAX([Number of reviews])          AS max_reviews_single_product
FROM amazon_data
GROUP BY [Product Category]
ORDER BY total_reviews DESC;


-- ------------------------------------------------------------
-- Q3. Top 10 products by review count
--     Business use: Find best-sellers and high-engagement products
-- ------------------------------------------------------------
SELECT TOP 10
    [Product Category],
    LEFT([Product Description], 80)   AS product_short_name,
    [Price(Dollar)]                   AS price,
    [Number of reviews]               AS total_reviews
FROM amazon_data
ORDER BY [Number of reviews] DESC;


-- ------------------------------------------------------------
-- Q4. Monthly order trends (2019–2022)
--     Business use: Identify seasonal peaks for inventory planning
-- ------------------------------------------------------------
SELECT
    YEAR([Order Date])                AS order_year,
    MONTH([Order Date])               AS order_month,
    DATENAME(MONTH, [Order Date])     AS month_name,
    COUNT(*)                          AS total_orders,
    ROUND(AVG([Price(Dollar)]), 2)    AS avg_order_value
FROM amazon_data
GROUP BY
    YEAR([Order Date]),
    MONTH([Order Date]),
    DATENAME(MONTH, [Order Date])
ORDER BY order_year, order_month;


-- ------------------------------------------------------------
-- Q5. Year-over-year order volume comparison
--     Business use: Track business growth trends annually
-- ------------------------------------------------------------
SELECT
    YEAR([Order Date])                AS order_year,
    COUNT(*)                          AS total_orders,
    ROUND(AVG([Price(Dollar)]), 2)    AS avg_price,
    SUM([Number of reviews])          AS total_reviews
FROM amazon_data
GROUP BY YEAR([Order Date])
ORDER BY order_year;


-- ------------------------------------------------------------
-- Q6. Price segmentation — budget vs mid vs premium products
--     Business use: Understand catalog pricing distribution
-- ------------------------------------------------------------
SELECT
    [Product Category],
    SUM(CASE WHEN [Price(Dollar)] < 25  THEN 1 ELSE 0 END) AS budget_products,
    SUM(CASE WHEN [Price(Dollar)] BETWEEN 25 AND 100 THEN 1 ELSE 0 END) AS mid_range_products,
    SUM(CASE WHEN [Price(Dollar)] > 100 THEN 1 ELSE 0 END) AS premium_products,
    COUNT(*)                                                AS total_products
FROM amazon_data
GROUP BY [Product Category]
ORDER BY total_products DESC;


-- ------------------------------------------------------------
-- Q7. Review-to-price ratio (value perception index)
--     Business use: Products with high reviews at low price = high value perception
-- ------------------------------------------------------------
SELECT TOP 10
    [Product Category],
    LEFT([Product Description], 80)    AS product_short_name,
    [Price(Dollar)]                    AS price,
    [Number of reviews]                AS reviews,
    ROUND(CAST([Number of reviews] AS FLOAT) / NULLIF([Price(Dollar)], 0), 1) AS reviews_per_dollar
FROM amazon_data
WHERE [Price(Dollar)] > 0
ORDER BY reviews_per_dollar DESC;


-- ------------------------------------------------------------
-- Q8. Category performance by quarter
--     Business use: Identify which categories spike in which quarters
-- ------------------------------------------------------------
SELECT
    [Product Category],
    YEAR([Order Date])                 AS order_year,
    DATEPART(QUARTER, [Order Date])    AS quarter,
    COUNT(*)                           AS total_orders,
    ROUND(AVG([Price(Dollar)]), 2)     AS avg_price
FROM amazon_data
GROUP BY
    [Product Category],
    YEAR([Order Date]),
    DATEPART(QUARTER, [Order Date])
ORDER BY [Product Category], order_year, quarter;


-- ------------------------------------------------------------
-- Q9. Products priced above category average (premium flagging)
--     Business use: Find outlier premium products in each category
-- ------------------------------------------------------------
SELECT
    a.[Product Category],
    LEFT(a.[Product Description], 80)  AS product_short_name,
    a.[Price(Dollar)]                  AS product_price,
    ROUND(cat_avg.avg_price, 2)        AS category_avg_price,
    ROUND(a.[Price(Dollar)] - cat_avg.avg_price, 2) AS price_above_avg
FROM amazon_data a
JOIN (
    SELECT [Product Category], AVG([Price(Dollar)]) AS avg_price
    FROM amazon_data
    GROUP BY [Product Category]
) cat_avg ON a.[Product Category] = cat_avg.[Product Category]
WHERE a.[Price(Dollar)] > cat_avg.avg_price
ORDER BY price_above_avg DESC;


-- ------------------------------------------------------------
-- Q10. Shipment destination analysis
--      Business use: Understand geographic demand distribution
-- ------------------------------------------------------------
SELECT
    Shipment,
    COUNT(*)                           AS total_orders,
    ROUND(AVG([Price(Dollar)]), 2)     AS avg_order_value,
    SUM([Number of reviews])           AS total_reviews
FROM amazon_data
GROUP BY Shipment
ORDER BY total_orders DESC;
