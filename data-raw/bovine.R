state_centroids <- dplyr::as_tibble(jsonlite::fromJSON("data-raw/state_data/state_centroids.json")$data) |>
    dplyr::rename(State = name)

data <- readr::read_tsv(
    file = "data-raw/scraped_outbreak_data/bovine.csv",
    show_col_types = F,
    locale = vroom::locale(encoding = "UTF-16")
)

data <- data |>
    dplyr::left_join(state_centroids, by = dplyr::join_by("State")) |>
    dplyr::mutate(`County Name` = "NA", EndDate = "NA", NumInfected = "NA", GeoLoc = purrr::map2(lat, lon, ~ c(.x, .y))) |>
    dplyr::select("Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc")

bovine <- jsonlite::toJSON(data, pretty = T)
usethis::use_data(bovine, overwrite = TRUE)