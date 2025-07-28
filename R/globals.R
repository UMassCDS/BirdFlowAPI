# Define extent of exported data (ai_app_extent)
corners = data.frame(x = c(-170, -170, -50, -50), y = c(10, 80, 10, 80))
csf <- sf::st_as_sf(corners,coords = c("x", "y"))
sf::st_crs(csf) <- "epsg:4326"

ai_app_crs <- sf::st_crs("EPSG:3857")
web_corners <- sf::st_transform(csf, ai_app_crs)
ai_app_extent <- terra::ext(web_corners)
rm(corners, csf, web_corners)


# Configure S3 bucket, its url and the path within it used for flow output
s3_bucket_name <- "avianinfluenza"
s3_flow_path <- "flow/"
s3_flow_url <- "https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/"


# Define local cache for temporary output images
# Will then be copied to AWS
local_cache <- tempdir()
if(!file.exists(local_cache))
   dir.create(local_cache)
