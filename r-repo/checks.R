check_vp_object <- function(x) {

    packages <- x$packages

    if (!"vpackages" %in% class(x)) {
        stop("x is not a 'vpackages' object.")
    }
    if (!"list" %in% class(x)) {
        stop("x is not a list.")
    }
    if (is.null(packages$main)) {
        stop("The main slot is NULL.")
    }
    if (!is.character(packages$main)) {
        stop("The main slot is not a character vector.")
    }
    if (is.null(packages$deps)) {
        stop("The deps slot is NULL.")
    }
    if (!"list" %in% class(packages$deps)) {
        stop("The deps slot is not a list.")
    }
    if (is.null(packages$total)) {
        stop("The total slot is NULL.")
    }
    if (!is.character(packages$total)) {
        stop("The total slot is not a character vector.")
    }

    stopifnot(check_parts_and_total(x))

    if (is.null(x$settings)) {
        stop("The settings slot is NULL.")
    }
    if (!"list" %in% class(x$settings)) {
        stop("The settings slot is not a list.")
    }

    return(TRUE)
}

check_packages_vector <- function(x, type) {

    if (type == "main") {
        x <- x$packages$main
    } else if (type == "total") {
        x <- x$packages$total
    } else if (type == "deps") {
        x <- unlist(x$packages$deps)
    } else if (type == "pruned") {
        x <- x$packages$pruned
    } else {
        stop("type is not 'main' or 'total'.")
    }
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
    
    return(x)
}

check_parts_and_total <- function(x) {

    x <- x$packages

    parts <- unique(c(x$main, unlist(unname(x$deps))))
    total <- unique(x$total)
    if (length(parts) != length(total)) {
        stop("The sum of the main and dependencies does not equal the total.")
    }
    if (any(!parts %in% total)) {
        stop("The parts are not a subset of the total.")
    }

    return(TRUE)
}

check_deps_object <- function(x){

    x <- x$packages$deps

    if (!is.list(x)) {
        stop("x is not a list.")
    }
    if (length(x) == 0) {
        stop("x is an empty list.")
    }
    if (any(duplicated(names(x)))) {
        stop("x contains duplicated names.")
    }
    if (any(names(x) == "")) {
        stop("x contains empty strings.")
    }
    if (any(grepl("^\\s+$", names(x)))) {
        stop("x contains strings with only spaces.")
    }
    if (any(!names(x) %in% suppressMessages(get_available_packages()))) {
        stop("x contains packages that are not available through any of the specified repositories.")
    }
    if (any(!sapply(x, is.character))) {
        stop("x contains elements that are not character vectors.")
    }
    if (any(sapply(x, length) == 0)) {
        stop("x contains elements that are empty character vectors.")
    }
    if (any(sapply(x, function(x) any(duplicated(x))))) {
        stop("x contains elements that are character vectors with duplicated elements.")
    }
    if (any(sapply(x, function(x) any(x == "")))) {
        stop("x contains elements that are character vectors with empty strings.")
    }
    if (any(sapply(x, function(x) any(grepl("^\\s+$", x))))) {
        stop("x contains elements that are character vectors with strings with only spaces.")
    }
    if (any(sapply(x, function(x) any(!x %in% suppressMessages(get_available_packages()))))) {
        stop("x contains elements that are character vectors with packages that are not available through any of the specified repositories.")
    }
    return(TRUE)
}

check_before_download <- function(x) {

    download_vector <- x$packages$pruned

    if (is.null(download_vector)) {
        stop("The pruned vector is NULL.")
    }

    if (!is.character(download_vector)) {
        stop("The pruned vector is not a character vector.")
    }

    if (length(download_vector) == 0) {
        stop("The pruned vector is empty. Only base R dependencies are found.")
    }

    if (is.null(x$summary$download$directory)) {
        stop("The download directory is NULL.")
    }

    if (!dir.exists(x$summary$download$directory)) {
        stop("The download directory does not exist.")
    }

    return(TRUE)
}

assert_class <- function(x, cond) {
    cond <- switch(
        cond,
        "initiated" = "vpackages",
        "main" = "vp_main",
        "deps" = "vp_dependencies",
        "downloaded" = "vp_download",
        "repository" = "vp_repository",
        "updated" = "vp_update",
    )
    if (!cond %in% class(x)) {
        stop("x does not meet the condition.")
    }
    return(TRUE)
}
