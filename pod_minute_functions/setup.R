# Source .Renviron
readRenviron(file.path(getwd(), ".Renviron"))

# Load required packages
library(tidyverse)
library(lwdataexplorer)
library(stringr)
library(here)

# Load pipeline functions
source_files <- list.files("pod_minute_functions", pattern = "\\.R$", full.names = TRUE)

# Source all function files except setup.R
source_files <- source_files[basename(source_files) != "setup.R"]

lapply(source_files, source)