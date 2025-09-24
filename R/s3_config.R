s3_config <- new.env()

# Define extent of exported data (ai_app_extent)
# s3_config$ai_app_crs <- sf::st_crs("EPSG:3857")

# Note now storing extent as a simple vector (xmin, xmax, ymin, ymax) in EPSG:3857
# s3_config$ai_app_extent <- c(-18924313.4348565, -5565974.53966368, 1118889.97485796, 15538711.0963092)

# s3_configure S3 bucket, its url and the path within it used for flow output
# s3_config$s3_bucket_name <- "avianinfluenza"
# s3_config$s3_flow_path <- "flow/"
# s3_config$s3_flow_url <- "https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/"

# Define local cache for temporary output images, will then be copied to AWS
# s3_config$local_cache <- tempdir()
# if(!file.exists(s3_config$local_cache))
#    dir.create(s3_config$local_cache)

set_s3_config <- function(access_key = NULL, secret_key = NULL, region = NULL, bucket = NULL, log = TRUE, log_file_path = "./flow_debug.log") {
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
}

# TODO: add all s3_config params here?
get_s3_config <- function() {
  access_key <- s3_config$access_key %||% Sys.getenv("AWS_ACCESS_KEY_ID", unset = NA)
  secret_key <- s3_config$secret_key %||% Sys.getenv("AWS_SECRET_ACCESS_KEY", unset = NA)
  region <- s3_config$region %||% Sys.getenv("AWS_DEFAULT_REGION", unset = NA)
  bucket <- s3_config$bucket %||% Sys.getenv("S3_BUCKET_NAME", unset = NA)
  list(access_key = access_key, secret_key = secret_key, region = region, bucket = bucket)
}

`%||%` <- function(a, b) if (!is.null(a) && !is.na(a) && nzchar(a)) a else b
