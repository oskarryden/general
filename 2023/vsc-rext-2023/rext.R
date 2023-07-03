# Script to set up VSC R extensions


# Install R packages and some system packages
install.packages("languageserver")
install.packages("rmarkdown")
system("sudo apt install pandoc")
remotes::install_github("ManuelHentschel/vscDebugger")
install.packages("httpgd")
