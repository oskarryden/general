if (Sys.getenv("USER") == "parrot") setwd("~/oskar_personal_repositories")
if (Sys.getenv("USER") == "oskar") setwd("~/code")

getwd()

# Object 
source("general/r-repo/class.R")
source("general/r-repo/object.R")
source("general/r-repo/helper.R")
source("general/r-repo/helper2.R")
source("general/r-repo/checks.R")

vp <- create_vp_object()
str(vp)

# Define
source("general/r-repo/define.R")
vp_main <- add_main_packages(vp, c("vutils", "vbase", "vanalysis"))

# Depends
source("general/r-repo/depends.R")
vp_deps <- add_main_dependencies(vp_main)

# Download
source("general/r-repo/download.R")
vp_down <- download_packages(vp_deps)

# Repository
source("general/r-repo/repository.R")
vp_repo <- make_repository(vp_down)

# update
source("general/r-repo/update.R")
vp_update1 <- update_repository(vp_repo)
vp_update1$settings

# update with new package
add_pack <- c("abind")
vp_update2 <- update_repository(vp_update1, add_pack)

vp_update2$settings

# Try to install:
install.packages |> formals()
# manually set repos
tryRepo <- "http://10.8.0.20/dataset-construction/vdem/R"
install.packages("abind", repos = tryRepo)
install.packages("abind")