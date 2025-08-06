county_centroids <- dplyr::as_tibble(jsonlite::fromJSON("data-raw/county_data/counties.json")) |>
    dplyr::mutate(state = stringr::str_to_title(tolower(state)))

data <- readr::read_tsv(
    file = "data-raw/scraped_outbreak_data/commercial_backyard_stocks.csv",
    show_col_types = F,
    locale = vroom::locale(encoding = "UTF-16"),
    skip = 1
)

data <- dplyr::as_tibble(data) |>
    dplyr::rename(date_NA = `NA`)

date_cols <- setdiff(colnames(data), c("Confirmed", "State", "County Name", "Special Id", "Production"))

data <- tidyr::pivot_longer(data, cols = tidyr::all_of(date_cols), values_drop_na = T, names_to = "date", values_to = "number") |>
    dplyr::left_join(county_centroids, by = c("County Name" = "county", "State" = "state")) |>
    dplyr::mutate(EndDate = "NA") |>
    dplyr::rename(NumInfected = number, Date = date) |>
    dplyr::mutate(GeoLoc = purrr::map2(lat, lon, ~ c(.x, .y))) |>
    dplyr::select("Confirmed", "State", "County Name", "Production", "EndDate", "NumInfected", "GeoLoc")

commercial_backyard_stocks <- jsonlite::toJSON(data, pretty = T)
usethis::use_data(commercial_backyard_stocks, overwrite = TRUE)