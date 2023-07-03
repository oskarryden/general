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