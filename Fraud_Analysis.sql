USE fraud_analysis;

-- PaySim fraud analysis
-- Part 1 builds the three datasets used in the Tableau dashboard.
-- Part 2 has extra checks that are not on the dashboard.


-- PART 1: DASHBOARD

-- KPI tiles: total transactions, fraud cases, overall fraud rate
SELECT
  COUNT(*) AS total_txns,
  SUM(isFraud) AS fraud_txns,
  ROUND(100 * SUM(isFraud) / COUNT(*), 4) AS fraud_rate_pct
FROM transactions;

-- Chart 1, Fraud_Type4.csv: fraud rate by transaction type
SELECT
  type,
  COUNT(*) AS total_txns,
  SUM(isFraud) AS fraud_txns,
  ROUND(100 * SUM(isFraud) / COUNT(*), 4) AS fraud_rate_pct
FROM transactions
GROUP BY type
ORDER BY fraud_rate_pct DESC;

-- Chart 2, Balance_Mismatch.csv: fraud rate when balances add up vs not
-- flag is 1 when the sender balance did not drop by exactly the amount
-- cash in raises the balance, so nearly every cash in row is flagged 1 here
SELECT
  CASE WHEN ABS((oldbalanceOrg - amount) - newbalanceOrig) > 1 THEN 1 ELSE 0 END AS balance_mismatch_flag,
  COUNT(*) AS txns,
  SUM(isFraud) AS frauds,
  ROUND(100 * SUM(isFraud) / COUNT(*), 4) AS fraud_rate_pct
FROM transactions
GROUP BY balance_mismatch_flag;

-- Chart 3, balance_drain.csv: sender balance before and after
-- first 100,000 transfers and cash outs in table order, not a random sample
SELECT type, amount, oldbalanceOrg, newbalanceOrig, isFraud
FROM transactions
WHERE type IN ('TRANSFER', 'CASH_OUT')
LIMIT 100000;

-- check for chart 3, should return 100000, 157, 80012, 19988, 40071
SELECT
  COUNT(*) AS total_rows,
  SUM(isFraud) AS frauds,
  SUM(type = 'CASH_OUT') AS cash_outs,
  SUM(type = 'TRANSFER') AS transfers,
  SUM(oldbalanceOrg > 0 AND newbalanceOrig = 0) AS emptied
FROM (
  SELECT type, amount, oldbalanceOrg, newbalanceOrig, isFraud
  FROM transactions
  WHERE type IN ('TRANSFER', 'CASH_OUT')
  LIMIT 100000
) s;


-- PART 2: EXTRA CHECKS

-- how well the built in flag works
SELECT isFlaggedFraud, COUNT(*) AS txns, SUM(isFraud) AS frauds
FROM transactions
GROUP BY isFlaggedFraud;

-- accounts emptied to zero, largest first
SELECT type, amount, oldbalanceOrg, newbalanceOrig, isFraud
FROM transactions
WHERE oldbalanceOrg > 0 AND newbalanceOrig = 0
ORDER BY amount DESC
LIMIT 50;

-- balance check corrected for cash in
-- cash in adds to the balance, everything else subtracts
SELECT
  CASE WHEN ABS(oldbalanceOrg
         + (CASE WHEN type = 'CASH_IN' THEN amount ELSE -amount END)
         - newbalanceOrig) > 1 THEN 1 ELSE 0 END AS balance_mismatch_flag,
  COUNT(*) AS txns,
  SUM(isFraud) AS frauds,
  ROUND(100 * SUM(isFraud) / COUNT(*), 4) AS fraud_rate_pct
FROM transactions
GROUP BY balance_mismatch_flag;

-- receivers of many transfers and cash outs
SELECT nameDest, COUNT(*) AS txns_received, SUM(isFraud) AS frauds
FROM transactions
WHERE type IN ('TRANSFER', 'CASH_OUT')
GROUP BY nameDest
HAVING COUNT(*) >= 5
ORDER BY txns_received DESC
LIMIT 50;

-- risk score: how much fraud each score level catches
-- the rules were picked by looking at this same data, so this is in sample
SELECT
  risk_score,
  COUNT(*) AS txns,
  SUM(isFraud) AS frauds,
  ROUND(100 * SUM(isFraud) / COUNT(*), 4) AS fraud_rate_pct
FROM (
  SELECT
    isFraud,
    (CASE WHEN type IN ('TRANSFER', 'CASH_OUT') THEN 1 ELSE 0 END)
  + (CASE WHEN amount >= 200000 THEN 1 ELSE 0 END)
  + (CASE WHEN ABS(oldbalanceOrg
        + (CASE WHEN type = 'CASH_IN' THEN amount ELSE -amount END)
        - newbalanceOrig) > 1 THEN 1 ELSE 0 END)
  + (CASE WHEN oldbalanceOrg > 0 AND newbalanceOrig = 0 THEN 1 ELSE 0 END) AS risk_score
  FROM transactions
) s
GROUP BY risk_score
ORDER BY risk_score DESC;
