## References:
https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Add_002don-packages

# Some information about R and packages
## Installing a package
To install packages from source on a Unix-alike use in a terminal
```bash
R CMD INSTALL -l /path/to/library pkg1 pkg2 …
```
The part `-l /path/to/library` can be omitted, in which case the first library of a normal R session is used (that shown by `.libPaths()[1]`). 

Installing using a `tar.gz` file can also be implemented from `install.packages` (or a URL to such a file) by setting argument `repos=NULL`. This is the default if the argument to `install.packages` is a single file name with the extension `.tar.gz`, `.tgz` or `.tar.bz2`.

You can list the versions of a package that are available on CRAN with
```R
av <- available.packages(filters=list())
class(av); str(av); dim(av)
# The filters argument is a named list of filters to be applied to the list of available packages. The names of the list are the names of the filters, and the values are the values to be used for the filters. The filters are applied in the order in which they appear in the list.

# Show the available information in the `av` object
colnames(av)

# Show the available versions of the lattice package: two hits!
av[av[, grepl("^Pack", colnames(av))] == "lattice", c("Package", "Version", "Depends", "Imports", "Suggests")]

# Show the ten most recently updated packages
av[order(av[, "Date"], decreasing = TRUE), c("Package", "Version", "Date")][1:10, ]
```

## Updating packages
The command `update.packages()` is the simplest way to ensure that all the packages on your system are up to date. It downloads the list of available packages and their current versions, compares it with those installed and offers to fetch and install any that have later versions on the repositories.
`update.packages()` annoying.

An alternative interface to keeping packages up-to-date is provided by the command `packageStatus()`, which returns an object with information on all installed packages and packages available at multiple repositories. The function `packageStatus()` is a wrapper for `installed.packages()` and `available.packages()`, and returns a data frame with the following columns:
```R
instpck <- packageStatus()$inst
instpck |> head()
instpck <- packageStatus(lib.loc = .libPaths()[1])
instpck$inst
```

## Remove packages
Packages can be removed in a number of ways. From a command prompt they can be removed by
```bash
R CMD REMOVE -l /path/to/library pkg1 pkg2 …
```
From `R`, they can be removed by
```R
remove.packages(c("pkg1", "pkg2"), lib = file.path("path", "to", "library"))
```
## Setting up a repository
Utilities such as `install.packages` can be pointed at any CRAN-style repository. Such a repository is characterized by a set of directories containing packages, a `PACKAGES` file (or equivalent) in each directory, and a `PACKAGES.gz` file (or equivalent) in each directory. The `PACKAGES` file contains information about the packages in the directory, and the `PACKAGES.gz` file is a compressed version of the `PACKAGES` file. The `PACKAGES` file is a text file with one record per package. The fields in the `PACKAGES` file are:
```R
Package: The name of the package.
Version: The version of the package.
Depends: Packages that this package depends on.
Imports: Packages that this package imports.
Suggests: Packages that this package suggests.
License: The license under which this package is released.
NeedsCompilation: Does this package need compilation?
```
The basename of the repository must be a URL scheme that `download.packages` supports (which also includes `https://`, `ftp://` and `file://`). Under that base URL there should be directory trees for one or more of the following types of package distributions:
- `source`: located at `src/contrib` and containing `.tar.gz` files. Other forms of compression can be used, e.g. `.tar.bz2` or `.tar.xz` files. Complete repositories contain the sources corresponding to any binary packages, and in any case it is wise to have a `src/contrib` area with a possibly empty PACKAGES file.
- `win.binary`: located at bin/windows/contrib/x.y for R versions x.y.z and containing .zip files for Windows.
- `mac.binary`: located at bin/macosx/contrib/4.y for the CRAN builds for macOS for R versions 4.y.z, containing .tgz files.
"mac.binary.el-capitan": located at bin/macosx/el-capitan/contrib/3.y for the CRAN builds for R versions 3.y.z, containing .tgz files. 

Each of these directories must contain a PACKAGES file, and the source directory must contain a PACKAGES.gz file. The function `write_PACKAGES` from `tools` can be used to create these files.

options
# Options for {available.packages}
options(available_packages_filters = c("R_version", "OS_type", "subarch", "CRAN", "duplicates"))
getOption("available_packages_filters")