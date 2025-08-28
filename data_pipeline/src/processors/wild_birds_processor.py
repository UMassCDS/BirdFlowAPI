import pandas as pd
import json
import os
from ..utils.jitter_function import add_random_jitter

# TODO: export this to new file in utils -- this is common in WB and CBS
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

# # TEMPORARY CODE, JUST FOR DEMO
# csv_data = data.copy()
# csv_data["jitter_lat"] = csv_data["GeoLoc"].apply(lambda x: x[0])
# csv_data["jitter_lon"] = csv_data["GeoLoc"].apply(lambda x: x[1])
# csv_data = csv_data[["lon", "lat", "jitter_radius", "jitter_lat", "jitter_lon"]]
# csv_data.to_csv("jittered_wild_birds_temp.csv")

data = data[["Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc"]]
wild_birds_save_path = os.path.join("data_pipeline", "data", "processed_data", "jittered_wild_birds.json")
data.to_json(path_or_buf=wild_birds_save_path, orient="records", indent=4)
