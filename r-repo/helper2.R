# Print the R version
print_r_version <- function() {
    message(sprintf("R version: [%s].", getRversion()))
}

# Print the R repository
print_r_repository <- function() {
    message(sprintf("R repository: [%s].", toString(getOption("repos"))))
}

# Print the R library
print_r_library <- function() {
    message(sprintf("R library [n:%i]: [%s].",
        length(.libPaths()), toString(.libPaths())))
}

read_vp_object <- function(path) {
    vp <- readRDS(path)
    return(vp)
}
