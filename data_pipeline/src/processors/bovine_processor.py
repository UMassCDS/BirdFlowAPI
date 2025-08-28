import pandas as pd
import os

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
data = data[["Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc"]]

bovine_save_path = os.path.join("data_pipeline", "data", "processed_data", "bovine.json")
data.to_json(path_or_buf=bovine_save_path, orient="records", indent=4)

print(data.head())
