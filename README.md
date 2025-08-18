# BirdFlowAPI

BirdFlowAPI is an R package containing the API and backend code for the Avian Influenza Project. It provides tools for analyzing Avian Influenza data, including bird abundance, movement patterns, and outbreak information across North America.

## Installation

The development version of BirdFlowAPI can be installed from GitHub with:
```r
devtools::install_github("UMassCDS/BirdFlowAPI")
```

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
