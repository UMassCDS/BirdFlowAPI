# Load flow colors
flow_colors <- readRDS(file.path("data-raw", "flow_data", "flow_cols.Rds"))

# Save processed data as .rda object
usethis::use_data(flow_colors, overwrite = TRUE)
