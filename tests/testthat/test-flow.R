test_that("flow does not throw error with single input point", {
  taxa <- "total"
  week = 15
  date <- "2022-01-01"
  lat <- 42
  lon <- -70
  direction <- "forward"
  loc <- paste0(lat, ",", lon)
  expect_no_error(
    res <- flow(loc = loc, week = week, taxa = taxa,
                direction = direction, n = 10, save_local = TRUE)
    )
})

test_that("flow does not throw error with single multi-point input", {
  taxa <- "total"  # all taxa
  loc <- "42,-70;43,-72;40,-75" # test multi-point
  week <- 12
  direction <- "forward"
  expect_no_error(
    res <- flow(loc = loc, week = week, taxa = taxa,
                direction = direction, n = 10))
})

test_that("status is either success or cached", {
  taxa <- "ambduc"
  loc <- "42,-70"
  week <- 3
  direction <- "forward"
  n <- 1
  res <- flow(loc = loc, week = week, taxa = taxa, n = n, direction = direction)
  expect_true(res$status == "success" || res$status == "cached")
})
