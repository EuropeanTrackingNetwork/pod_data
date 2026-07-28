# pod_data
Download long-term POD datasets from ETN-underwater acoustics using the [R package _lwdataexplorer_](https://github.com/lifewatch/lwdataexplorer). Minute data is queried per ~10 days to avoid server-related issues. 

To access lwdataexplorer datasets, your ETN credentials (userid and password) must be filled in a .Renviron file. These credentials can be found when you log into the [ETN Data Platform](https://www.lifewatch.be/etn/). In the top right of the platform, click your name and choose "ETN R access." See your credentials to connect to the ETN database. 

Full tutorial to configure your credentials: https://inbo.github.io/etn/articles/authentication.html

The script is divided into the following steps: 
1. Download and check data per year. Subset data to certain projects or stations and quality control each field.
2. Standardize minute-resolution datasets for data publication (e.g. to MarineInfo, https://www.vliz.be/en/imis?module=dataset&dasid=8999).
3. Aggregation of data into hourly resolution.
4. Conversion of data into a DwC-A structure for EMODnet Biology and OBIS, which is composed of three files (event, occurrence and emof).
5. Quality control the DwC-A structure. 
