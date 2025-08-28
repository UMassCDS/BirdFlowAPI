import pandas as pd
import os
from ..utils.jitter_function import add_random_jitter

states_csv_path = os.path.join("data_pipeline", "data", "original_data", "states.csv")
states = pd.read_csv(states_csv_path).drop(["index"], axis=1)
states = states.rename(columns={"state": "State"})

bovine_data_path = os.path.join("data_pipeline", "data", "scraped_data", "bovine.csv")
data = pd.read_csv(bovine_data_path, delimiter="\t", encoding="utf-16")

data = pd.merge(data, states, how="left", on="State")
data["County Name"] = None
data["EndDate"] = None
data["NumInfected"] = None
data["GeoLoc"] = list(zip(data["lat"], data["lon"]))

# Add jitter to each point
data["GeoLoc"] = data.apply(
    lambda row: add_random_jitter(row["lat"], row["lon"], row["jitter_radius"]),
    axis=1
)

# TEMPORARY CODE - JUST FOR DEMO
csv_data = data.copy()
csv_data["jitter_lat"] = csv_data["GeoLoc"].apply(lambda x: x[0])
csv_data["jitter_lon"] = csv_data["GeoLoc"].apply(lambda x: x[1])
csv_data = csv_data[["lon", "lat", "jitter_radius", "jitter_lat", "jitter_lon"]]
csv_data.to_csv("jittered_points.csv")

data = data[["Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc"]]
bovine_save_path = os.path.join("data_pipeline", "data", "processed_data", "bovine.json")
data.to_json(path_or_buf=bovine_save_path, orient="records", indent=4)

print(data.head())
