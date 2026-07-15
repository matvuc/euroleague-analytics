-- The frame (4 PRECEDING to CURRENT ROW) is what makes this rolling rather than
-- cumulative. A 5-game window sliding forward one game at a time. ORDER BY
-- game_date defines "preceding". PARTITION keeps each team's window separate.
-- First four games of a season have a partial window by design.
SELECT team_code, game_date, round, win,
       ROUND(AVG(win) OVER (
           PARTITION BY team_code, season
           ORDER BY game_date
           ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
       ) * 100) AS rolling_5_form
FROM fact_team_game
WHERE season = 2024
ORDER BY team_code, game_date;