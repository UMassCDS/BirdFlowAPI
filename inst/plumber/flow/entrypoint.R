library(plumber)
library(BirdFlowR)
library(jsonlite)
library(paws)
library(terra)

# TODO: fix this filepath after migrating globals.R
source("config/globals.R")

# Create plumber router
pr <- pr()

# Add CORS filter
pr <- pr %>%
  pr_filter("cors", function(req, res) {
    res$setHeader("Access-Control-Allow-Origin", "*")
    res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
    if (req$REQUEST_METHOD == "OPTIONS") {
      res$status <- 200
      return(list())
    } else {
      forward()
    }
  }) %>%
  pr_mount("/hello", plumb(system.file("plumber", "flow", "endpoints", "hello.R", package = "BirdFlowAPI"))) %>%
  pr_mount("/predict", plumb(system.file("plumber", "flow", "endpoints", "predict.R", package = "BirdFlowAPI"))) %>%
  pr_mount("/mock", plumb(system.file("plumber", "flow", "endpoints", "mock_api.R", package = "BirdFlowAPI"))) %>%
  pr_mount("/api", plumb(system.file("plumber", "flow", "endpoints", "api.R", package = "BirdFlowAPI")))

# Run the API
pr$run(host = "0.0.0.0", port = 8000)