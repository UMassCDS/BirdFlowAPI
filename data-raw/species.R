#-------------------------------------------------------------------------------
#  Load species
#-------------------------------------------------------------------------------
# Using JSON so that the taxa file is identical to that used by front end:
#  avianfluapp/src/assets/taxa.json
species <- jsonlite::read_json(file.path("data-raw", "taxa.json")) |> 
   do.call(rbind, args = _) |> 
   as.data.frame()
names(species) <- c("species", "label")
species$species <- as.character(species$species)
species$label <- as.character(species$label)
species <- species[!species$species == "total", ]


#-------------------------------------------------------------------------------
# Load Population and Join to species
#-------------------------------------------------------------------------------
# File from  
# https://github.com/birdflow-science/BirdFlowWork/tree/main/population/data/final
pop <- read.csv(file.path("data-raw", "population.csv")) |>
   dplyr::filter(species_code %in% species$species) |>
   dplyr::select(species = species_code, population = americas_pop)

species <- dplyr::left_join(species, pop, by = dplyr::join_by("species" == "species"))


#-------------------------------------------------------------------------------
# Save processed data as .rda object
#-------------------------------------------------------------------------------
usethis::use_data(species, overwrite = TRUE)
