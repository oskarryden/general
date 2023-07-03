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

get_base_r_packages <- function(){
    sort(rownames(installed.packages(priority="base")))
}

prune_base_r_packages <- function(x) {
    x[!x %in% get_base_r_packages()]
}

# View DESCRIPTION file of a {package} in {directory}
# TODO: Update this function to use {utils::packageDescription}
show_package_description <- function(package, directory) {

}
