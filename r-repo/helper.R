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


read_vp_object <- function(path) {
    vp <- readRDS(path)
    stopifnot(check_vp_object(vp))
    return(vp)
}

timestamp_vp_class <- function(obj) {
    latest_class <- unlist(strsplit(x = class(obj)[length(class(obj))], split = "_"))
    stopifnot(is.character(latest_class) && is.vector(latest_class))
    if (latest_class[2] == "vpackages") {
        stop("The object is already timestamped")
    }
    latest_class <- latest_class[length(latest_class)]
    if (is.null(obj$settings$general[[latest_class]])) {
        obj$settings$general[[latest_class]] <- Sys.Date()
    } else {
        obj$settings$general[[latest_class]] <-
            c(obj$settings$general[[latest_class]], Sys.Date())
    }
    return(obj)
}

show_package_description <- function(package, library) {

    if (missing(library)) {
        library <- .libPaths()[1]
    }

    doc <- utils::packageDescription(package, lib.loc = library)
    fields <- c("Package", "Version", "Depends", "Imports", "Suggests", "SystemRequirements", "Repository", "Date/Publication", "Built")
    doc[names(doc) %in% fields]
}

