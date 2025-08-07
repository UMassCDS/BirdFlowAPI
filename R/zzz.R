.onLoad <- function(libname, pkgname) {
    load_models()
}

.ignore_unused_imports <- function() {
    plumber::plumb
}