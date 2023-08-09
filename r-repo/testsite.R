if (Sys.getenv("USER") == "parrot") setwd("~/oskar_personal_repositories")
if (Sys.getenv("USER") == "oskar") setwd("~/code")

getwd()

# Object 
source("general/r-repo/class.R")
source("general/r-repo/object.R")
source("general/r-repo/helper.R")
source("general/r-repo/checks.R")
lsf.str()

vp <- create_vp_object()
class(vp)
lapply(vp, class)
lapply(vp, str)

# Define
source("general/r-repo/define.R")
lsf.str()

vp_main <- add_main_packages(vp, "DBI")
class(vp_main)
lapply(vp_main, class)
lapply(vp_main, str)

# Depends
source("general/r-repo/depends.R")
lsf.str()
vp_deps <- add_main_dependencies(vp_main)
class(vp_deps)
lapply(vp_deps, class)
lapply(vp_deps, str)

# Download
source("general/r-repo/download.R")
lsf.str()

vp_down <- download_packages(vp_deps)
class(vp_down)
lapply(vp_down, class)
lapply(vp_down, str)

# Repository
source("general/r-repo/repository.R")
vp_repo <- make_repository(vp_down)

# update
source("general/r-repo/update.R")
vp_update1 <- update_repository(vp_repo)

add_pack <- c("dplyr")
vp_update2 <- update_repository(vp_update1, add_pack)


print_r_library()
print_r_version()
print_r_repository()

