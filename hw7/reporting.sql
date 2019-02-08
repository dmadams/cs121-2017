-- [Problem 6a]
SELECT protocol, num_requests FROM resource_dim NATURAL JOIN resource_fact
    ORDER BY num_requests DESC LIMIT 10;


-- [Problem 6b]
SELECT resource, response AS error_response, COUNT(*) AS count
    FROM resource_dim NATURAL JOIN resource_fact
    WHERE response >= 400
    GROUP BY resource, response ORDER BY count DESC LIMIT 20;


-- [Problem 6c]
SELECT ip_addr, COUNT(DISTINCT visit_val) AS num_visits,
        SUM(num_requests) AS tot_requests, SUM(total_bytes) AS tot_bytes
    FROM visitor_dim NATURAL JOIN visitor_fact
    GROUP BY ip_addr ORDER BY tot_bytes DESC LIMIT 20;


-- [Problem 6d]
-- The gap from August 1 to August 3 is due to the web server being shut down
-- because of Hurricane Erin.
WITH x AS (SELECT * FROM datetime_dim
    WHERE date_val >= '1995-07-23' AND date_val <= '1995-08-12')
SELECT date_val, SUM(num_requests) AS tot_requests,
        SUM(total_bytes) AS tot_bytes
    FROM x NATURAL LEFT JOIN resource_fact
    GROUP BY date_val ORDER BY date_val DESC;


-- [Problem 6e]
WITH x AS (SELECT date_val, resource, SUM(num_requests) AS tot_requests,
            SUM(total_bytes) AS tot_bytes
        FROM datetime_dim NATURAL JOIN resource_fact NATURAL JOIN resource_dim
        GROUP BY date_val, resource),
    y AS (SELECT date_val, MAX(tot_bytes) AS max FROM x
        GROUP BY date_val)
SELECT x.date_val, resource, tot_requests, tot_bytes FROM x JOIN y
    ON (x.date_val = y.date_val AND x.tot_bytes = y.max);


-- [Problem 6f]
WITH v AS (SELECT hour_val, COUNT(visit_val) AS tot_visits,
            COUNT(date_val) AS tot_days
        FROM datetime_dim NATURAL JOIN visitor_fact NATURAL JOIN visitor_dim
        WHERE weekend = FALSE
        GROUP BY hour_val),
    w AS (SELECT hour_val, COUNT(visit_val) AS tot_visits,
            COUNT(date_val) AS tot_days
        FROM datetime_dim NATURAL JOIN visitor_fact NATURAL JOIN visitor_dim
        WHERE weekend = TRUE
        GROUP BY hour_val),
    x AS (SELECT hour_val, (tot_visits / tot_days) AS avg_weekday_visits
        FROM v),
    y AS (SELECT hour_val, (tot_visits / tot_days) AS avg_weekend_visits
        FROM w)
SELECT * FROM x NATURAL JOIN y;

