# Purpose: make a CRAN-style repository of downloaded packages
# Definitions: The {total} packages are the main packages and their dependencies, which are downloaded to a directory defined by {download_dir}.

# function: make_repository
make_repository <- function(vp) {
        
    # Check vp
    stopifnot(check_vp_object(vp))

    # Check repo
    repo_type <- match.arg(
        arg = vp$settings$R$package_type,
        choices = c("source", "win.binary", "mac.binary"))
    if (!repo_type == "source") {
        stop("Only source repositories are supported at this time.")
    }

    # Create the repository.
    tryCatch({

        if (!"vp_updated" %in% class(vp)) {
            
            # Add class
            vp <- timestamp_vp_class(subclass_vp(vp, "repository"))
            message(sprintf("Creating a CRAN-style repository [%s].", repo_type))
            message(sprintf("Using packages directory: [%s].", vp$summary$download$directory))
            # Create the repository directory.
            repo <- gsub(
                pattern = "vpdir",
                replacement = "vprepo",
                fixed = TRUE,
                x = vp$summary$download$directory)

            # Decide extensions for the packages area
            packages_area <- switch(
                repo_type,
                source = file.path("R", "src", "contrib"),
                win.binary = file.path("bin", "windows", "contrib",
                    sprintf("%s.%s", R.version$major, substr(R.version$minor, 1, 1))),
                mac.binary = file.path("bin", "macosx", "contrib",
                    sprintf("%s.%s", R.version$major, substr(R.version$minor, 1, 1)))
                )

            if (dir.exists(repo)) {
                stop(sprintf("This exact directory already exists: %s", repo))
            }
            dir.create(
                path = file.path(repo, packages_area),
                recursive = TRUE,
                showWarnings = TRUE)
            message(sprintf("Created the repository directory: %s", repo))

        }
        
        if ("vp_updated" %in% class(vp)) {
            repo <- vp$summary$download$directory
            message(sprintf("Using the existing repository directory: [%s].", repo))
            repo <- vp$summary$repository$repo
            packages_area <-  vp$summary$repository$packages_area

        }

        # Copy packages to the repository directory.
        file.copy(
            from = list.files(vp$summary$download$directory, full.names = TRUE),
            to = file.path(repo, packages_area),
            recursive = FALSE,
            overwrite = FALSE)

        # Create the index files using {tools::write_PACKAGES()}
        n_written <- tools::write_PACKAGES(
            dir = file.path(repo, packages_area),
            type = repo_type,
            latestOnly = TRUE,
            addFiles = TRUE,
            validate = TRUE,
            verbose = TRUE)
        
        message(sprintf("Repository index contains [%i] packages.", n_written))
        message(sprintf("Expected [%i] packages.", vp$summary$download$n_download))

    }, error = function(e) {
            message("An error occurred. Removing the directory.")
            unlink(file.path(repo), recursive = TRUE)
            stop(e)
    })

    # summarise the repository
    vp <- summarise_repository(vp)

    # Return the {vp} object.
    stopifnot(check_vp_object(vp))
    message(sprintf("Finished with repository: [%s].", repo))
    return(vp)
}

summarise_repository <- function(vp) {
    
        vp$summary$repository$n_packages <- get("n_written", envir = as.environment(parent.frame()))
        vp$summary$repository$repo <- get("repo", envir = as.environment(parent.frame()))
        vp$summary$repository$packages_area <- get("packages_area", envir = as.environment(parent.frame()))
        vp$summary$repository$repo_type <- vp$settings$R$package_type
    
        return(vp)
}

# Check health of repo using tools::update_PACKAGES()

# Downstream packages
# downstream_packages <- c("dplyr", "data.table", "DBI")
# # Packages in {lib.loc} that recursively {dependencies} on {pkgs}
# tools::dependsOnPkgs(
#     pkgs = downstream_packages, 
#     dependencies = c("Enhances"),
#     recursive = TRUE,
#     lib.loc = .libPaths()[1])


