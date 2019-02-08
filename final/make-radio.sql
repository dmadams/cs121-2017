-- [Problem 1.3]

-- DROP TABLE commands:
DROP TABLE IF EXISTS playlist;
DROP TABLE IF EXISTS promotions;
DROP TABLE IF EXISTS ads;
DROP TABLE IF EXISTS emails;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS audio_files;

-- CREATE TABLE commands:

-- All of the audio files that the radio station has. Every audio file must be
-- a song, an ad, or a promotion and cannot be multiple.
CREATE TABLE audio_files (
    audio_id        INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
-- Path of the audio file.
    path            VARBINARY(1024)  NOT NULL  UNIQUE,
    file_name       VARCHAR(100)  NOT NULL,
    length          NUMERIC(7, 2)  NOT NULL,
-- Single character representing whether the audio file is a song, an ad, or a
-- promotion. (s, a, and p)
    af_type         CHAR(1)
);


-- All of the songs the radio station can play. Every song is also an audio
-- file.
CREATE TABLE songs (
    audio_id        INTEGER  NOT NULL  PRIMARY KEY,
-- Length of the intro in seconds. 
    intro_length    NUMERIC(7, 2)  NOT NULL,
-- True if song is explicit, false if not.
    explicit        BOOLEAN  NOT NULL,

    FOREIGN KEY (audio_id) REFERENCES audio_files(audio_id)
        ON UPDATE CASCADE  ON DELETE CASCADE
);


-- The tags that each song has. A song has 0 or more tags associated with it.
CREATE TABLE tags (
    audio_id        INTEGER  NOT NULL,
    tag             VARCHAR(30)  NOT NULL,

    PRIMARY KEY (audio_id, tag),
    FOREIGN KEY (audio_id) REFERENCES songs(audio_id)
        ON UPDATE CASCADE  ON DELETE CASCADE
);


-- Table of all the artists that sing a song that the station has. Every song
-- has 1 or more artists that sing it. An artist can sing multiple songs.
CREATE TABLE artists (
    audio_id        INTEGER  NOT NULL,
-- Does not auto increment because artists will be in this table multiple times
-- if they sing multiple song.
    artist_id       INTEGER  NOT NULL,
    artist_name     VARCHAR(100)  NOT NULL,

    PRIMARY KEY (audio_id, artist_id),
    FOREIGN KEY (audio_id) REFERENCES songs(audio_id)
        ON UPDATE CASCADE  ON DELETE CASCADE
);


-- Table of the companies that have paid for an ad.
CREATE TABLE companies (
    company_id      INTEGER  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
    company_name    VARCHAR(100)  NOT NULL
);


-- The contact email addresses associated with each company. Every company has
-- 1 or more email addresses associated with it.
CREATE TABLE emails (
    company_id      INTEGER  NOT NULL,
    email           VARCHAR(100)  NOT NULL,

    PRIMARY KEY (company_id, email),
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
        ON UPDATE CASCADE  ON DELETE CASCADE
);


-- All of the ads the station has been paid to play. Every ad has a company that
-- paid for it. Every ad is also an audio file.
CREATE TABLE ads (
    audio_id        INTEGER  NOT NULL  PRIMARY KEY,
    company_id      INTEGER  NOT NULL,
-- When ad should start being included in play schedule.
    start_date      TIMESTAMP  NOT NULL,
-- When ad should stop being included in play schedule.
    end_date        TIMESTAMP  NOT NULL,
    price           NUMERIC(6, 2)  NOT NULL,

    FOREIGN KEY (audio_id) REFERENCES audio_files(audio_id)
        ON UPDATE CASCADE  ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
        ON UPDATE CASCADE  ON DELETE CASCADE
);


-- All of the promotions the station has. Every promotion is also an audio file.
CREATE TABLE promotions (
    audio_id        INTEGER  NOT NULL  PRIMARY KEY,
-- The type of the promotion.
    p_type          VARCHAR(30)  NOT NULL,
    promotion_url   VARCHAR(1000),

    FOREIGN KEY (audio_id) REFERENCES audio_files(audio_id)
        ON UPDATE CASCADE  ON DELETE CASCADE
);


-- The station's master playlist.
CREATE TABLE playlist (
-- Only one audio file can start at any given time, so the primary key is the
-- play time of every audiofile.
    play_time       TIMESTAMP  NOT NULL  PRIMARY KEY,
    end_time        TIMESTAMP  NOT NULL,
    audio_id        INTEGER  NOT NULL,
-- True if the audio file was a listener request, false otherwise.
    l_request       BOOLEAN  NOT NULL,

    FOREIGN KEY (audio_id) REFERENCES audio_files(audio_id)
        ON UPDATE CASCADE  ON DELETE CASCADE
);