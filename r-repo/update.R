# Purpose: update packages.

# Function that update the {.vprepo} for specified packages
update_repository <- function(vp, packages) {
    
    # Check the vp object.
    check_vp_object(vp)
    # Check for repository.
    stopifnot(check_is_repository(vp))
    # Check the package_name.
    check_package_vector(packages)
    # Check if the package_name is in the vp object.
    if (!all(packages %in% vp$main)) {
        message("At least one package is not in the vp object.")
    }

    # Get the available packages.
    available_packages <- get_available_packages()
    # Check if the package_name is in the available_packages.
    if (!all(packages %in% available_packages$Package)) {
        stop("At least one package is not in the available_packages.")
    }

    # Subset
    available_packages <- available_packages[packages %in% available_packages$Package, ]
    if (!nrow(available_packages) > 0) {
        stop("No specified packages are available.")
    }

    # Get the current version of packages

    # Get the new version of packages

    # Update the repository with the new version of packages and possible dependencies

    # Update the vp

}


# function to check if there are later versions to install
 