county_centroids <- dplyr::as_tibble(jsonlite::fromJSON("data-raw/county_data/counties.json")) |>
    dplyr::mutate(state = stringr::str_to_title(tolower(state)))

data <- readr::read_csv("data-raw/scraped_outbreak_data/wild_birds.csv", show_col_types = F)

data <- data |>
    dplyr::left_join(county_centroids, by = c("County" = "county", "State" = "state")) |>
    dplyr::mutate(GeoLoc = purrr::map2(lat, lon, ~ c(.x, .y)), EndDate = "NA", NumInfected = "NA") |>
    dplyr::rename(Confirmed = `Date Detected`, Production = `Bird Species`, `County Name` = County) |>
    dplyr::select("Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc")

jsonlite::write_json(data, "data-raw/wildbirds.json", pretty = T)

wild_birds <- jsonlite::toJSON(data, pretty = T)
usethis::use_data(wild_birds, overwrite = TRUE)