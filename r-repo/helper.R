
get_base_r_packages <- function(){
    sort(rownames(installed.packages(priority="base")))
}

update_packages_slot <- function(vp, slot, ...) {

    slot <- match.arg(slot, c("main", "deps", "total"))
    # Force evaluate to avoid NSE-trap
    # If eval+substitute+alist is used, you need to pair the correct frame as enclose
    dots <- list(...)

    if (slot == "main") {
        values <- dots[["updates"]]
        # values is a vector
        stopifnot(is.character(values))
        vp$packages$main <- sort(unique(c(vp$packages$main, values)))
    }
    if (slot == "deps") {
        values <- dots[["updates"]]
        # values is a list
        stopifnot("list" %in% class(values))
        if (length(vp$packages$deps) == 0 & !has_class(vp, "vp_updated")) {
            vp$packages$deps <- values
        } else {
            for (nm in names(values)) {
                # add parent package
                vp$packages$deps[[nm]] <- values[[nm]]
            }
        }
    }

    if (slot == "total") {
        if (!is.null(dots[["updates"]])) {
            warning("Input to function is disregarded")
        }
        vp$packages$total <- sort(unique(c(
            vp$packages$total,
            c(vp$packages$main, unlist(unname(vp$packages$deps))))))
    }

    return(vp)
}

timestamp_class <- function(vp) {

    latest_class <- unlist(strsplit(x = class(vp)[length(class(vp))], split = "_"))
    stopifnot(is.character(latest_class) && is.vector(latest_class))
    if (latest_class[2] == "vpackages") {
        stop("Already timestamped")
    }
    latest_class <- latest_class[length(latest_class)]
    if (is.null(vp$settings$general[[latest_class]])) {
        vp$settings$general[[latest_class]] <- Sys.Date()
    } else {
        vp$settings$general[[latest_class]] <-
            c(vp$settings$general[[latest_class]], Sys.Date())
    }
    return(vp)
}

get_available_packages <- function(vp) {

    # Check filters
    if (is.null(getOption("available_packages_filters"))) {
        warning("Consider setting filters using `options(available_packages_filters = c(\"R_version\", \"OS_type\", \"subarch\", \"CRAN\", \"duplicates\"))` before running `get_available_packages`.")
    } else {
        message(sprintf("Filters used: [%s].",
            toString(getOption("available_packages_filters"))))
    }

    if (!missing(vp)) {
        message("Using repositories defined by the vp object.")
        repos <- vp$settings$R$repositories
    } else {
        message("Using repositories from options'.")
        stopifnot(`Specify repos through options`= !is.null(getOption("repos")))
        repos <- getOption("repos")
    }

    # Get all packages from {repo_name} available in {repos} with {filters}
    cran_packages <- utils::available.packages(
        repos = repos,
        filters = getOption("available_packages_filters"))

    # Unique behavior for {add_main_packages}
    call_stack <- sys.calls()
    # Get the function that called get_available_packages
    calling_function <- substitute(deparse(call_stack[[length(call_stack) - 1]][[1]]))

    if (calling_function == "check_packages_vector") {
        return(row.names(cran_packages))
    }
    
    return(cran_packages)
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

compare_across_rows <- function(df, expr) {
    # Capture as base for the call
    basecall <- bquote(.(substitute(expr)))
    out <- vector(mode = "logical", length = nrow(df))
    # Apply base call to each row
    for (i in seq_along(out)) {
        out[i] <- eval(basecall, envir = df[i, , drop = FALSE])
    }
    return(out)
}