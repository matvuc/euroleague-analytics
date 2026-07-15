-- Clutch performance; games decided by <=5 pts.
-- ABS(margin) so a 3-pt loss counts as clutch, not just a 3-pt win.
-- clutch_win_pct is win% among clutch games ONLY (filtered aggregate),
-- not clutch wins over total games, and that denominator is the whole point.
-- team_code grouping (MAX(team) for display) per the sponsor-rename rule.
-- Note: a 100% clutch win % can come from a tiny sample (a team with only
-- 2-3 clutch games), so treat extreme values as noise, not proven skill.
SELECT team_code,
       MAX(team) AS team_name,
       season,
       COUNT(*) AS total_games,
       COUNT(*) FILTER (WHERE ABS(margin) <= 5) AS clutch_games,
       ROUND(COUNT(*) FILTER (WHERE ABS(margin) <= 5) * 100.0 / COUNT(*)) AS clutch_pct_of_games,
       ROUND(AVG(win) FILTER (WHERE ABS(margin) <= 5) * 100) AS clutch_win_pct
FROM fact_team_game
GROUP BY team_code, season
ORDER BY team_code, season;