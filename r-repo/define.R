# function: add_main_packages
add_main_packages <- function(vp, packages, ...) {

    # Add class
    vp <- timestamp_class(add_class(vp, "vp_main"))

    if (missing(packages)) {
        stop("No packages specified.")
    } else {
        message(sprintf("Main packages: [%s]", toString(packages)))
    }

    # Add packages to main slot
    vp <- update_packages_slot(vp, "main", updates = packages)
    # Add packages to total slot
    vp <- update_packages_slot(vp, "total")

    # Checks
    stopifnot(check_packages_vector(vp, "main"))
    stopifnot(check_packages_vector(vp, "total"))
    
    # Return
    return(vp)
}

