-- [Problem 3]
DROP TABLE IF EXISTS visitor_fact;
DROP TABLE IF EXISTS resource_fact;
DROP TABLE IF EXISTS resource_dim;
DROP TABLE IF EXISTS datetime_dim;
DROP TABLE IF EXISTS visitor_dim;

-- Dimension table for the visitor information.
CREATE TABLE visitor_dim (
    visitor_id      INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    ip_addr         VARCHAR(200)  NOT NULL,
    visit_val       INTEGER(10)  NOT NULL  UNIQUE
);

-- Dimension table for the datetime information.
CREATE TABLE datetime_dim (
    date_id         INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    date_val        DATE  NOT NULL,
    hour_val        INTEGER  NOT NULL,
    weekend         BOOLEAN  NOT NULL,
    holiday         VARCHAR(20),

    CONSTRAINT uc_date UNIQUE (date_val, hour_val)
);

-- Dimension table for the resource information.
CREATE TABLE resource_dim (
    resource_id     INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    resource        VARCHAR(200)  NOT NULL,
    method          VARCHAR(15),
    protocol        VARCHAR(200),
    response        INTEGER  NOT NULL,

    CONSTRAINT uc_resource UNIQUE (resource, method, protocol, response)
);

-- Fact table that references datetime_dim and resource_dim.
CREATE TABLE resource_fact (
    date_id         INTEGER  NOT NULL,
    resource_id     INTEGER  NOT NULL,
    num_requests    INTEGER  NOT NULL,
    total_bytes     BIGINT,

    PRIMARY KEY(date_id, resource_id),
    FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (resource_id) REFERENCES resource_dim(resource_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Fact table that references datetime_dim and visitor_dim.
CREATE TABLE visitor_fact (
    date_id         INTEGER  NOT NULL,
    visitor_id      INTEGER  NOT NULL,
    num_requests    INTEGER  NOT NULL,
    total_bytes     INTEGER,

    PRIMARY KEY(date_id, visitor_id),
    FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (visitor_id) REFERENCES visitor_dim(visitor_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

