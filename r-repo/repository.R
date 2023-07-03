# Purpose: make a CRAN-style repository of downloaded packages
# Definitions: The {total} packages are the main packages and their dependencies, which are downloaded to a directory defined by {download_dir}.

# function: make_repository
make_repository <- function(vp, repository_dir) {
        
    # Check the `vp` object.
    stopifnot(check_vp_object(vp))
    
    # Create the repository.
    tryCatch({
        message("Creating the repository.")

        # Create the repository directory.

        # Create the index files
        tools::write_PACKAGES()


    },  error = function(e) {
            message("An error occurred. Removing the directory.")
            unlink(...)
            stop(e)
    })
    
    # Return the {vp} object.
    return(vp)
}




# function: read_vp_object
# Purpose: read a {vp} object from a file, which are stored as .rds files.
read_vp_object <- function(path) {
    vp <- check_vp_object(readRDS(path))
    return(vp)
}

# ------------------------------------------------------------------------------
# Downstream packages
# downstream_packages <- c("dplyr", "data.table", "DBI")
# # Packages in {lib.loc} that recursively {dependencies} on {pkgs}
# tools::dependsOnPkgs(
#     pkgs = downstream_packages, 
#     dependencies = c("Enhances"),
#     recursive = TRUE,
#     lib.loc = .libPaths()[1])


