# Design Justification — Hospital AI Data System

---

## Storage Systems

Each of the four goals drives a distinct storage requirement, shaped by the **type of data** involved — whether it is structured, unstructured, or time-stamped — and the nature of the workload it must support. The design assigns a purpose-built store to each category rather than forcing a single database to serve every use case.

**Goal 1 — Readmission Risk Prediction** is served by a **columnar data warehouse** (analytical store for structured data). A data warehouse is designed to hold large volumes of structured, historical records — rows and columns of patient demographics, diagnoses, procedures, billing codes, and discharge information — and to answer complex aggregation queries across millions of records efficiently. Years of structured treatment and billing data from the Electronic Health Records (EHR), Electronic Medical Records (EMR) and Admissions systems are loaded into this store nightly via a batch ETL pipeline. The readmission risk model is trained on this structured history and scores new patients by querying the same warehouse.

**Goal 2 — Plain-English Patient History Queries** requires two stores working together, because patient history contains two fundamentally different data types. The **structured data** — lab results, prescription records, diagnosis codes, admission dates — is held in a **relational transactional database (RDBMS)**, which organises information in well-defined tables and supports fast, precise lookups. The **unstructured data** — free-text clinical notes, doctor observations, nursing entries — cannot be searched by keyword matching alone; a doctor asking *"Any cardiac events before?"* needs the system to understand meaning, not just find matching words. For this, unstructured text is converted into numerical representations (embeddings) and stored in a **vector database (semantic search store)**, which is purpose-built for meaning-based retrieval across free-text content.

**Goal 3 — Monthly Management Reports** is served by the same **columnar data warehouse** used for Goal 1. Structured operational data — bed counts, department costs, admission and discharge volumes — is aggregated nightly into pre-computed summary views. The reporting service queries these structured summaries on a monthly schedule, eliminating any manual data gathering.

**Goal 4 — Real-Time ICU Vitals** is handled by a **time-series database**, fed through a **real-time event streaming platform**. ICU devices produce structured but extremely high-frequency data — a numeric reading for each vital sign, stamped with a precise timestamp, every second. A standard relational database would be overwhelmed by this write volume and lacks native support for time-windowed queries (e.g., rolling 5-minute averages). A time-series database is designed precisely for this pattern. The streaming platform sits in front of it, acting as a buffer that decouples the device producers from the consumers — the dashboard and the alert engine — so that no reading is lost even if one consumer experiences a brief delay.

---

## OLTP vs OLAP Boundary

The transactional system ends at the **relational database (RDBMS)** and the **time-series database** — the two operational stores that record events as they happen. The relational database handles structured writes of clinical, billing, and administrative records arriving from EHR systems, labs, and clinical workstations; each row represents a discrete, well-defined event such as an admission, a test result, or a prescription. The time-series database handles the continuous structured stream of numeric measurements from ICU devices. Both are optimised for low-latency individual writes and row-level consistency; neither is suited to multi-year aggregation queries.

The analytical system begins at the **columnar data warehouse**, which receives structured data nightly from the relational database via a batch ETL pipeline using Change Data Capture (CDC) — a mechanism that identifies and transfers only the rows that changed since the last run. This is the OLTP/OLAP handoff point: where write-optimised row stores pass their structured data to a read-optimised columnar store built for analysis. From this boundary onwards, data is no longer being modified — it is being studied. Heavy analytical workloads, including readmission model training and monthly report generation, run entirely within the warehouse and never touch the live operational stores, ensuring that clinical transactions are never slowed by analytical queries.

Unstructured data — clinical notes and free-text entries — follows a parallel path. It is ingested from the relational database into the vector database, where it is transformed into embeddings and indexed for semantic search. This path is outside the OLTP/OLAP boundary in the traditional sense; it represents a third workload type, distinct from both transactional writes and columnar analytics.

---

## Trade-offs

**The primary trade-off is data freshness versus system simplicity and cost.**

By routing structured data through a nightly batch pipeline into the warehouse, the design avoids the significant cost and operational complexity of continuous real-time streaming into an analytical store. The consequence is that the readmission risk model and monthly reports always work with data that is up to 12 hours old. A clinical event — a new diagnosis, a changed medication — occurring late at night may not be reflected in the following morning's risk score until the batch has completed.

This lag is clinically acceptable for Goals 1 and 3. Readmission risk is assessed at admission or before discharge, not in real time, and management reports are inherently retrospective. The trade-off would only become problematic if the hospital later required intra-day risk scoring, for example at shift handovers.

**Mitigation strategies:**

1. **Event-driven micro-batch triggers**: For high-priority patients, a targeted trigger on the relational database can push a specific updated record into the warehouse within minutes of a key clinical event — such as a new diagnosis or discharge decision — without waiting for the full nightly batch. This narrows the freshness gap for individual patients without redesigning the overall pipeline.

2. **Incremental batch loads**: Replacing full nightly refreshes with incremental loads — transferring only the structured rows that changed since the last run — reduces the batch window significantly and allows the pipeline to run multiple times per day if the hospital's needs grow, without architectural changes.

3. **Strict streaming isolation for Goal 4**: The real-time path through the streaming platform and time-series database is completely independent of the batch pipeline. This ensures that the one goal where data freshness is genuinely non-negotiable — ICU monitoring — is never subject to any batch delay. The trade-off is deliberately contained to the two goals where a data lag is clinically tolerable.
