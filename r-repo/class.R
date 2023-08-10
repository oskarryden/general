
add_class <- function(x, new_class) {
    
    if (missing(new_class)) stop("Empty class")
    if (!is.character(new_class)) stop("new_class must be of type character")
    stopifnot(has_pre_class(x, new_class))

    if (new_class == "vp_updated" && has_class(x, "vp_updated")) {
        return(x)
    }

    if (has_class(x, new_class)) {
        stop("new_class already exists for x")
    }

    # Add class
    class(x) <- c(class(x), new_class)
    return(x)
}

has_class <- function(x, exist_class) {

    if (length(exist_class) == 1) {
        out <- exist_class %in% class(x)
    } else {
        out <- all(exist_class %in% class(x))
    }

    stopifnot(isTRUE(out) | isFALSE(out))

    return(out)
}

is_vp <- function(x) {
    has_class(x, exist_class = "vpackages")
}

class_table <- function() {

    classes <- c("vpackages", paste0("vp_", c(
        "main", "dependencies", "download", "repository", "updated")))

    out <- data.frame(
        classes = classes,
        pre_class = c(NA_character_, classes[seq(1, length(classes)) - 1 ])
    )

    return(out)
}

has_pre_class <- function(x, focal) {

    if (focal == "vpackages") return(TRUE)

    ct <- class_table()[["pre_class"]][class_table()[["classes"]] == focal]
    out <- has_class(x, exist_class = ct)
    stopifnot(isTRUE(out) | isFALSE(out))
    
    return(out)
}

