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
show_package_description <- function(package, library) {
    doc <- utils::packageDescription(package, lib.loc = library)
    fields <- c("Package", "Version", "Depends", "Imports", "Suggests", "SystemRequirements", "Repository", "Date/Publication", "Built")
    doc[names(doc) %in% fields]
}

