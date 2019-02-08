-- [Problem 1]
DROP PROCEDURE IF EXISTS sp_deposit;
-- Deposits amount into the specified account by adding amount to the account's
-- balance.
-- Status:
--     0 - Operation was completed succcessfully
--    -1 - Amount was negative or 0
--    -2 - Account number was invalid
DELIMITER $
CREATE PROCEDURE sp_deposit(account_number VARCHAR(15), amount NUMERIC(12, 2),
        OUT status INTEGER)
this_proc: BEGIN
    IF amount <= 0 THEN
        SET status = -1;
        LEAVE this_proc;
    END IF;
    START TRANSACTION;
        UPDATE account SET balance = balance + amount
            WHERE account.account_number = account_number;
        IF ROW_COUNT() = 0 THEN
            SET status = -2;
        ELSE
            SET status = 0;
        END IF;
    COMMIT;
END$
DELIMITER ;


-- [Problem 2]
DROP PROCEDURE IF EXISTS sp_withdraw;
-- Withdraws amount from the specified account by subtracting amount from the
-- account's balance.
-- Status:
--     0 - Operation was completed succcessfully
--    -1 - Amount was negative or 0
--    -2 - Account number was invalid
--    -3 - Insufficient funds
DELIMITER $
CREATE PROCEDURE sp_withdraw(account_number VARCHAR(15), amount NUMERIC(12, 2),
        OUT status INTEGER)
this_proc: BEGIN
    IF amount <= 0 THEN
        SET status = -1;
        LEAVE this_proc;
    END IF;
    START TRANSACTION;
        UPDATE account SET balance = balance - amount
            WHERE account.account_number = account_number;
        IF ROW_COUNT() = 0 THEN
            SET status = -2;
            ROLLBACK;
        ELSEIF (SELECT balance FROM account
                WHERE account.account_number = account_number) < 0 THEN
            SET status = -3;
            ROLLBACK;
        ELSE
            SET status = 0;
            COMMIT;
        END IF;
END$
DELIMITER ;


-- [Problem 3]
DROP PROCEDURE IF EXISTS sp_transfer;
-- Transfers amount from account 1 to account 2 by subtracting amount from the
-- first account's balance and adding it to the second account's balance.
-- Status:
--     0 - Operation was completed succcessfully
--    -1 - Amount was negative or 0
--    -2 - An account number was invalid
--    -3 - Insufficient funds
DELIMITER $
CREATE PROCEDURE sp_transfer(account_1_number VARCHAR(15),
        amount NUMERIC(12, 2), account_2_number VARCHAR(15),
        OUT status INTEGER)
this_proc: BEGIN
    START TRANSACTION;
        IF account_2_number NOT IN (SELECT account_number FROM account) THEN
            SET status = -2;
            LEAVE this_proc;
        END IF;
        CALL sp_withdraw(account_1_number, amount, status);
        IF status != 0 THEN
            LEAVE this_proc;
        END IF;
        CALL sp_deposit(account_2_number, amount, status);
    COMMIT;
END$
DELIMITER ;

