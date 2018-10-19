# R-ArcGIS Summarize Tool

# Execute R-ArcGIS Summarize Tool
tool_exec <- function(in_params, out_params) {

  # Load required packages
  arc.progress_label('Loading required R packages...')
  arc.progress_pos(25)
  
  pkgs = c('dplyr')
  load_pkgs(pkgs)

  # Get parameters
  source_data = in_params$in_data
  group_fields = unname(unlist(in_params$group_fields))
  summarize_fields = unname(unlist(in_params$summarize_fields))
  summarize_funs = unname(unlist(in_params$summarize_funs))
  results = out_params$results
  
  # Import data set to data frame
  arc.progress_label('Reading data...')
  arc.progress_pos(50)
  data = arc.open(source_data)
  
  # Read data, and cast to to regular data frame to discard spatial data, if input is a feature class...
  data_df = arc.select(data, c(group_fields, summarize_fields)) %>% data.frame()
  
  # Create sorted data frame
  arc.progress_label('Summarizing selected columns by group fields...')
  arc.progress_pos(75)

  # Group the data frame using the selected group fields, and then summarize
  # the data frame by group using the provided functions.
  if (!is.null(group_fields)) {
    summarize_df <- group_by_at(data_df, vars(group_fields))
  }
  else
  {
    summarize_df <- data_df
  }
  
  # The funs_() method lets us convert a list of strings to functions, and provide arguments
  # that will be applied to each, such as 'na.rm=TRUE'.  So a list of function names like
  # fun_(c("mean","median"), args=list(na.rm=TRUE))
  summarize_df <- summarize_df %>%
    summarize_at(vars(summarize_fields), funs_(summarize_funs, args=list(na.rm = TRUE)))
  
  # Write data frame to output standalone table.
  arc.write(results, summarize_df)

  return(out_params)

}

# Install and load all packages provided from a character vector
load_pkgs <- function(pkgs) {
  invisible(lapply(pkgs, function(pkg) {
    if(!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg, quiet = TRUE)
    suppressWarnings(suppressMessages(require(pkg, character.only = TRUE)))
  }))
  
}

# Load the arcgisbinding package, and call arc.check_product():
load_arcgisbinding <- function() {
  if (suppressWarnings(suppressMessages(require(arcgisbinding)))) {
    arc.check_product()
  } else {
    stop("Failed to load the arcgisbinding package!")
  }
}

# When this script is sourced in R/RStudio, the following code to test the tool_exec() function:
test_tool = function(){
  
  # If the arcgisbinding package isn't loaded, let's load it, and test our tool_exec() funciton...
  load_arcgisbinding()
  
  temp = getwd() # Substitute this with another location on disk if you like...
  out_dir = file.path(temp, "SummarizeSamples")
  
  if (dir.exists(out_dir))
  {
    unlink(out_dir, recursive=TRUE)
    Sys.sleep(1)  # Wait one second, or the dir.create() method may fail...
  }
  dir.create(out_dir)
  
  
  tool_exec(
    list(
      in_data = "data/census/CSDsJoined.lyrx",
      group_fields = NULL,
      summarize_fields = list("income2016csd.pop2016_t","income2016csd.pop2011_t"),
      summarize_funs = list("mean",'median','min','max','sd')
    ),
    list(
      results = file.path(out_dir, "results.csv")
    )
  )
  message(paste(c("Results saved to: ",out_dir), collapse=""))
}

# If running as a stand-alone script, test the tool:
if (!exists("arc.env") || is.null(arc.env()$workspace)) {
  test_tool()
}

