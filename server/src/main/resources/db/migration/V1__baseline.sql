-- Baseline migration. Real tables arrive in Phase 4 (accounts, sync, puzzles).
CREATE TABLE app_meta (
    key        VARCHAR(64) PRIMARY KEY,
    value      TEXT        NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO app_meta (key, value) VALUES ('schema_baseline', 'phase-0');
