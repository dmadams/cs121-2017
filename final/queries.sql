-- [Problem 1.4a]
WITH a AS (SELECT artist_name, COUNT(audio_id) AS total_l_requests
        FROM playlist NATURAL JOIN artists
        WHERE l_request = TRUE
        GROUP BY artist_name),
    b AS (SELECT MAX(total_l_requests) AS max FROM a)
SELECT artist_name, total_l_requests FROM a JOIN b
    ON a.total_l_requests = b.max;


-- [Problem 1.4b]
SELECT company_name, SUM(price) AS amount_owed
    FROM playlist NATURAL JOIN ads NATURAL JOIN companies
    WHERE play_time < CURRENT_TIMESTAMP() - INTERVAL 30 DAY
    GROUP BY company_name
    ORDER BY amount_owed DESC;

