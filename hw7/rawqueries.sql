-- [Problem 2a]
SELECT COUNT(logtime) FROM raw_web_log;


-- [Problem 2b]
SELECT ip_addr, COUNT(ip_addr) AS num_requests FROM raw_web_log
    GROUP BY ip_addr ORDER BY num_requests DESC LIMIT 20;


-- [Problem 2c]
SELECT resource, COUNT(resource) AS num_requests, SUM(bytes_sent) AS tot_bytes
    FROM raw_web_log GROUP BY resource ORDER BY tot_bytes DESC LIMIT 20;


-- [Problem 2d]
SELECT visit_val, ip_addr, COUNT(visit_val) AS num_requests,
        MIN(logtime) AS start_time, MAX(logtime) AS end_time
    FROM raw_web_log GROUP BY visit_val, ip_addr
    ORDER BY num_requests DESC LIMIT 20;

