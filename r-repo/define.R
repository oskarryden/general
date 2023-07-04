# Purpose: Functions to define main external R packages for project
# Definitions: `Main packages` are those packages that define the starting node for tracking dependencies. `External` are those packages that are reachable via the CRAN repository (TODO: Add other repositories?) Thus, 'internal' packages  are those packages that are created and maintained by the project itself.

# function: add_main_packages
add_main_packages <- function(vp, packages, repos) {

    # Check the `vp` object.
    stopifnot(check_vp_object(vp))

    if (missing(packages)) {
        stop("No packages specified.")
    } else {
        check_packages_vector(packages)
        message(sprintf("Adding [%s] packages", toString(packages)))
    }

    # Add packages to main slot
    vp$main <- sort(append(x = vp$main, values = packages))

    # Add packages to total slot
    vp$total <- sort(append(x = vp$total, values = packages))

    # Return updated object
    stopifnot(check_vp_object(vp))
    message("Finished adding main packages.")
    return(vp)
}

# function: get_available_packages
get_available_packages <- function() {

    # Check filters
    if (is.null(getOption("available_packages_filters"))) {
        warning("No filters for packages are set.")
        message("Consider setting filters using `options(available_packages_filters = c(\"R_version\", \"OS_type\", \"subarch\", \"CRAN\", \"duplicates\"))` before running `get_available_packages`.")
    } else {
        message("Filters for packages are set.")
        message(sprintf("Filters: [%s].", toString(getOption("available_packages_filters"))))
    }

    stopifnot(`Specify repos through options`= !is.null(getOption("repos")))
    stopifnot(`There should be at least one repo`= length(getOption("repos")) > 0)

    # Get all packages from {repo_name} available in {repos} with {filters}
    message(sprintf("Repos used: [%s].", toString(getOption("repos"))))
    cran_packages <- utils::available.packages(
        repos = getOption("repos"),
        filters = getOption("available_packages_filters")
        )

    # Functionality for {add_main_packages}
    call_stack <- sys.calls()
    # Get the function that called get_available_packages
    calling_function <- substitute(deparse(call_stack[[length(call_stack) - 1]][[1]]))

    if (calling_function == "check_packages_vector") {
        return(row.names(cran_packages))
    }
    
    return(cran_packages)
}




