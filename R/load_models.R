#' Load BirdFlow Models
#'
#' Loads and caches BirdFlow models for all species listed in the `species` object.
#' Models are retrieved from the avian flu BirdFlow model collection hosted on S3.
#' If the models are already loaded in the global `models` environment, they are not reloaded.
#'
#' @return
#' Invisibly returns `NULL`. The loaded models are stored in a global environment called `models`.
#'
#' @examples
#' \dontrun{
#'   load_models()
#'   ls(models)  # list the loaded species models
#' }
#'
#' @export
load_models <- function() {
    # Load BirdFlow models
    BirdFlowR::birdflow_options(collection_url = "https://birdflow-science.s3.amazonaws.com/sparse_avian_flu/")
    index <- BirdFlowR::load_collection_index()
    if(!all(species$species %in% index$species_code)) {
        miss <- setdiff(species$species, index$species_code)
        stop("Expected BirdFlow models:", paste(miss, collapse = ", "), " are missing from the model collection." )
    }

    # This is slow so skipping if it's already done - useful when developing to 
    # avoid having to wait to reload. 
    if(!exists("models") || !is.environment(models) || !all(species$species %in% names(models))) {
        models <<- new.env(parent = globalenv())
        print(paste("Loading", length(species$species), "models from https://birdflow-science.s3.amazonaws.com/avian_flu/"))
        for (sp in species$species) {
            print(paste0("Loading model for species: ", sp))
            models[[sp]] <- BirdFlowR::load_model(model = sp)
        }
    }
}