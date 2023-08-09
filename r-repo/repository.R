# Purpose: make a CRAN-style repository of downloaded packages
# Definitions: The {total} packages are the main packages and their dependencies, which are downloaded to a directory defined by {download_dir}.

# function: make_repository
make_repository <- function(vp) {
        
    # Check repo
    repo_type <- match.arg(
        arg = vp$settings$R$package_type,
        choices = c("source", "win.binary", "mac.binary"))
    if (!repo_type == "source") {
        stop("Only source repositories are supported at this time.")
    }

    # Create the repository.
    tryCatch({

        if (!has_class(vp, "vp_updated")) {
            
            # Add class
            vp <- timestamp_class(add_class(vp, "vp_repository"))
            message("Creating a CRAN-style repository.")
            
            # Create the repository directory.
            repo <- gsub(
                pattern = "vpdir",
                replacement = "vprepo",
                fixed = TRUE,
                x = vp$summary$download$directory)

            # Decide extensions for the packages area
            packages_area <- switch(repo_type,
                source = file.path("R", "src", "contrib"),
                win.binary = file.path("bin", "windows", "contrib",
                    sprintf("%s.%s", R.version$major, substr(R.version$minor, 1, 1))),
                mac.binary = file.path("bin", "macosx", "contrib",
                    sprintf("%s.%s", R.version$major, substr(R.version$minor, 1, 1)))
                )

            if (dir.exists(repo)) {
                stop(sprintf("Directory already exists: [%s]", repo))
            }
            dir.create(
                path = file.path(repo, packages_area),
                recursive = TRUE,
                showWarnings = TRUE)
            message(sprintf("Repository created: [%s]", repo))

        }
        
        if (has_class(vp, "vp_updated")) {
            repo <- vp$summary$repository$repo
            packages_area <-  vp$summary$repository$packages_area
            message(sprintf("Using existing repository: [%s].", repo))
        }

        # Repository
        repo_packages_area <- file.path(repo, packages_area)

        # Copy packages to the repository directory.
        message(sprintf("Packages are copied from: [%s].",
            vp$summary$download$directory))
        file.copy(
            from = list.files(vp$summary$download$directory, full.names = TRUE),
            to = repo_packages_area,
            recursive = FALSE,
            overwrite = FALSE)

        # Create the index files using {tools::write_PACKAGES()}
        n_written <- tools::write_PACKAGES(
            dir = repo_packages_area,
            type = repo_type,
            latestOnly = TRUE,
            addFiles = TRUE,
            validate = TRUE,
            verbose = TRUE)
        
        message(
            sprintf("Repository contains [%i] packages, expected number is: [%i]",
                n_written, vp$summary$download$n_download))

    }, error = function(e) {
            message("An error occurred. Removing the directory.")
            unlink(file.path(repo), recursive = TRUE)
            stop(e)
    })

    # summarise the repository
    vp <- summarise_repository(vp)

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


