-- [Problem 1a]
DROP TABLE IF EXISTS user_info;
-- This table will store usernames, salts, and hashed passwords for users to be
-- used when authenticating a login.
CREATE TABLE user_info (
    username        VARCHAR(20)  NOT NULL  PRIMARY KEY,
    salt            CHAR(10)  NOT NULL,
    password_hash   CHAR(64)  NOT NULL
);


-- [Problem 1b]
DROP PROCEDURE IF EXISTS sp_add_user;
-- Adds a new user, taking a new username and password as input. The username
-- must not already exist in the user_info table.
DELIMITER $
CREATE PROCEDURE sp_add_user(new_username VARCHAR(20), password VARCHAR(20))
BEGIN
    DECLARE salt CHAR(10) DEFAULT make_salt(10);
    DECLARE salted_pass VARCHAR(30) DEFAULT CONCAT(salt, password);
    DECLARE hashed_pass CHAR(64) DEFAULT SHA2(salted_pass, 256);
    
    INSERT INTO user_info VALUES(new_username, salt, hashed_pass);
END$
DELIMITER ;


-- [Problem 1c]
DROP PROCEDURE IF EXISTS sp_change_password;
-- Changes the password for an existing user, taking their username and new
-- password as input. If the username is not in the user_info table, nothing
-- will happen.
DELIMITER $
CREATE PROCEDURE sp_change_password(username VARCHAR(20),
    new_password VARCHAR(20))
BEGIN
    DECLARE salt CHAR(10) DEFAULT make_salt(10);
    DECLARE salted_pass VARCHAR(30) DEFAULT CONCAT(salt, new_password);
    DECLARE hashed_pass CHAR(64) DEFAULT SHA2(salted_pass, 256);
    
    UPDATE user_info SET username = username, salt = salt, password_hash = 
            hashed_pass
        WHERE user_info.username = username;
END$
DELIMITER ;


-- [Problem 1d]
DROP FUNCTION IF EXISTS authenticate;
-- Checks if the user has entered the correct username and password. Returns
-- TRUE if the username and password are valid (the username is in the user_info
-- table and once the entered password has been salted and hashed it matches the
-- stored hashed password) and FALSE if not.
DELIMITER $
CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20))
    RETURNS BOOLEAN
BEGIN
    DECLARE auth BOOLEAN DEFAULT FALSE;
    DECLARE salt CHAR(10) DEFAULT
        (SELECT salt FROM user_info WHERE user_info.username = username);
    DECLARE user_hashed_pass CHAR(64) DEFAULT
        (SELECT password_hash FROM user_info
            WHERE user_info.username = username);
    DECLARE input_salted_pass VARCHAR(30) DEFAULT CONCAT(salt, password);
    DECLARE input_hashed_pass CHAR(64) DEFAULT SHA2(input_salted_pass, 256);

-- Checks that the hashed and salted input password and stored password are not
-- null. This is equivalent to checking that the username is in the user_info
-- table. 
    IF (input_hashed_pass IS NOT NULL) AND (user_hashed_pass IS NOT NULL) THEN
-- Checks that the passwords match after being salted and hashed.
        IF input_hashed_pass = user_hashed_pass THEN
            SET auth = TRUE;
        END IF;
    END IF;
    
    RETURN auth;
END$
DELIMITER ;

