# function: add_main_packages
add_main_packages <- function(vp, packages) {

    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    # Add class
    vp <- timestamp_vp_class(subclass_vp(vp, "main"))

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
    stopifnot(check_vp_object(vp))
    message("Finished adding main packages.")
    return(vp)
}

