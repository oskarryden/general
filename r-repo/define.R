# function: add_main_packages
add_main_packages <- function(vp, packages) {

    # Check

    # Add class
    vp <- timestamp_class(add_class(vp, "vp_main"))

    if (missing(packages)) {
        stop("No packages specified.")
    } else {
        message(sprintf("Adding [%s] packages", toString(packages)))
    }

    # Add packages to main slot
    vp <- update_packages_slot(vp, "main", updates = packages)
    stopifnot(check_packages_vector(vp, "main"))

    # Add packages to total slot
    vp <- update_packages_slot(vp, "total")
    stopifnot(check_packages_vector(vp, "total"))

    # Return updated object
    message("Finished adding main packages.")
    return(vp)
}

