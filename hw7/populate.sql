-- PLEASE DO NOT INCLUDE date-udfs HERE!!!

-- [Problem 4a]
INSERT INTO resource_dim (resource, method, protocol, response)
    SELECT DISTINCT resource, method, protocol, response FROM raw_web_log;


-- [Problem 4b]
INSERT INTO visitor_dim (ip_addr, visit_val)
    SELECT DISTINCT ip_addr, visit_val FROM raw_web_log;


-- [Problem 4c]
DROP PROCEDURE IF EXISTS populate_dates;
-- Populates datetime_dim using data from raw_web_log and UDFs defined in
-- date-udfs.sql.
DELIMITER $
CREATE PROCEDURE populate_dates(d_start DATE, d_end DATE)
BEGIN
    DECLARE d DATE DEFAULT d_start;
    DECLARE h INTEGER DEFAULT 0;

    WHILE d <= d_end DO
        SET h = 0;
        WHILE h <= 23 DO
            INSERT INTO datetime_dim (date_val, hour_val, weekend, holiday)
                VALUES (d, h, is_weekend(d), is_holiday(d));
            SET h = h + 1;
        END WHILE;
        SET d = d + INTERVAL 1 DAY;
    END WHILE;
END$
DELIMITER ;


-- [Problem 5a]
INSERT INTO resource_fact SELECT date_id, resource_id, COUNT(*), SUM(bytes_sent)
    FROM ((resource_dim JOIN raw_web_log
            ON (resource_dim.resource = raw_web_log.resource
            AND resource_dim.method <=> raw_web_log.method
            AND resource_dim.protocol <=> raw_web_log.protocol
            AND resource_dim.response = raw_web_log.response))
        JOIN datetime_dim
            ON (datetime_dim.date_val = DATE(raw_web_log.logtime)
            AND datetime_dim.hour_val = HOUR(raw_web_log.logtime)))        
    GROUP BY date_id, resource_id;


-- [Problem 5b]
INSERT INTO visitor_fact SELECT date_id, visitor_id, COUNT(*), SUM(bytes_sent)
    FROM ((visitor_dim JOIN raw_web_log
            ON visitor_dim.visit_val = raw_web_log.visit_val)
        JOIN datetime_dim
            ON (datetime_dim.date_val = DATE(raw_web_log.logtime)
            AND datetime_dim.hour_val = HOUR(raw_web_log.logtime))) 
    GROUP BY date_id, visitor_id;

