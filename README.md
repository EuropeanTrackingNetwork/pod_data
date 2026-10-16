# pod_data
Download minute and/or hourly resolution long-term POD datasets from ETN-underwater acoustics using the [R package _lwdataexplorer_](https://github.com/lifewatch/lwdataexplorer). 

To access lwdataexplorer datasets, your ETN credentials (userid and password) must be filled in a .Renviron file. These credentials can be found when you log into the [ETN Data Platform](https://www.lifewatch.be/etn/). In the top right of the platform, click your name and choose "ETN R access." See your credentials to connect to the ETN database. 

Full tutorial to configure your credentials: https://inbo.github.io/etn/articles/authentication.html

Minute data can be downloaded via run_pod_minute.R or cpod_pipeline.Rmd. Minute data is queried per ~10 days to avoid server-related issues. Hourly data can only be downloaded via cpod_pipeline.Rmd.

run_pod_minute.R works by sourcing pod_pipeline.R, which calls the functions in pod_minute_functions.
It.s pipeline is as follows:
1. DOWNLOAD data. Specifically:
    - It downloads only user specified quality data at minute-resoution in 10 day intervals within the given time range
    - Download is facilitated by lwdataexplorer::getCpodData()
2. CLEAN AND FILTER dataset. Specifically:
    - Removes exact duplicates
    - Converts dates to be readable to R
    - Makes sure dates are within the desired range
    - Filters projects, species, and qualities (precautionary measure)
    - Drops detections recorded after the valid date period
    - Removes unrecorded minutes
    - Filters stations (the function will request specific user input for the station filter in the console)
3. QUALITY CHECK downloaded dataset (does not remove data). Checks:
    - duplicate column names
    - duplicate rows
    - missing values (prints deployment ID and fields with missing data)
    - deployment and recovery dates (checks if deployment date is later than recovery date)
    - records beyond valid-data date (checks how many records occurred after the valid data period)
    - lost minutes (counts rows where the total click count is below 4095)
    - temperature continuity (detects jumps of 2°C or more)
4. SAVE dataset as .csv and .RData. Paths:
    - ./minute_datasets/csv
    - ./minute_datasets/RData
5. FORMAT dataset to align with IMIS standards. If:
    - Only Lo quality is present in dataset: No formatting possible (IMIS only accepts Mod and Hi data)
    - Lo + Hi AND/OR + Mod quality is present in dataset: Lo data is removed, columns are renamed, aggregated to Mod+Hi,
      and formatted to IMIS standard
    - Regardless of whether Mod or/and Hi is present (Lo is excluded), qualities will be renamed to Mod+Hi (details not necessary)
6. SAVE formatted dataset as a .csv. Paths
    - ./minute_datasets/IMIS

cpod_pipeline.Rmd is divided into the following steps: 
1. Download and check data per year. Subset data to certain projects or stations and quality control each field.
2. Standardize minute-resolution datasets for data publication (e.g. to MarineInfo, https://www.vliz.be/en/imis?module=dataset&dasid=8999).
3. Aggregation of data into hourly resolution.
4. Conversion of data into a DwC-A structure for EMODnet Biology and OBIS, which is composed of three files (event, occurrence and emof).
5. Quality control the DwC-A structure. 

If you want to request a DOI for the dataset, fill out the form at https://marineinfo.org/metasubmit/
