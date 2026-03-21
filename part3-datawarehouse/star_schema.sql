-- Star Schema Design for Retail Transactions

/*
Star Schema Design:
dim_date: Contains temporal attributes such as day, month, year, quarter, and day of week.
dim_store: Stores unique retail locations and their cities.
dim_product: Contains unique products and their standardized categories.
fact_sales: The central table containing numeric measures (units sold, unit price, total amount) and foreign keys to the dimension tables.
*/

-- Create Dimension Tables

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    day_of_week VARCHAR(15) NOT NULL
);

CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    store_city VARCHAR(100) NOT NULL
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- Create Fact Table
CREATE TABLE fact_sales (
    transaction_id VARCHAR(20) PRIMARY KEY,
    date_id INT NOT NULL,
    store_id INT NOT NULL,
    product_id INT NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    units_sold INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (store_id) REFERENCES dim_store(store_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);

-- Insert Cleaned Sample Data

/*
Data Cleaning Summary
Dates: Standardized mixed formats (e.g., DD/MM/YYYY, MM/DD/YYYY, and - delimiters) into a consistent YYYY-MM-DD format.
Categories: Standardized inconsistent casing (e.g., "electronics" vs "Electronics") and unified naming (e.g., "Grocery" to "Groceries").
Missing Values: Filled missing store_city values by mapping them to their respective store_name (e.g., Chennai from Chennai Anna).
*/

-- Insert into dim_date
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230102, '2023-01-02', 2, 1, 2023, 1, 'Monday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230120, '2023-01-20', 20, 1, 2023, 1, 'Friday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230122, '2023-01-22', 22, 1, 2023, 1, 'Sunday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230127, '2023-01-27', 27, 1, 2023, 1, 'Friday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230204, '2023-02-04', 4, 2, 2023, 1, 'Saturday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230320, '2023-03-20', 20, 3, 2023, 1, 'Monday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230401, '2023-04-01', 1, 4, 2023, 2, 'Saturday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230402, '2023-04-02', 2, 4, 2023, 2, 'Sunday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230424, '2023-04-24', 24, 4, 2023, 2, 'Monday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230504, '2023-05-04', 4, 5, 2023, 2, 'Thursday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230809, '2023-08-09', 9, 8, 2023, 3, 'Wednesday');
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week) VALUES (20230829, '2023-08-29', 29, 8, 2023, 3, 'Tuesday');

-- Insert into dim_store
INSERT INTO dim_store (store_id, store_name, store_city) VALUES (1, 'Chennai Anna', 'Chennai');
INSERT INTO dim_store (store_id, store_name, store_city) VALUES (2, 'Delhi South', 'Delhi');
INSERT INTO dim_store (store_id, store_name, store_city) VALUES (3, 'Bangalore MG', 'Bangalore');

-- Insert into dim_product
INSERT INTO dim_product (product_id, product_name, category) VALUES (1, 'Speaker', 'Electronics');

-- Insert into fact_sales
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5000', 20230829, 1, 1, 'CUST045', 3, 49262.78, 147788.34);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5258', 20230504, 1, 1, 'CUST046', 10, 49262.78, 492627.8);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5068', 20230401, 2, 1, 'CUST049', 3, 49262.78, 147788.34);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5090', 20230127, 2, 1, 'CUST024', 9, 49262.78, 443365.02);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5186', 20230320, 2, 1, 'CUST039', 16, 49262.78, 788204.48);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5222', 20230809, 2, 1, 'CUST035', 18, 49262.78, 886730.04);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5031', 20230102, 3, 1, 'CUST010', 20, 49262.78, 985255.6);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5043', 20230402, 3, 1, 'CUST006', 16, 49262.78, 788204.48);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5070', 20230204, 3, 1, 'CUST020', 15, 49262.78, 738941.7);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5095', 20230120, 3, 1, 'CUST031', 5, 49262.78, 246313.9);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5167', 20230122, 3, 1, 'CUST006', 10, 49262.78, 492627.8);
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES ('TXN5205', 20230424, 3, 1, 'CUST004', 17, 49262.78, 837467.26);
