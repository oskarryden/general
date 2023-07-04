# Purpose: Download the {total} packages as defined by the {vp} object to a directory defined by {download_dir}, which should be a path to non-existent directory.
# Definitions: The {total} packages are the main packages and their dependencies.

# function: download_packages
download_packages <- function(vp, package_type) {
    
    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    # Add class
    vp <- subclass_downloaded(vp)
    # Create the download directory.
    directory_path <- create_dir()

    tryCatch({
        # Get the package type.
        if (missing(package_type)) {
            package_type <- getOption("pkgType")
        }
        match.arg(arg = package_type, choices = c("source", "win.binary", "mac.binary")) 
        vp$settings$package_type <- package_type
        
        # Populate the {vp} object with the paths to the downloaded packages.
        vp$settings$destination <- directory_path
    
        # Check the {vp} object.
        stopifnot(check_vp_object(vp))

        # Prune the {vp} object for base R packages.
        vp$pruned_pcks <- prune_base_r_packages(vp$total)

        # Download the packages.
        message(sprintf("Downloading [%i] 'pruned' packages.", length(vp$pruned_pcks)))
        message(sprintf("Package type: [%s].", vp$settings$package_type))
        message(sprintf("Repo(s): [%s].", toString(vp$settings$repos)))
        message(sprintf("Saving to [%s].", vp$settings$destination))
        utils::download.packages(
            pkgs = vp$pruned_pcks,
            destdir = vp$settings$destination,
            type = vp$settings$package_type,
            repos = vp$settings$repos,
            method = "libcurl"
        )
    },  error = function(e) {
            message("An error occurred. Removing the directory.")
            unlink(directory_path, recursive = TRUE)
            stop(e)
    })

    # Return the {vp} object.
    vp$settings$download_date <- Sys.Date()
    return(vp)
}

# function: create_dir
# note: strict function that is quite decisive in what it does.
create_dir <- function() {

    .dir <- file.path("~", paste0(".vpdir-", Sys.Date()))
    if (dir.exists(.dir)) {
        stop(sprintf("This exact directory already exists: %s", .dir))
    }
    dir.create(.dir, recursive = FALSE, showWarnings = TRUE)
    message(sprintf("Created directory: %s", .dir))
    return(.dir)
}
