library(testthat)
library(callthat)
library(httr)

test_that("example API test", {
    expect_silent({
        # Start plumber API
        local_api <- call_that_plumber_start(system.file("plumber/flow/endpoints/another_endpoint.R", package = "BirdFlowAPI"))
        # Start test session
        api_session <- call_that_session_start(local_api)
    })
    expect_s3_class(
        # Make API call
        get_predict <- call_that_api_get(api_session, endpoint = "status", query = NULL), "response"
    )

    # Run tests on response
    expect_equal(get_predict$status_code, 200)

    # Close session and plumber API
    expect_null(call_that_session_stop(api_session))
})