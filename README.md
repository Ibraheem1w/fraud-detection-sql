# Fraud Detection SQL

SQL analysis of the PaySim dataset, with a Tableau dashboard. PaySim is a simulated set of mobile money transactions with a fraud label on each row. The question is which transactions are fraud and what their balances look like.

## Data

2,563,479 transactions from the PaySim dataset on Kaggle, loaded into MySQL. Each row has the transaction type, the amount, the sender balance before and after, and a fraud label.

## Findings

Overall, 2,302 transactions are labeled fraud, a rate of 0.09%.

Fraud only happens in two types. TRANSFER has 1,143 fraud cases out of 212,634 (0.54%) and CASH_OUT has 1,159 out of 913,739 (0.13%). PAYMENT, DEBIT, and CASH_IN have none.

The built in isFlaggedFraud column did not catch any of the actual fraud.

Fraud tends to empty the sender account. In the sample used for the scatter plot, 147 of the 157 fraud cases left the sender with a zero balance.

The balance check compares the sender balance change to the amount. Among rows where the balance changed by exactly the amount, 2,276 were fraud out of 560,625 (0.41%). Among rows where it did not, 26 were fraud out of 2,002,854 (0.0013%). Fraud sits almost entirely in rows where the balance math adds up.

## Dashboard

The Tableau dashboard (Fraud_Detection.twbx) has a fraud rate by type chart, a scatter plot of sender balance before and after, and the reconciled versus mismatched comparison. Each chart is built from one query in fraud_analysis.sql.

## Running it

Load the PaySim CSV into a MySQL table called transactions in a database called fraud_analysis, then run fraud_analysis.sql. Part 1 of the file builds the three datasets used in the dashboard. Part 2 has extra checks.

## Limits

PaySim is simulated, and its balances often do not add up. These patterns may not hold on real bank data.

The balance check assumes money leaves the sender account. CASH_IN adds money, so nearly every CASH_IN row is counted as mismatched. That puts about 565,000 normal transactions in the mismatched group and makes the gap look bigger than it is. Fraud is still concentrated in the reconciled group.

The scatter plot uses the first 100,000 transfers and cash outs in table order, which includes 157 of the 2,302 fraud cases. It is not a random sample.

The fraud labels come with the dataset. The queries describe fraud, they do not detect it.
