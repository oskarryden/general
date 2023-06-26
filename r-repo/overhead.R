# References:
# https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Add_002don-packages

# Installing 
# To install packages from source on a Unix-alike use in a terminal
# R CMD INSTALL -l /path/to/library pkg1 pkg2 …
# The part ‘-l /path/to/library’ can be omitted, in which case the first library of a normal R session is used (that shown by .libPaths()[1]). 

# tar.gz
# install.packages can install a source package from a local .tar.gz file (or a URL to such a file) by setting argument repos to NULL: this will be selected automatically if the name given is a single .tar.gz file. 

# versions of R
av <- available.packages(filters=list())

# Updating packages
#The command update.packages() is the simplest way to ensure that all the packages on your system are up to date. It downloads the list of available packages and their current versions, compares it with those installed and offers to fetch and install any that have later versions on the repositories.
# update.packages() annoying

#An alternative interface to keeping packages up-to-date is provided by the command packageStatus(), which returns an object with information on all installed packages and packages available at multiple repositories.
instpck <- packageStatus()$inst
instpck |> head()
instpck <- packageStatus(lib.loc = .libPaths()[1])
instpck$inst

# REmove packages
# Packages can be removed in a number of ways. From a command prompt they can be removed by
# R CMD REMOVE -l /path/to/library pkg1 pkg2 …
# From a running R process they can be removed by
# remove.packages(c("pkg1", "pkg2"),
#                   lib = file.path("path", "to", "library"))

# Setting up a repository
# Utilities such as install.packages can be pointed at any CRAN-style repository, and R users may want to set up their own.
# The ‘base’ of a repository is a URL such as https://www.stats.ox.ac.uk/pub/RWin/:
# this must be an URL scheme that download.packages supports (which also includes ‘https://’, ‘ftp://’ and ‘file://’).
# Under that base URL there should be directory trees for one or more of the following types of package distributions:
#     "source": located at src/contrib and containing .tar.gz files. Other forms of compression can be used, e.g. .tar.bz2 or .tar.xz files. Complete repositories contain the sources corresponding to any binary packages, and in any case it is wise to have a src/contrib area with a possibly empty PACKAGES file.
#     "win.binary": located at bin/windows/contrib/x.y for R versions x.y.z and containing .zip files for Windows.
#     "mac.binary": located at bin/macosx/contrib/4.y for the CRAN builds for macOS for R versions 4.y.z, containing .tgz files.
#     "mac.binary.el-capitan": located at bin/macosx/el-capitan/contrib/3.y for the CRAN builds for R versions 3.y.z, containing .tgz files. 

# Each terminal directory must also contain a PACKAGES file.
# This can be a concatenation of the DESCRIPTION files of the packages separated by blank lines, but only a few of the fields are needed.
# The simplest way to set up such a file is to use function write_PACKAGES in the tools package, and its help explains which fields are needed.

# Optionally there can also be PACKAGES.rds and PACKAGES.gz files, downloaded in preference to PACKAGES. (If you have a mis-configured server that does not report correctly non-existent files you may need these files.)
# To add your repository to the list offered by setRepositories(), see the help file for that function.
# Incomplete repositories are better specified via a contriburl argument than via being set as a repository.
# A repository can contain subdirectories, when the descriptions in the PACKAGES file of packages in subdirectories must include a line of the form 
