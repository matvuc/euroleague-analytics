-- Each seasons win % vs the teams own multi-season average.
-- Two-stage: CTE aggregates to one row per team-season AND attaches each
-- teams career average via AVG(...) OVER (PARTITION BY team_code), no
-- ORDER BY, so it's a flat baseline across all of that teams rows, not a
-- running average. Signed diff (not absolute) so peaks read positive and
-- down years read negative.
WITH team_season AS (
    SELECT team_code,
           MAX(team) AS team_name,
           season,
           AVG(win) AS win_pct,
           AVG(AVG(win)) OVER (PARTITION BY team_code) AS career_avg
    FROM fact_team_game
    GROUP BY team_code, season
)
SELECT team_code,
       team_name,
       season,
       ROUND(win_pct * 100)                  AS win_pct,
       ROUND(career_avg * 100)               AS career_avg_win_pct,
       ROUND((win_pct - career_avg) * 100)   AS diff_from_own_avg
FROM team_season
ORDER BY team_code, season;