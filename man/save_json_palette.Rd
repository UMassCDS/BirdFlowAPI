% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/save_json_palette.R
\name{save_json_palette}
\alias{save_json_palette}
\title{Save JSON file with palette information}
\usage{
save_json_palette(file, max, min = 0, n = 10, col_matrix, stretch_first = 2)
}
\arguments{
\item{file}{The name of the json file to write the palette to}

\item{max}{The maximum value represented by the color scale.}

\item{min}{The minimum value represented by the color scale.}

\item{n}{The number of  values used to represent the color scale.}

\item{col_matrix}{A matrix with RGB values for each color displayed.  Should have
dimension of 256 x 3 and values 0 to 255.
See abundance_cols and movement_cols defined in 00_set_ai_parameters.R
for suitable objects.}

\item{stretch_first}{if not NULL set to the percentage of the color scale
bar that the first value should be stretched over. This is useful when,
as in the ebirds abundance scale the color for zero is different then
the remaining colors. When set the remaining colors get compressed slightly.}
}
\value{
File is written, nothing is returned.
}
\description{
Save JSON file with palette information
}
