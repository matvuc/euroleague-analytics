-- Joining to dim_team for the name is the canonical star-schema pattern,
-- even though team name is also denormalized into the fact table for convenience.


select t.team_name, 
		ROUND(AVG(f.pts)) as average_points_scored, 
		Round(AVG(f.opp_pts)) as average_points_allowed
from fact_team_game f
join dim_team t on t.team_code = f.team_code
group by t.team_name
order by average_points_scored DESC;