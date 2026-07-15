with win_percentage_table as (
	select season, team, team_code
	AVG(win) as win_percentage
	from fact_team_game ftg 
	group by season, team_code
)

select season, team_name, round(win_percentage * 100) as win_pct,
		RANK() over (partition by team_code order by win_pct) as season_rank
from win_percentage_table
order by season, season_rank;