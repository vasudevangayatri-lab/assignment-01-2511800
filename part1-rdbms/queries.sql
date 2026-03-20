-- To complete the relational database setup, here are the SQL queries based on the 3NF schema 
-- designed in the previous step. These queries use standard joins and aggregations to extract 
-- insights from the normalized tables.

-- Q1: List all customers from Mumbai along with their total order value
SELECT 
    c.customer_name, 
    SUM(o.quantity * p.unit_price) AS total_order_value
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Products p ON o.product_id = p.product_id
WHERE c.customer_city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name;

-- Q2: Find the top 3 products by total quantity sold
SELECT 
    p.product_name, 
    SUM(o.quantity) AS total_quantity_sold
FROM Products p
JOIN Orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Q3: List all sales representatives and the number of unique customers they have handled
SELECT 
    sr.sales_rep_name, 
    COUNT(DISTINCT o.customer_id) AS unique_customers_handled
FROM SalesReps sr
LEFT JOIN Orders o ON sr.sales_rep_id = o.sales_rep_id
GROUP BY sr.sales_rep_id, sr.sales_rep_name;

-- Q4: Find all orders where the total value exceeds 10,000, sorted by value descending
SELECT 
    o.order_id, 
    (o.quantity * p.unit_price) AS total_value
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
WHERE (o.quantity * p.unit_price) > 10000
ORDER BY total_value DESC;

-- Q5: Identify any products that have never been ordered
-- This query is only possible because the 3NF schema separates Products from Orders
SELECT 
    p.product_name
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;