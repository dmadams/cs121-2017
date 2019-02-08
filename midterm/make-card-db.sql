-- [Problem 9]
DROP TABLE IF EXISTS cards_for_sale;
DROP TABLE IF EXISTS player_cards;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS card_types;

-- This table stores all of the player details for every player of the game.
CREATE TABLE players (
    player_id       INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    username        VARCHAR(30)  NOT NULL  UNIQUE,
    email           VARCHAR(100)  NOT NULL,
    register_date   TIMESTAMP  NOT NULL  DEFAULT CURRENT_TIMESTAMP(),
    player_status   CHAR(1)  NOT NULL  DEFAULT 'A'
);

-- This table stores every single type of card in the game and all of the
-- details associated with that card type.
CREATE TABLE card_types (
    type_id         INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    card_name       VARCHAR(100)  NOT NULL  UNIQUE,
    card_desc       VARCHAR(4000),
    card_value      NUMERIC(5, 1)  NOT NULL,
    total_circulation   INTEGER
);

-- This table stores which players own which copy of each card. A player can
-- own multiple copies of each card type, but each card has an unique ID. Also,
-- no two players can own a card with the same card ID.
CREATE TABLE player_cards (
    card_id         INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    type_id         INTEGER  NOT NULL  REFERENCES card_types,
    player_id       INTEGER  NOT NULL  REFERENCES players,

    FOREIGN KEY (type_id) REFERENCES card_types(type_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- This table stores which cards are for sale by which players, the offering
-- date, and the price the card is being offered for.
CREATE TABLE cards_for_sale (
    player_id       INTEGER  NOT NULL  REFERENCES player_cards,
    card_id         INTEGER  NOT NULL  REFERENCES player_cards,
    offer_date      TIMESTAMP  NOT NULL  DEFAULT CURRENT_TIMESTAMP(),
    card_price      NUMERIC(7, 2)  NOT NULL,

    PRIMARY KEY(player_id, card_id),
    FOREIGN KEY (card_id) REFERENCES player_cards(card_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player_cards(player_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
