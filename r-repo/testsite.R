R
if (Sys.getenv("USER") == "parrot") setwd("~/oskar_personal_repositories")
if (Sys.getenv("USER") == "oskar") setwd("~/code")
source("general/r-repo/objectclass.R")
source("general/r-repo/define.R")
source("general/r-repo/depends.R")
source("general/r-repo/download.R")
source("general/r-repo/repository.R")
source("general/r-repo/helper.R")
source("general/r-repo/checks.R")
source("general/r-repo/update.R")

lsf.str()

print_r_library()
print_r_version()
print_r_repository()

# Try the function make_vp_object() in the console.
stopifnot(!is.null(make_vp_object()))
# class
stopifnot("vpackages" %in% class(make_vp_object()))
# structure
str(make_vp_object())
# length
length(make_vp_object())

# Try the function check_vp_object() in the console.
stopifnot(check_vp_object(make_vp_object()))

check_vp_object(list())
check_vp_object(list(main = c(), deps = list(), total = c()))
check_vp_object(list(main = c("a"), deps = list(), total = c("a")))
check_vp_object(c())
check_vp_object(1)
check_vp_object("a")
check_vp_object(TRUE)
check_vp_object(FALSE)
check_vp_object(NULL)
check_vp_object(NA)
check_vp_object(Inf)
check_vp_object(-Inf)
check_vp_object(data.frame())
dd <- data.frame(); class(dd) <- c(class(dd),"vpackages")
check_vp_object(dd)
ll <- list(); class(ll) <- c(class(ll),"vpackages")
check_vp_object(ll)

# ------------------------------------------------------------------------------
# Try the function add_main_packages() in the console.
add_main_packages(make_vp_object())
add_main_packages(make_vp_object(), c(""))
add_main_packages(make_vp_object(), c(" ", "    "))
add_main_packages(make_vp_object(), c("fake_package"))

add_main_packages(make_vp_object(), c("ggplot2"))
add_main_packages(make_vp_object(), c("ggplot2", "dplyr"))
check_vp_object(add_main_packages(make_vp_object(), c("ggplot2")))
check_vp_object(add_main_packages(make_vp_object(), c("ggplot2", "dplyr")))

# Try the get_available_packages() function in the console.
#options(available_packages_filters = c("R_version", "OS_type", "subarch", "duplicates"))
get_available_packages() |> invisible()
get_available_packages("no") |> invisible()
get_available_packages() |> head()
get_available_packages() |> tail()
get_available_packages() |> as.data.frame() |> View()
get_available_packages() |> as.data.frame() |> subset(Package == "rstan") |> str()
f <- function() {
    get_available_packages()
}
f() |> head()
add_main_packages(make_vp_object(), "ggplot2")
add_main_packages(make_vp_object(), "fake_package")
add_main_packages(make_vp_object(), c("rstan", "dplyr"))

# ------------------------------------------------------------------------------
# Checkpoint the make_vp_object() + add_main_packages() functions.
# Create an object from the two functions
vpob <- make_vp_object()
str(vpob)

vpob_main <- add_main_packages(vpob, c("data.table", "DBI", "rstan", "ggplot2", "dplyr", "zoo"))
str(vpob_main)
vpob$packages$deps_type

vpob_deps <- add_main_dependencies(vpob_main)
str(vpob_deps)

vpob_downloaded <- download_packages(vpob_deps)
str(vpob_downloaded)
class(vpob_downloaded)

vpob_repository <- make_repository(vpob_downloaded)
str(vpob_repository)
class(vpob_repository)

vp <- vpob_repository
