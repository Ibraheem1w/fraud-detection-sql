USE fraud_analysis;
SELECT COUNT(*) AS total_rows FROM transactions;
SELECT 
  COUNT(*) AS total_txns,
  SUM(isFraud) AS fraud_txns,
  ROUND(100 * SUM(isFraud) / COUNT(*), 6) AS fraud_rate_pct
FROM transactions;
SELECT 
  type,
  COUNT(*) AS txns,
  ROUND(AVG(amount), 2) AS avg_amount
FROM transactions
GROUP BY type
ORDER BY txns DESC;
SELECT 
  type,
  COUNT(*) AS total_txns,
  SUM(isFraud) AS fraud_txns,
  ROUND(100 * SUM(isFraud) / COUNT(*), 6) AS fraud_rate_pct
FROM transactions
GROUP BY type
ORDER BY fraud_rate_pct DESC;
SELECT 
  isFlaggedFraud,
  COUNT(*) AS txns,
  SUM(isFraud) AS frauds
FROM transactions
GROUP BY isFlaggedFraud;
SELECT 
  type, amount, oldbalanceOrg, newbalanceOrig, isFraud
FROM transactions
WHERE oldbalanceOrg > 0
  AND newbalanceOrig = 0
ORDER BY amount DESC
LIMIT 50;
SELECT
  CASE 
    WHEN ABS((oldbalanceOrg - amount) - newbalanceOrig) > 1 THEN 1
    ELSE 0
  END AS balance_mismatch_flag,
  COUNT(*) AS txns,
  SUM(isFraud) AS frauds,
  ROUND(100 * SUM(isFraud) / COUNT(*), 6) AS fraud_rate_pct
FROM transactions
GROUP BY balance_mismatch_flag;
SELECT 
  nameOrig,
  step,
  COUNT(*) AS txns_in_step,
  SUM(isFraud) AS frauds_in_step
FROM transactions
GROUP BY nameOrig, step
HAVING COUNT(*) >= 5
ORDER BY txns_in_step DESC
LIMIT 50;
SELECT
  t.*,
  (
    (CASE WHEN t.type IN ('TRANSFER','CASH_OUT') THEN 1 ELSE 0 END) +
    (CASE WHEN t.amount >= 200000 THEN 1 ELSE 0 END) +
    (CASE WHEN ABS((t.oldbalanceOrg - t.amount) - t.newbalanceOrig) > 1 THEN 1 ELSE 0 END) +
    (CASE WHEN t.oldbalanceOrg > 0 AND t.newbalanceOrig = 0 THEN 1 ELSE 0 END)
  ) AS risk_score
FROM transactions t
ORDER BY risk_score DESC, isFraud DESC, amount DESC
LIMIT 100;
