# function: add_main_packages
add_main_packages <- function(vp, packages, repos) {

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
    vp$packages$main <- sort(append(x = vp$packages$main, values = packages))

    # Add packages to total slot
    vp$packages$total <- sort(append(x = vp$packages$total, values = packages))

    # Return updated object
    stopifnot(check_vp_object(vp))
    check_packages_vector(vp, "main")
    message("Finished adding main packages.")
    return(vp)
}

