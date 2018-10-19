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
    load_pkgs("sp")
    
    # Check if voronoi polygons should be created for the generated random points:
    create_polygons <- !is.null(polygons_path) && polygons_path != "NA"
  
    # Load the input boundary feature class as a spatial data frame:
    arc.progress_label(paste(c('Loading boundary feature class:', boundary), collapse=" "))
    arc.progress_pos(25)
    bnd <- arc.open(boundary)
    bnd_df <- arc.select(bnd)
    bnd_sp <- arc.data2sp(bnd_df)
  
    # Generate points with the spsample() function from the sp package and convert to a spatial data frame:
    arc.progress_label(paste(c('Generating', as.character(num_samples), "sample points..."), collapse=" "))
    arc.progress_pos(50)
    sample <- spsample(bnd_sp, n=num_samples, type = "random")
    sample_sp <- SpatialPointsDataFrame(sample, data=data.frame(id=rep(1:length(sample))))

    # Write the sample points to the output path specified in out_params:
    arc.write(points_path, sample_sp, overwrite = TRUE)

    # If the user chose to generate voronoi polygons:
    if (create_polygons)
    {
    
        arc.progress_label(paste(c("Generating polygons..."), collapse=" "))
        arc.progress_pos(75)

        load_pkgs("SDraw")

        # Generate Voronoi polygons:
        vor_sp <- voronoi.polygons(sample_sp, bnd_sp)
        vor_sp$id <- sample_sp$id

        # Write the sample points to the output path specified in out_params:
        arc.write(polygons_path, vor_sp, overwrite = TRUE)
    }
  
    message("Done!")
  
    # Return results.
    return(out_params)
  
}

test_tool <- function() {
  
    # Load the arcgisbinding package
    library(arcgisbinding)
    arc.check_product()

    out_gdb = file.path(getwd(), "data", "results.gdb")

    # Define test input parameters
    in_params <- list(
        boundary = "data/toronto/neighbourhoods.shp",
        num_samples = 200,
        sources_path = 'R'
    )

    # Define test output parameters
    out_params <- list(
        points_path = file.path(out_gdb, "random_points"),
        polygons_path = file.path(out_gdb, "random_polygons")
    )

    # Execute the tool function:
    tool_exec(in_params, out_params)

    message(paste(c("Results saved to: ", out_gdb), collapse=""))
 
}

# If running as a stand-alone script, test the tool:
if (!exists("arc.env") || is.null(arc.env()$workspace)) {
  test_tool()
}

