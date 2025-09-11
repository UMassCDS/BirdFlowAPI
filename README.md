# BirdFlowAPI

BirdFlowAPI is an R package containing the API and backend code for the Avian Influenza Project. It provides tools for analyzing Avian Influenza data, including bird abundance, movement patterns, and outbreak information across North America.

## Installation

You can build and install BirdFlowAPI locally or from GitHub.


**Install from local cloned repository:**
```r
devtools::install()
```

**Install from GitHub:**
```r
devtools::install_github("UMassCDS/BirdFlowAPI")
```

## Configure API

The `load_models.R` file defines a function `load_models` that loads the the models of all species. The `load_models` function must be explicitly called while configuring the API. This is done by running `load_models()`.

## Testing

Run the full test suite:
```r
devtools::test()
```

Run a specific test file:
```r
testthat::test_file("tests/testthat/test-example.R")
```

## R CMD Check

<!-- badges: start -->
[![R-CMD-check](https://github.com/UMassCDS/BirdFlowAPI/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UMassCDS/BirdFlowAPI/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## S3 Configuration

BirdFlowAPI supports saving output files to AWS S3 or locally, with flexible credential management:

**Supported Modes:**
- **IAM Role (EC2/AWS):**
  - Attach an IAM role with S3 permissions to your EC2 instance.
  - Set only the region and bucket name:
    ```r
    Sys.setenv(AWS_DEFAULT_REGION = "us-east-1", S3_BUCKET_NAME = "your-bucket-name")
    # Or in R:
    set_s3_config(region = "us-east-1", bucket = "your-bucket-name")
    ```
  - Do NOT set access/secret keys; they are auto-detected.
- **Environment Variables:**
  - Set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`, and `S3_BUCKET_NAME` in your environment or `.Renviron`.
- **Explicit Setter Function:**
  - Call `set_s3_config(access_key, secret_key, region, bucket)` in R.
- **GitHub Secrets (CI/CD):**
  - Use GitHub Actions to set environment variables from secrets before running R code.

**Default Behavior:**
- If S3 is not configured, files are saved locally.
- To force local mode, use `flow(..., save_local = TRUE)`.

**Example:**
```r
set_s3_config(region = "us-east-1", bucket = "my-bucket")
flow(...)
```

See package documentation for more details.
