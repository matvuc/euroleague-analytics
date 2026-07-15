with win_pct as (
	select team_code, season, MAX(team) as team_name,
	ROUND(avg(win) filter (where venue = 'home') * 100) as home_win_pct,
	round(avg(win) filter (where venue = 'away') * 100) as away_win_pct
	from fact_team_game
	group by team_code,season
	having count(*) > 10
	order by team_code,season
)
select team_code, team_name, season, home_win_pct, away_win_pct,
	   home_win_pct - away_win_pct as home_edge
from win_pct;