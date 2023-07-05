# Purpose: update packages.

# update directory
update_directory <- function(vp, packages) {
    
    # Check the vp object.
    check_vp_object(vp)
    # Check for directory.
    stopifnot(assert_class(vp, "downloaded"))
    # Check for repository.
    stopifnot(assert_class(vp, "repository"))
    vp <- timestamp_vp_class(subclass_vp(vp, "updated"))

    if (missing(packages)) {
        packages <- vp$packages$pruned
        message("Looking for updates among the previously downloaded packages.")
    }
    # Check the package_name.
    # stopifnot(check_packages_vector(vp, "pruned"))
    # Subset the packages that are not up-to-date
    not_up_to_date <- find_updates(vp, packages)

    # No updates or new packages
    if (not_up_to_date == 0 & isTRUE(all(packages %in% vp$packages$pruned))) {
        return(vp)
    }

    # No updates but new packages
    if (not_up_to_date == 0 & !all(packages %in% vp$packages$main)) {
        vp$packages$main <- sort(unique(c(vp$main, packages)))

        vp <- get_dependencies(vp, type = vp$summary$packages$deps_type)

        return(vp)
    }

    # All packages in main
    if (!all(not_up_to_date[, "Packages"] %in% vp$packages$main)) {
        message("Extending main with at least one new package.")
        vp$packages$main <- sort(unique(c(vp$main, not_up_to_date[, "Packages"])))
    }

    # Replacing available packages


    # Update dependencies
    vp <- get_dependencies(vp, type = vp$summary$packages$deps_type)
    message(sprintf("Found [%i] net dependencies.", count_packages(vp, "deps")))

    # Check the {deps} object.
    stopifnot(check_deps_object(vp))

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
    
    orig <- vp$packages$available_packages
    orig <- orig[orig[, "Package"] %in% packages, ]
    new <- get_available_packages(vp)
    new <- new[new[, "Package"] %in% packages, ]

    merged <- merge(
        x = orig,
        y = new,
        by = "Package",
        all = TRUE,
        suffixes = c("_vp", "_repos"))

    # Compare MD5sums
    compare_merged <-
        merged[, grepl("^MD5sum_|^Package$|^Version_", colnames(merged))]
    
    # Check if the MD5sums and versions are the same
    compare_merged[["MD5sum_same"]] <-  
        compare_merged$MD5sum_vp  == compare_merged$MD5sum_repos
    compare_merged[["Version_same"]] <-
        base::package_version(compare_merged$Version_vp)  == base::package_version(compare_merged$Version_repos)

    if (isTRUE(all(c(compare_merged$MD5sum_same, compare_merged$Version_same)))) {
        message("All packages are up-to-date.")
        return(0)
    }

    # Subset the packages that are not up-to-date
    updates_available <-
        compare_merged[!compare_merged$MD5sum_same | is.na(compare_merged$MD5sum_same), "Packages"]

    orig_sub <- org[!org[, "Package"] %in% updates_available, ]
    out <- rbind(orig_sub, new)
    stopifnot(is.matrix(out))
    
    return(out)
}


# function to check if there are later versions to install
 