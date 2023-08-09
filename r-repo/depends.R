# Purpose: functions that defines dependencies for main packages.
# Definitions: Dependencies are defined as those packages that are required for the main packages to function, as given by the package authors of the main package. This includes both `Depends` and `Imports` packages. The chain of dependencies is followed recursively, meaning that the dependencies of the dependencies are also included. The `Suggests` packages are not included in the dependencies. The reverse dependencies, which are packages that depend on the main packages, are also not included in the dependencies. That is, the purpose is to capture the dependencies of the main packages, not the reverse dependencies, aka the upstream dependencies.

# function: add_main_dependencies
add_main_dependencies <- function(vp, deps_type = c("Depends","Imports")) {

    vp <- timestamp_class(add_class(vp, "vp_dependencies"))
    # Check type of dependency
    deps_type <- match.arg(arg = deps_type, several.ok = TRUE, choices = c(
        "Depends",
        "Imports",
        "LinkingTo",
        "Suggests",
        "Enhances",
        "all",
        "most",
        "strong"))

    # Define the main dependencies
    vp <- get_dependencies(vp, which = deps_type)
    # Update the total packages
    vp <- update_packages_slot(vp, "total")
    # Summarise dependencies
    vp <- summarise_packages(vp)
    
    message(sprintf("Net dependencies: [%i]", count_packages(vp, "deps")))
    
    # return
    return(vp)
}

get_dependencies <- function(vp, ...) {

    # Initiate arguments to dependency search
    do_call_args <- list(
        packages = vp$packages$main,
        db = check_available_packages(get_available_packages(vp)),
        which = "most",
        recursive = TRUE,
        reverse = FALSE)
    
    # Expand dots
    if (...length() > 0 & !is.null(...names())) {
        dots <- list(...)
        if (length(dots) != length(names(dots))) {
            stop("Unnamed arguments in ...")
        }
    # Replace if ... \in deps_call_args
        for (nm in names(do_call_args)) {
            if (nm %in% names(dots)) {
                do_call_args[[nm]] <- dots[[nm]]
            }
        }
    }

    # Get dependencies
    deps_found <- do.call(tools::package_dependencies, do_call_args)
    vp <- update_packages_slot(vp, "deps", updates = deps_found)

    # Return
    return(vp)
}

summarise_packages <- function(vp) {

    vp$summary$packages$n_main <- count_packages(vp, "main")
    vp$summary$packages$n_deps_per_main <- setNames(unlist(lapply(vp$packages$deps, length)), names(vp$packages$deps))
    vp$summary$packages$n_net_deps <- sum(vp$summary$packages$n_deps_per_main)
    vp$summary$packages$n_total <- count_packages(vp, "total")

    if (!has_class(vp, "vp_updated")) {
        vp$summary$packages$deps_type <-
            get("deps_type", envir = as.environment(parent.frame()))
    }

    return(vp)
}