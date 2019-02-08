-- [Problem a]
-- This query computes the customer name and a count of the number of accounts
-- that that customer has with the bank (will give a count of 0 if the customer
-- has no accounts).
SELECT customer_name, COUNT(loan_number) AS num_loans
    FROM customer NATURAL LEFT JOIN borrower
    GROUP BY customer_name ORDER BY num_loans DESC;


-- [Problem b]
-- This query computes the branch names for branches that have assets less than
-- the total amount of their loans.
WITH l AS (SELECT branch_name, SUM(amount) AS sum FROM loan
    GROUP BY branch_name)
SELECT branch_name FROM branch NATURAL JOIN l
    WHERE assets < sum;


-- [Problem c]
SELECT branch_name, 
    (SELECT COUNT(*) FROM account
        WHERE account.branch_name = branch.branch_name) AS num_accounts, 
    (SELECT COUNT(*) FROM loan
        WHERE loan.branch_name = branch.branch_name) AS num_loans
    FROM branch ORDER BY branch_name ASC;


-- [Problem d]
WITH a AS (SELECT branch_name, COUNT(account_number) AS num_accounts
        FROM branch NATURAL LEFT JOIN account
        GROUP BY branch_name),
    l AS (SELECT branch_name, COUNT(loan_number) AS num_loans
        FROM branch NATURAL LEFT JOIN loan
        GROUP BY branch_name)
SELECT branch_name, num_accounts, num_loans FROM a NATURAL JOIN l
    ORDER BY branch_name ASC;

