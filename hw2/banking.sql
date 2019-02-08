-- [Problem 1a]
SELECT loan_number, amount FROM loan
    WHERE amount >= 1000 AND amount <= 2000;


-- [Problem 1b]
SELECT loan_number, amount FROM loan NATURAL JOIN borrower NATURAL JOIN customer
    WHERE customer_name = 'Smith'
    ORDER BY loan_number;


-- [Problem 1c]
SELECT branch_city FROM branch NATURAL JOIN account
    WHERE account_number = 'A-446';


-- [Problem 1d]
SELECT customer_name, account_number, branch_name, balance FROM depositor
NATURAL JOIN account
    WHERE customer_name LIKE('J%');


-- [Problem 1e]
SELECT customer_name FROM depositor
    GROUP BY customer_name
    HAVING COUNT(account_number) > 5;


-- [Problem 2a]
DROP VIEW IF EXISTS pownal_customers;
CREATE VIEW pownal_customers AS
    SELECT account_number, customer_name FROM depositor NATURAL JOIN account
        WHERE branch_name = 'Pownal';


-- [Problem 2b]
DROP VIEW IF EXISTS onlyacct_customers;
CREATE VIEW onlyacct_customers AS
    SELECT DISTINCT customer_name, customer_street, customer_city FROM customer
    NATURAL JOIN depositor LEFT JOIN borrower
        USING (customer_name)
        WHERE loan_number IS NULL;


-- [Problem 2c]
DROP VIEW IF EXISTS branch_deposits;
CREATE VIEW branch_deposits AS 
    SELECT branch_name, SUM(balance) AS sum, AVG(balance) AS average FROM branch
    LEFT JOIN account
        USING (branch_name)
        GROUP BY branch_name;


-- [Problem 3a]
SELECT DISTINCT customer_city FROM customer
    WHERE customer_city NOT IN (SELECT branch_city FROM branch)
    ORDER BY customer_city;


-- [Problem 3b]
SELECT customer_name FROM customer
    LEFT JOIN depositor 
        USING (customer_name)
    LEFT JOIN borrower
        USING (customer_name)
    WHERE loan_number IS NULL AND account_number IS NULL;


-- [Problem 3c]
UPDATE account SET balance = balance + 50
    WHERE branch_name IN (SELECT branch_name FROM branch
        WHERE branch_city = 'Horseneck');


-- [Problem 3d]
UPDATE account, branch SET balance = balance + 50
    WHERE account.branch_name = branch.branch_name
    AND branch_city = 'Horseneck';


-- [Problem 3e]
WITH m AS (
    SELECT DISTINCT MAX(balance) AS balance FROM account
        GROUP BY branch_name)
SELECT account_number, branch_name, balance FROM account JOIN m
    USING (balance);


-- [Problem 3f]
SELECT * FROM account
    WHERE (branch_name, balance)
    IN (SELECT DISTINCT branch_name, MAX(balance) AS balance FROM account
        GROUP BY branch_name);


-- [Problem 4]
WITH a AS (
    SELECT b1.branch_name AS b1_name, b1.assets AS b1_assets, b2.branch_name
    AS b2_name, b2.assets AS b2_assets 
        FROM branch AS b1 LEFT JOIN branch AS b2
        ON b1.assets < b2.assets)
SELECT b1_name AS branch_name, b1_assets AS assets, COUNT(b2_name) + 1 AS rank
    FROM a GROUP BY b1_name;

