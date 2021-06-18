#!/usr/bin/env bash

echo 'macr: Installing or upgrading R on macOS using Homebrew cask (https://brew.sh)'


# Check if Homebrew installed ---
if ! command -v brew &> /dev/null
then
  echo 'ERROR: Homebrew not found with command brew. Please install Homebrew before using this script. Aborting script.'
  exit 1
fi


# Argument parsing ---

# Default values for switch arguments
uninstall_first=0
blas=1

# Argument parsing loop
while [[ "$#" -gt 0 ]]
do
case $1 in

  -u|--uninstall-first|-f|--force)
    uninstall_first=1
    shift 1
    ;;

  -n|--no-blas)
    blas=0
    shift 1
    ;;

  # -t|--tail)
  #     TAIL="tail=$2"
  #     shift 2
  #     ;;

  *)
    echo "WARNING: Ignoring command line argument: $1"
    shift 1
    ;;

esac
done


# R installation/upgrade ---

echo 'First, updatng Homebrew formulae and casks ...'
brew update

# Check if R installed by brew already
brew list --cask r  &> /dev/null
list_status=$?

# Logic sequence
if [ ! $list_status -eq 0 ]
then
  echo 'No existing Hombrew installation of R found. Installing R using Homebrew ...'
  # brew install --cask r

elif [ $uninstall_first -eq 1 ]
then
  echo 'Uninstalling existing Homebrew installation of R ...'
  # brew uninstall --cask r
  echo 'Installing R using Homebrew ...'
  # brew install --cask r

else
  brew outdated --cask r
  outdated_status=$?
  if [ $outdated_status -eq 0 ]
  then
    R --version
    echo 'MESSAGE: Homebrew installation of R is already up-to-date. No upgrade required. Script is ending.'
    exit 0
  else
    echo 'Upgrading Hombrew installation of R ...'
    # brew upgrade --cask r
  fi

fi

# Check R successfully installed, abort if not
R --version
if [ ! $? -eq 0 ]
then
  echo 'ERROR: R installation/upgrade failed. Aborting script.'
  exit 1
fi


# BLAS: Make R multi-threaded using Apple's Accelerate Framework ---
if [ $blas -eq 1 ]
then
  echo 'Linking Apple BLAS to make R run multi-threaded by default where possible ...'

  # Performance without linking BLAS (vecLib) from Apple's Accelerate Framework, i.e. *no* default multi-threading
  Rscript -e "sessionInfo()"
  Rscript -e "d <- 2e3; system.time({ x <- matrix(rnorm(d^2),d,d); tcrossprod(x) })"
  echo 'CHECK: You should see only default BLAS and matrix manipulation in R takes a long time. Installs with no default multi-threading.'

  # Linked via a symlink
  # ln -sf \
  #   /System/Library/Frameworks/Accelerate.framework/Versions/Current/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib \
  #   /Library/Frameworks/R.framework/Versions/Current/Resources/lib/libRblas.dylib

  # Check performance again
  Rscript -e "sessionInfo()"
  Rscript -e "d <- 2e3; system.time({ x <- matrix(rnorm(d^2),d,d); tcrossprod(x) })"
  echo 'CHECK: You should now see that BLAS uses the Accelerate Framework and the matrix manipulation time has been dramatically reduced. R now runs multi-threaded by default for these sorts of operations.'

else
  echo 'WARNING: You chose *not* to link Apple BLAS, which means there is *no* default multi-threading. Performance will be compromised.'

fi


# Install packages ---
echo "Installing packages ..."
Rscript --verbose --vanilla install-packages.R packages.yml


# Configire IRkernel for using R in Jupyter ---
# - done using R

# This needs to be done while conda base environment is active, because it needs to see the Jupyter installation
# condaon
# conda activate base
# wget https://raw.githubusercontent.com/jarvisrob/set-up-mac/master/install-irkernel.R -P ~/tmp
# Rscript --verbose --vanilla ~/tmp/install-irkernel.R
# rm ~/tmp/install-irkernel.R
# condaoff




