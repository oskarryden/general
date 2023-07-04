# Purpose: Define the object class for the `vpackages` object.
# Notes: This defines the object-classes that are used by `vpackages`.

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
    settings$r_version <- getRversion()
    settings$base_r <- get_base_r_packages()
    settings$system_info <- Sys.info()[c("sysname", "release", "version", "machine", "user", "nodename")]
    settings$repos <- getOption("repos")
    settings$lib_paths <- .libPaths()
    settings$start_date <- Sys.Date()
    
    # Place in init object
    init$settings <- settings

    # Add class
    out <- class_vp(init)

    # Check the `out` object.
    stopifnot(check_vp_object(out))

    return(out)
}


class_vp <- function(obj) {
    stopifnot(!"vpackages" %in% class(obj))
    class(obj) <- append(x=class(obj), values="vpackages")
    return(obj)
}

subclass_has_main <- function(obj) { 
    stopifnot("vpackages" %in% class(obj))
    class(obj) <- append(x=class(obj), values="vp_has_main")
    return(obj)
}
subclass_has_dependencies <- function(obj) {
    stopifnot("vp_has_main" %in% class(obj))
    class(obj) <- append(x=class(obj), values="vp_has_dependencies")
    return(obj)
}

subclass_downloaded <- function(obj) {
    stopifnot("vp_has_dependencies" %in% class(obj))
    class(obj) <- append(x=class(obj), values="vp_downloaded")
    return(obj)
}

subclass_has_repository <- function(obj) {
    stopifnot("vp_downloaded" %in% class(obj))
    class(obj) <- append(x=class(obj), values="vp_has_repository")
    return(obj)
}