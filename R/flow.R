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

if(FALSE) {
   # Manually set function arguments for dev and debugging
   # Running code here allows running function body code outside of the
   # function definition (line by line)


   ## Setup - duplicates loading done in entrypoint.R
   # Change the working directory to "api" before sourcing so relative paths in
   # the other files are correct


   # Load globals and helpers
   original_wd <- getwd()
   if(!grepl("api$", getwd()))
      setwd("api")
   source("config/globals.R")
   source("utils/helpers.R")
   source("utils/symbolize_raster_data.R")
   source("utils/save_json_palette.R")
   source("utils/range_rescale.R")
   setwd(original_wd)

   # Set example arguments values as R objects
   taxa <- "mallar3"
   taxa <- "total"  # all taxa
   week = 15
   date <- "2022-01-01"
   lat <- 42
   lon <- -70
   loc <-
   direction <- "forward"
   n <- 10 # prob 20 when deployed
   loc <- "1,2;3,4;12.12,-13.13" # test multi-point
   loc <- paste0(lat, ",", lon)
}

save_local_path <- "config/save_local.flag"


#' Implement inflow and outflow
#'
#' This function is the heart of the inflow and outflow api and does all
#' the work. It is wrapped by both of those endpoints
#'
#' @param taxa a taxa.  Should be either "total" (sum across all species) or
#' one of the species listed in config/taxa.json
#' @param loc One or more locations as a scalar character each location should
#' be latitude and longitude separated by a comma, multiple locations are separated by
#' a semicolon  e.g. "42,-72"   or "42,-72;43.4,-72.7"
#' @param n The number of weeks to project forward (note output will include
#' the initial week so will have n + 1 images)
#' @param week The week number to start at.
#' @param direction Which direction to project in "backward" for inflow or "forward" for outflow"
#' @param save_local True/False boolean flag - determines whether to save results locally (default: value in config/save_local.flag, or FALSE if not present). If FALSE, results are uploaded to S3 if configured.
#' @returns A list with components:
#'
#' `start` a list with:
#'    `week`  as input
#'    `taxa`, as input
#'    `loc`,  as input
#'    `type` - "inflow" or "outflow"
#' `status` either: "success", "error", "outside mask"
#' `result` a list of information about the images each item includes
#'    `week`
#'    `url`
#'    `legend`
#'    `type`
#' @export
flow <- function(loc, week, taxa, n, direction = "forward", save_local = FALSE) {
  # TODO:
  # utils::data("species", package = "BirdFlowAPI", envir = environment())

  # load_models()

  s3_cfg <- get_s3_config()
  s3_enabled <- !is.na(s3_cfg$bucket) && nzchar(s3_cfg$bucket)

  format_error <- function(message, status = "error") {
    log_progress(paste("ERROR:", message))
    list(
      start = list(week = week, taxa = taxa, loc = loc),
      status = status,
      message = message
    )
  }

  log_progress <- function(msg) {
    cat(sprintf("[%s] %s\n", Sys.time(), msg), file = "./flow_debug.log", append = TRUE)
  }

  log_progress(paste0("Starting flow function with arguments: loc=", loc, ", week=", week, ", taxa=", taxa, ", n=", n, ", direction=", direction, ", save_local=", save_local))
  log_progress(paste0("S3 enabled: ", s3_enabled, ", S3 config: ", paste(names(s3_cfg), s3_cfg, sep="=", collapse=", ")))

  # Convert location to lat/lon dataframe
  lat_lon <- strsplit(loc, ";") |>
    unlist() |>
    strsplit(split = ",") |>
    do.call(rbind, args = _) |>
    as.data.frame()
  for (i in seq_len(ncol(lat_lon))) lat_lon[, i] <- as.numeric(lat_lon[, i])
  names(lat_lon) <- c("lat", "lon")

  if (!taxa %in% c(species$species, "total")) return(format_error("invalid taxa"))
  if (!week %in% as.character(1:52)) return(format_error("invalid week"))
  if (!n %in% as.character(1:52)) return(format_error("invalid n"))
  if (!direction %in% c("forward", "backward")) return(format_error("invalid direction"))
  log_progress("Input validation passed.")

  week <- as.numeric(week)
  n <- as.numeric(n)
  flow_type <- ifelse(direction == "forward", "outflow", "inflow")

  # Snap lat/lon to cell center using the first model (all models use same grid)
  bf <- models[[ifelse(taxa == "total", species$species[1], taxa)]]
  xy <- BirdFlowR::latlon_to_xy(lat_lon$lat, lat_lon$lon, bf = bf)
  col <- BirdFlowR::x_to_col(xy$x, bf = bf)
  row <- BirdFlowR::y_to_row(xy$y, bf = bf)
  x <- BirdFlowR::col_to_x(col, bf = bf)
  y <- BirdFlowR::row_to_y(row, bf = bf)
  snapped_latlon <- BirdFlowR::xy_to_latlon(x, y, bf = bf)
  snapped_latlon$lat <- round(snapped_latlon$lat, 2)
  snapped_latlon$lon <- round(snapped_latlon$lon, 2)
  lat_lon <- snapped_latlon

  # Re-compute snapped xy for later use
  xy <- BirdFlowR::latlon_to_xy(lat_lon$lat, lat_lon$lon, bf = bf)

  # Form file names and S3 keys using snapped lat/lon
  snapped_lat <- paste(lat_lon$lat, collapse = "_")
  snapped_lon <- paste(lat_lon$lon, collapse = "_")
  cache_prefix <- paste0(direction, "/", taxa, "_", week, "_", snapped_lat, "_", snapped_lon, "/")
  pred_weeks <- BirdFlowR::lookup_timestep_sequence(bf, start = week, n = n, direction = direction)
  png_files <- paste0(flow_type, "_", taxa, "_", pred_weeks, ".png")
  symbology_files <- paste0(flow_type, "_", taxa, "_", pred_weeks, ".json")
  png_bucket_paths <- paste0(s3_flow_path, cache_prefix, png_files)
  symbology_bucket_paths <- paste0(s3_flow_path, cache_prefix, symbology_files)
  png_urls <- paste0(s3_flow_url, cache_prefix, png_files)
  symbology_urls <- paste0(s3_flow_url, cache_prefix, symbology_files)
  tiff_bucket_path <- paste0(s3_flow_path, cache_prefix, flow_type, "_", taxa, ".tif")

  # --- CACHE CHECK BLOCK ---
  cache_hit <- TRUE
  if (!save_local && s3_enabled) {
    for (i in seq_along(pred_weeks)) {
      png_exists <- aws.s3::object_exists(object = png_bucket_paths[i], bucket = s3_cfg$bucket)
      json_exists <- aws.s3::object_exists(object = symbology_bucket_paths[i], bucket = s3_cfg$bucket)
      if (!png_exists || !json_exists) {
        cache_hit <- FALSE
        break
      }
    }
    tiff_exists <- aws.s3::object_exists(object = tiff_bucket_path, bucket = s3_cfg$bucket)
    if (!tiff_exists) cache_hit <- FALSE
  } else {
    # Local cache: check if all files exist in localtmp
    dir.create("localtmp", showWarnings = FALSE)
    local_cache_prefix <- file.path("localtmp", gsub("/", "_", cache_prefix))
    png_local_paths <- file.path(local_cache_prefix, png_files)
    json_local_paths <- file.path(local_cache_prefix, symbology_files)
    tiff_local_path <- file.path(local_cache_prefix, paste0(flow_type, "_", taxa, ".tif"))
    cache_hit <- all(file.exists(c(png_local_paths, json_local_paths, tiff_local_path)))
  }

  if (cache_hit) {
    log_progress(paste0("Cache hit for prefix: ", cache_prefix, ". Returning cached results."))
    result <- vector("list", length = n + 1)
    for (i in seq_along(pred_weeks)) {
      result[[i]] <- list(
        week = pred_weeks[i],
        url = if (save_local) png_local_paths[i] else png_urls[i],
        legend = if (save_local) json_local_paths[i] else symbology_urls[i],
        type = flow_type
      )
      log_progress(paste0("Cached result for week ", pred_weeks[i], ": url=", result[[i]]$url, ", legend=", result[[i]]$legend))
    }
    log_progress(if (save_local) "Returned cached result from localtmp" else "Returned cached result from S3")
    return(
      list(
        start = list(week = week, taxa = taxa, loc = loc),
        status = "cached",
        result = result,
        geotiff = if (save_local) tiff_local_path else paste0(s3_flow_url, cache_prefix, flow_type, "_", taxa, ".tif")
      )
    )
  }
  # --- END CACHE CHECK BLOCK ---

  # Continue with prediction
  if (save_local || !s3_enabled) {
    dir.create("localtmp", showWarnings = FALSE)
    out_path <- file.path("localtmp", gsub("/", "_", cache_prefix))
    dir.create(out_path, recursive = TRUE, showWarnings = FALSE)
  } else {
    out_path <- tempfile(pattern = "flow_", tmpdir = "/dev/shm")
    dir.create(out_path, recursive = TRUE)
  }

  target_species <- if (taxa == "total") species$species else taxa
  skipped <- rep(FALSE, length(target_species))

  combined <- NULL
  any_valid <- FALSE

  for (i in seq_along(target_species)) {
    sp <- target_species[i]
    bf <- models[[sp]]
    valid <- BirdFlowR::is_location_valid(bf, timestep = week, x = xy$x, y = xy$y)
    if (!all(valid)) {
      next
    }
    any_valid <- TRUE
    start_distr <- BirdFlowR::as_distr(xy, bf)
    if (nrow(lat_lon) > 1) {
      start_distr <- apply(start_distr, 1, sum)
      start_distr <- start_distr / sum(start_distr)
    }
    log_progress(paste("Starting prediction for", sp))
    pred <- predict(bf, start_distr, start = week, n = n, direction = direction)
    location_i <- BirdFlowR::xy_to_i(xy, bf = bf)
    initial_population_distr <- BirdFlowR::get_distr(bf, which = week)
    start_proportion <- sum(initial_population_distr[location_i]) / 1
    abundance <- pred * species$population[species$species == sp] / prod(terra::res(bf) / 1000) * start_proportion
    this_raster <- BirdFlowR::rasterize_distr(abundance, bf = bf, format = "terra")
    if (is.null(combined)) {
      combined <- this_raster
    } else {
      combined <- combined + this_raster
    }
  }

  if (!any_valid) {
    log_progress("No valid starting location. Returning error.")
    return(format_error("Invalid starting location", "outside mask"))
  }

  log_progress("Before writing TIFF")
  tiff_path <- file.path(out_path, paste0(flow_type, "_", taxa, ".tif"))
  log_progress(paste0("Writing TIFF to: ", tiff_path))
  terra::writeRaster(combined, tiff_path, overwrite = TRUE, filetype = 'GTiff')

  log_progress("Projecting and cropping raster for web output.")
  log_progress(paste0("combined class: ", class(combined)))
  log_progress(paste0("ai_app_crs$input: ", ai_app_crs$input))
  log_progress(paste0("ai_app_extent: ", ai_app_extent))
  if (is.null(combined) || !inherits(combined, "SpatRaster")) {
    log_progress("ERROR: combined raster is NULL or not a SpatRaster. Aborting.")
    return(format_error("combined raster is NULL or not a SpatRaster"))
  }
  if (is.null(ai_app_crs$input)) {
    log_progress("ERROR: ai_app_crs$input is NULL. Aborting.")
    return(format_error("ai_app_crs$input is NULL"))
  }
  if (is.null(ai_app_extent)) {
    log_progress("ERROR: ai_app_extent is NULL. Aborting.")
    return(format_error("ai_app_extent is NULL"))
  }

  log_progress("Projecting")
  web_raster <- combined |> terra::project(ai_app_crs$input)
  log_progress("Cropping")
  web_raster <- terra::crop(web_raster, ai_app_extent)
  log_progress("Done cropping")
  png_paths <- file.path(out_path, png_files)
  symbology_paths <- file.path(out_path, symbology_files)
  for (i in seq_along(pred_weeks)) {
    week_raster <- web_raster[[i]]
    max_val <- terra::minmax(week_raster)[2]
    log_progress(paste0("Symbolizing raster data for week ", pred_weeks[i], ", max value: ", max_val))
    symbolize_raster_data(png = png_paths[i], col_palette = flow_colors,
                          rast = week_raster, max_value = max_val)
    save_json_palette(symbology_paths[i], max = max_val, col_matrix = flow_colors)
    log_progress(paste0("Saved PNG: ", png_paths[i], ", JSON: ", symbology_paths[i]))
  }

  # --- UPLOAD OR LOCAL SAVE ---
  if (!save_local && s3_enabled) {
    log_progress(paste("Uploading TIFF to S3:", tiff_path, "->", tiff_bucket_path))
    tryCatch({
      aws.s3::put_object(
        file = tiff_path,
        object = tiff_bucket_path,
        bucket = s3_cfg$bucket,
        region = s3_cfg$region
      )
      log_progress("TIFF upload successful.")
    }, error = function(e) {
      log_progress(paste("TIFF upload ERROR:", e$message))
    })
    file.remove(tiff_path)

    for (i in seq_along(pred_weeks)) {
      log_progress(paste("Uploading PNG to S3:", png_paths[i], "->", png_bucket_paths[i]))
      tryCatch({
        aws.s3::put_object(
          file = png_paths[i],
          object = png_bucket_paths[i],
          bucket = s3_cfg$bucket,
          region = s3_cfg$region
        )
        log_progress(paste("PNG upload successful:", png_bucket_paths[i]))
      }, error = function(e) {
        log_progress(paste("PNG upload ERROR:", e$message))
      })
      file.remove(png_paths[i])

      log_progress(paste("Uploading JSON to S3:", symbology_paths[i], "->", symbology_bucket_paths[i]))
      tryCatch({
        aws.s3::put_object(
          file = symbology_paths[i],
          object = symbology_bucket_paths[i],
          bucket = s3_cfg$bucket,
          region = s3_cfg$region
        )
        log_progress(paste("JSON upload successful:", symbology_bucket_paths[i]))
      }, error = function(e) {
        log_progress(paste("JSON upload ERROR:", e$message))
      })
      file.remove(symbology_paths[i])
    }
    log_progress(paste0("All files uploaded to S3 and local files removed. Output path: ", out_path))
    unlink(out_path, recursive = TRUE)
  } else {
    log_progress(paste0("Files saved locally in: ", out_path))
    message("Files saved locally in: ", out_path)
    # Optionally, you can keep the files for inspection
  }

  # --- MEMORY CLEANUP ---
  rm(combined, web_raster, week_raster, abundance, pred, start_distr, initial_population_distr)
  gc()
  # --- END MEMORY CLEANUP ---

  result <- vector("list", length = n + 1)
  for (i in seq_along(pred_weeks)) {
    result[[i]] <- list(
      week = pred_weeks[i],
      url = if (save_local) png_paths[i] else png_urls[i],
      legend = if (save_local) symbology_paths[i] else symbology_urls[i],
      type = flow_type
    )
  }

  log_progress("Flow function complete. Returning result.")
  return(
    list(
      start = list(week = week, taxa = taxa, loc = loc),
      status = "success",
      result = result,
      geotiff = if (save_local) tiff_path else paste0(s3_flow_url, cache_prefix, flow_type, "_", taxa, ".tif")
    )
  )
}
