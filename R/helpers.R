greet <- function(name) {
  paste("Hello", name)
}

#' Load an RDS model from a public S3 URL directly into memory
#' 
#' Downloads and loads an RDS model directly into memory from a public S3 URL
#' 
#' @param model_url URL pointing to the RDS file
#' @return R object from the loaded RDS file
load_model_from_url <- function(model_url) {
  readRDS(url(model_url))
}