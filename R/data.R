#' Species populations and labels
#'
#' A dataset containing population estimates for various North American duck species
#'
#' @format A data frame with 9 rows and 3 columns:
#' \describe{
#'   \item{species}{Character code for the species.}
#'   \item{label}{Common name of the species.}
#'   \item{population}{Estimated population size.}
#' }
#' @source <https://github.com/UMassCDS/avian-influenza-api-backend>
"species"

#' Flow colors
#'
#' An integer matrix with 256 rows and 3 columns
#'
#' @format An integer matrix with 256 rows and 3 columns:
#' \describe{
#'   \item{red}{Red channel intensity (0–255)}
#'   \item{green}{Green channel intensity (0–255)}
#'   \item{blue}{Blue channel intensity (0–255)}
#' }
#' @source <https://github.com/UMassCDS/avian-influenza-api-backend>
"flow_colors"

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

# Declare these as global variables so package check doesn't flag them
utils::globalVariables(c("species", "flow_colors"))
