# ================================
# COMMENTS
# ================================

# 1. To use this package, input parameters and execute this script (run_pod.R). 

# 2. Remember to fill in your ETN credentials in the .Renviron file!
#    Credentials can be found by visiting ETN (https://www.lifewatch.be/etn/). Click on your user name in the top right-hand side > ETN R access.

# 3. To see that projects you have access to, visit ETN. Click on: Pick a context > Underwater acoustics > your user name in the top right-hand side > Settings.

# 4. If you want to request a DOI for the dataset, fill out the form at https://marineinfo.org/metasubmit/.

# 5. Please make sure you use standardised naming for stations in ETN.
#    e.g. consistent name across all deployments at the same station, capitalised first letter, etc.

# 6. This package is suitable for handling both CPOD and FPOD data.

# ================================
# USER INPUT
# ================================

# Desired start and end date of dataset
# Assign an excessively large date range if all data is wanted 
start_date <- "2025-06-15"       
stop_date  <- "2025-06-30"  

# Assign a name to your dataset
dataset_name <- "Dataset"       

# Choose between 'NBHF', 'Sonar', 'Other cet', 'unclassed' (NBHF = Harbour porpoise)
species <- c('NBHF')               

# ETN project(s) to download. To keep all open and own embargoed projects, input: c('')
project_name <- c('Lifewatch')   

# Desired quality of clicks to download: 3 = High, 2 = Mod, 1 = Lo. Multiple qualities can be selected, e.g. c(3, 2)
quality <- c(1,2,3)

# ================================
# RUN PIPELINE
# ================================

# PIPELINE:

# 1. DOWNLOAD data. Specifically:
#     - It downloads only user specified quality data at minute-resoution in 10 day intervals within the given time range
#     - Download is facilitated by lwdataexplorer::getCpodData()
# 2. CLEAN AND FILTER dataset. Specifically:
#     - Removes exact duplicates
#     - Converts dates to be readable to R
#     - Makes sure dates are within the desired range
#     - Filters projects, species, and qualities (precautionary measure)
#     - Drops detections recorded after the valid date period
#     - Removes unrecorded minutes
#     - Filters stations (the function will request specific user input for the station filter in the console)
# 3. QUALITY CHECK downloaded dataset (does not remove data). Checks:
#     - duplicate column names
#     - duplicate rows
#     - missing values (prints deployment ID and fields with missing data)
#     - deployment and recovery dates (checks if deployment date is later than recovery date)
#     - records beyond valid-data date (checks how many records occurred after the valid data period)
#     - lost minutes (counts rows where the total click count is below 4095)
#     - temperature continuity (detects jumps of 2°C or more)
# 4. SAVE dataset as .csv and .RData. Paths:
#     - ./minute_datasets/csv
#     - ./minute_datasets/RData
# 5. FORMAT dataset to align with IMIS standards. If:
#     - Only Lo quality is present in dataset: No formatting possible (IMIS only accepts Mod and Hi data)
#     - Lo + Hi AND/OR + Mod quality is present in dataset: Lo data is removed, columns are renamed, aggregated to Mod+Hi, 
#       and formatted to IMIS standard
#     - Regardless of whether Mod or/and Hi is present (excluding Lo), qualities will be renamed to Mod+Hi (details not necessary)
# 6. SAVE formatted dataset as a .csv. Paths
#     - ./minute_datasets/IMIS

# Load required packages and functions
source("pod_minute_functions/setup.R")

# Run pipeline
pod_dataset <- pod_pipeline(start_date = start_date, 
                            stop_date = stop_date, 
                            dataset_name = dataset_name, 
                            species = species, 
                            project_name = project_name, 
                            quality = quality)
