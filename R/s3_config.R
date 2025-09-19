s3_config <- new.env()

#' Set S3 configuration explicitly
#'
#' Allows user to set S3 credentials and bucket at runtime. If not set, environment variables or IAM role will be used.
set_s3_config <- function(access_key = NULL, secret_key = NULL, region = NULL, bucket = NULL) {
  assign(".s3_config", list(
    access_key = access_key,
    secret_key = secret_key,
    region = region,
    bucket = bucket
  ), envir = .GlobalEnv)
}

#' Get S3 configuration from explicit config, environment variables, or IAM role
get_s3_config <- function() {
  config <- if (exists(".s3_config", envir = .GlobalEnv)) get(".s3_config", envir = .GlobalEnv) else list()
  access_key <- config$access_key %||% Sys.getenv("AWS_ACCESS_KEY_ID", unset = NA)
  secret_key <- config$secret_key %||% Sys.getenv("AWS_SECRET_ACCESS_KEY", unset = NA)
  region     <- config$region     %||% Sys.getenv("AWS_DEFAULT_REGION", unset = NA)
  bucket     <- config$bucket     %||% Sys.getenv("S3_BUCKET_NAME", unset = NA)
  list(access_key = access_key, secret_key = secret_key, region = region, bucket = bucket)
}

#' Null coalescing operator for config values
`%||%` <- function(a, b) if (!is.null(a) && !is.na(a) && nzchar(a)) a else b