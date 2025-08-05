# This creates a JSON file with county centroids for use with the Avian Flu app.
# 
# It relies on county boundaries downloaded as geoJASON from here:
# https://data.dumfriesva.gov/Government/GIS-US-County-Boundaries/729p-e9m2/about_data
# as GeoJason to 
# avian_influenza/counties/US_County_Boundaries_20241011.geojson
# On 2024-10-11 
# The geoJSON file 2+ MB and excluded from the repository by .gitignore
#
# The csv file created by this R file is saved in the respository though.

f <- "avian_influenza/counties/US_County_Boundaries_20241011.geojson"

# Read polygons
d <- sf::st_read(f)

# Add centroids and drop polygons
centroids <- sf::st_centroid(d)
coords <- sf::st_coordinates(centroids)
colnames(coords) <- c("lon", "lat")
d <- cbind(sf::st_drop_geometry(centroids), coords)

# Create table to crosswalk state codes to state names
fips_text <-
"      01        ALABAMA
       02        ALASKA
       04        ARIZONA
       05        ARKANSAS
       06        CALIFORNIA
       08        COLORADO
       09        CONNECTICUT
       10        DELAWARE
       11        DISTRICT OF COLUMBIA
       12        FLORIDA
       13        GEORGIA
       15        HAWAII
       16        IDAHO
       17        ILLINOIS
       18        INDIANA
       19        IOWA
       20        KANSAS
       21        KENTUCKY
       22        LOUISIANA
       23        MAINE
       24        MARYLAND
       25        MASSACHUSETTS
       26        MICHIGAN
       27        MINNESOTA
       28        MISSISSIPPI
       29        MISSOURI
       30        MONTANA
       31        NEBRASKA
       32        NEVADA
       33        NEW HAMPSHIRE
       34        NEW JERSEY
       35        NEW MEXICO
       36        NEW YORK
       37        NORTH CAROLINA
       38        NORTH DAKOTA
       39        OHIO
       40        OKLAHOMA
       41        OREGON
       42        PENNSYLVANIA
       44        RHODE ISLAND
       45        SOUTH CAROLINA
       46        SOUTH DAKOTA
       47        TENNESSEE
       48        TEXAS
       49        UTAH
       50        VERMONT
       51        VIRGINIA
       53        WASHINGTON
       54        WEST VIRGINIA
       55        WISCONSIN
       56        WYOMING"
fips_text <- gsub("^[[:blank:]]+", "", fips_text)
fips_text <- gsub("([[:digit:]]{2})([ \t]+)", "\\1\t", fips_text, perl = TRUE)
fips_text <- gsub("\n\t", "\n", fips_text)

# Add header
fips_text <- paste0("statefp\tstate\n", fips_text)

# Add Puerto Rico
fips_text <- paste0(fips_text, "\n72\tPUERTO RICO")
states <- readr::read_tsv(fips_text)
stopifnot(all(d$statefp %in% states$statefp))



# Add state names to counties
counties <- dplyr::left_join(d, states) |> dplyr::rename(county = name)

# Select columns
counties <- dplyr::select(counties, "county", "state",
                          "geoid", "lon", "lat")


counties <- counties[order(counties$geoid), ]
rownames(counties) <- NULL

readr::write_csv(counties, "avian_influenza/counties/counties.csv")


# Write JSON (it is ignored by .gitignore so won't be in repository)
js <- jsonlite::toJSON(counties, pretty = TRUE)
writeLines(js, "avian_influenza/counties/counties.json")