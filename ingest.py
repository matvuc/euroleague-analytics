"""
Euroleague Team Performance — ETL
Pulls game reports from the official Euroleague API, reshapes each game into
two team-rows (one per team), computes win/margin, writes CSVs, and loads
into Postgres.

Usage:
    python ingest.py            # pulls SEASONS below, writes CSV + loads Postgres
    python ingest.py --csv-only # skip the Postgres load (just produce CSVs)

Requires: pip install euroleague-api pandas sqlalchemy psycopg2-binary
"""
import argparse
import pandas as pd
from euroleague_api.game_stats import GameStats

# config 
# Season = the START year. 2023 == the 2023-24 season.
SEASONS = [2020, 2021, 2022, 2023, 2024]
PG_URL = "postgresql+psycopg2://postgres:postgres@localhost:5432/euroleague"
#


def pull_seasons(seasons):
    """Pull game reports for each season. ~ 2 min per season."""
    gs = GameStats("E")
    frames = []
    for yr in seasons:
        print(f"Pulling season {yr} ...")
        frames.append(gs.get_game_report_single_season(yr))
    return pd.concat(frames, ignore_index=True)


def to_long(df):
    """Wide (one row/game) -> long (one row per team per game)."""
    base = ["Season", "Gamecode", "Round", "phaseType.name", "date"]
    cols = {"Season": "season", "Gamecode": "gamecode", "Round": "round",
            "phaseType.name": "phase", "date": "game_date"}

    home = df[base + ["local.club.name", "local.club.code", "local.score",
                      "road.club.name", "road.club.code", "road.score"]].copy()
    home.columns = base + ["team", "team_code", "pts", "opp", "opp_code", "opp_pts"]
    home["venue"] = "home"

    away = df[base + ["road.club.name", "road.club.code", "road.score",
                      "local.club.name", "local.club.code", "local.score"]].copy()
    away.columns = base + ["team", "team_code", "pts", "opp", "opp_code", "opp_pts"]
    away["venue"] = "away"

    long = pd.concat([home, away], ignore_index=True).rename(columns=cols)
    long = long[long["pts"].notna()]                       # drop unplayed games
    long["win"] = (long["pts"] > long["opp_pts"]).astype(int)
    long["margin"] = long["pts"] - long["opp_pts"]
    long["game_date"] = pd.to_datetime(long["game_date"])
    return long


def build_dims(long):
    dim_team = (long[["team_code", "team"]].drop_duplicates()
                .rename(columns={"team": "team_name"}).sort_values("team_code"))
    dim_season = pd.DataFrame({"season": sorted(long["season"].unique())})
    dim_season["season_label"] = dim_season["season"].apply(
        lambda y: f"{y}-{str(y + 1)[-2:]}")
    return dim_team, dim_season


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv-only", action="store_true")
    args = ap.parse_args()

    raw = pull_seasons(SEASONS)
    fact = to_long(raw)
    dim_team, dim_season = build_dims(fact)

    fact.to_csv("fact_team_game.csv", index=False)
    dim_team.to_csv("dim_team.csv", index=False)
    dim_season.to_csv("dim_season.csv", index=False)
    print(f"Wrote {len(fact)} team-game rows, "
          f"{len(dim_team)} teams, {len(dim_season)} seasons.")

    if args.csv_only:
        return

    from sqlalchemy import create_engine
    engine = create_engine(PG_URL)
    dim_team.to_sql("dim_team", engine, if_exists="replace", index=False)
    dim_season.to_sql("dim_season", engine, if_exists="replace", index=False)
    fact.to_sql("fact_team_game", engine, if_exists="replace", index=False)
    print("Loaded into Postgres.")


if __name__ == "__main__":
    main()
