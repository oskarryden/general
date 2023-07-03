# Purpose: make a CRAN-style repository of downloaded packages



# ------------------------------------------------------------------------------
# Downstream packages
downstream_packages <- c("dplyr", "data.table", "DBI")
# Packages in {lib.loc} that recursively {dependencies} on {pkgs}
tools::dependsOnPkgs(
    pkgs = downstream_packages, 
    dependencies = c("Enhances"),
    recursive = TRUE,
    lib.loc = .libPaths()[1])


