import geopandas as gpd
import numpy as np
import os

geodata = gpd.read_file(os.path.join("data_pipeline", "data", "original_data", "cb_2024_us_state_500k", "cb_2024_us_state_500k.shp"))
geodata = geodata.rename(columns={"NAME": "state", "GEOID": "geoid"})

geodata["area_m2"] = geodata["ALAND"] + geodata["AWATER"]
geodata["centroid"] = geodata.to_crs("+proj=cea").centroid.to_crs(geodata.crs)
geodata["lat"] = geodata["centroid"].y
geodata["lon"] = geodata["centroid"].x
geodata["jitter_radius"] = 0.25 * np.sqrt(geodata["area_m2"] / np.pi)

geodata = geodata[["state", "geoid", "lat", "lon", "area_m2", "jitter_radius"]]
states_csv_save_path = os.path.join("data_pipeline", "data", "original_data", "states.csv")
geodata.to_csv(states_csv_save_path, index_label="index")