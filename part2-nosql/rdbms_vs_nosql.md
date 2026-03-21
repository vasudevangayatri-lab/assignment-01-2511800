**Subjective — part2-nosql/rdbms_vs_nosql.md**

## Database Recommendation
Choosing between **MySQL and MongoDB** for a healthcare patient management system requires balancing data integrity with scalability. In this scenario, MySQL (RDBMS) is the superior recommendation for the core patient management system.

The primary reason lies in the ACID (Atomicity, Consistency, Isolation, Durability) properties inherent to MySQL. Healthcare data, such as patient records, prescriptions, and billing, demands "Immediate Consistency". If a doctor updates a dosage, that change must be reflected instantly and accurately across all tables. 

Under the **CAP Theorem**, MySQL prioritizes Consistency and Availability (CA). A relational structure ensures that complex relationships between patients, doctors, and insurance providers are enforced via foreign keys and normalized schemas, preventing the "data orphans" that can occur in a BASE (Basically Available, Soft state, Eventual consistency) environment like MongoDB.

However, the requirement for a **fraud detection module** introduces a significant pivot. Fraud detection often involves analyzing massive volumes of semi-structured data, such as login patterns, IP addresses, and real-time behavioral telemetry, which doesn't fit neatly into a rigid table. For this specific module, I would recommend a Polyglot Persistence approach.
> - Polyglot persistence is the practice of using multiple, different database technologies (SQL, NoSQL, graph, key-value) within a single application to best match the specific data needs of each component. It is considered a modern, strategic approach to avoid the limitations of "one-size-fits-all" monolithic databases. 

While the core patient data should remain in MySQL to satisfy regulatory compliance and data integrity, the fraud detection component should utilize MongoDB. MongoDB’s horizontal scalability and flexible schema allow it to ingest high-velocity "Big Data" that a relational database might struggle to index efficiently. 

In terms of the CAP theorem, MongoDB leans toward Consistency and Partition Tolerance (CP), making it excellent for managing distributed data across clusters. By using both, the healthcare startup can ensure that sensitive medical records are strictly ACID-compliant, while the analytical fraud engine remains agile and scalable.

## ACID vs. BASE Comparison

|Feature  |	ACID (Relational / MySQL) | (NoSQL / MongoDB)|
| :------------- |:-------------:|:----------------: | 
| Full Name      |Atomicity, Consistency, Isolation, Durability | Basically Available, Soft state, Eventual consistency
|Consistency	 |Immediate: Data is updated across all nodes instantly.|Eventual: Data will become consistent over time.
|Flexibility	| Rigid: Requires a predefined schema (tables/rows).	|Fluid: Dynamic schema (documents/key-value).|
|Scaling	|Vertical: Increase CPU/RAM on a single server.	|Horizontal: Add more servers to a cluster (Sharding).|
|Best For	|Financial systems, Healthcare records, ERPs.	|Real-time analytics, IoT, Content Management.|	

## Mapping to the CAP Theorem

When choosing a database, the CAP Theorem states that a distributed system can only provide two of the following three guarantees: Consistency, Availability, and Partition Tolerance.

- **MySQL (CA/CP):** Typically focuses on Consistency and Availability. In a distributed setup, it can be configured for Partition Tolerance, but it will always prioritize data integrity (Consistency) over speed.
- **MongoDB (CP):** Focuses on Consistency and Partition Tolerance. If a network partition occurs, MongoDB will stop writes to the primary node until a new election completes to ensure that no conflicting data is written, maintaining a "single version of the truth."
