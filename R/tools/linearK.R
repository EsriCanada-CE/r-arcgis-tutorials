# R-ArcGIS Linear-K Tool

tool_exec = function(in_params, out_params) {

  # Load required packages
  arc.progress_label('Loading required R packages...')
  arc.progress_pos(0)
  pkgs = c('sp', 'dplyr', 'maptools', 'spatstat')
  load_pkgs(pkgs)

  # Get parameters
  in_points = in_params$in_points
  in_lines = in_params$in_lines
  num_sims = in_params$num_sims
  out_table = out_params$out_table
  out_plot_png = out_params$out_plot_png
  
  arc.progress_label('Reading data...')
  arc.progress_pos(25)
  
  pts_sp <- arc.open(in_points) %>% arc.select() %>% arc.data2sp()
  lines_sp <- arc.open(in_lines) %>% arc.select() %>% arc.data2sp()
  
  lines_linnet <- as.linnet(lines_sp)
  pts_ppp <- as.ppp(pts_sp)
  pts_lpp <- lpp(pts_ppp, L=lines_linnet)
  
  if (num_sims > 0)
  {
    arc.progress_label(paste(c('Performing Linear-K analysis with ',num_sims,' simulations.'), collapse=""))
    arc.progress_pos(50)
    
    lk <- envelope(pts_lpp, fun=linearK, nsim=num_sims)
  }
  else
  {
    arc.progress_label('Performing Linear-K with no simulations.')
    arc.progress_pos(75)
    
    lk <- linearK(pts_lpp)
  }
  
  png(out_plot_png)
  plot(lk)
  dev.off()
  
  arc.write(out_table, lk)

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
  
  # Load the arcgisbinding package
  library(arcgisbinding)
  arc.check_product()
  
  temp = getwd() # Substitute this with another location on disk if you like...
  out_dir = file.path(temp, "LinearKSamples")
  
  if (dir.exists(out_dir))
  {
    unlink(out_dir, recursive=TRUE)
    Sys.sleep(1)  # Wait one second, or the dir.create() method may fail...
  }
  dir.create(out_dir)
  
  
  tool_exec(
    list(
      in_points = "data/toronto/KSI_byc.shp",
      in_lines = "data/toronto/CENTRELINE_WGS84_byc.shp",
      num_sims = 0
    ),
    list(
      out_table = file.path(out_dir, "linearKresults.csv"),
      out_plot_png = file.path(out_dir, "linearKresults.png")
    )
  )
  
  message(paste(c("Results saved to: ",out_dir), collapse=""))
}

# If running as a stand-alone script, test the tool:
if (!exists("arc.env") || is.null(arc.env()$workspace)) {
  test_tool()
}
