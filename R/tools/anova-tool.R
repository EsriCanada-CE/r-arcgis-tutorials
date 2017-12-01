# R-ArcGIS ANOVA Tool

tool_exec <-function(in_params, out_params) {

  # Load required packages
  arc.progress_label('Loading required R packages...')
  arc.progress_pos(0)
  load_pkgs('dplyr')

  # Get input/output parameters
  in_data <- in_params$in_data
  response_var <- in_params$response_var
  predictor_var <- in_params$predictor_var
  predictor_groups <- in_params$predictor_groups
  anova_table <- out_params$anova_table
  stats_table <- out_params$stats_table
  
  if (is.null(predictor_groups) || predictor_groups == "NA" || predictor_groups < 2)
  {
    warning("Defaulting to minimum of 2 predictor groups.")
    predictor_groups <- 2
  }
  
  # Import data set to data frame
  arc.progress_label('Reading data...')
  arc.progress_pos(25)
  
  data <- arc.open(in_data)
  data_df <- arc.select(data, fields = c(response_var, predictor_var)) %>% 
    filter_at(vars(c(response_var, predictor_var)), all_vars(!is.na(.)))

  # Group data into quantiles using predictor field:
  grouped_df <- data_df %>%
    mutate(predictor_rank = ntile(data_df[[predictor_var]], predictor_groups)) %>%
    group_by(predictor_rank)
  
  # Create box and whisker plot
  boxplot(grouped_df[[response_var]] ~ factor(grouped_df$predictor_rank), 
          ylab = response_var, 
          xlab = paste(c('Group (', predictor_var, ')'),collapse=""))
  
  # Write summary statistics to table
  if (!is.null(stats_table) && stats_table != 'NA') {
    
    # Get summary stats from groups
    arc.progress_label('Calculating summary statistics for each group...')
    arc.progress_pos(50)
    
    summary_funcs <- c('mean', 'sd')
    summary_df <- grouped_df %>%
      summarize_at(vars(response_var, predictor_var), funs_(summary_funcs, args=list(na.rm = TRUE))) %>% data.frame()
    
    arc.write(stats_table, summary_df)
  }

  # Perform ANOVA test
  arc.progress_label('Performing ANOVA...')
  arc.progress_pos(75)
  
  anova_fit <- aov(grouped_df[[response_var]] ~ factor(grouped_df$predictor_rank))
  anova_results <- summary(anova_fit)
  
  print(anova_results)

  # Write ANOVA results to table
  if (!is.null(anova_table) && anova_table != 'NA') {
    
    # Change name of grouping variable label in output, and write to data frame
    rownames(anova_results[[1]])[1] = predictor_var
    anova_df <- data.frame(anova_results[[1]])
    
    arc.write(anova_table, anova_df)
  }

  arc.progress_label('Done')
  arc.progress_pos(100)
  
  return(out_params)

}

# Install and load all packages provided from a character vector
load_pkgs <- function(pkgs) {
  invisible(lapply(pkgs, function(pkg) {
    if(!requireNamespace(pkg, quietly = TRUE))
      install.packages(pkg, quiet = TRUE, repos = "https://cloud.r-project.org")
    suppressWarnings(suppressMessages(require(pkg, character.only = TRUE)))
  }))
}

# Function to test in standalone R:
test_tool <- function(){
  
  # Load the arcgisbinding package...
  library(arcgisbinding)
  arc.check_product()
  
  temp <- getwd() # Substitute this with another location on disk if you like...
  out_dir = file.path(temp, "data", "ANOVASamples")
  
  if (dir.exists(out_dir))
  {
    unlink(out_dir, recursive=TRUE)
    Sys.sleep(1)  # Wait one second, or the dir.create() method may fail...
  }
  dir.create(out_dir)
  
  
  results <- tool_exec(
    list(
      in_data = "data/census/CSDsJoined.lyr",
      response_var = "income2016csd.hh_low_income_percent_t",
      predictor_var = "income2016csd.income_median_t",
      predictor_groups = 5
    ),
    list(
      stats_table = file.path(out_dir, "summary_stats.csv"),
      anova_table = file.path(out_dir, "anvoa_results.csv")
    )
  )
  
  message(paste(c("Results saved to: ",out_dir), collapse=""))
}

# Run the test_tool() function:
# test_tool()
