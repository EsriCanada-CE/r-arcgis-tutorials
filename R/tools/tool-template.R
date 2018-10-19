# R Tool Template ==============================================================

# Every R-ArcGIS tool that you create will follow the same general form.  You
# will need to define a function named 'tool_exec' within your R script.  This
# function will then be executed once you call the R script from within ArcGIS
# for Desktop (i.e., ArcMap, or ArcGIS Pro) via a GP tool.

# The tool_exec() function  has two arguments: in_params and out_params.  You
# can alias these arguments however you want, but we will be using the default
# names throughout this tutorial.

# Both in_params and out_params will be lists of parameters of provided from
# the user via the GP tool. Depending on how many parameters are provided,
# the lengths of these lists will differ.

tool_exec <- function(in_params, out_params) {
  
  # You can assign input and output parameters to variables by specifying the
  # the appropriate element from the parameter lists.
  input_value <- in_params[[1]]
  result_path <- out_params[[1]]
  
  print(input_value)
  print(class(input_value))
  
  # Determine how many parameters are being passed:
  message(paste('Number of input parameters:', length(in_params), sep = ' '))
  message(paste('Number of output parameters:', length(out_params), sep = ' '))
  
  
  # The input/output parameters are also supplied as named list object, so 
  # you can access parameters by their names as configured in the script 
  # tool in the toolbox.
  message(paste0(
    'Input parameter names: `', paste(names(in_params), collapse = '`, `'), '`'
  ))
  message(paste0(
    'Output parameter names: `', paste(names(out_params), collapse = '`, `'), '`'
  ))
  
  # You can use arc.progress_label() and arc.progress_pos() to indicate how
  # far you are in your analysis.  These functions will give the user visual
  # feedback to help them understand which if any sections of the R-ArcGIS
  # GP tool are taking longer to finish, or are encountering errors.
  arc.progress_label('Setting progress...')
  arc.progress_pos(50)
  
  # Perform some analysis on your data...
  
  # If output parameters are derived, you will need to return values for them:
  out_params$output <- paste(paste("You input this text: ", input_value, sep=' '))
  
  # Return results.
  return(out_params)
  
}

# Function to test in standalone R:
test_tool <- function(){
  
  # If the arcgisbinding package isn't loaded, let's load it, and test our tool_exec() function...
  library(arcgisbinding)
  arc.check_product()
  
  # Note: the paths below are relative to the root folder containing the tutorial 
  # files. To change this, either specify full paths, or update the working 
  # directory with the setwd() command before running this tool.
  tool_exec(
    list(
      input = "data/input.shp",
      value = 5
    ),
    list(
      result_path = "data/result.shp"
    )
  )
}

# Test the tool if running directly in R/RStudio:
if (!exists("arc.env") || is.null(arc.env()$workspace)) {
  test_tool()
}
