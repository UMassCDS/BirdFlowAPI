library(testthat)
library(callthat)
library(httr)

test_that("example API test", {
  expect_silent({
    # Start plumber API
    local_api <- call_that_plumber_start(api_folder = system.file("plumber/flow/endpoints", package = "BirdFlowAPI"), api_file = "another_endpoint.R")
    # Start test session
    api_session <- call_that_session_start(local_api)
  })

  # Make API call
  get_predict <- call_that_api_get(api_session, endpoint = "status", query = NULL)
  expect_s3_class(get_predict, "response")

  # Run tests on response
  expect_equal(get_predict$status_code, 200)

  # Test to confirm the output of the API is correct
  content <- content(get_predict)[[1]][[1]]
  expect_equal(content, "API is running fine!")

  # Close session and plumber API
  expect_null(call_that_session_stop(api_session))
})
