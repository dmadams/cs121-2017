-- [Problem 1a]
SELECT SUM(perfectscore) AS perfect_score FROM assignment;


-- [Problem 1b]
SELECT sec_name, COUNT(username) AS num_students 
    FROM section NATURAL LEFT JOIN student
    GROUP BY sec_name;


-- [Problem 1c]
DROP VIEW IF EXISTS totalscores;
CREATE VIEW totalscores AS
    (SELECT username, SUM(score) AS total_score
        FROM submission
        WHERE graded = 1
        GROUP BY username);


-- [Problem 1d]
DROP VIEW IF EXISTS passing;
CREATE VIEW passing AS
    (SELECT username, total_score FROM totalscores
        WHERE total_score >= 40);


-- [Problem 1e]
DROP VIEW IF EXISTS failing;
CREATE VIEW failing AS
    (SELECT username, total_score FROM totalscores
        WHERE total_score < 40);


-- [Problem 1f]
SELECT DISTINCT username
    FROM passing NATURAL JOIN submission NATURAL JOIN assignment
    WHERE sub_id NOT IN (SELECT sub_id FROM fileset) AND shortname LIKE 'lab%';

-- 'harris'
-- 'ross'
-- 'miller'
-- 'turner'
-- 'edwards'
-- 'murphy'
-- 'simmons'
-- 'tucker'
-- 'coleman'
-- 'flores'
-- 'gibson'


-- [Problem 1g]
SELECT DISTINCT username
    FROM passing NATURAL JOIN submission NATURAL JOIN assignment
    WHERE sub_id NOT IN (SELECT sub_id FROM fileset)
    AND (shortname = 'midterm' OR shortname = 'final');


-- [Problem 2a]
SELECT username FROM assignment NATURAL JOIN submission NATURAL JOIN fileset
    WHERE shortname = 'midterm' AND sub_date > due;


-- [Problem 2b]
SELECT DISTINCT HOUR(sub_date) AS hour, COUNT(fset_id) AS count
    FROM fileset NATURAL JOIN submission NATURAL JOIN assignment
    WHERE shortname LIKE 'lab%'
    GROUP BY hour;


-- [Problem 2c]
SELECT COUNT(fset_id) AS count
    FROM fileset NATURAL JOIN submission NATURAL JOIN assignment
    WHERE shortname = 'final' AND sub_date < due 
    AND TIMEDIFF(due, sub_date) <= '00:30:00';


-- [Problem 3a]
ALTER TABLE student ADD email VARCHAR(200);
UPDATE student SET email = username || '@caltech.edu';
ALTER TABLE student
    MODIFY COLUMN email VARCHAR(200) NOT NULL;


-- [Problem 3b]
ALTER TABLE assignment ADD submit_files BOOLEAN DEFAULT TRUE;
UPDATE assignment SET submit_files = NOT (shortname LIKE 'dq%');


-- [Problem 3c]
DROP TABLE IF EXISTS gradescheme;
CREATE TABLE gradescheme (
    scheme_id       INTEGER  NOT NULL PRIMARY KEY,
    scheme_desc     VARCHAR(100)  NOT NULL
);
INSERT INTO gradescheme VALUES
    (0, 'Lab assignment with min-grading.'),
    (1, 'Daily quiz.'),
    (2, 'Midterm or final exam.');
ALTER TABLE assignment CHANGE gradescheme scheme_id INTEGER NOT NULL;
ALTER TABLE assignment
    ADD FOREIGN KEY (scheme_id) REFERENCES gradescheme(scheme_id);


-- [Problem 4a]
DROP FUNCTION IF EXISTS is_weekend;
DELIMITER $
CREATE FUNCTION is_weekend(d DATE) RETURNS BOOLEAN
BEGIN
    DECLARE day INTEGER;
    SET day = DAYOFWEEK(d);
    RETURN (day = 1 OR day = 7);
END$
DELIMITER ;


-- [Problem 4b]
DROP FUNCTION IF EXISTS is_holiday;
DELIMITER $
CREATE FUNCTION is_holiday(d DATE) RETURNS VARCHAR(20)
BEGIN
    DECLARE h VARCHAR(20);
    
    IF MONTH(d) = 1 AND DAY(d) = 1 THEN SET h = 'New Year\'s Day';
    END IF;
    IF MONTH(d) = 7 AND DAY(d) = 4 THEN SET h = 'Independence Day';
    END IF;
    IF MONTH(d) = 5 AND DAYOFWEEK(d) = 2 AND DAY(d) > 24
        THEN SET h = 'Memorial Day';
    END IF;
    IF MONTH(d) = 9 AND DAYOFWEEK(d) = 2 AND DAY(d) < 8
        THEN SET h = 'Labor Day';
    END IF;
    IF MONTH(d) = 11 AND DAYOFWEEK(d) = 5 AND DAY(d) > 21 AND DAY(d) < 29
        THEN SET h = 'Thanksgiving';
    END IF;

    RETURN h;
END$
DELIMITER ;


-- [Problem 5a]
SELECT DISTINCT is_holiday(sub_date) AS holiday, COUNT(sub_date) AS count
    FROM fileset GROUP BY holiday;


-- [Problem 5b]
SELECT CASE is_weekend(sub_date) WHEN TRUE THEN 'weekend'
    WHEN FALSE THEN 'weekday' END AS day,
    COUNT(sub_date) AS count
    FROM fileset GROUP BY day; 

