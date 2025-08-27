#' Counties CSV
#'
#' A CSV dataset containing the name, state, geoid, latitude, longitude, area (m^2), and jitter radius of each county in the United States
#'
#' @format A CSV file with 8 columns:
#' \describe{
#'   \item{""}{Index No.}
#'   \item{"county"}{County name}
#'   \item{"state"}{State}
#'   \item{"geoid"}{Geo ID}
#'   \item{"lat"}{Latitude}
#'   \item{"lon"}{Longitude}
#'   \item{"area_m2"}{Area in square meters}
#'   \item{"jitter_radius"}{Jitter radius in meters}
#' }
"counties_csv"

#' Counties JSON
#'
#' A JSON dataset containing the name, state, geoid, latitude, longitude, area (m^2), and jitter radius of each county in the United States
#'
#' @format A JSON file with 7 fields:
#' \describe{
#'   \item{"county"}{County name}
#'   \item{"state"}{State}
#'   \item{"geoid"}{Geo ID}
#'   \item{"lat"}{Latitude}
#'   \item{"lon"}{Longitude}
#'   \item{"area_m2"}{Area in square meters}
#'   \item{"jitter_radius"}{Jitter radius in meters}
#' }
"counties_json"