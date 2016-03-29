# Function to install packages if they are not already in library
install_missing <- function(pkgs, repos) {
    missing_pkgs <- setdiff(pkgs, rownames(installed.packages()))
    if (length(missing_pkgs) > 0) install.packages(missing_pkgs, repos = repos)
}

# Install packages required for the Spring 2016 Computational Institute
pkg_list <- c("tidyr", "dplyr", "RSQLite", "sp", "rgdal", "rgeos",
              "raster", "shiny", "shinythemes", "leaflet")

install_missing(pkg_list, repos = "http://cran.us.r-project.org")


# Verify that packages can be loaded
suppressMessages({
    library(tidyr)
    library(dplyr)
    library(RSQLite)
    library(sp)
    library(rgdal)
    library(rgeos)
    library(raster)
    library(shiny)
    library(shinythemes)
    library(leaflet)
})


# Check access to files
species <- read.csv("/nfs/public-data/ci-spring2016/Data/species.csv")

# If all the code above ran without any "Warning" or "Error", 
# you are ready for the workshop!




