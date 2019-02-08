-- [Problem 1]
DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS accident;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS person;


CREATE TABLE person (
    driver_id   CHAR(10)  NOT NULL  PRIMARY KEY,
    name        VARCHAR(60)  NOT NULL,
    address     VARCHAR(120)  NOT NULL
);

CREATE TABLE car (
    license     CHAR(7)  NOT NULL  PRIMARY KEY,
    model       VARCHAR(30),
    year        INTEGER
);

CREATE TABLE accident (
    report_number   INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    date_occurred   DATETIME  NOT NULL,
    location        VARCHAR(240)  NOT NULL,
    description     VARCHAR(6000)
);

CREATE TABLE owns (
    driver_id   CHAR(10)  NOT NULL REFERENCES person,
    license     CHAR(7)  NOT NULL REFERENCES car,

    PRIMARY KEY (driver_id, license),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE participated (
    driver_id       CHAR(10)  NOT NULL REFERENCES person,
    license         CHAR(7)  NOT NULL REFERENCES car,
    report_number   INTEGER  NOT NULL  AUTO_INCREMENT REFERENCES accident,
    damage_amount  NUMERIC(13, 2)  NOT NULL,

    PRIMARY KEY (driver_id, license, report_number),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
        ON UPDATE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)
        ON UPDATE CASCADE,
    FOREIGN KEY (report_number) REFERENCES accident(report_number)
        ON UPDATE CASCADE
);