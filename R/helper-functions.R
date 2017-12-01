# Helper functions


# Install and load all packages provided from a character vector
load_pkgs <- function(pkgs) {

  # Use lapply() to execute a function for each item in the pkgs vector...
  invisible(lapply(pkgs, function(pkg) {

    # Require the namespace of each package - if this returns false,
    # install the package:
    if(!requireNamespace(pkg, quietly = TRUE))
      install.packages(pkg, quiet = TRUE, repos = "https://cloud.r-project.org")

    # Require the package (character.only = TRUE is needed to
    # require packages when names are passed as character strings)
    if (pkg == "arcgisbinding")
    {
      load_arcgisbinding()
    }
    else
    {
      # Calling require() or library() inside the suppressWarnings() and
      # suppressMessages() methods will prevent warnings about missing packages
      # from being printed to theconsole.
      
      suppressWarnings(suppressMessages(require(pkg, character.only = TRUE)))
    }
  }))

}


# Load the arcgisbinding package, and call arc.check_product() to bind the
# session to ArcGIS Pro/Desktop.
load_arcgisbinding <- function() {

  # Calling require() or library() inside the suppressWarnings() and
  # suppressMessages() methods will prevent warnings about missing packages,
  # or the the prompt to call arc.check_product() from being printed to the
  # console.

  if (suppressWarnings(suppressMessages(require(arcgisbinding)))) {

    # When the arcgisbinding package is successfully loaded, call the
    # arc.check_product() method:
    arc.check_product()
    return(TRUE)

  } else {

    # Raise an error to stop the execution.  We could also raise a warning() instead, and/or return(FALSE)
    stop("Failed to load the arcgisbinding package!")

  }
}
