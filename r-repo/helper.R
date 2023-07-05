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

get_available_packages <- function(vp) {

    # Check filters
    if (is.null(getOption("available_packages_filters"))) {
        warning("No filters for packages are set.")
        message("Consider setting filters using `options(available_packages_filters = c(\"R_version\", \"OS_type\", \"subarch\", \"CRAN\", \"duplicates\"))` before running `get_available_packages`.")
    } else {
        message("Filters for packages are set.")
        message(sprintf("Filters: [%s].", toString(getOption("available_packages_filters"))))
    }

    # Check vp
    if (!missing(vp)) {
        stopifnot(check_vp_object(vp))
        message("Using the available packages from the vp object.")
        repos <- vp$settings$R$repositories
    } else {
        message("Using the available packages from the R repositories.")
        stopifnot(`Specify repos through options`= !is.null(getOption("repos")))
        repos <- getOption("repos")
    }

    # Get all packages from {repo_name} available in {repos} with {filters}
    message(sprintf("Repos used: [%s].", toString(repos)))
    cran_packages <- utils::available.packages(
        repos = repos,
        filters = getOption("available_packages_filters")
        )

    # Functionality for {add_main_packages}
    call_stack <- sys.calls()
    # Get the function that called get_available_packages
    calling_function <- substitute(deparse(call_stack[[length(call_stack) - 1]][[1]]))

    if (calling_function == "check_packages_vector") {
        return(row.names(cran_packages))
    }
    
    return(cran_packages)
}

replace_available_packages <- function(vp, new) {
    stopifnot(check_vp_object(vp))
    vp$packages$available_packages <- new
    return(vp)
}

count_packages <- function(vp, type) {
    # Count the number of packages
    if (type == "main") {
        return(length(vp$packages$main))
    } else if (type == "deps") {
        return(length(unlist(vp$packages$deps)))
    } else if (type == "total") {
        return(length(vp$packages$total))
    } else if (type == "pruned") {
        return(length(vp$packages$pruned))
    } else {
        stop("Unknown type.")
    }
}

show_package_description <- function(package, library) {

    if (missing(library)) {
        library <- .libPaths()[1]
    }

    doc <- utils::packageDescription(package, lib.loc = library)
    fields <- c("Package", "Version", "Depends", "Imports", "Suggests", "SystemRequirements", "Repository", "Date/Publication", "Built")
    doc[names(doc) %in% fields]
}

