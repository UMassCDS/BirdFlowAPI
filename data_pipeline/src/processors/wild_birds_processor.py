import pandas as pd
import json
import os
from ..utils.jitter_function import add_random_jitter
from ..utils.format_date import format_date

full_county_info_path = os.path.join("data_pipeline", "data", "original_data", "counties.csv")
county_centroids = pd.read_csv(full_county_info_path).rename(columns={"county": "County", "state": "State"}) # TODO: rename
county_centroids["State"] = county_centroids["State"].str.title()

wild_birds_data_path = os.path.join("data_pipeline", "data", "scraped_data", "wild_birds.csv")
data = pd.read_csv(wild_birds_data_path)
data = pd.merge(data, county_centroids, how="inner", on=("County", "State")) # TODO: left join? some counties are incorrectly labelled in data
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
wild_birds_save_path = os.path.join("data_pipeline", "data", "processed_data", "jittered_wild_birds.json") # TODO: rename file
data.to_json(path_or_buf=wild_birds_save_path, orient="records", indent=4)
