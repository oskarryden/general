# Set up miniCRAN

R

# R version
R.version; R.version.string
# Libs paths
.libPaths(); lib_focus

# Directory of libraries to search
lib_focus <- .libPaths()[1]

# All currently installed packages in {lib_focus}
inst_pcks <- as.data.frame(installed.packages(lib.loc = lib_focus))
inst_pcks[, c("Package", "Version", "Built")] |> head()

# miniCRAN
if (!"miniCRAN" %in% inst_pcks$Package) {
    install.packages("miniCRAN")
} else {
    sprintf("miniCRAN [%s] is already installed.",
        inst_pcks[inst_pcks$Package == "miniCRAN", "Version"]) |>  
        message(appendLF = TRUE)
    library(miniCRAN)
    # Attach tools
    library(tools)
}

# Options 
options(available_packages_filters = c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))
getOption("available_packages_filters")

# Helper for {show_package_description}
.capture_description_field <- function(pattern, description_file) {
    sidx <- grep(sprintf("^%s:", pattern), description_file)
    stopifnot(length(sidx) == 1 & sidx > 0)
    
    sidx_end <- sidx + 1
    repeat {
        if (grepl("^\\s", description_file[sidx_end])) {
            sidx_end <- sidx_end + 1
        } else {
            sidx_end <- sidx_end - 1
            break
        }
    }

    field_rows <- seq(from = sidx, to = sidx_end, by = 1)
    field <-
        gsub(pattern = "\\s{2,}", replacement = "", x = 
            trimws(
                strsplit(
                    strsplit(
                        paste0(description_file[field_rows], collapse = ""),
                            ":")[[1]][2],
                                ",")[[1]]
                                    )
                                        )
    out <- toString(field)
    return(out)
}

# View DESCRIPTION file of a {package} in {directory}
show_package_description <- function(package, directory) {

    p <- deparse(substitute(package))
    fields <- c("Depends", "Imports", "Suggests")

    if (!p %in% installed.packages(lib.loc = directory)[,1]) {
        stop(sprintf("Package [%s] is not installed in [%s].", p, directory))
    }

    desc_file <- system.file(
        "DESCRIPTION",
        package = p,
        lib.loc = directory) |> 
        readLines()
    
    sprintf("Source directory: %s", directory) |> message(appendLF = TRUE)
    sprintf("DESCRIPTION file fields for [%s]:", p) |> message(appendLF = TRUE)
    
    for (fi in fields) {
        sprintf(
            "%s: %s", 
            fi, .capture_description_field(fi, desc_file)) |> 
        message(appendLF = TRUE)
    }
}

show_package_description(package = dplyr, directory = lib_focus)

# TODO: a function that extracts all version-specific dependencies for a package

# ------------------------------------------------------------------------------
# Upstream packages

# Decide main packages
main_packages <- c("dplyr", "data.table", "zoo")

# All packages that are available in {repos}
cran_packages <-
    available.packages(
        repos = options("repos")$repos[["CRAN"]],
        filters = getOption("available_packages_filters"))

# Packages in {db} that {pkgs} depends on
# inspired by miniCRAN::PkgDep
main_dependecies <-
    tools::package_dependencies(
        packages = main_packages, 
        db = cran_packages,
        which = c("Depends", "Imports"),
        recursive = TRUE,
        reverse = FALSE)

dplyr_needed <- main_dependecies[[1]]
pth <- file.path(tempfile(), "dplyrdeps")
dir.create(pth, recursive = TRUE)

# Download all dependencies of {dplyr} to {pth}
# TODO: Function that downloads all dependencies of a package into a directory
# NOTE: Create a wrapper around download.packages that that also creates a proper file structure

download.packages(
    pkgs = "data.table",
    destdir = pth,
    type = "source",
    repos = options("repos")$repos[["CRAN"]])

miniCRAN::makeRepo(
    pkgs = dplyr_needed,
    path = pth,
    type = "source",
    repos = options("repos")$repos[["CRAN"]])

list.files(pth, recursive = TRUE, full.names = TRUE)  |> basename()

available.packages(repos = pth, filters = getOption("available_packages_filters"))
miniCRAN::pkgAvail(pth)[,  c("Package", "Version")]



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


