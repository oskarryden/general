# Purpose: Download the {total} packages as defined by the {vp} object to a directory defined by {download_dir}, which should be a path to non-existent directory.
# Definitions: The {total} packages are the main packages and their dependencies.

# function: download_packages
download_packages <- function(vp, package_type) {
    
    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    # Add class
    vp <- timestamp_vp_class(subclass_vp(vp, "download"))
    # Create the download directory.
    directory_path <- create_dir()

    tryCatch({
        # Get the package type
        if (missing(package_type)) {
            package_type <- getOption("pkgType")
        }
        vp$settings$R$package_type <- match.arg(arg = package_type, choices = c("source", "win.binary", "mac.binary")) 
            
        # Prune the vp object for base R packages
        vp <- prune_base_r_packages(vp)
        # Summarise the download
        vp <- summarise_download(vp)
        message(sprintf("Using package type: [%s].", vp$settings$R$package_type))
        message(sprintf("Downloading from: [%s].", toString(vp$settings$R$repositories)))
        # Download the packages.
        stopifnot(check_before_download(vp))
        get_packages(vp)
        message(sprintf("Done with downloading [%i] 'pruned' packages.", count_packages(vp, "pruned")))
        message(sprintf("Packages are in [%s].", vp$summary$download$directory))
    },  error = function(e) {
            message("An error occurred. Removing the directory.")
            unlink(directory_path, recursive = TRUE)
            stop(e)
    })
    # Return
    stopifnot(check_vp_object(vp))
    return(vp)
}

# Wrapper for {utils::download.packages}
get_packages <- function(vp) {
    utils::download.packages(
        pkgs = vp$packages$pruned,
        destdir = vp$summary$download$directory,
        type = vp$settings$R$package_type,
        repos = vp$settings$R$repositories,
        method = "libcurl")
}

# function: create_dir
# note: strict function that is quite decisive in what it does.
create_dir <- function() {

    dir <- file.path("~", paste0(".vpdir-", Sys.Date()))
    if (dir.exists(dir)) {
        stop(sprintf("This exact directory already exists: %s", dir))
    }
    dir.create(dir, recursive = FALSE, showWarnings = TRUE)
    message(sprintf("Created directory: %s", dir))
    return(dir)
}

prune_base_r_packages <- function(vp) {

    vp$packages$pruned <- vp$packages$total[!vp$packages$total %in% get_base_r_packages()]
    if (length(vp$packages$pruned) == 0) {
        stop("No packages left after pruning.")
    }
    return(vp)
}

summarise_download <- function(vp) {
    
    vp$summary$download$directory <- get("directory_path", envir = as.environment(parent.frame()) )
    vp$summary$download$n_download <- count_packages(vp, "pruned")

    return(vp)
}


