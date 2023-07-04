# Purpose: functions that defines dependencies for main packages.
# Definitions: Dependencies are defined as those packages that are required for the main packages to function, as given by the package authors of the main package. This includes both `Depends` and `Imports` packages. The chain of dependencies is followed recursively, meaning that the dependencies of the dependencies are also included. The `Suggests` packages are not included in the dependencies. The reverse dependencies, which are packages that depend on the main packages, are also not included in the dependencies. That is, the purpose is to capture the dependencies of the main packages, not the reverse dependencies, aka the upstream dependencies.

# function: add_main_dependencies
add_main_dependencies <- function(vp, deps_type = c("Depends","Imports")) {

    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    # Add class 
    vp <- subclass_has_dependencies(vp)
    # Check the `packages` argument.
    packages <- vp[["main"]]
    stopifnot(check_packages_vector(packages))
    # Check the `db` argument.
    db <- vp[["available_packages"]]
    stopifnot(check_available_packages(db))
    # Check the `dependency_type` argument.
    deps_type <- match.arg(
        arg = deps_type,
        choices = c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances"),
        several.ok = TRUE)
    # Define the main dependencies as {deps} from {packages} that can be found in {db}.
    deps <- tools::package_dependencies(
        packages = packages, 
        db = db,
        which = deps_type,
        recursive = TRUE,
        reverse = FALSE
        )   
    message(sprintf("Found [%i] net dependencies.", length(unlist(deps))))

    # Check the {deps} object.
    stopifnot(check_deps_object(deps))

    # Add/replace the dependencies to the `vp` object.
    vp[["deps"]] <- deps

    # Update the total packages
    vp[["total"]] <- update_total_packages(vp)

    # Return the `vp` object.
    stopifnot(check_vp_object(vp))
    return(vp)
}

update_total_packages <- function(vp) {
    # Update the total packages
    total <- sort(unique(c(vp[["main"]], unlist(unname(vp[["deps"]])))))
    return(total)
}