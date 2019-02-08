-- [Problem 1]
CREATE INDEX ind1 ON account (branch_name, balance);


-- [Problem 2]
DROP TABLE IF EXISTS mv_branch_account_stats;
CREATE TABLE mv_branch_account_stats (
    branch_name     VARCHAR(15)     NOT NULL,
    num_accounts    INTEGER         NOT NULL,
    total_deposits  DECIMAL(12, 2)  NOT NULL,
    avg_balance     DECIMAL(12, 2)  NOT NULL,
    min_balance     DECIMAL(12, 2)  NOT NULL,
    max_balance     DECIMAL(12, 2)  NOT NULL
);


-- [Problem 3]
INSERT INTO mv_branch_account_stats
    SELECT branch_name, COUNT(*), SUM(balance), AVG(balance), MIN(balance),
            MAX(balance)
        FROM account GROUP BY branch_name;


-- [Problem 4]
DROP VIEW IF EXISTS branch_account_stats;
CREATE VIEW branch_account_stats AS
    SELECT branch_name, COUNT(*) AS num_accounts,
            SUM(balance) AS total_deposits, AVG(balance) AS avg_balance,
            MIN(balance) AS min_balance, MAX(balance) AS max_balance
        FROM account GROUP BY branch_name;


-- [Problem 5]
DROP PROCEDURE IF EXISTS on_insert_helper;
DELIMITER $
CREATE PROCEDURE on_insert_helper(name VARCHAR(15), balance DECIMAL(12, 2))
BEGIN
    IF name IN (SELECT branch_name FROM mv_branch_account_stats) THEN
        UPDATE mv_branch_account_stats SET num_accounts = num_accounts + 1,
                total_deposits = total_deposits + balance, 
                avg_balance = total_deposits / num_accounts
            WHERE branch_name = name;
        IF balance < (SELECT min_balance FROM mv_branch_account_stats
                WHERE branch_name = name) THEN
            UPDATE mv_branch_account_stats SET min_balance = balance
                WHERE branch_name = name;
        ELSEIF balance > (SELECT max_balance FROM mv_branch_account_stats
                WHERE branch_name = name) THEN
            UPDATE mv_branch_account_stats SET max_balance = balance
                WHERE branch_name = name;
        END IF;
    ELSE
        INSERT INTO mv_branch_account_stats
            VALUES (name, 1, balance, balance, balance, balance);
    END IF;
END$
DELIMITER ;

CREATE TRIGGER on_insert AFTER INSERT ON account
    FOR EACH ROW CALL on_insert_helper(NEW.branch_name, NEW.balance);



-- [Problem 6]
DROP PROCEDURE IF EXISTS on_delete_helper;
DELIMITER $
CREATE PROCEDURE on_delete_helper(name VARCHAR(15), balance DECIMAL(12, 2))
BEGIN
    IF 1 = (SELECT num_accounts FROM mv_branch_account_stats
            WHERE branch_name = name) THEN
        DELETE FROM mv_branch_account_stats WHERE branch_name = name;
    ELSE
        UPDATE mv_branch_account_stats SET num_accounts = num_accounts - 1,
                total_deposits = total_deposits - balance,
                avg_balance = total_deposits / num_accounts
            WHERE branch_name = name;
        IF balance = (SELECT min_balance FROM mv_branch_account_stats
                WHERE branch_name = name) THEN
            UPDATE mv_branch_account_stats SET min_balance = 
                    (SELECT MIN(balance) FROM account GROUP BY branch_name
                        HAVING branch_name = name)
                WHERE branch_name = name;
        ELSEIF balance = (SELECT max_balance FROM mv_branch_account_stats
                WHERE branch_name = name) THEN
            UPDATE mv_branch_account_stats SET max_balance = 
                    (SELECT MAX(balance) FROM account GROUP BY branch_name
                        HAVING branch_name = name)
                WHERE branch_name = name;
        END IF;
    END IF;
END$
DELIMITER ;

CREATE TRIGGER on_delete AFTER DELETE ON account
    FOR EACH ROW CALL on_delete_helper(OLD.branch_name, OLD.balance);



-- [Problem 7]
DROP PROCEDURE IF EXISTS on_update_helper;
DELIMITER $
CREATE PROCEDURE on_update_helper(old_name VARCHAR(15), new_name VARCHAR(15), old_balance DECIMAL(12, 2), new_balance DECIMAL(12, 2))
BEGIN
IF NOT (old_name = new_name AND old_balance = new_balance) THEN
    IF old_name = new_name THEN
        UPDATE mv_branch_account_stats SET
                total_deposits = total_deposits - old_balance + new_balance,
                avg_balance = total_deposits / num_accounts
            WHERE branch_name = new_name;
        IF old_balance = (SELECT min_balance FROM mv_branch_account_stats
                WHERE branch_name = new_name) THEN
            IF new_balance < old_balance THEN
                UPDATE mv_branch_account_stats SET min_balance = new_balance
                    WHERE branch_name = new_name;
            ELSE
                UPDATE mv_branch_account_stats SET min_balance = 
                        (SELECT MIN(balance) FROM account GROUP BY branch_name
                            HAVING branch_name = new_name)
                    WHERE branch_name = new_name;
            END IF;
        ELSEIF old_balance = (SELECT max_balance FROM mv_branch_account_stats
                WHERE branch_name = new_name) THEN
            IF new_balance > old_balance THEN
                UPDATE mv_branch_account_stats SET max_balance = new_balance
                    WHERE branch_name = new_name;
            ELSE
                UPDATE mv_branch_account_stats SET max_balance = 
                        (SELECT MAX(balance) FROM account GROUP BY branch_name
                            HAVING branch_name = new_name)
                    WHERE branch_name = new_name;
            END IF;
        END IF;
    ELSE
        UPDATE mv_branch_account_stats SET num_accounts = num_accounts - 1,
                total_deposits = total_deposits - old_balance,
                avg_balance = total_deposits / num_accounts
            WHERE branch_name = old_name;
        UPDATE mv_branch_account_stats SET num_accounts = num_accounts + 1,
                total_deposits = total_deposits + old_balance,
                avg_balance = total_deposits / num_accounts
            WHERE branch_name = new_name;
        IF old_balance = (SELECT min_balance FROM mv_branch_account_stats
                WHERE branch_name = old_name) THEN
            UPDATE mv_branch_account_stats SET min_balance = 
                    (SELECT MIN(balance) FROM account GROUP BY branch_name
                        HAVING branch_name = old_name)
                WHERE branch_name = old_name;
        ELSEIF old_balance = (SELECT max_balance FROM mv_branch_account_stats
                WHERE branch_name = old_name) THEN
            UPDATE mv_branch_account_stats SET min_balance = 
                    (SELECT MAX(balance) FROM account GROUP BY branch_name
                        HAVING branch_name = old_name)
                WHERE branch_name = old_name;
        END IF;
        IF new_balance < (SELECT min_balance FROM mv_branch_account_stats
                WHERE branch_name = new_name) THEN
            UPDATE mv_branch_account_stats SET min_balance = new_balance
                WHERE branch_name = new_name;
        ELSEIF new_balance > (SELECT max_balance FROM mv_branch_account_stats
                WHERE branch_name = new_name) THEN
            UPDATE mv_branch_account_stats SET max_balance = new_balance
                WHERE branch_name = new_name;
        END IF;
    END IF;
END IF;
END$
DELIMITER ;

CREATE TRIGGER on_update AFTER UPDATE ON account
    FOR EACH ROW CALL on_update_helper(OLD.branch_name, NEW.branch_name, OLD.balance, NEW.balance);

