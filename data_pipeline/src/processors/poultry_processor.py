import pandas as pd
import os
from ..utils.jitter_function import add_random_jitter
from ..utils.format_date import format_date

counties_path = os.path.join("data", "original_data", "counties.csv")
counties = pd.read_csv(counties_path)
counties = counties.drop(labels=["Unnamed: 0"], axis=1)
counties = counties.rename(columns={"county": "County Name", "state": "State"})
counties["State"] = counties["State"].str.title()

# CBS = commercial and backyard stocks = poultry
poultry_data_path = os.path.join("data", "scraped_data", "poultry.csv")
data = pd.read_csv(poultry_data_path, delimiter="\t", encoding="utf-16", header=1, dtype=str)
data = data.rename(columns={"Confirmed Diagnosis": "Confirmed"})
data = pd.melt(
    data,
    id_vars=["Confirmed", "State", "County Name", "Special ID", "Production"],
    var_name="EndDate",
    value_name="NumInfected",
    ignore_index=True
).dropna().reset_index(drop=True)
data["NumInfected"] = data["NumInfected"].str.replace(',', '').astype(int)

data = pd.merge(left=data, right=counties, how="inner", on=("County Name", "State"))

# Add random jitter to lat-lon
data["GeoLoc"] = data.apply(
    func=lambda row: add_random_jitter(row["lat"], row["lon"], row["jitter_radius"]),
    axis=1
)

# Convert date to appropriate format
data["Confirmed"] = data.apply(
    func=lambda row: format_date(row["Confirmed"], ["%d-%b-%y", "%d-%b-%Y", "%M-%b-%Y"]),
    axis=1
)

data = data[["Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc"]]
poultry_save_path = os.path.join("data", "processed_data", "poultry.json")
data.to_json(path_or_buf=poultry_save_path, orient="records", indent=4)
