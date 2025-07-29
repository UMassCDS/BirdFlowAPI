test_that("example API test", {
  expect_silent({
    # Start plumber API
    local_api <- callthat::call_that_plumber_start(api_folder = system.file("plumber", "flow", "endpoints", package = "BirdFlowAPI"), api_file = "hello.R")
    # Start test session
    api_session <- callthat::call_that_session_start(local_api)
  })

  # Make API call
  query_text <- "Test echo endpoint - success!"
  get_predict <- callthat::call_that_api_get(api_session, endpoint = "echo", query = list(text = query_text))
  expect_s3_class(get_predict, "response")

  # Run tests on response
  expect_equal(get_predict$status_code, 200)

  # Test to confirm the output of the API is correct
  content <- httr::content(get_predict)[[1]][[1]]
  expect_equal(content, paste("The text is echo:", query_text))

  # Close session and plumber API
  expect_null(callthat::call_that_session_stop(api_session))
})
