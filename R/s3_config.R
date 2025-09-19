s3_config <- new.env()

set_s3_config <- function(access_key = NULL, secret_key = NULL, region = NULL, bucket = NULL) {
  assign(".s3_config", list(
    access_key = access_key,
    secret_key = secret_key,
    region = region,
    bucket = bucket
  ), envir = .GlobalEnv)
}

get_s3_config <- function() {
  config <- if (exists(".s3_config", envir = .GlobalEnv)) get(".s3_config", envir = .GlobalEnv) else list()
  access_key <- config$access_key %||% Sys.getenv("AWS_ACCESS_KEY_ID", unset = NA)
  secret_key <- config$secret_key %||% Sys.getenv("AWS_SECRET_ACCESS_KEY", unset = NA)
  region     <- config$region     %||% Sys.getenv("AWS_DEFAULT_REGION", unset = NA)
  bucket     <- config$bucket     %||% Sys.getenv("S3_BUCKET_NAME", unset = NA)
  list(access_key = access_key, secret_key = secret_key, region = region, bucket = bucket)
}

`%||%` <- function(a, b) if (!is.null(a) && !is.na(a) && nzchar(a)) a else b