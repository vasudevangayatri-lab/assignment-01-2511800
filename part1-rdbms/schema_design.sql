-- 1.2 — Schema Design - Part 1: RDBMS Schema Design (part1-rdbms/schema_design.sql)
-- To normalize the data to Third Normal Form (3NF) and eliminate the identified anomalies, we must split the flat structure into entities where every non-key attribute is dependent only on the primary key. 

-- Below is the SQL schema design and data population script.
-- Best practice for VARCHAR dimensioning is to set the length to the smallest reasonable maximum based on actual data profiling, rathen than using arbitrary defaults like 255. Accurate sizing optimizes storage, improves index performance and enforces data integrity. Hence I have defined the tables with specific dimentioning.
-- For readability and consistency with ORM (Object-Relational Mapping) tools, for schema names i have used lower case, pluralized nouns seperated by undrscore without any prefixes like tbl etc.
-- As a good practice included NOT NULL constraint to PK, though explicit declation is not required.

-- 1.Create Customers Table
-- Eliminates redundancy of customer contact details
CREATE TABLE Customers (
    customer_id VARCHAR(20) PRIMARY KEY NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100) NOT NULL
);

-- 2. Create Products Table
-- Prevents Deletion Anomaly (products exist even without orders)
CREATE TABLE Products (
    product_id VARCHAR(20) PRIMARY KEY NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

-- 3. Create SalesReps Table
-- Eliminates Update Anomaly (standardizes office addresses)
CREATE TABLE SalesReps (
    sales_rep_id VARCHAR(20) PRIMARY KEY NOT NULL,
    sales_rep_name VARCHAR(100) NOT NULL,
    sales_rep_email VARCHAR(100) NOT NULL,
    office_address TEXT NOT NULL
);

-- 4. Create Orders Table
-- Links entities together and stores transaction-specific data
CREATE TABLE Orders (
    order_id VARCHAR(20) PRIMARY KEY NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    sales_rep_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (sales_rep_id) REFERENCES SalesReps(sales_rep_id)
);

-- DATA POPULATION

-- Populate Customers
INSERT INTO Customers (customer_id, customer_name, customer_email, customer_city) VALUES
('C001', 'Rohan Mehta', 'rohan@gmail.com', 'Mumbai'),
('C002', 'Priya Sharma', 'priya@gmail.com', 'Delhi'),
('C003', 'Amit Verma', 'amit@gmail.com', 'Bangalore'),
('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai'),
('C006', 'Neha Gupta', 'neha@gmail.com', 'Delhi');

-- Populate Products
INSERT INTO Products (product_id, product_name, category, unit_price) VALUES
('P001', 'Laptop', 'Electronics', 55000),
('P003', 'Desk Chair', 'Furniture', 8500),
('P004', 'Notebook', 'Stationery', 120),
('P005', 'Headphones', 'Electronics', 3200),
('P007', 'Pen Set', 'Stationery', 250);

-- Populate SalesReps
INSERT INTO SalesReps (sales_rep_id, sales_rep_name, sales_rep_email, office_address) VALUES
('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
('SR02', 'Anita Desai', 'anita@corp.com', 'Delhi Office, Connaught Place, New Delhi - 110001'),
('SR03', 'Ravi Kumar', 'ravi@corp.com', 'South Zone, MG Road, Bangalore - 560001');
-- Note: SR04 and SR05 can now be added without needing a sale (Solves Insertion Anomaly)

-- Populate Orders
INSERT INTO Orders (order_id, customer_id, product_id, sales_rep_id, quantity, order_date) VALUES
('ORD1027', 'C002', 'P004', 'SR02', 4, '2023-11-02'),
('ORD1114', 'C001', 'P007', 'SR01', 2, '2023-08-06'),
('ORD1153', 'C006', 'P007', 'SR01', 3, '2023-02-14'),
('ORD1002', 'C002', 'P005', 'SR02', 1, '2023-01-17'),
('ORD1118', 'C006', 'P007', 'SR02', 5, '2023-11-10');

-- NOTE: How this Schema Eliminates Anomalies:
-- 1.Insertion Anomaly Solved: We can now insert a new Product or Sales Rep into their respective tables even if they don't have an order yet.
-- 2.Update Anomaly Solved: If e.g. sales rep- Deepak Joshi's office address changes, we only need to update one row in the SalesReps table. It will automatically reflect across all his historical orders via the foreign key.
-- 3.Deletion Anomaly Solved: If we delete an order from the Orders table, the Customer's info and the Product's details remain safely stored in their independent tables.
