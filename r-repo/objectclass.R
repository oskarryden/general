# function: make_vp_object 
make_vp_object <- function() {
    message("Initiating a 'vpackages' object.")
    init <- list()

    # Adding slots for package names
    init$main <- vector(mode = "character", length = 0)
    init$deps <- list()
    init$total <- vector(mode = "character", length = 0)

    # Adding available packages
    init$available_packages <- get_available_packages()
    stopifnot(check_available_packages(init$available_packages))

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
    init$summary <- list()
    init$summary$packages <- list()
    init$summary$download <- list()
    init$summary$repository <- list()

    # Add class
    out <- class_vp(init)
    # Check out
    stopifnot(check_vp_object(out))
    message("Finished initiating a 'vpackages' object.")
    return(out)
}

# functions to add classes to the object for each stage of the process
class_vp <- function(obj) {
    stopifnot(!"vpackages" %in% class(obj))
    class(obj) <- append(x=class(obj), values="vpackages")
    return(obj)
}

subclass_has_main <- function(obj) { 
    stopifnot("vpackages" %in% class(obj) && !("vp_has_main" %in% class(obj)))
    class(obj) <- append(x=class(obj), values="vp_has_main")
    return(obj)
}
subclass_has_dependencies <- function(obj) {
    stopifnot("vpackages" %in% class(obj) && !("vp_has_dependencies" %in% class(obj)))
    class(obj) <- append(x=class(obj), values="vp_has_dependencies")
    return(obj)
}

subclass_is_downloaded <- function(obj) {
    stopifnot("vpackages" %in% class(obj) && !("vp_is_downloaded" %in% class(obj)))
    class(obj) <- append(x=class(obj), values="vp_is_downloaded")
    return(obj)
}

subclass_has_repository <- function(obj) {
    stopifnot("vpackages" %in% class(obj) && !("vp_has_repository" %in% class(obj)))
    class(obj) <- append(x=class(obj), values="vp_has_repository")
    return(obj)
}