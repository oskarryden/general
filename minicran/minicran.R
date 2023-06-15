
R
install.packages("miniCRAN")
library(miniCRAN)


packages <- c("dplyr")
pkgDep("glmnet", suggests = FALSE, Rversion = "4.3")

tools::package_dependencies("cmdstanr", which = "Imports", recursive = TRUE)
