-- LAG reaches back one row within the partition. PARTITION BY team_code, season
-- keeps it inside one team's season; ORDER BY round defines "previous game."
-- Uses a CTE because prev_margin can't be referenced in the SELECT that creates it.
-- First game of a season has no predecessor, so prev_margin (and the change) is NULL.
-- Cumulative margin is the teams overall point differental across the season.
WITH with_prev AS (
    SELECT team_code, season, round, game_date, margin,
           LAG(margin) OVER (
               PARTITION BY team_code, season
               ORDER BY round
           ) AS prev_margin
    FROM fact_team_game
)
SELECT team_code, season, round, margin, prev_margin,
       margin - prev_margin AS margin_change,
       SUM(margin) over 
       (partition by team_code, season 
       order by round 
       rows between unbounded preceding and current row) 
       as cumulative_margin
FROM with_prev
ORDER BY team_code, season, round;