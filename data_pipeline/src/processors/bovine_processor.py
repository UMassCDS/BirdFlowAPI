import pandas as pd
import json
import os

state_centroids_path = os.path.join("data_pipeline", "data", "original_data", "state_centroids.json")
try:
    with open(state_centroids_path, "r") as file:
        state_centroids = json.load(file)["data"]
        state_centroids = pd.DataFrame(state_centroids).rename(columns={"name": "State"})
except Exception as ex:
    print(ex)

bovine_data_path = os.path.join("data_pipeline", "data", "scraped_data", "bovine.csv")
try:
    data = pd.read_csv(bovine_data_path, delimiter="\t", encoding="utf-16")
except Exception as ex:
    print(ex)

data = pd.merge(data, state_centroids, how="left", on="State")
data["County Name"] = None
data["EndDate"] = None
data["NumInfected"] = None
data["GeoLoc"] = list(zip(data["lat"], data["lon"]))
data = data[["Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc"]]

bovine_save_path = os.path.join("data_pipeline", "data", "processed_data", "bovine.json")
data.to_json(path_or_buf=bovine_save_path, orient="records", indent=4)
