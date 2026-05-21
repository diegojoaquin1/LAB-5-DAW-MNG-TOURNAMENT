-- =============================================
-- SCHEMA: eSports Tournament System
-- Motor: PostgreSQL
-- Nomenclatura: inglés, plural, snake_case
-- =============================================

-- Tabla: organizers
CREATE TABLE organizers (
    id              SERIAL PRIMARY KEY,
    organization_name VARCHAR(150) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    website         VARCHAR(255),
    status          SMALLINT     NOT NULL DEFAULT 1,
    created         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_id      INT          NOT NULL,
    modified_id     INT          NOT NULL
);

-- Tabla: teams
CREATE TABLE teams (
    id              SERIAL PRIMARY KEY,
    team_name       VARCHAR(100) NOT NULL,
    logo_url        VARCHAR(255),
    status          SMALLINT     NOT NULL DEFAULT 1,
    created         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_id      INT          NOT NULL,
    modified_id     INT          NOT NULL
);

-- Tabla: players
CREATE TABLE players (
    id              SERIAL PRIMARY KEY,
    gamertag        VARCHAR(50)  NOT NULL UNIQUE,
    email           VARCHAR(100) NOT NULL UNIQUE,
    rank            VARCHAR(50),
    teams_id        INT,
    status          SMALLINT     NOT NULL DEFAULT 1,
    created         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_id      INT          NOT NULL,
    modified_id     INT          NOT NULL,
    CONSTRAINT fk_players_teams
        FOREIGN KEY (teams_id) REFERENCES teams(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Tabla: tournaments
CREATE TABLE tournaments (
    id                  SERIAL PRIMARY KEY,
    organizers_id       INT          NOT NULL,
    game_name           VARCHAR(100) NOT NULL,
    tournament_title    VARCHAR(150) NOT NULL,
    virtual_prize       VARCHAR(100),
    max_participants    INT          NOT NULL DEFAULT 0,
    event_date          DATE         NOT NULL,
    status              SMALLINT     NOT NULL DEFAULT 1,
    created             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_id          INT          NOT NULL,
    modified_id         INT          NOT NULL,
    CONSTRAINT fk_tournaments_organizers
        FOREIGN KEY (organizers_id) REFERENCES organizers(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla N:M: players_tournaments (orden alfabético)
CREATE TABLE players_tournaments (
    id                  SERIAL PRIMARY KEY,
    players_id          INT NOT NULL,
    tournaments_id      INT NOT NULL,
    score               INT DEFAULT 0,
    final_position      INT,
    status              SMALLINT  NOT NULL DEFAULT 1,
    created             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_id          INT       NOT NULL,
    modified_id         INT       NOT NULL,
    CONSTRAINT fk_pt_players
        FOREIGN KEY (players_id) REFERENCES players(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pt_tournaments
        FOREIGN KEY (tournaments_id) REFERENCES tournaments(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT uq_players_tournaments
        UNIQUE (players_id, tournaments_id)
);

-- =============================================
-- ÍNDICES
-- =============================================

CREATE INDEX idx_players_teams             ON players(teams_id);
CREATE INDEX idx_tournaments_organizers    ON tournaments(organizers_id);
CREATE INDEX idx_tournaments_event_date    ON tournaments(event_date);
CREATE INDEX idx_players_tournaments_p     ON players_tournaments(players_id);
CREATE INDEX idx_players_tournaments_t     ON players_tournaments(tournaments_id);