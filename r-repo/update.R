# Purpose: update packages.

# update repository
update_repository <- function(vp, packages) {
    
    stopifnot(check_vp_object(vp))
    stopifnot(assert_class(vp, "downloaded"))
    stopifnot(assert_class(vp, "repository"))
    vp <- timestamp_vp_class(subclass_vp(vp, "updated"))

    if (missing(packages)) {
        packages <- vp$packages$pruned
        message("Looking for updates among the previously downloaded packages.")
    }
    
    updates_outcome <- find_updates(vp, packages)

    # No updates found
    if (length(updates_outcome) == 1) {
        if (updates_outcome == 0) {
            message("No updates found.")
            return(vp)
        }
    }

    # Updates found
    message(sprintf("Found [%i] updates.", length(updates_outcome)))
    vp <- update_packages_slot(vp, "main", updates = updates_outcome)
    vp <- update_packages_slot(vp, "total")

    # Get new dependencies
    vp <- get_dependencies(
        vp,
        packages = updates_outcome,
        which = vp$summary$packages$deps_type)
    message(sprintf("Identified [%i] net dependencies.", count_packages(vp, "deps")))

    # Update the total packages
    vp <- update_packages_slot(vp, "total")
    
    # Summarise packages
    vp <- summarise_packages(vp)
    stopifnot(check_vp_object(vp))

    # Determine the packages to download
    vp <- prune_total_packages(vp, expr = get_base_r_packages())
    vp <- summarise_download(vp)

    # Download the packages
    updates_to_download <- subset_to_update(
        vp = vp,
        updates = updates_outcome,
        expr = get_base_r_packages())
    vp <- get_packages(vp, pkgs = updates_to_download)

    message(sprintf("Done with downloading [%i] updates.", length(updates_to_download)))
    message(sprintf("Packages are in [%s].", vp$summary$download$directory))

    # Update the repository
    vp <- make_repository(vp)

    # Return the `vp` object
    stopifnot(check_vp_object(vp))
    return(vp)
}

find_updates <- function(vp, packages) {
    
    # State variables to keep
    state_vars <- c("Package", "Version", "MD5sum")
    # State of the vp-repository
    current_state <- get_repository_PACKAGES(vp)[, state_vars]
    # State of the remote repositories
    remotes_state <- as.data.frame(get_available_packages(vp))[, state_vars]
    # Merge the states
    merged_states <- merge_states(current_state, remotes_state)
    # Filter the states
    filtered_states <- filter_state(merged_states, packages)
    # Compare the states
    compared_states <- compare_states(filtered_states)

    # Condition for no updates
    if (length(compared_states) == 1) {
        if (compared_states == 0) {
            return(0)
        } 
    }
    # Condition for possible updates
    if (nrow(compared_states) > 0) {
        out <- compared_states$Package
        return(out)
    }
}

get_repository_path <- function(vp) {
    x <- Filter(f = \(s) is.character(s),  x = vp$summary$repository)
    x <- x[names(x) %in% c("repo", "packages_area")]
    .call <- call("file.path")
    for (i in seq_along(x)) {
        .call[[i+1]] <- x[[i]] 
    }
    return(eval(.call))
}

get_repository_PACKAGES <- function(vp) {
    path <- get_repository_path(vp)
    out <- as.data.frame(readRDS(file.path(path, "PACKAGES.rds")))
    stopifnot(is.data.frame(out))
    return(out)
}

merge_states <- function(current, remotes) {
    # Merge the states
    merged_state <- merge(
        x = current,
        y = remotes,
        by = "Package",
        all = TRUE,
        suffixes = c("_current", "_remote"))
    stopifnot(is.data.frame(merged_state))
    return(merged_state)
}

filter_state <- function(state, packages) {
    # Filter the states
    filtered_state <- state[with(state, Package %in% packages & !is.na(Package)), ]
    stopifnot(is.data.frame(filtered_state))
    stopifnot(nrow(filtered_state) > 0)
    return(filtered_state)
}

compare_states <- function(state) {
    # Compare the states
    version <- compare_package_version(state)
    MD5 <- compare_package_MD5sum(state)

    if (length(version) > 1 & length(MD5) > 1) {
        out <- state[!version | !MD5, ]
        return(out)
    }

    if (version == 0 & MD5 == 0) {
        return(0)
    }

    message("Something went wrong.")
}

compare_package_MD5sum <- function(state) {
    state_identical <- with(state, identical(MD5sum_current, MD5sum_remote))

    if (state_identical) {
        return(0)
    }

    out <- compare_across_rows(
        df = state,
        expr = identical(MD5sum_current, MD5sum_remote)
        )
    
    return(out)
}

compare_package_version <- function(state) {
    state_identical <- with(state,
        identical(
            base::package_version(Version_current, strict = FALSE),
            base::package_version(Version_remote, strict = FALSE))
        )

    if (state_identical) {
        return(0)
    }

    out <- compare_across_rows(
        df = state,
        expr = identical(
            base::package_version(Version_current, strict = FALSE),
            base::package_version(Version_remote, strict = FALSE))
        )
    
    return(out)
}

subset_dependencies <- function(vp, package) {
    
    if (!package %in% names(vp$packages$deps)) {
        stop("Package does not exists as node in the dependency object.")
    }

    out <- vp$packages$deps[[package]]
    return(out)
}

subset_to_update <- function(vp, updates, expr) {

    expr <- substitute(expr); stopifnot(is.call(expr))

    deps <- unlist(sapply(updates, subset_dependencies, vp = vp))
    tot <- sort(unique(c(updates, deps)))
    out <- tot[!tot %in% eval(expr)]

    return(out)
}
# function to check if there are later versions to install


