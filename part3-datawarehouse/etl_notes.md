## ETL Decisions
 
### Decision 1 — Standardizing Temporal Data
**Problem:** The raw `date` column contained highly inconsistent formats, including `DD/MM/YYYY`, `MM/DD/YYYY`, and usage of both dashes `-` and slashes `/`. This prevented direct casting to a SQL DATE type and would cause errors in chronological reporting.
**Resolution:** Implemented a multi-pass date parser that attempted various format strings. Once parsed into a standard internal datetime object, the data was exported in the ISO-8601 standard `YYYY-MM-DD` for the dimension table, and a numeric `YYYYMMDD` format was generated for the `date_id` surrogate key.
 
### Decision 2 — Handling Missing Geographic Metadata
**Problem:** Approximately 6% of the records had `NULL` values in the `store_city` column. However, the `store_name` (e.g., 'Chennai Anna') was always present, implying that the city information was missing but recoverable.
**Resolution:** Created a mapping dictionary between unique `store_name` values and their corresponding `store_city`. During the ETL process, a lookup was performed to fill null city values based on the store name before the data reached the `dim_store` table, ensuring 100% data completeness for geographic reporting.
 
### Decision 3 — Categorical Case and Label Normalization
**Problem:** The `category` column suffered from "dirty" categorical data. Specifically, there were casing inconsistencies (e.g., 'electronics' vs. 'Electronics') and label synonyms (e.g., 'Grocery' vs. 'Groceries'). Without resolution, these would appear as separate categories in BI dashboards.
**Resolution:** Applied a two-step normalization process: first, converting all strings to a standard "Title Case," and second, applying a specific mapping to merge synonyms into a single master label ('Groceries'). This ensures that revenue metrics are correctly aggregated under a single unified category header.
