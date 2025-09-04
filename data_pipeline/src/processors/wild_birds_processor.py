import pandas as pd
import json
import os
from ..utils.jitter_function import add_random_jitter
from ..utils.format_date import format_date

full_county_info_path = os.path.join("data", "original_data", "counties.csv")
counties = pd.read_csv(full_county_info_path).rename(columns={"county": "County", "state": "State"})
counties["State"] = counties["State"].str.title()

wild_birds_data_path = os.path.join("data", "scraped_data", "wild_birds.csv")
data = pd.read_csv(wild_birds_data_path)
data = pd.merge(data, counties, how="inner", on=("County", "State"))
data["EndDate"] = None
data["NumInfected"] = None
data = data.rename(columns={"Date Detected": "Confirmed", "Bird Species": "Production", "County": "County Name"})

# Add jitter to each point
data["GeoLoc"] = data.apply(
    lambda row: add_random_jitter(row["lat"], row["lon"], row["jitter_radius"]),
    axis=1
)

# Convert date to appropriate format
data["Confirmed"] = data.apply(
    func=lambda row: format_date(row["Confirmed"], "%m/%d/%Y"),
    axis=1
)

data = data[["Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc"]]
wild_birds_save_path = os.path.join("data", "processed_data", "jittered_wild_birds.json")
data.to_json(path_or_buf=wild_birds_save_path, orient="records", indent=4)
