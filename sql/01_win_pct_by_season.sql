-- Win % per team per season.
-- AVG(win) works because win is stored as 1/0, so its average is the win rate.
-- (Equivalent solution I came up with using conditional aggregation: COUNT(CASE WHEN win=1...) * 1.0 / COUNT(*))
SELECT team, season,
       ROUND(AVG(win) * 100, 1) AS win_percentage
FROM fact_team_game
GROUP BY team, season
ORDER BY season, win_percentage DESC;