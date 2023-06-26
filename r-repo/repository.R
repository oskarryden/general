# vpackages
# References:
# https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Add_002don-packages

getOption("defaultPackages")

# ------------------------------------------------------------------------------
# R version
R.version; R.version.string

# Libs paths
.libPaths()

# Directory of libraries to search
lib_focus <- .libPaths()[1]

library(tools)
source(file.path("~", "code", "general", "r-repo", "helper.R"))
source(file.path("~", "code", "general", "r-repo", "files.R"))
source(file.path("~", "code", "general", "r-repo", "overhead.R"))

# Options for {available.packages}
options(available_packages_filters = c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))
getOption("available_packages_filters")

show_package_description(package = data.table, directory = lib_focus)

# TODO: a function that extracts all version-specific dependencies for a package

# ------------------------------------------------------------------------------
# Upstream packages


# TODO: Wrapper to get all available packages from a repository
# NOTE: Useful when there is a custom package repository
# All packages that are available in {repos}
cran_packages <- utils::available.packages(
    repos = options("repos")$repos[["CRAN"]],
    filters = getOption("available_packages_filters")
    )


# Decide main packages
main_packages <- c("RPostgreSQL", "data.table", "zoo")

# TODO: Wrapper to get all dependencies of a package
# Packages in {db} that {packages} depends on
# inspired by miniCRAN::PkgDep
main_dependencies <- tools::package_dependencies(
    packages = main_packages, 
    db = cran_packages,
    which = c("Depends", "Imports"),
    recursive = TRUE,
    reverse = FALSE
    )

dplyr_needed <- main_dependencies[[1]]
pth <- file.path(tempfile(), "dplyrdeps")
dir.create(pth, recursive = TRUE)

# Download all dependencies of {dplyr} to {pth}
# TODO: Function that downloads all dependencies of a package into a directory
# NOTE: Create a wrapper around download.packages that that also creates a proper file structure

create_package_directory <- function(pck, directory, pck_type, repository) {
    
    if ("list" %in% class(pck)) {
        if (length(names(pck)) > 0) {
            main_pck <- names(pck)
            pck <- c(main_pck, unname(pck))
        }
        pck <- unlist(pck)
    }
    stopifnot(`Nothing to download` = length(pck) > 0)
    message(sprintf("Packages to download: [%s].", toString(pck)))
    
    if (missing(directory)) {
        directory <- file.path(tempfile(), "temporary_directory")
    }
    message(sprintf("Repository: [%s].", directory))

    if (missing(pck_type)) {
        pck_type <- getOption("pkgType")
    }
    # Do we even want the binary packages?
    match.arg(pck_type, c("source", "win.binary", "mac.binary"))
    message(sprintf("Package type: [%s].", pck_type))

    if (missing(repository)) {
        repository <- unname(getOption("repos"))
    }
    message(sprintf("Repository: [%s].", repository))

    # Which packages are available in {repository}
    #TODO: add check for R version
    available_packages <- as.data.frame(available.packages(
        repos = repository,
        filters = getOption("available_packages_filters")
    ))
    not_available <- available_packages[!available_packages$Packages %in% pck]
    if (length(not_available) > 0) {
        message(sprintf("Packages not available in [%s]: [%s].", 
            repository, toString(not_available)))
    } else {
        message(sprintf("All packages are available in [%s].", repository))
    }

    # Create directory structure for R packages inside {directory}
    out_directory <- file.path(directory, "src", "contrib")
    if (!dir.exists(out_directory)) {
        dir.create(out_directory, recursive = TRUE)
    }

    # Warnings if we lack necessary packages that lives in other {directories}
    # For example, base R packages do not live in our repository.
    invisible(suppressWarnings(download.packages(
        pkgs = pck,
        destdir = out_directory,
        type = pck_type,
        repos = repository
    )))
}

create_package_directory(pck = main_dependencies, pck_type = "source")

# TODO: Function that turns a package directory into a repository
create_repository_from_directory <- function(directory) {
}



download.packages(
    pkgs = "data.table",
    destdir = pth,
    type = "source",
    repos = options("repos")$repos[["CRAN"]])


# miniCRAN::makeRepo(
#     pkgs = dplyr_needed,
#     path = pth,
#     type = "source",
#     repos = options("repos")$repos[["CRAN"]])
list.files(pth, recursive = TRUE, full.names = TRUE)  |> basename()

available.packages(repos = pth, filters = getOption("available_packages_filters"))
#miniCRAN::pkgAvail(pth)[,  c("Package", "Version")]



# TODO: Copy of addPackage that can add a new package to a local repo
miniCRAN::addPackage

# ------------------------------------------------------------------------------
# Downstream packages
downstream_packages <- c("dplyr", "data.table", "DBI")
# Packages in {lib.loc} that recursively {dependencies} on {pkgs}
tools::dependsOnPkgs(
    pkgs = downstream_packages, 
    dependencies = c("Enhances"),
    recursive = TRUE,
    lib.loc = .libPaths()[1])


