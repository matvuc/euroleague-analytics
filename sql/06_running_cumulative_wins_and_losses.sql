-- Running cumulative wins and losses through each team's season.
-- Both measures walk the same window, so it's defined once and reused.
SELECT team_code,
       team AS team_name,
       season,
       round,
       win,
       SUM(win)     OVER w AS cumulative_wins,
       SUM(1 - win) OVER w AS cumulative_losses
FROM fact_team_game
WINDOW w AS (
    PARTITION BY team_code, season
    ORDER BY round
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
ORDER BY team_code, season, round;