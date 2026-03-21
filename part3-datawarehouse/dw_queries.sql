-- DW Queries for Retail Business Intelligence

-- Q1: Total sales revenue by product category for each month
-- Goal: Provides insight into category performance trends over time.
-- Logic: Joins fact_sales with dim_product and dim_date dimensions, grouping by category, year, and month.
SELECT 
    p.category, 
    d.year, 
    d.month, 
    SUM(f.total_amount) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY p.category, d.year, d.month
ORDER BY d.year, d.month, total_revenue DESC;


-- Q2: Top 2 performing stores by total revenue
-- Goal: Identifies the highest-grossing retail locations by summing all transactions
-- Logic: Joins fact_sales with dim_store, sums the total_amount, and sorts the result to find the top two performers.
SELECT 
    s.store_name, 
    SUM(f.total_amount) AS total_revenue
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_revenue DESC
LIMIT 2;
/*
-- Q3: Month-over-month sales trend across all stores
-- Goal: Measures growth across all retail locations.
-- Logic: Uses a Common Table Expression (CTE) to aggregate total monthly sales and employs the LAG() window function 
-- to calculate revenue differences and percentage growth/decline compared to the previous month.
WITH monthly_sales AS (
    SELECT 
        d.year, 
        d.month, 
        SUM(f.total_amount) AS current_month_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month
)
SELECT 
    year, 
    month, 
    current_month_revenue,
    LAG(current_month_revenue) OVER (ORDER BY year, month) AS previous_month_revenue,
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY year, month)) / 
        LAG(current_month_revenue) OVER (ORDER BY year, month)) * 100, 
        2
    ) AS mom_growth_percentage
FROM monthly_sales
ORDER BY year, month;
*/
/*
-- Q3: Month-over-month sales trend across all stores
-- Subquery version for compatibility with older SQL engines 
-- (As MySQL Workbench gave an error as WITH is not valid at that position for the server version. 
--  specific database engine that doesn't support Common Table Expressions (CTEs).)
SELECT 
    year, 
    month, 
    current_month_revenue,
    LAG(current_month_revenue) OVER (ORDER BY year, month) AS previous_month_revenue,
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY year, month)) / 
        NULLIF(LAG(current_month_revenue) OVER (ORDER BY year, month), 0)) * 100, 
        2
    ) AS mom_growth_percentage
FROM (
    SELECT 
        d.year, 
        d.month, 
        SUM(f.total_amount) AS current_month_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month
) AS monthly_sales
ORDER BY year, month;
*/

-- Q3: Month-over-month sales trend across all stores
-- This version uses a SELF-JOIN for compatibility with older SQL engines.
SELECT 
    curr.year, 
    curr.month, 
    curr.monthly_revenue AS current_month_revenue,
    prev.monthly_revenue AS previous_month_revenue,
    ROUND(
        ((curr.monthly_revenue - prev.monthly_revenue) / NULLIF(prev.monthly_revenue, 0)) * 100, 
        2
    ) AS mom_growth_percentage
FROM (
    -- Subquery to aggregate sales by year and month
    SELECT d.year, d.month, SUM(f.total_amount) AS monthly_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month
) AS curr
LEFT JOIN (
    -- Identical subquery to join against
    SELECT d.year, d.month, SUM(f.total_amount) AS monthly_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month
) AS prev ON (
    -- Join logic for the previous month (Same year or year rollover)
    (curr.year = prev.year AND curr.month = prev.month + 1) OR
    (curr.year = prev.year + 1 AND curr.month = 1 AND prev.month = 12)
)
/*
Key Considerations for Older Servers:
NULLIF Usage: I kept the NULLIF check to prevent Division by Zero errors, which is critical in older engines that may crash on such operations.
Subquery Aliasing: Each subquery is explicitly aliased (AS curr and AS prev), which is mandatory in MySQL.
Join Condition: The OR condition handles the year-end transition (Year 2023 Month 1 joining to Year 2022 Month 12).
*/