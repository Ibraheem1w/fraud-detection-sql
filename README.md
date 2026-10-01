# Financial Fraud Detection Analysis (SQL)

## Overview
This project analyzes ~2.5 million financial transactions to identify fraud patterns using SQL. The goal is to explore how transaction types, balance behavior, and rule-based indicators can be used to surface high-risk activity in large datasets.

All analysis is performed in MySQL without machine learning, reflecting how fraud teams often begin investigations using rule-based logic.

## Dataset
- Source: PaySim (synthetic mobile money transaction data)
- Rows used: ~2.56 million transactions
- Transaction types: PAYMENT, TRANSFER, CASH_OUT, DEBIT
- Fraud rate: ~0.09%

Each record includes sender and receiver balances before and after the transaction, enabling balance-consistency analysis.

## Key Findings
- Fraud is almost entirely concentrated in TRANSFER and CASH_OUT transactions.
- Fraudulent transactions are more likely to show a fully reconciled balance, with the sender's account draining to exactly zero. Legitimate transactions are actually more likely to show a balance mismatch. This is the opposite of what I expected going in.
- System-flagged fraud (`isFlaggedFraud`) misses a large portion of confirmed fraud cases.

## Dashboard
Built a Tableau dashboard on top of the SQL analysis. It includes fraud rate by transaction type, the balance reconciliation finding described above, and a scatter plot showing the account drain pattern fraud follows.

Dashboard: https://public.tableau.com/app/profile/ibraheem.a1570/viz/Fraud_Detection_17876652679100/Dashboard1

## Technical Approach
- Large-scale SQL aggregation and filtering
- Balance reconciliation checks using conditional logic
- Behavioral analysis by sender and time step
- A rule-based risk score combining transaction type, amount, balance mismatch, and zero-out behavior, used to rank transactions for manual review in the absence of a machine learning model. Note: the balance-mismatch component currently flags mismatches as a risk factor, which runs counter to the reconciliation finding above, an area for future refinement.

The final output ranks transactions by risk score to surface the most suspicious activity.

## Files
- 'Fraud_Detection.sql` – Full exploratory analysis, fraud pattern queries, and risk scoring logic

## Tools
- MySQL
- MySQL Workbench
- SQL (CASE statements, aggregation, filtering)
