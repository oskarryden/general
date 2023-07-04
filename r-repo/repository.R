# Purpose: make a CRAN-style repository of downloaded packages
# Definitions: The {total} packages are the main packages and their dependencies, which are downloaded to a directory defined by {download_dir}.

# function: make_repository
make_repository <- function(vp, repo_type = "source") {
        
    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    # Add class
    vp <- subclass_has_repository(vp)
    # Check the `repo_type` argument.
    repo_type <- match.arg(arg = repo_type, choices = c("source", "win.binary", "mac.binary"))
    if (!repo_type == "source") {
        stop("Only source repositories are supported at this time.")
    }

    # Create the repository.
    tryCatch({
        message(sprintf("Creating a CRAN-style repository [%s].", repo_type))

        # Create the repository directory.
        .repo <- gsub(
            pattern = "vpdir",
            replacement = "vprepo",
            fixed = TRUE,
            x = vp$settings$destination)

        # Decide extenions for the packages area
        .packages_area <- switch(
            repo_type,
            source = file.path("R", "src", "contrib"),
            win.binary = file.path("bin", "windows", "contrib",
                sprintf("%s.%s", R.version$major, substr(R.version$minor, 1,1))),
            mac.binary = file.path("bin", "macosx", "contrib",
                sprintf("%s.%s", R.version$major, substr(R.version$minor, 1,1)))
            )

        if (dir.exists(.repo)) {
            stop(sprintf("This exact directory already exists: %s", .repo))
        }
        dir.create(
            path = file.path(.repo, .packages_area),
            recursive = TRUE,
            showWarnings = TRUE)
        message(sprintf("Created the repository directory: %s", .repo))

        # Copy packages to the repository directory.
        message("Moving packages to the packages area.")
        file.copy(
            from = list.files(vp$settings$destination, full.names = TRUE),
            to = file.path(.repo, .packages_area),
            recursive = FALSE,
            overwrite = TRUE)
        message("Finished moving packages to the packages area.")

        # Create the index files using {tools::write_PACKAGES()}
        n_written <- tools::write_PACKAGES(
            dir = file.path(.repo, .packages_area),
            type = repo_type,
            latestOnly = TRUE,
            addFiles = TRUE,
            validate = TRUE,
            verbose = TRUE)
        
        message(sprintf("Repository index contains [%i] packges.", n_written))
        message(sprintf("Expected [%i] packages.", length(vp$pruned_pcks)))
        message(sprintf("Difference: [%i] packages.", length(vp$pruned_pcks) - n_written))

    },  error = function(e) {
            message("An error occurred. Removing the directory.")
            unlink(file.path(.repo), recursive = TRUE)
            stop(e)
    })

    # Store .repo and .packages_area in vp object
    vp$settings$repository_destination <- .repo
    vp$settings$packages_area <- .packages_area

    # Return the {vp} object.
    stopifnot(check_vp_object(vp))
    message("Finished creating the repository.")
    message(sprintf("Repository location: [%s].", vp$settings$repository_destination))
    return(vp)
}


# Downstream packages
# downstream_packages <- c("dplyr", "data.table", "DBI")
# # Packages in {lib.loc} that recursively {dependencies} on {pkgs}
# tools::dependsOnPkgs(
#     pkgs = downstream_packages, 
#     dependencies = c("Enhances"),
#     recursive = TRUE,
#     lib.loc = .libPaths()[1])


