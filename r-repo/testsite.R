# Try the function make_vp_object() in the console.
make_vp_object()
# class
class(make_vp_object())
# structure
str(make_vp_object())
# length
length(make_vp_object())

# Try the function check_vp_object() in the console.
check_vp_object(make_vp_object())

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
options(available_packages_filters = c("R_version", "OS_type", "subarch", "duplicates"))
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
vpob <- add_main_packages(vpob, c("data.table", "DBI", "rstan", "ggplot2", "dplyr"))
vpob |> str()

# try add_main_dependencies() in the console.
vpob <- add_main_dependencies(vpob)


# ------------------------------------------------------------------------------
create_dir("")
create_dir(" ")
create_dir("  ")
create_dir(dir)

create_dir("test")
create_dir("test")
create_dir("test/test/", recursive = FALSE)
unlink("~/test", recursive = TRUE)

# test download_packages() in the console
download_packages(vpob, download_dir = "testdeps")