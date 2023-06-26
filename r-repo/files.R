# View DESCRIPTION file of a {package} in {directory}
show_package_description <- function(package, directory) {

    p <- deparse(substitute(package))
    fields <- c("Depends", "Imports", "Suggests")

    if (!p %in% installed.packages(lib.loc = directory)[,1]) {
        stop(sprintf("Package [%s] is not installed in [%s].", p, directory))
    }

    desc_file <- system.file(
        "DESCRIPTION",
        package = p,
        lib.loc = directory) |> 
        readLines()
    
    sprintf("Source directory: %s", directory) |> message(appendLF = TRUE)
    sprintf("DESCRIPTION file fields for [%s]:", p) |> message(appendLF = TRUE)
    
    for (fi in fields) {
        sprintf(
            "%s: %s", 
            fi, .capture_description_field(fi, desc_file)) |> 
        message(appendLF = TRUE)
    }
}