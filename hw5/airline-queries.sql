-- [Problem 6a]
SELECT purchases.customer_id AS purchaser_id, purchase_id, purchase_date,
       conf_number, sale_price, ticket_id, flight_number, flight_date,
       seat_number, tickets.customer_id AS traveler_id,
       last_name AS traveler_last_name, first_name AS traveler_first_name
    FROM (customers NATURAL JOIN tickets) JOIN purchases
        USING (purchase_id)
    WHERE purchases.customer_id = 54321
    ORDER BY purchase_date DESC, flight_date ASC, traveler_last_name ASC,
             traveler_first_name ASC;


-- [Problem 6b]
WITH all_icspd AS (SELECT iata_code, sale_price,
                    TIMESTAMP(flight_date, flight_time) AS datetime
        FROM flights NATURAL JOIN tickets),
    2weeks_icsp AS (SELECT iata_code, sale_price FROM all_icspd 
        WHERE datetime >= CURRENT_TIMESTAMP() - INTERVAL 2 WEEK),
    a AS (SELECT iata_code FROM airplanes)
SELECT iata_code, SUM(sale_price) AS revenue
    FROM a NATURAL LEFT JOIN 2weeks_icsp;

-- [Problem 6c]
SELECT customer_id FROM travelers NATURAL JOIN (tickets NATURAL JOIN flights)
    WHERE international = TRUE
    AND (passport_number IS NULL OR country IS NULL OR emergency_contact IS NULL
         OR emergency_phone IS NULL);

