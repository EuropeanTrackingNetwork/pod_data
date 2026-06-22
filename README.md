# pod_data
Download long-term POD datasets using the [R package _lwdataexplorer_](https://github.com/lifewatch/lwdataexplorer). Minute data is downloaded every ~10 days to avoid server-related issues. 

Steps include: 
1. Download and check data per year. Subset data to certain projects or stations and quality control each field.
2. Standardize minute-resolution datasets for publication to IMIS.
3. Aggregation of data into hourly resolution.
4. Conversion of hourly resolution datasets into DwC-A and generate OBIS files.
5. Quality control final OBIS data. 
