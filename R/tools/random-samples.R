# A tool to use the spsample method to generate points, and optionally
# use deldir/SPdraw packages to generate voronoi polygons

tool_exec <- function(in_params, out_params) {
  
  boundary <- in_params$boundary
  num_samples <- in_params$num_samples
  sources_path <- in_params$sources_path
  points_path <- out_params$points_path
  polygons_path <- out_params$polygons_path
  
  if (!is.null(sources_path) && sources_path != "NA")
  {
    source(file.path(sources_path, "helper-functions.R"))
  }
  
  arc.progress_label('Loading packages...')
  arc.progress_pos(0)
  load_pkgs(c("sp", "dplyr"))
  
  # Check if voronoi polygons should be created for the generated random points:
  create_polygons <- !is.null(polygons_path) && polygons_path != "NA"
  
  # Determine how many steps our code will execute, and define a function that
  # return a percentage for a given percent that we can use for the progress bar
  progress_steps <- if (create_polygons) 3 else 4
  progress <- function(step) { return(step/progress_steps*100) }
  
  # Load the input boundary feature class:
  arc.progress_label(paste(c('Loading boundary feature class:', boundary), collapse=" "))
  arc.progress_pos(progress(1))
  bnd <- arc.open(boundary)
  
  # Get the output spatial reference from arc.env()...otherwise, default to the input boundary reference. 
  spatial_ref <- arc.env()$outputCoordinateSystem
  if (is.null(spatial_ref)) {
    warning(paste(c(
      "No output spatial reference in GP environment - defaulting to spatial reference of ",
      boundary)))
    spatial_ref <- bnd@shapeinfo$WKT
  }
  
  bnd_sp <- arc.select(bnd, sr = spatial_ref) %>% arc.data2sp()
  
  # Generate points with the spsample() function from the sp package:
  arc.progress_label(paste(c('Generating', as.character(num_samples), "sample points..."), collapse=" "))
  arc.progress_pos(progress(2))
  
  sample <- spsample(bnd_sp, n=num_samples, type="random")
  sample_sp <- SpatialPointsDataFrame(sample, data=data.frame(id=rep(1:length(sample))))
  sample_df <- arc.sp2data(sample_sp)
  
  arc.write(points_path, sample_df, shape_info=list(type="Point", WKT=spatial_ref))
  if (create_polygons)
  {
    
    arc.progress_label(paste(c("Generating polygons..."), collapse=" "))
    arc.progress_pos(progress(3))
    
    load_pkgs("SDraw")
    
    vor <- voronoi.polygons(sample_sp, bnd_sp)  # Generate Voronoi polygons
    vor_df <- arc.sp2data(vor)
    vor_df$id <- sample_df$id
    
    arc.write(polygons_path, vor_df, shape_info=list(type="Polygon", WKT=spatial_ref))
  }
  
  message("Done!")
  
  # Return results.
  return(out_params)
  
}

test_tool <- function() {
  
  # Load the arcgisbinding package
  library(arcgisbinding)
  arc.check_product()
  
  temp = getwd() # Substitute this with another location on disk if you like...
  out_dir = file.path(temp, "data", "RandomSamples")
  
  if (dir.exists(out_dir))
  {
    unlink(out_dir, recursive=TRUE)
    Sys.sleep(1)  # Wait one second, or the dir.create() method may fail...
  }
  dir.create(out_dir)
  
  
  tool_exec(
    list(  # in_params:
      boundary = "data/toronto/neighbourhoods.shp",
      num_samples = 200,
      sources_path = "R"
    ),
    list(  # out_params:
      points_path = file.path(out_dir, "points.shp"),
      polygons_path = file.path(out_dir, "polygons.shp")
    )
  )
  message(paste(c("Results saved to: ",out_dir), collapse=""))
  
}

# The following code will test the tool_exec() function if 'arc.env()$workspace' is not defined.
# Accessing arc.env() may fail in 32-bit / ArcMap.  A variation is implemented in the
# 'random-samples-arcmap.R' script that will work with ArcMap (and is pre-configured in the
# r-arcgis-arcmap.tbx included with the tutorial files) 
if (is.null(arc.env()$workspace)) {
  test_tool()
}

