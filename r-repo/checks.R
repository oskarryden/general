# Purpose: Functions to check the `vpackages` workflow.

check_vp_object <- function(x) {
    if (!"vpackages" %in% class(x)) {
        stop("x is not a 'vpackages' object.")
    }
    if (!"list" %in% class(x)) {
        stop("x is not a list.")
    }
    if (is.null(x$main)) {
        stop("The main slot is NULL.")
    }
    if (!is.character(x$main)) {
        stop("The main slot is not a character vector.")
    }
    if (is.null(x$deps)) {
        stop("The deps slot is NULL.")
    }
    if (!"list" %in% class(x$deps)) {
        stop("The deps slot is not a list.")
    }
    if (is.null(x$total)) {
        stop("The total slot is NULL.")
    }
    if (!is.character(x$total)) {
        stop("The total slot is not a character vector.")
    }

    stopifnot(check_parts_and_total(x))

    if (is.null(x$available_packages)) {
        stop("The available_packages slot is NULL.")
    }
    if (!is.matrix(x$available_packages)) {
        stop("The available_packages slot is not a matrix.")
    }
    if (is.null(x$settings)) {
        stop("The settings slot is NULL.")
    }
    if (!"list" %in% class(x$settings)) {
        stop("The settings slot is not a list.")
    }

    return(TRUE)
}

check_packages_vector <- function(x) {
    if (!is.character(x)) {
        stop("x is not a character vector.")
    }
    if (length(x) == 0) {
        stop("x is an empty character vector.")
    }
    if (any(duplicated(x))) {
        stop("x contains duplicated elements.")
    }
    if (any(x == "")) {
        stop("x contains empty strings.")
    }
    if (any(grepl("^\\s+$", x))) {
        stop("x contains strings with only spaces.")
    }

    if (any(x %in% get_base_r_packages())) {
        message(sprintf("Do not include packages that are part of base R [%s].", toString(get_base_r_packages())))
        stop("x contains packages that are part of base R.")
    }

    if (any(!x %in% suppressMessages(get_available_packages()))) {
        stop("x contains packages that are not available in any of the specified repositories.")
    }
    return(TRUE)
}

check_available_packages <- function(x) {
    if (!is.matrix(x)) {
        stop("x is not a matrix.")
    }
    if (nrow(x) == 0) {
        stop("x is an empty matrix.")
    }
    if (!all(c("Package", "Version", "Repository", "Priority", "Depends", "Imports", "Suggests", "Enhances") %in% colnames(x))) {
        stop("x is lacking important columns.")
    }
    return(TRUE)
}

check_parts_and_total <- function(x) {
    parts <- unique(c(x[["main"]], unlist(unname(x[["deps"]]))))
    total <- unique(x[["total"]])
    if (length(parts) != length(total)) {
        stop("The sum of the main and dependencies does not equal the total.")
    }
    if (any(!parts %in% total)) {
        stop("The parts are not a subset of the total.")
    }

    return(TRUE)
}

check_deps_object <- function(deps){
    if (!is.list(deps)) {
        stop("deps is not a list.")
    }
    if (length(deps) == 0) {
        stop("deps is an empty list.")
    }
    if (any(duplicated(names(deps)))) {
        stop("deps contains duplicated names.")
    }
    if (any(names(deps) == "")) {
        stop("deps contains empty strings.")
    }
    if (any(grepl("^\\s+$", names(deps)))) {
        stop("deps contains strings with only spaces.")
    }
    if (any(!names(deps) %in% suppressMessages(get_available_packages()))) {
        stop("deps contains packages that are not available through any of the specified repositories.")
    }
    if (any(!sapply(deps, is.character))) {
        stop("deps contains elements that are not character vectors.")
    }
    if (any(sapply(deps, length) == 0)) {
        stop("deps contains elements that are empty character vectors.")
    }
    if (any(sapply(deps, function(x) any(duplicated(x))))) {
        stop("deps contains elements that are character vectors with duplicated elements.")
    }
    if (any(sapply(deps, function(x) any(x == "")))) {
        stop("deps contains elements that are character vectors with empty strings.")
    }
    if (any(sapply(deps, function(x) any(grepl("^\\s+$", x))))) {
        stop("deps contains elements that are character vectors with strings with only spaces.")
    }
    if (any(sapply(deps, function(x) any(!x %in% suppressMessages(get_available_packages()))))) {
        stop("deps contains elements that are character vectors with packages that are not available through any of the specified repositories.")
    }
    return(TRUE)
}