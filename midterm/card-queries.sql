-- [Problem 10]
SELECT * FROM card_types
    WHERE card_value >= 10 AND total_circulation IS NULL;


-- [Problem 11]
UPDATE card_types SET card_value = card_value + 10
    WHERE type_id IN (SELECT type_id FROM player_cards NATURAL JOIN players
        WHERE username = 'ted_codd');


-- [Problem 12]
DELETE FROM players WHERE username = 'smith';


-- [Problem 13]
WITH deck_vals AS (SELECT player_id, SUM(card_value) AS tot_val
    FROM player_cards NATURAL JOIN card_types GROUP BY player_id)
SELECT player_id, username, email, tot_val FROM players NATURAL JOIN deck_vals
    ORDER BY tot_val DESC LIMIT 5;


-- [Problem 14a]
SELECT * FROM card_types
    WHERE total_circulation <
    (SELECT COUNT(card_id) AS num_cards FROM player_cards
        WHERE card_types.type_id = player_cards.type_id);


-- [Problem 14b]
WITH in_circ AS (SELECT type_id, COUNT(card_id) AS num_cards
    FROM player_cards GROUP BY type_id)
SELECT type_id, card_name, card_desc, card_value, total_circulation
    FROM in_circ NATURAL JOIN card_types
    WHERE num_cards > total_circulation;


DROP VIEW IF EXISTS overissued_cards;
CREATE VIEW overissued_cards AS
    WITH in_circ AS (SELECT type_id, COUNT(card_id) AS num_cards
        FROM player_cards GROUP BY type_id)
    SELECT type_id, card_name, card_desc, card_value, total_circulation
        FROM in_circ NATURAL JOIN card_types
        WHERE num_cards > total_circulation;


-- [Problem 15]
WITH rare_cards AS (SELECT type_id FROM card_types
        WHERE total_circulation <= 10),
    rares_owned AS (SELECT player_id, COUNT(DISTINCT type_id) AS num_owned
        FROM player_cards NATURAL JOIN rare_cards
        GROUP BY player_id)
SELECT player_id FROM rares_owned WHERE num_owned = 
    (SELECT COUNT(type_id) FROM rare_cards);


-- [Problem 16]
DROP VIEW IF EXISTS newbie_card_types;
CREATE VIEW newbie_card_types AS
    WITH player_cards_count AS (SELECT player_id, type_id,
        COUNT(card_id) AS num_cards
        FROM player_cards GROUP BY player_id, type_id)
    SELECT type_id, card_name, card_desc, num_cards
        FROM card_types NATURAL JOIN player_cards_count NATURAL JOIN players
        WHERE register_date >= CURRENT_TIMESTAMP() - INTERVAL 1 WEEK;


-- [Problem 17]
DROP VIEW IF EXISTS user_types;
CREATE VIEW user_types AS
    SELECT * FROM 
        (SELECT username, email, CASE 
            WHEN (SELECT COUNT(card_id) FROM cards_for_sale
                    WHERE players.player_id = cards_for_sale.player_id)
                / (SELECT COUNT(card_id) FROM player_cards
                    WHERE players.player_id = player_cards.player_id)
            < 0.3 THEN 'player'
            WHEN (SELECT COUNT(card_id) FROM cards_for_sale
                    WHERE players.player_id = cards_for_sale.player_id)
                / (SELECT COUNT(card_id) FROM player_cards
                    WHERE players.player_id = player_cards.player_id)
            >= 0.3 THEN 'seller'
            END AS player_type FROM players) AS x
        WHERE player_type IS NOT NULL;

