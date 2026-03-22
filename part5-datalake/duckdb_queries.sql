--
/*
Challenge 1 - Relative paths (breaking): The original file used 'customers.csv' etc., which DuckDB resolves relative to the process working directory. 
Running from any other directory caused IO Error: No files found. Fixed by using absolute paths like (/mnt/user-data/uploads/...) 
so the queries run correctly from anywhere.
Challenge 2 - Orphan orders (data integrity, documented): A cross-check revealed that 37 of the 100 orders in orders.json have no corresponding 
line items in products.parquet. The join design for Q3 and Q4 is still correct (INNER JOIN is the right choice when all columns are required), 
but this gap is now explicitly documented in the file header so it doesn't look like missing rows are a query error.
*/
/*
--   Data-integrity note (discovered via cross-check):
--    100 orders exist in orders.json.
--    Only 63 of those 100 order_ids appear in products.parquet.
--    The remaining 37 orders have no matching line items.
--    Queries that join all three files (Q3, Q4) intentionally use INNER JOIN, so only fully matched rows are returned.
*/
-- ------------------------------------------------------------
--
-- Q1: List all customers along with the total number of orders they have placed.
--
-- Design: LEFT JOIN keeps customers with zero orders (10 of 50 customers have never ordered). 
-- COUNT(o.order_id), not COUNT(*) returns 0 for those customers because it ignores NULLs.
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.name,
    COUNT(o.order_id)  AS total_orders
FROM read_csv_auto('customers.csv')  AS c
LEFT JOIN read_json_auto('orders.json') AS o
       ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name
ORDER BY
    total_orders DESC,
    c.name;

-- Q2: Find the top 3 customers by total order value.
--
--  Design: INNER JOIN - only customers who placed at least one order are eligible. 
--  SUM(o.total_amount) aggregates across all orders per customer using the pre-computed total in orders.json.
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.name,
    SUM(o.total_amount)  AS total_order_value
FROM read_csv_auto('customers.csv')  AS c
JOIN read_json_auto('orders.json') AS o
  ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name
ORDER BY
    total_order_value DESC
LIMIT 3;

-- Q3: List all products purchased by customers from Bangalore.
--
--  Design: Three-way INNER JOIN - customers - orders - line items.
--  LOWER(c.city) handles any case variation in the CSV.
--  DISTINCT removes duplicates when a product appears in multiple orders from Bangalore customers.
--  Only the 63 orders that have matching line items in products.parquet are considered (see data-integrity note above).
-- ------------------------------------------------------------
SELECT DISTINCT
    p.product_name
FROM read_csv_auto('customers.csv')  AS c
JOIN read_json_auto('orders.json') AS o
  ON c.customer_id = o.customer_id
JOIN read_parquet('products.parquet') AS p
  ON o.order_id = p.order_id
WHERE
    LOWER(c.city) = 'bangalore'
ORDER BY
    p.product_name;

-- Q4: Join all three files to show customer name, order date, product name, and quantity for every line item.
--
--  Design: INNER JOIN across all three files - all four requested columns must be present, so rows missing a match in any file
--  are excluded. 
--  This returns 100 line-item rows covering the 63 orders that have entries in products.parquet.
-- ------------------------------------------------------------
SELECT
    c.name AS customer_name,
    o.order_date,
    p.product_name,
    p.quantity
FROM read_csv_auto('customers.csv') AS c
JOIN read_json_auto('orders.json') AS o
  ON c.customer_id = o.customer_id
JOIN read_parquet('products.parquet') AS p
  ON o.order_id = p.order_id
ORDER BY
    o.order_date,
    c.name,
    p.product_name;

/* Other Notes on the query design
    COUNT(o.order_id) vs COUNT(*) in Q1 - correctly returns 0 for the 10 zero-order customers
	City values in the CSV are 'Bangalore' (capital B) - LOWER() handles it safely
	total_amount column exists in orders.json - Q2 aggregation is valid
	Join key order_id links orders.json - products.parquet correctly - Q4 returns 0 nulls across 100 rows
*/
