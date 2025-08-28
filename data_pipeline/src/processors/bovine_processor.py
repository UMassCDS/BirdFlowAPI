import pandas as pd
import os
from ..utils.jitter_function import add_random_jitter
from ..utils.format_date import format_date

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

# Convert date to appropriate format
data["Confirmed"] = data.apply(
    func=lambda row: format_date(row["Confirmed"], "%d-%b-%y"),
    axis=1
)

data = data[["Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc"]]
bovine_save_path = os.path.join("data_pipeline", "data", "processed_data", "jittered_bovine.json")
data.to_json(path_or_buf=bovine_save_path, orient="records", indent=4)
