.onLoad <- function(libname, pkgname) {
    utils::data("species", package = "BirdFlowAPI", envir = parent.env(environment()))
    utils::data("flow_colors", package = "BirdFlowAPI", envir = parent.env(environment()))
    load_models()
}

.ignore_unused_imports <- function() {
    plumber::plumb
}