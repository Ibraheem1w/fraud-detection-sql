# Financial Fraud Detection Analysis (SQL)

## Overview
This project analyzes ~2.5 million financial transactions to identify fraud patterns
using SQL. The goal is to explore how transaction types, balance behavior, and
rule-based indicators can be used to surface high-risk activity in large datasets.

All analysis is performed in MySQL without machine learning, reflecting how
fraud teams often begin investigations using rule-based logic.
---

## Dataset
- Source: PaySim (synthetic mobile money transaction data)
- Rows used: ~2.56 million transactions
- Transaction types: PAYMENT, TRANSFER, CASH_OUT, DEBIT
- Fraud rate: ~0.13%

Each record includes sender and receiver balances before and after the transaction,
enabling balance-consistency analysis.
---

## Key Findings
- Fraud is almost entirely concentrated in TRANSFER and CASH_OUT transactions
- Balance mismatches are significantly more common in fraudulent activity
- Transactions that drain the sender balance to zero show elevated fraud risk
- System-flagged fraud misses a large portion of confirmed fraud cases
---

## Technical Approach
- Large-scale SQL aggregation and filtering
- Balance reconciliation checks using conditional logic
- Behavioral analysis by sender and time step
- Rule-based risk scoring using multiple fraud indicators

The final output ranks transactions by risk score to surface the most suspicious activity.
## Files
- `fraud_analysis.sql` – Full exploratory analysis, fraud pattern queries, and risk scoring logic

---

## Tools
- MySQL
- MySQL Workbench
- SQL (CASE statements, aggregation, filtering)
