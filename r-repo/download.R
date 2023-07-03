# Purpose: Download the {total} packages as defined by the {vp} object to a directory defined by {download_dir}, which should be a path to non-existent directory.
# Definitions: The {total} packages are the main packages and their dependencies.

# function: download_packages
download_packages <- function(vp, download_dir, recursive_dir = FALSE, package_type) {
    
    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    # Check the recursive argument.
    stopifnot(is.logical(recursive_dir))
    # Create the download directory.
    directory_path <- create_dir(download_dir, recursive = recursive_dir)

    tryCatch({
        # Get the package type.
        if (missing(package_type)) {
            package_type <- getOption("pkgType")
        }
        match.arg(arg = package_type, choices = c("source", "win.binary", "mac.binary")) 
        # Get repos

        # Populate the {vp} object with the paths to the downloaded packages.
        vp$destination <- directory_path
        vp$type <- package_type
        vp$repos <- getOption("repos")

        # Check the {vp} object.
        stopifnot(check_vp_object(vp))

        # Prune the {vp} object for base R packages.
        vp$pruned_pcks <- prune_base_r_packages(vp$total)

        # Download the packages.
        message(sprintf("Downloading [%i] 'pruned' packages.", length(vp$pruned_pcks)))
        message(sprintf("Package type: [%s].", vp$type))
        message(sprintf("Repo(s): [%s].", vp$repos))
        message(sprintf("Saving to [%s].", vp$destination))
        utils::download.packages(
            pkgs = vp$pruned_pcks,
            destdir = vp$destination,
            type = vp$type,
            repos = vp$repos,
            method = "libcurl"
        )
    },  error = function(e) {
            message("An error occurred. Removing the directory.")
            unlink(directory_path, recursive = TRUE)
            stop(e)
    })

    # Return the {vp} object.
    return(vp)
}

# function: create_dir
# note: places your directory automatically in your home directory; dns '~'.
create_dir <- function(x, recursive = FALSE) {

    if (!is.character(x)) {
        stop("x is not a character vector.")
    }
    if (length(x) != 1) {
        stop("x is not a length 1 character vector.")
    }
    if (x == "") {
        stop("x is an empty string.")
    }
    if (grepl("\\s+", x)) {
        stop("x contains one or more spaces.")
    }
    if (grepl("^~", x)) {
        stop("x starts with a tilde.")
        }

    # Create .dir
    .dir <- file.path("~", x)
    if (dir.exists(.dir)) {
        stop("The directory already exists.")
    }
    dir.create(.dir, recursive = recursive)
    return(.dir)
}
