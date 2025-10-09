# Helper function to return a standardized list of paramaters for testing flow
# These parameters can be used to test fundamental properties of the flow result
standard_flow_input <- function() {
  return(list(
    taxa = "ambduc",
    loc = "42,-70",
    week = 15,
    direction = "forward",
    n = 10,
    save_local = TRUE
  ))
}

test_that("flow does not throw error with single input point", {
  params <- standard_flow_input()
  expect_no_error(
    res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  )
})

test_that("flow does not throw error with single multi-point input", {
  params <- standard_flow_input()
  multi_point_loc <- "42,-70;43,-72;40,-75" # test multi-point
  expect_no_error(
    res <- flow(loc = multi_point_loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  )
})

test_that("status is either success or cached (outflow)", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(res$status == "success" || res$status == "cached")
})

test_that("status is either success or cached (inflow)", {
  params <- standard_flow_input()
  direction <- "backward"
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = direction, save_local = params$save_local)
  expect_true(res$status == "success" || res$status == "cached")
})

test_that("output taxa matches input", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(res$start$taxa == params$taxa)
})

test_that("output loc matches input", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(res$start$loc == params$loc)
})

test_that("output week matches input", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(res$start$week == params$week)
})

test_that("geotiff is a valid AWS link", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(
    grepl("https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/", res$geotiff) ||
    grepl(paste0(get_s3_config()$local_temp_path, "/"), res$geotiff)
  )
})

test_that("length of result is n + 1", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(length(res$result) == (params$n + 1))
})

test_that("result contents are valid (outflow)", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  for(i in seq_along(res$result)) {
    row <- res$result[[i]]
    expect_true(row$week == params$week + i - 1)
    expect_true(
      grepl("https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/", row$url) ||
      grepl(paste0(get_s3_config()$local_temp_path, "/"), row$url)
    )
    expect_true(
      grepl("https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/", row$legend) ||
      grepl(paste0(get_s3_config()$local_temp_path, "/"), row$legend)
    )
    expect_true(row$type == "outflow")
  }
})

test_that("result contents are valid (inflow)", {
  params <- standard_flow_input()
  direction <- "backward"
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = direction, save_local = params$save_local)
  curr_week <- params$week
  for(i in seq_along(res$result)) {
    row <- res$result[[i]]
    expect_true(row$week == curr_week)
    curr_week <- curr_week - 1
    if(curr_week == 0) {
      curr_week <- 52
    }
    expect_true(
      grepl("https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/", row$url) ||
      grepl(paste0(get_s3_config()$local_temp_path, "/"), row$url)
    )
    expect_true(
      grepl("https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/", row$legend) ||
      grepl(paste0(get_s3_config()$local_temp_path, "/"), row$legend)
    )
    expect_true(row$type == "inflow")
  }
})



test_that("total is not constrained by indivual taxa NAs", {
  params <- standard_flow_input()

  # Make a total projection
  params$taxa <- "total"
  expect_no_error(total_result <- do.call(flow, params))
  total <- terra::rast(total_result$geotiff)

  # Same start but for american black duck
  params$taxa <- "ambduc"
  expect_no_error(ambduc_result <- do.call(flow, params))
  ambduc <- terra::rast(ambduc_result$geotiff)

  # There should be more NA's in the American black duck result than in the total
  ambduc_nas <- terra::values(ambduc) |> is.na() |> sum()
  total_nas <- terra::values(total) |> is.na() |> sum()
  expect_true(ambduc_nas > total_nas)

  # The total should not be NA anywhere that ambduc is not NA
  n_wrong <- (is.na(total) & !is.na(ambduc)) |> terra::values() |> sum()
  expect_equal(n_wrong, 0)

})
