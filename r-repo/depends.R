# Purpose: functions that defines dependencies for main packages.
# Definitions: Dependencies are defined as those packages that are required for the main packages to function, as given by the package authors of the main package. This includes both `Depends` and `Imports` packages. The chain of dependencies is followed recursively, meaning that the dependencies of the dependencies are also included. The `Suggests` packages are not included in the dependencies. The reverse dependencies, which are packages that depend on the main packages, are also not included in the dependencies. That is, the purpose is to capture the dependencies of the main packages, not the reverse dependencies, aka the upstream dependencies.

# function: add_main_dependencies
add_main_dependencies <- function(vp, deps_type = c("Depends","Imports")) {

    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    # Add class 
    vp <- timestamp_vp_class(subclass_has_dependencies(vp))
    # Check main.
    stopifnot(check_packages_vector(vp[["main"]]))
    # Check the `db` argument.
    stopifnot(check_available_packages(vp[["available_packages"]]))
    # Check the `dependency_type` argument.
    deps_type <- match.arg(
        arg = deps_type,
        choices = c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances"),
        several.ok = TRUE)
    # Define the main dependencies as {deps} from {packages} that can be found in {db}.
    deps <- get_dependencies(
        packages = vp[["main"]],
        db = vp[["available_packages"]],
        which = deps_type,
        recursive = TRUE,
        reverse = FALSE) 
    message(sprintf("Found [%i] net dependencies.", length(unlist(deps))))

    # Check the {deps} object.
    stopifnot(check_deps_object(deps))

    # Add dependencies
    vp$deps <- deps

    # Update the total packages
    vp <- update_total_packages(vp)

    # Summarise dependencies
    vp <- summarise_packages(vp)

    # Return the `vp` object.
    stopifnot(check_vp_object(vp))
    return(vp)
}

get_dependencies <- function(...) {
    tools::package_dependencies(...) 
}


update_total_packages <- function(vp) {
    # Update the total packages
    vp$total <- sort(unique(c(vp$main, unlist(unname(vp$deps)))))
    return(vp)
}

summarise_packages <- function(vp) {

    stopifnot(check_vp_object(vp))

    vp$summary$packages$n_main <- length(vp$main)
    vp$summary$packages$n_deps_per_main <- setNames(unlist(lapply(vp$deps, length)), names(vp$deps))
    vp$summary$packages$n_net_deps <- sum(vp$summary$packages$n_deps_per_main)
    vp$summary$packages$n_total <- length(vp$total)
    vp$summary$packages$deps_type <- get("deps_type", envir = as.environment(parent.frame()))

    return(vp)
}