-- Group by team_code (stable) not team name: sponsors rename clubs each
-- season (Baskonia -> Bitci/Cazoo Baskonia), which would otherwise split
-- one club across multiple rows.
SELECT team_code,
       MAX(team) AS team_name,
       ROUND(AVG(win) FILTER (WHERE venue = 'home') * 100) AS home_win_percentage,
       ROUND(AVG(win) FILTER (WHERE venue = 'away') * 100) AS away_win_percentage
FROM fact_team_game
GROUP BY team_code, season
ORDER BY team_code, season;