test_that("example API test", {
  expect_silent({
    # Start plumber API
    local_api <- callthat::call_that_plumber_start(api_folder = system.file("plumber", "flow", "endpoints", package = "BirdFlowAPI"), api_file = "mock_api.R")
    # Start test session
    api_session <- callthat::call_that_session_start(local_api)
  })

  # Make API call
  get_predict <- callthat::call_that_api_get(api_session, endpoint = "inflow", query = list(loc = NULL, week = 10, taxa = "total", n = 20))
  expect_s3_class(get_predict, "response")

  # Run tests on response
  expect_equal(get_predict$status_code, 200)
  
  # Test to confirm the output of the API is correct
  content <- httr::content(get_predict)
  start <- content$start
  status <- content$status
  result <- content$result

  expect_equal(start$week[[1]], 10)
  expect_equal(start$taxa[[1]], "total")
  expect_equal(start$location[[1]][[1]], 42.0982)
  expect_equal(start$location[[1]][[2]], -106.9629)
  expect_equal(status[[1]], "success")
  
  for(i in 1:length(result)) {
    elem <- result[[i]]
    week <- elem$week[[1]]
    url <- elem$url[[1]]
    legend <- elem$legend[[1]]
    expect_equal(week, length(result) - i + 1)
    
    # TODO: convert this into a regex pattern
    expect_true(grepl("abundance_total_", url))
    expect_true(grepl(as.character(length(result) - i + 1), url))
    expect_true(grepl("scale_abundance_total", legend))
  }

  # Close session and plumber API
  expect_null(callthat::call_that_session_stop(api_session))
  expect_null(callthat::call_that_plumber_stop(api_session))
})
