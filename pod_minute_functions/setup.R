# Load required packages
library(tidyverse)
library(lwdataexplorer)
library(stringr)
library(here)

# Load pipeline functions
source_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
lapply(source_files, source)