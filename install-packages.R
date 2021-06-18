# This script is meant to be called via the command line and Rscript after
# installing or upgrading R. Should be called with a vanilla config (see 
# https://linux.die.net/man/1/rscript). Final argument is the yaml file
# containing the list of packages to install.

# Suggested call:
# Rscript --verbose --vanilla install-packages.R packages.yml

# CRAN repo to use
cran_repo <- "https://cloud.r-project.org/"

# Prerequisite packages for this package installation script to work:
# - yaml: so can read the .yml file that contains the list of packages and where
#     they are sourced from
install.packages("yaml", repos = cran_repo)

# Also requires the "devtools" package so can install from GitHub (and other
# repos). Gets upset if try to use install.packages() for devtools if it has
# already been installed. So check first.
installed <- installed.packages()
if (sum(installed[, "Package"] == "devtools") == 0) {
  install.packages("devtools", repos = cran_repo)
}

# Capture command line arguments
cmd_args <- commandArgs(trailingOnly = TRUE)

# Read package listing yml file. Defaults to "packages.yml" if argument is not
# provided.
if (length(cmd_args) == 0) {
  filename <- "packages.yml"
} else {
  filename <- cmd_args[1]
}
packages <- yaml::read_yaml(filename)

# Install packages
install.packages(packages$cran, repos = cran_repo)
devtools::install_github(packages$github)

# List installed packages
installed <- installed.packages()
print(installed[, c("Version", "Built")])
