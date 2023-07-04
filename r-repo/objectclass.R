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

    out <- init
    class(out) <- append(x = class(init), values = "vpackages")

    # Check the `out` object.
    stopifnot(check_vp_object(out))

    return(out)
}

