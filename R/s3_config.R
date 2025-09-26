s3_config <- new.env()

set_s3_config <- function(access_key = NULL, secret_key = NULL, region = NULL, bucket = NULL, log = TRUE, log_file_path = "./flow_debug.log", local_temp_path = "localtmp") {
  s3_config$access_key <- access_key
  s3_config$secret_key <- secret_key
  s3_config$region <- region
  s3_config$bucket <- bucket

  s3_config$ai_app_crs <- sf::st_crs("EPSG:3857")
  s3_config$ai_app_extent <- c(-18924313.4348565, -5565974.53966368, 1118889.97485796, 15538711.0963092)
  s3_config$s3_bucket_name <- "avianinfluenza"
  s3_config$s3_flow_path <- "flow/"
  s3_config$s3_flow_url <- "https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/"
  s3_config$local_cache <- tempdir()
  if(!file.exists(s3_config$local_cache))
    dir.create(s3_config$local_cache)
  
  s3_config$log <- log
  s3_config$log_file_path <- log_file_path
  s3_config$local_temp_path <- local_temp_path
}

get_s3_config <- function() {
  list(
    access_key = s3_config$access_key %||% Sys.getenv("AWS_ACCESS_KEY_ID", unset = NA),
    secret_key = s3_config$secret_key %||% Sys.getenv("AWS_SECRET_ACCESS_KEY", unset = NA),
    region = s3_config$region %||% Sys.getenv("AWS_DEFAULT_REGION", unset = NA),
    bucket = s3_config$bucket %||% Sys.getenv("S3_BUCKET_NAME", unset = NA),
    ai_app_crs = s3_config$ai_app_crs %||% NA,
    ai_app_extent = s3_config$ai_app_extent %||% NA,
    s3_bucket_name = s3_config$s3_bucket_name %||% NA,
    s3_flow_path = s3_config$s3_flow_path %||% NA,
    s3_flow_url = s3_config$s3_flow_url %||% NA,
    local_cache = s3_config$local_cache %||% NA,
    log = s3_config$log %||% NA,
    log_file_path = s3_config$log_file_path %||% NA,
    local_temp_path = s3_config$local_temp_path %||% NA
  )
}

`%||%` <- function(a, b) {
  if (is.null(a)) return(b)
  if (is.atomic(a) && length(a) == 1 && is.na(a)) return(b)
  if (is.character(a) && length(a) == 1 && !nzchar(a)) return(b)
  a
}
