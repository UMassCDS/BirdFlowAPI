load_models <- function() {
    # Load BirdFlow models
    BirdFlowR::birdflow_options(collection_url = "https://birdflow-science.s3.amazonaws.com/avian_flu/")
    index <- BirdFlowR::load_collection_index()
    if(!all(species$species %in% index$species_code)) {
        miss <- setdiff(species$species, index$species_code)
        stop("Expected BirdFlow models:", paste(miss, collapse = ", "), " are missing from the model collection." )
    }

    # This is slow so skipping if it's already done - useful when developing to 
    # avoid having to wait to reload. 
    if(!exists("models") || !is.environment(models) || !all(species$species %in% names(models))) {
        models <- new.env(parent = globalenv())
        for (sp in species$species) {
            print(paste0("Loading model for species: ", sp))
            models[[sp]] <- BirdFlowR::load_model(model = sp)
        }
    }    
}