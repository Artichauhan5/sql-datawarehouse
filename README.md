An end-to-end data engineering and analytics project built using Microsoft SQL Server, transforming raw operational data into business-ready analytical datasets through a 3-Tier Medallion Architecture (Bronze, Silver, and Gold layers).

📌 Project Overview
This project implements a enterprise-grade data warehouse on SQL Server. Raw transactional data is ingested, cleansed, transformed, and modeled to deliver high-performance dimensional models for executive reporting and business intelligence.

Bronze Layer: Raw data staging via automated T-SQL bulk procedures.

Silver Layer: Data cleansing, deduplication, type casting, and schema standardization.

Gold Layer: Star Schema dimensional modeling (Facts & Dimensions) optimized for business reporting.

⚙️ Engineering & Pipeline Details
1. Bronze Layer (Raw Ingestion)
Ingests raw source datasets into SQL Server with zero transformations to preserve historical source state.

Utilizes T-SQL stored procedures and high-performance BULK INSERT operations for rapid loading.

2. Silver Layer (Data Cleansing & Transformation)
Normalizes, cleanses, and structures data into reliable, relationally intact tables.

Handles missing/null values, removes duplicate records, and aligns data types across fields.

Enforces primary key and foreign key relationships to secure data integrity.

3. Gold Layer (Dimensional Modeling)
Transforms cleansed Silver data into a business-friendly Star Schema using database views.

Implements surrogate keys, dimension tables (e.g., DimCustomer, DimProduct), and fact tables (e.g., FactSales).

Optimizes analytical query response times for downstream BI reporting.

📊 Business Analytics & Key Metrics
The Gold layer supports advanced T-SQL queries using Common Table Expressions (CTEs) and Window Functions to extract strategic business insights:

Customer Analytics: RFM segmentation (Recency, Frequency, Monetary value) and customer cohort behavior.

Sales Trends: Month-over-month (MoM) growth, cumulative running totals, and seasonal variance.

Product Performance: Top-selling product hierarchies and cross-category penetration metrics.
