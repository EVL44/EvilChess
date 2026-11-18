-- Phase 4: accounts, puzzles, sync, server-side imports.

CREATE TABLE users (
    id               UUID PRIMARY KEY,
    email            VARCHAR(320) UNIQUE,
    password_hash    VARCHAR(100),
    display_name     VARCHAR(40)      NOT NULL,
    google_sub       VARCHAR(255) UNIQUE,
    apple_sub        VARCHAR(255) UNIQUE,
    -- Glicko-2 puzzle rating
    puzzle_rating    DOUBLE PRECISION NOT NULL DEFAULT 1500,
    puzzle_rd        DOUBLE PRECISION NOT NULL DEFAULT 350,
    puzzle_vol       DOUBLE PRECISION NOT NULL DEFAULT 0.06,
    puzzles_played   INT              NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ      NOT NULL DEFAULT now()
);

-- Refresh tokens are stored as SHA-256 hashes and rotated on every use.
CREATE TABLE refresh_tokens (
    id           UUID PRIMARY KEY,
    user_id      UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash   CHAR(64)    NOT NULL UNIQUE,
    expires_at   TIMESTAMPTZ NOT NULL,
    revoked_at   TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX refresh_tokens_user ON refresh_tokens (user_id);

-- Lichess puzzle database (CC0). Themes are space-separated, padded with
-- spaces at both ends so "LIKE '% fork %'" matches whole words.
CREATE TABLE puzzles (
    id             VARCHAR(12) PRIMARY KEY,
    fen            VARCHAR(100) NOT NULL,
    moves          TEXT         NOT NULL,
    rating         INT          NOT NULL,
    rating_rd      INT          NOT NULL,
    popularity     INT          NOT NULL,
    nb_plays       INT          NOT NULL,
    themes         TEXT         NOT NULL,
    opening_tags   TEXT
);
CREATE INDEX puzzles_rating ON puzzles (rating);

CREATE TABLE puzzle_attempts (
    user_id      UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    puzzle_id    VARCHAR(12) NOT NULL REFERENCES puzzles (id) ON DELETE CASCADE,
    win          BOOLEAN     NOT NULL,
    rating_after DOUBLE PRECISION NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, puzzle_id)
);

CREATE TABLE rush_scores (
    user_id     UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    mode        VARCHAR(20) NOT NULL,
    best        INT         NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, mode)
);

-- Generic last-write-wins sync store. The server does not interpret the
-- payloads; the app does.
CREATE TABLE sync_items (
    user_id     UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    kind        VARCHAR(30)  NOT NULL,
    item_key    VARCHAR(200) NOT NULL,
    payload     TEXT,
    deleted     BOOLEAN      NOT NULL DEFAULT FALSE,
    -- When the client changed the item (decides conflicts)
    updated_at  TIMESTAMPTZ  NOT NULL,
    -- When the server stored it (drives "changes since")
    server_seq  BIGSERIAL    NOT NULL,
    PRIMARY KEY (user_id, kind, item_key)
);
CREATE INDEX sync_items_seq ON sync_items (user_id, server_seq);

CREATE TABLE linked_accounts (
    user_id          UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    provider         VARCHAR(20) NOT NULL,
    username         VARCHAR(60) NOT NULL,
    newest_game_at   TIMESTAMPTZ,
    last_synced_at   TIMESTAMPTZ,
    status           VARCHAR(20) NOT NULL DEFAULT 'idle',
    last_error       TEXT,
    imported         INT         NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, provider)
);
