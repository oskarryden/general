# Länk här: https://mc-stan.org/cmdstanr/

# notera att options(warn=2) kommer att ge error
# sätt warn=0 eller warn=1
options(warn=0)

# Installera från Git
install.packages(
    "cmdstanr",
    repos = c("https://mc-stan.org/r-packages/", getOption("repos")))

# I det andra steget behöver vi ett C++-program, kolla här:
# https://mc-stan.org/docs/cmdstan-guide/cmdstan-installation.html#cpp-toolchain

# I det tredje steget
library(cmdstanr)
check_cmdstan_toolchain()
install_cmdstan()

# cmdstan kommer att installera sig själv. Var programmet installerar sig
# bestäms av två saker:
# 1. Finns det en miljövariabel som heter "CMDSTAN", då blir det destinationen.
# 2. Om inte (1), så blir det Sys.getenv("HOME").
# Mappen heter ~/.cmdstan/cmdstan-[version]
# Kolla:
cmdstan_path()
cmdstan_version()
# Vi kan också ändra med set_cmdstan_path()

# Testa att kompilera en modell
file <- file.path(cmdstan_path(), "examples", "bernoulli", "bernoulli.stan")
mod <- cmdstan_model(file)
mod$print()
mod$exe_file()
# names correspond to the data block in the Stan program
data_list <- list(N = 10, y = c(0,1,0,0,0,0,0,0,0,1))
fit <- mod$sample(
    data = data_list, 
    seed = 123, 
    chains = 4, 
    parallel_chains = 4,
    refresh = 500)
