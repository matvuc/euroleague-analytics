-- Euroleague Team Performance — star schema
-- Run after ingest.py has loaded the raw tables, OR create these first and
-- have ingest.py append. The to_sql load uses if_exists='replace', so the
-- simplest path is: run ingest.py, then add keys/indexes below.

-- ---- dimensions --------------------------------------------------------
ALTER TABLE dim_team   ADD PRIMARY KEY (team_code);
ALTER TABLE dim_season ADD PRIMARY KEY (season);

-- ---- fact --------------------------------------------------------------
-- Grain: one row per team per game (a team-game).
-- A single game produces exactly two rows (home + away).
ALTER TABLE fact_team_game
    ADD CONSTRAINT fk_team   FOREIGN KEY (team_code) REFERENCES dim_team(team_code),
    ADD CONSTRAINT fk_season FOREIGN KEY (season)    REFERENCES dim_season(season);

CREATE INDEX idx_ftg_team    ON fact_team_game (team_code);
CREATE INDEX idx_ftg_season  ON fact_team_game (season);
CREATE INDEX idx_ftg_venue   ON fact_team_game (venue);

-- Sanity check: every game should appear exactly twice (home + away).
-- SELECT season, gamecode, COUNT(*) FROM fact_team_game
-- GROUP BY season, gamecode HAVING COUNT(*) <> 2;   -- expect 0 rows
