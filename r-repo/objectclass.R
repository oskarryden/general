# function: make_vp_object 
make_vp_object <- function() {
    message("Initiating a 'vpackages' object.")
    init <- list()
    
    # Packages
    packages <- list()
    class(packages) <- append(x=class(packages), values="vp_packages")
    packages$main <- vector(mode = "character", length = 0)
    packages$deps <- list()
    packages$total <- vector(mode = "character", length = 0)
    #packages$available_packages <- get_available_packages()
    init$packages <- packages

    # Adding information about the R configuration
    settings <- list()
    class(settings) <- append(x=class(settings), values="vp_settings")
    # About R
    settings$R <- list()
    settings$R$r_version <- getRversion()
    settings$R$base_r <- get_base_r_packages()
    settings$R$repositories <- getOption("repos")
    settings$R$libpaths <- .libPaths()
    # About the system
    settings$system <- list()
    settings$system$info <- Sys.info()[c("sysname", "release", "version", "machine", "user", "nodename")]
    # General
    settings$general <- list()
    settings$general$start_date <- Sys.Date()
    # Add settings
    init$settings <- settings

    # Add summary
    summary <- list()
    class(summary) <- append(x=class(summary), values="vp_summary")
    summary$packages <- list()
    summary$download <- list()
    summary$repository <- list()
    init$summary <- summary

    # Add class
    out <- class_vp(init)
    stopifnot(check_vp_object(out))
    message("Returning a vpackages object.")
    return(out)
}

# functions to add classes to the vpect for each stage of the process
class_vp <- function(vp) {
    stopifnot(!"vpackages" %in% class(vp))
    class(vp) <- append(x=class(vp), values="vpackages")
    return(vp)
}

subclass_vp <- function(vp, sc) {
    sc <- switch(sc,
        main = "vp_main",
        dependencies = "vp_dependencies",
        download = "vp_download",
        repository = "vp_repository",
        updated = "vp_updated")
    
    if (sc == "vp_updated") {
        stopifnot("vp_repository" %in% class(vp))
        class(vp) <- append(x=class(vp), values=sc)
        return(vp)
    }

    stopifnot("vpackages" %in% class(vp) && !(sc %in% class(vp)))
    class(vp) <- append(x=class(vp), values=sc)
    
    return(vp)
}
