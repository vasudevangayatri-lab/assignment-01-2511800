Subjective — part5-datalake/architecture_choice.md 
## Architecture Recommendation
I would recommend a **Data Lakehouse** architecture for this startup, as it combines the flexibility of a Data Lake with the performance and structure of a Data Warehouse.

First, the startup is dealing with **diverse data types**: structured (payment transactions), semi-structured (GPS logs), and unstructured (text reviews and images).

A Data Warehouse can only store structured data, so images and raw text would need to go elsewhere. A Data Lake stores everything but has weak querying. The Lakehouse supports all these types together, which avoids building and maintaining separate storage systems and can store all these formats in one unified system without forcing rigid schemas upfront, unlike a traditional Data Warehouse.

Second, **Payment data needs ACID transactions**: Unlike GPS logs or reviews, payment records cannot afford inconsistency or partial writes. A plain Data Lake doesn't support ACID transactions by default. Lakehouse formats like Delta Lake or Apache Iceberg add this capability on top of object storage, making it suitable for financial data without a separate database and it provides strong data governance and reliability.

Third, **it supports both analytics and machine learning efficiently**: The company may want to run BI queries (e.g., revenue trends, delivery times) while also training models on reviews (sentiment analysis) or images (menu recognition). A Data Lakehouse allows direct access to raw and processed data without duplication, reducing latency and complexity without copying data between systems.

Features like ACID transactions, schema enforcement, and versioning (found in Lakehouse systems) ensure data quality and consistency—critical for financial data and reporting accuracy. Additionally, a Data Lakehouse is **cost-effective and scalable**, as it typically uses cloud object storage while still enabling high-performance querying through optimized engines.

In summary, overall, the Lakehouse is a practical middle ground - more flexible than a warehouse, more structured than a lake. Data Lakehouse offers the best balance of flexibility, performance, and governance, making it ideal for a fast-growing, data-rich food delivery startup with evolving analytical and AI needs.
