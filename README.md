# Transaction Fraud & Risk Analysis

## Overview
This project analyses **24 million transaction records** to identify fraud patterns, behavioural anomalies, and credit risk indicators across users, merchants, and transaction types.     

---

## Project Structure
- **transaction_fraud_and_risk_analysis.pdf**
- sql_scripts
    - **transaction_fraud_and_risk_analysis.sql**
    - tables_relationship.sql
    - transactions_cleaning.sql
    - transactions_cleaning.sql
    - user_info_cleaning.sql 
- other
    - data_preparation.pdf
 
---

## Questions Addressed
- How does fraud risk vary when users’ daily spending exceeds their own 30-day rolling average?
- Which merchant cities have the highest fraud rates?
- Which merchants have the highest fraud rate?
- How does fraud differ based on transaction type?
- How many credit cards fall into utilisation bands based on average monthly spend versus credit limit?
- For each user, what percentage of total spend goes to their top merchant? 

---

## Key Findings & Results
- Extreme deviations from a user’s normal spending behavior are rare but strongly correlated with fraud risk.
- Certain merchant cities and merchants exhibit unusually high fraud rates relative to transaction volume.
- Online transactions account for a disproportionate share of fraud compared to chip and swipe transactions.
- The majority of credit cards operate well below their credit limits, while a small subset consistently approaches high utilisation levels.
- A small number of users concentrate a significant proportion of their spending with a single merchant.


---

## Notes
- SQL scripts contain the final production-ready queries used to generate findings.
- PDFs provide supporting documentation on data preparation, table relationships, and analytical conclusions.

