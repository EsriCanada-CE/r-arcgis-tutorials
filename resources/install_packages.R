repo = "https://cloud.r-project.org"

## To install from a local 'miniCRAN' repository, uncomment the following line, and correct the path
# repo = "file:///D:/r-arcgis/resources/miniCRAN/" ## install from absolute path to miniCRAN folder
# repo = paste(paste("file:///",getwd(),sep=""),"/resources/miniCRAN/", sep="")  ## relative path to miniCRAN folder

# The following packages may be installed to ensure R-ArcGIS tutiorials will work offline: 
pkgs <- c(
    
    # Packages needed to view R notebooks in RStudio (R Markdown files, *.Rmd)
    "evaluate",
    "digest",
    "formatR",
    "highr",
    "markdown",
    "stringr",
    "yaml",
    "Rcpp",
    "htmltools",
    "caTools",
    "bitops",
    "knitr",
    "jsonlite",
    "base64enc",
    "rprojroot",
    "rmarkdown",
    
    # Hadley Wickham's tidyverse (ggplot2, dplyr, etc.):
    "tidyverse",
    
    # Packages used by samples/exercises:
    "sp",
    "sm",
    "maptools",
    "foreign",
    "kernlab",
    "rms",
    "cluster",
    "rgdal",
    "rgeos",
    "mclust",
    "deldir",
    "lctools",
    "gdata",
    "spatstat",
    "spdplyr",
    "REAT",
    "ineq",
    "SDraw"
)

invisible(lapply(pkgs, function(pkg) {

    # Require the namespace of each package - if this returns false, install the package:
    if(!requireNamespace(pkg, quietly = TRUE))
      install.packages(pkg, repos = repo, quiet = TRUE)

}))
