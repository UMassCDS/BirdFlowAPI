# The extent values were derived from spherical coordinates

corners = data.frame(x = c(-170, -170, -50, -50), y = c(10, 80, 10, 80))
csf <- sf::st_as_sf(corners,coords = c("x", "y"))
sf::st_crs(csf) <- "epsg:4326"
ai_app_crs <- sf::st_crs("EPSG:3857")
web_corners <- sf::st_transform(csf, ai_app_crs)
ai_app_extent <- terra::ext(web_corners)
ai_app_exttent <- ai_app_extent[] |> as.numeric()
