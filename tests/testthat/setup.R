load_models()
set_s3_config()


# Set the cache directory to a new tempdir for the duration of the tests.
# and delete it after tests complete.
# If running individual tests manually don't run this code.
original_local_temp <- get_s3_config()$local_temp
local_temp <- withr::local_tempdir("cache", .local_envir = teardown_env())
s3_config$local_temp <- local_temp
withr::defer(
  s3_config$local_temp <- original_local_temp, envir = teardown_env()
  )
