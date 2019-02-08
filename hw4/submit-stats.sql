-- [Problem 1]
DROP FUNCTION IF EXISTS min_submit_interval;
DELIMITER $
CREATE FUNCTION min_submit_interval(id INTEGER) RETURNS INTEGER
BEGIN
    DECLARE min_int INTEGER DEFAULT NULL;
    DECLARE val1 TIMESTAMP;
    DECLARE val2 TIMESTAMP;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT sub_date FROM fileset
            WHERE sub_id = id;
            
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = TRUE;

    OPEN cur;

    FETCH cur INTO val1;
    loop1: LOOP
        FETCH cur INTO val2;
        IF done THEN
            LEAVE loop1;
        END IF;
        IF min_int IS NULL THEN
            SET min_int = ABS(UNIX_TIMESTAMP(val1) - UNIX_TIMESTAMP(val2));
        END IF;
        IF ABS(UNIX_TIMESTAMP(val1) - UNIX_TIMESTAMP(val2)) < min_int THEN
            SET min_int = ABS(UNIX_TIMESTAMP(val1) - UNIX_TIMESTAMP(val2));
        END IF;
        SET val1 = val2;
    END LOOP;
    RETURN min_int;
END$
DELIMITER ;



-- [Problem 2]
DROP FUNCTION IF EXISTS max_submit_interval;
DELIMITER $
CREATE FUNCTION max_submit_interval(id INTEGER) RETURNS INTEGER
BEGIN
    DECLARE max_int INTEGER;
    DECLARE val1 TIMESTAMP;
    DECLARE val2 TIMESTAMP;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT sub_date FROM fileset
            WHERE sub_id = id;
            
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = TRUE;

    OPEN cur;

    FETCH cur INTO val1;
    loop1: LOOP
        FETCH cur INTO val2;
        IF done THEN
            LEAVE loop1;
        END IF;
        IF max_int IS NULL THEN
            SET max_int = ABS(UNIX_TIMESTAMP(val1) - UNIX_TIMESTAMP(val2));
        END IF;
        IF ABS(UNIX_TIMESTAMP(val1) - UNIX_TIMESTAMP(val2)) > max_int THEN
            SET max_int = ABS(UNIX_TIMESTAMP(val1) - UNIX_TIMESTAMP(val2));
        END IF;
        SET val1 = val2;
    END LOOP;
    RETURN max_int;
END$
DELIMITER ;



-- [Problem 3]
DROP FUNCTION IF EXISTS avg_submit_interval;
DELIMITER $
CREATE FUNCTION avg_submit_interval(id INTEGER) RETURNS DOUBLE
BEGIN
    DECLARE avg_int DOUBLE;
    DECLARE tot DOUBLE;
    DECLARE num INTEGER;
    DECLARE val1 TIMESTAMP;
    DECLARE val2 TIMESTAMP;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT sub_date FROM fileset
            WHERE sub_id = id;
            
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = TRUE;

    OPEN cur;
    
    SET tot = 0;
    SET num = 0;
    FETCH cur INTO val1;
    loop1: LOOP
        FETCH cur INTO val2;
        IF done THEN
            LEAVE loop1;
        END IF;
        SET tot = tot + ABS(UNIX_TIMESTAMP(val1) - UNIX_TIMESTAMP(val2));
        SET num = num + 1;
        SET val1 = val2;
    END LOOP;
    IF NOT num = 0 THEN
        SET avg_int = tot / num;
    END IF;
    RETURN avg_int;
END$
DELIMITER ;



-- [Problem 4]
CREATE INDEX ind1 ON fileset (sub_id, sub_date);

