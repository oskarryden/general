# function: add_main_packages
add_main_packages <- function(vp, packages, repos) {

    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    # Add class
    vp <- timestamp_vp_class(subclass_has_main(vp))

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
get_available_packages <- function(vp) {

    # Check filters
    if (is.null(getOption("available_packages_filters"))) {
        warning("No filters for packages are set.")
        message("Consider setting filters using `options(available_packages_filters = c(\"R_version\", \"OS_type\", \"subarch\", \"CRAN\", \"duplicates\"))` before running `get_available_packages`.")
    } else {
        message("Filters for packages are set.")
        message(sprintf("Filters: [%s].", toString(getOption("available_packages_filters"))))
    }

    # Check vp
    if (!missing(vp)) {
        stopifnot(check_vp_object(vp))
        message("Using the available packages from the vp object.")
        repos <- vp$settings$R$repositories
    } else {
        message("Using the available packages from the R repositories.")
        stopifnot(`Specify repos through options`= !is.null(getOption("repos")))
        repos <- getOption("repos")
    }

    # Get all packages from {repo_name} available in {repos} with {filters}
    message(sprintf("Repos used: [%s].", toString(repos)))
    cran_packages <- utils::available.packages(
        repos = repos,
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




