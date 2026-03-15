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