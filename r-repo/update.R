# Purpose: update packages.

# update directory
update_directory <- function(vp, packages) {
    
    # Check the vp object.
    check_vp_object(vp)
    # Check for directory.
    stopifnot(assert_class(vp, "downloaded"))
    # Check for repository.
    stopifnot(assert_class(vp, "repository"))

    if (missing(packages)) {
        packages <- vp$pruned
        message("Looking for updates among the previously downloaded packages.")
    }
    # Check the package_name.
    check_packages_vector(packages)

    # Subset the packages that are not up-to-date
    not_up_to_date <- find_updates(vp, packages)

    if (not_up_to_date == 0) {
        message("All packages are up-to-date.")
        return(vp)
    }

    # Are any packages in not_up_to_date not in pruned?
    if (!all(not_up_to_date %in% vp$pruned)) {
        message("Some packages in not_up_to_date are not in main.")
        message("Adding them to main.")
        vp$main <- sort(unique(c(vp$main, not_up_to_date)))
    }

    # Replacing the available packages
    vp$available_packages <- get_available_packages()

    # Update dependencies
    deps <- get_dependencies(
        packages = vp$main,
        db = vp$available_packages,
        which = vp$summary$packages$deps_type,
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

    # Return the `vp` object
    stopifnot(check_vp_object(vp))

    # Download the packages
    vp <- download_packages(vp)

    # Update the vp
    vp <- make_repository(vp)

    # Return the `vp` object
    stopifnot(check_vp_object(vp))
    return(vp)
}

find_updates <- function(vp, packages) {
    
    vp_available <- vp$available_packages
    vp_available <- vp_available[vp_available[, "Package"] %in% packages, ]
    available_in_repos <- get_available_packages(vp)
    available_in_repos <- available_in_repos[available_in_repos[, "Package"] %in% packages, ]

    available_merged <- merge(
        x = vp_available,
        y = available_in_repos,
        by = "Package",
        all = TRUE,
        suffixes = c("_vp", "_repos"))

    # Compare MD5sums
    compare_merged <- available_merged[, grepl("^MD5sum_|^Package$|^Version_", names(available_merged))]
    
    # Check if the MD5sums and versions are the same
    compare_merged[["MD5sum_same"]] <- compare_merged$MD5sum_vp  == compare_merged$MD5sum_repos
    compare_merged[["Version_same"]] <- compare_merged$Version_vp  == compare_merged$Version_repos

    if (isTRUE(all(c(compare_merged$MD5sum_same, compare_merged$Version_same)))) {
        message("All packages are up-to-date.")
        return(0)
    }

    # Subset the packages that are not up-to-date
    updates_available <- compare_merged[!compare_merged$MD5sum_same | is.na(compare_merged$MD5sum_same), "Packages"]

    return(updates_available)
}


# function to check if there are later versions to install
 