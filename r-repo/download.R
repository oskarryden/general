# Purpose: Download the {total} packages as defined by the {vp} object to a directory defined by {download_dir}, which should be a path to non-existent directory.
# Definitions: The {total} packages are the main packages and their dependencies.

# function: download_packages
download_packages <- function(vp, package_type) {
    
    # Add class
    vp <- timestamp_class(add_class(vp, "vp_download"))
    # Create the download directory.
    directory_path <- create_dir(vp)

    tryCatch({
        # Get the package type
        if (missing(package_type)) {
            package_type <- getOption("pkgType")
        }

        vp$settings$R$package_type <- match.arg(
            arg = package_type,
            choices = c("source", "win.binary", "mac.binary")) 
            
        # Prune the vp object for base R packages
        vp <- prune_total_packages(vp, expr = get_base_r_packages())

        # Summarise the download
        vp <- summarise_download(vp)
        
        # Download the packages.
        stopifnot(check_before_download(vp))
        cat("\n")
        get_packages(vp)
        message(sprintf("Downloaded [%i] packages.", count_packages(vp, "pruned")))
        message(sprintf("Repositories used: [%s].", toString(vp$settings$R$repositories)))
        message(sprintf("Directory used: [%s].", vp$summary$download$directory))
    
    },  error = function(e) {
            unlink(directory_path, recursive = TRUE)
            message("Removing the directory.")
            stop(e)
    })
    # Return
    return(vp)
}

# Wrapper for {utils::download.packages}
get_packages <- function(vp, ...) {

    # Form args
    do_call_args <- list(
        pkgs = vp$packages$pruned,
        destdir = vp$summary$download$directory,
        type = vp$settings$R$package_type,
        repos = vp$settings$R$repositories,
        method = "libcurl"
        )
    
    if (...length() > 0 & !is.null(...names())) {
    # Expand dots
        dots <- list(...)
        if (length(dots) != length(names(dots))) {
            stop("Unnamed arguments in ...")
        }
    # Replace if dots \in deps_call_args
        for (nm in names(do_call_args)) {
            if (nm %in% names(dots)) {
                do_call_args[[nm]] <- dots[[nm]]
            }
        }
    }

    # Download
    do.call(utils::download.packages, do_call_args)
    # Return
    return(vp)
}

# function: create_dir
# note: strict function that is quite decisive in what it does.
create_dir <- function(vp) {

    if (has_class(vp, "vp_updated")) {
        dir <- vp$summary$download$directory
        stopifnot(dir.exists(dir))
        return(dir)
    }
    
    dir <- file.path("~", paste0("vpdir-", Sys.Date()))
    if (dir.exists(dir)) {
        stop(sprintf("This exact directory already exists: %s", dir))
    }

    dir.create(dir, recursive = FALSE, showWarnings = TRUE)

    return(dir)
}

prune_total_packages <- function(vp, expr) {

    expr <- substitute(expr)
    stopifnot(is.call(expr))

    vp$packages$pruned <- vp$packages$total[!vp$packages$total %in% eval(expr)]
    if (length(vp$packages$pruned) == 0) {
        stop("No packages left after pruning.")
    }

    return(vp)
}

summarise_download <- function(vp) {
    
    vp$summary$download$n_download <- count_packages(vp, "pruned")
    
    if (!has_class(vp, "vp_updated")) {
        vp$summary$download$directory <- get(
            x = "directory_path",
            envir = as.environment(parent.frame()) )
    }

    return(vp)
}


