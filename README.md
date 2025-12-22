# Transaction Fraud & Risk Analysis

## Overview
This project analyzes large-scale transaction data to identify fraud patterns, behavioral anomalies, and credit risk indicators across users, merchants, and transaction types.  
Using SQL, the analysis focuses on translating transactional data into actionable insights for fraud detection and risk management.

The dataset contains approximately **24 million transaction records**, requiring efficient querying and aggregation strategies.

---

## Project Structure
/sql
├── <script_1>.sql
├── <script_2>.sql
├── <script_3>.sql
├── <script_4>.sql
└── <script_5>.sql

/docs
├── data_preparation_and_relationship_analysis.pdf
└── transaction_fraud_and_risk_analysis.pdf

---

## Key Questions Addressed
- Which users exhibit extreme deviations from their normal spending behavior, and how does this relate to fraud risk?
- Which merchant cities and merchants demonstrate disproportionately high fraud rates?
- How does fraud prevalence differ across transaction types (chip, swipe, online)?
- How are credit cards distributed across utilisation bands based on average monthly spend?
- To what extent do users concentrate spending with a single merchant?

---

## Tools & Techniques
- **SQL**
  - Common Table Expressions (CTEs)
  - Window functions
  - Conditional aggregation
  - CASE statements
  - Time-based aggregations
- **Data Analysis Concepts**
  - Behavioral anomaly detection
  - Fraud rate calculation
  - Risk segmentation
  - Credit utilisation analysis

---

## Key Findings & Results
- Extreme deviations from a user’s normal spending behavior are rare but strongly correlated with fraud risk.
- Certain merchant cities and merchants exhibit unusually high fraud rates relative to transaction volume.
- Online transactions account for a disproportionate share of fraud compared to chip and swipe transactions.
- The majority of credit cards operate well below their credit limits, while a small subset consistently approaches high utilisation levels.
- A small number of users concentrate a significant proportion of their spending with a single merchant.

---

## Outcome
This project demonstrates the application of SQL to large transactional datasets to support fraud detection, behavioral analysis, and risk management.  
The focus is on producing clear, business-relevant insights rather than purely technical outputs.

---

## Notes
- SQL scripts contain the final production-ready queries used to generate findings.
- PDFs provide supporting documentation on data preparation, table relationships, and analytical conclusions.
