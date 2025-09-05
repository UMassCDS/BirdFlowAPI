# Define extent of exported data (ai_app_extent)
ai_app_crs <- sf::st_crs("EPSG:3857")

# Note now storing extent as a simple vector (xmin, xmax, ymin, ymax) in EPSG:3857
ai_app_extent <- c(-18924313.4348565, -5565974.53966368,
                   1118889.97485796, 15538711.0963092)

# Configure S3 bucket, its url and the path within it used for flow output
s3_bucket_name <- "avianinfluenza"
s3_flow_path <- "flow/"
s3_flow_url <- "https://avianinfluenza.s3.us-east-2.amazonaws.com/flow/"


# Define local cache for temporary output images
# Will then be copied to AWS
local_cache <- tempdir()
if(!file.exists(local_cache))
   dir.create(local_cache)
