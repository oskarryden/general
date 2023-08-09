# function: create_vp_object 
create_vp_object <- function() {
    
    # Packages
    packages <- add_class(list(), "vp_packages")
    packages$main <- vector(mode = "character", length = 0)
    packages$deps <- list()
    packages$total <- vector(mode = "character", length = 0)

    # Adding information about the R configuration
    settings <- add_class(list(), "vp_settings")
    # R
    settings$R <- list()
    settings$R$r_version <- getRversion()
    settings$R$base_r <- get_base_r_packages()
    settings$R$repositories <- getOption("repos")
    settings$R$libpaths <- .libPaths()
    # System
    settings$system <- list()
    settings$system$info <- Sys.info()[c("sysname", "release", "version", "machine", "user", "nodename")]
    # General
    settings$general <- list()
    settings$general$start_date <- Sys.Date()
    
    # Summary
    summary <- add_class(list(), "vp_summary")
    summary$packages <- list()
    summary$download <- list()
    summary$repository <- list()
    
    # Out object
    out <- add_class(list(), "vpackages")
    out$packages <- packages
    out$settings <- settings
    out$summary <- summary
    
    return(out)
}