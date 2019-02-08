-- [Problem 5]

-- DROP TABLE commands:
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS flight_seats;
DROP TABLE IF EXISTS seats;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS airplanes;
DROP TABLE IF EXISTS phone_numbers;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS purchasers;
DROP TABLE IF EXISTS travelers;
DROP TABLE IF EXISTS customers;


-- CREATE TABLE commands:

-- This table stores every customer for the airline and their basic info. Every
-- customer may also be either a traveler, a purchaser, or both.
CREATE TABLE customers (
    customer_id     INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    email           VARCHAR(100)  NOT NULL  UNIQUE,
    first_name      VARCHAR(40)  NOT NULL,
    last_name       VARCHAR(40)  NOT NULL
);


-- This table stores the travelers and their relevant info for international
-- flights. All of the info is allowed to be null (which is the case when the
-- traveler is flying domestic) except customer id. Every traveler is also a
-- customer.
CREATE TABLE travelers (
    customer_id     INTEGER  NOT NULL  PRIMARY KEY,
    passport_number VARCHAR(40),
    country         VARCHAR(60),
    emergency_contact VARCHAR(80),
-- A phone number for an emergency contact. This is a VARCHAR(20) because
-- different countries have a wide variety of formats for phone numbers and we
-- want to be able to store them all.
    emergency_phone VARCHAR(20),
    frequent_flyer  CHAR(7),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- This table stores the purchasers and their relevant payment info. All info is
-- allowed to be null except customer id. Every purchaser is also a customer.
CREATE TABLE purchasers (
    customer_id     INTEGER  NOT NULL  PRIMARY KEY,
    cc_number       CHAR(16),
-- The expiration date for a credit card of the form MM/YY, ex: "01/17".
    exp_date        CHAR(5),
    ver_code        CHAR(3),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- This table stores every purchase ever made from the airline by a purchaser.
CREATE TABLE purchases (
    purchase_id     INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    customer_id     INTEGER  NOT NULL,
    purchase_date   TIMESTAMP  NOT NULL  DEFAULT CURRENT_TIMESTAMP(),
    conf_number     CHAR(6)  NOT NULL  UNIQUE,

-- If a purchaser is deleted from purchasers, we do not necessarily want to
-- remove purchases associated with them. Even without the purchaser in our db,
-- we may still want to be able to refer to a purchase's info. However, if a 
-- purchaser's customer id is updated or changed for some reason, we want to
-- update it in this table as well.
    FOREIGN KEY (customer_id) REFERENCES purchasers(customer_id)
        ON UPDATE CASCADE
);


-- This table stores the phone numbers associated with each customer.
CREATE TABLE phone_numbers (
    customer_id     INTEGER  NOT NULL,
-- This is a VARCHAR(20) because different countries have a wide variety of
-- formats for phone numbers and we want to be able to store them all.
    phone_number    VARCHAR(20)  NOT NULL,

-- Both customer id and phone number need to be primary keys.
    PRIMARY KEY(customer_id, phone_number),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- This table stores the basic information for every type of airplane.
CREATE TABLE airplanes (
    iata_code       CHAR(3)  NOT NULL  PRIMARY KEY,
    company         VARCHAR(40)  NOT NULL,
    model           VARCHAR(40)  NOT NULL
);


-- This table stores all of the info for every one of the airline's flights. The
-- flight numbers can be reused but never on the same day, so therefore we need
-- two primary keys: flight number and flight date.
CREATE TABLE flights (
    flight_number   VARCHAR(10)  NOT NULL,
    flight_date     DATE  NOT NULL,
    iata_code       CHAR(3)  NOT NULL,
    flight_time     TIME  NOT NULL,
    source          CHAR(3)  NOT NULL,
    destination     CHAR(3)  NOT NULL,
-- A boolean value declaring whether the flight is international or not.
    international   BOOLEAN  NOT NULL  DEFAULT FALSE,

-- As explained above, flight numbers are reused so we need two primary keys.
    PRIMARY KEY(flight_number, flight_date),
    FOREIGN KEY (iata_code) REFERENCES airplanes(iata_code)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- This table stores all the seats and info for the seats for each type of
-- plane. This is distinct from flight_seats in that flight_seats stores just
-- the seat numbers that each flight has.
CREATE TABLE seats (
    seat_number     VARCHAR(4)  NOT NULL,
    iata_code       CHAR(3)  NOT NULL,
-- Seat class will be stored as a string, ex: "first", "business", "coach", etc.
    seat_class      VARCHAR(10)  NOT NULL,
-- Seat type will be stored as a string, ex: "window", "aisle", "middle", etc.
    seat_type       VARCHAR(10)  NOT NULL,
-- A boolean value declaring whether the seat is in an exit row or not.
    exit_row        BOOLEAN  NOT NULL  DEFAULT FALSE,

-- We need two primary keys because it will be common for many types of planes
-- to have overlapping seat numbers. For example, the majority of planes will
-- have a seat with a seat number of "1A".
    PRIMARY KEY(seat_number, iata_code),
    FOREIGN KEY (iata_code) REFERENCES airplanes(iata_code)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- This table stores the seat numbers for the seats that are on each flight.
-- This makes it much easier to check whether or not a seat is available and
-- to avoid booking more people on the flight than seats available *COUGH*
-- United *COUGH*. The IATA code for the airplane the flight is on is not
-- necessary to be included here because it is simple enough to
-- retrieve it from flights if it is needed.
CREATE TABLE flight_seats (
    flight_number   VARCHAR(10)  NOT NULL,
    flight_date     DATE  NOT NULL,
    seat_number     VARCHAR(4)  NOT NULL,

-- Flight number, flight date, and seat number all need to be primary keys
-- because flights are designated by both flight number and flight date and
-- seats are designated by their seat number on each plane.
    PRIMARY KEY(flight_number, flight_date, seat_number),
    FOREIGN KEY (flight_number, flight_date) REFERENCES flights(flight_number,
                 flight_date)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (seat_number) REFERENCES seats(seat_number)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- This table stores all of the tickets the airline has ever sold and the
-- corresponding info for them. Every ticket must have an associated flight,
-- seat on that flight, traveler, and purchase.
CREATE TABLE tickets (
-- Unique integer identifying each ticket for every ticket ever sold. 
    ticket_id       INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    flight_number   VARCHAR(10)  NOT NULL,
    flight_date     DATE  NOT NULL,
    seat_number     VARCHAR(4)  NOT NULL,
    customer_id     INTEGER  NOT NULL,
    purchase_id     INTEGER  NOT NULL,
-- The price the ticket was sold for. (will not be more than $10,000)
    sale_price      NUMERIC(7, 2)  NOT NULL,

-- If a flight is updated or canceled (deleted), we want this to be reflected in
-- the ticket. In the case where the flight is canceled, we can rationalize
-- deleting our tickets for that flight as having to refund them. However, since
-- we're an airline and therefore a bunch of bastards we will force our
-- customers to claim their refund based on their purchase info. Purchases will
-- not be automatically refunded if the flight is canceled.
--
-- If the seat is assigned a different number or somehow ceases to exist, we
-- will also reflect this in our ticket info. We will not automatically
-- refund the purchase if the seat is gone, say due to snake and Samuel L.
-- Jackson activities. Asking for a refund is the customer's responsibilty. 
    FOREIGN KEY (flight_number, flight_date, seat_number) REFERENCES
                 flight_seats(flight_number, flight_date, seat_number)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
-- If the customer id of a traveler is changed, we will reflect this in the
-- ticket. We will not allow a traveler to be deleted if they currently have
-- tickets assigned to them.
    FOREIGN KEY (customer_id) REFERENCES travelers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
-- If the purchase id is updated or deleted, we will reflect this in the ticket.
-- In the case where the purchase is deleted, we will delete the ticket as the
-- customer has somehow managed to navigate our purposefully terrible refund
-- process and successfully claim a refund, and we therefore want to sell a new
-- ticket for the seat to a new customer.
    FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

