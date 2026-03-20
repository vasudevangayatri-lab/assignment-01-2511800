# Sec 1: Anomaly Analysis

The analysis of the `orders_flat.csv` file reveals several database design issues. Because this is a flat file (non-normalized), it contains significant data redundancy, leading to the following anomalies:

## 1. Update Anomaly
An update anomaly occurs when data is stored redundantly in multiple rows, and changing it in one place requires updating every single occurrence to maintain consistency.
- **Evidence in Data:** The Sales Representative SR01 (Deepak Joshi) has his office address recorded in two different ways across the dataset:
  - Row-40 has “Mumbai HQ, Nariman Point, Mumbai - 400021”
  - Row-39 has “Mumbai HQ, Nariman Pt, Mumbai - 400021”
- **Problem:** If the office moves, we must update 83 different rows for this specific representative. If even one row is missed (as seen above with the abbreviation), the database provides conflicting information.

## 2. Deletion Anomaly
A deletion anomaly occurs when deleting a record (like an order) unintentionally results in the loss of other unrelated, important information.
- **Example Case:** For any product in the Order file. For example, Product P006 (Standing Desk).
- **Problem:** If we decide to cancel or delete the specific orders associated with this product to clean up the sales history, we will simultaneously lose all record of the product itself (its name, category, and unit price). There is no independent "Products" list; the product exists only as long as an order for it exists.

## 3. Insertion Anomaly
An insertion anomaly occurs when it is impossible to add certain data to the database because it requires the presence of other unrelated data.
- **Example Case:** Adding a new Sales Representative or a New Product.
- **Problem:** If the company hires a new sales rep (e.g., SR04) or launches a new product (e.g., P009), we cannot add them to this file until they are associated with an Order ID. Since `order_id` is the primary key for the table, we cannot have a "placeholder" row for a representative who hasn't made a sale yet or a product that hasn't been bought yet.

## Summary of Data Redundancy
The following table shows how many times info must be repeated, increasing the risk of the anomalies mentioned above:

| Entity Type | Unique IDs | Total Row Occurrences | Redundancy Level |
|--------------|--------------|------------------------|------------------|
| Sales Reps   | 3            | 186 rows              | High (SR01 appears 83 times) |
| Customers    | 8            | 186 rows              | High (C008 appears 28 times) |
| Products     | 7            | 186 rows              | Medium (P004 appears 34 times) |



# Sec 2: Normalization Justification

While keeping all data in a single flat table may appear "simpler" for basic data entry, it is a classic case of technical debt that leads to data corruption and operational inefficiency. Based on the `orders_flat.csv` dataset, the argument that normalization is "over-engineering" is refuted by three critical issues:

1. **Data Integrity and the Update Anomaly**
   - In a flat structure, a single piece of information is repeated across dozens of rows. For example, Sales Rep SR01 (Deepak Joshi) appears 83 times.
   - In the current file, his office address is recorded inconsistently (using both "Nariman Point" and "Nariman Pt").
   - Fixing this requires a risky global search-and-replace. If one row is missed, the database provides conflicting truths.
   - By normalizing into a `SalesReps` table, the address exists in exactly one place, guaranteeing 100% consistency with a single update.

2. **Prevention of Data Loss (Deletion Anomaly)**
   - The flat file ties the existence of a product to the existence of an order.
   - For instance, if we delete the orders for P006 (Wireless Mouse) to archive old sales, we unintentionally delete the product itself from our system.
   - We lose its category and price.
   - Normalizing to 3NF ensures that the "Product" entity exists independently of "Transactions," protecting our master data.

3. **Operational Flexibility (Insertion Anomaly)**
   - Under the flat-table logic, we cannot add a new Sales Rep or a new Product to the system until a sale actually occurs because `order_id` (Primary Key) cannot be null.
   - Normalization allows the business to onboard employees and catalog inventory in advance of sales, which is essential for scalable business operations.

In summary, normalization is not over-engineering; it is the foundation of data reliability. It transforms a fragile spreadsheet into a robust relational system that prevents human error and supports business growth.
