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

test_that("status is either success or cached", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(res$status == "success" || res$status == "cached")
})

test_that("result taxa matches input", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(res$start$taxa == params$taxa)
})

test_that("result loc matches input", {
  params <- standard_flow_input()
  res <- flow(loc = params$loc, week = params$week, taxa = params$taxa, n = params$n, direction = params$direction, save_local = params$save_local)
  expect_true(res$start$loc == params$loc)
})

test_that("result start week matches input", {
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
