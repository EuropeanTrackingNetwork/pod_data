# Format data for IMIS

prepare_imis_data <- function(pod_dataset) {

  # STOP IF ONLY LO QUALITY IS SELECTED
  # Check which quality levels were selected/present
  qualities_present <- sort(unique(pod_dataset$quality))
  
  # Stop if only Lo quality is present
  if (all(qualities_present == 1)) {
    stop("Only Lo quality data present. IMIS only accepts Hi and Mod data - No IMIS dataset can be created")}
  
  # 2. REMOVE LOW-QUALITY DATA 
  # Lo quality data dropped from IMIS dataset. 
  pod_imis <- pod_dataset %>% dplyr::filter(quality != 1)
  
  # 3. RENAME COLUMNS TO IMIS NAMES 
  pod_imis <- pod_imis %>% 
    dplyr::rename(Deployment_fk = deployment_fk, Datetime..UTC. = time, Species = species, Milliseconds = milliseconds, 
                  Number_clicks_filtered = number_clicks_filtered, Number_clicks_total = number_clicks_total, Lost_minutes = lost_minutes,
                  Recorded = recorded, Dpm = dpm, Angle = angle, Quality = quality, Projectname = projectname, Projectcode = projectcode, 
                  IMIS_dataset_ID = imis_dataset_id, Station = station, Latitude = latitude, Longitude = longitude, Mooring_type = mooring_type, 
                  Receiver = receiver, Deploy_date_time = deploy_date_time, Recover_date_time = recover_date_time, 
                  Valid_data_until_datetime = valid_data_until_datetime)
  
  # 4. CHECK WHICH QUALITY LEVELS ARE PRESENT 
  qualities_present <- sort(unique(pod_imis$Quality)) 
  message("Quality levels present in IMIS data (Lo quality exluded): ", paste(qualities_present, collapse = ", "))
  
  # 5. AGGREGATE ONLY IF BOTH HI AND MOD EXIST
  # if dataset contains both Hi and Mod data, aggregate...
  message("Aggregating data and labelling all rows as Hi+mod")
  
  pod_imis <- pod_imis %>%
    dplyr::group_by(
      Projectname, Projectcode, IMIS_dataset_ID, Station, Datetime..UTC.,
      Latitude, Longitude, Mooring_type, Species, Receiver, Deployment_fk,
      Deploy_date_time, Recover_date_time, Valid_data_until_datetime
    ) %>%
    dplyr::summarise(
      Recorded = sum(Recorded, na.rm = TRUE),
      Milliseconds = sum(Milliseconds, na.rm = TRUE),
      Number_clicks_filtered = sum(Number_clicks_filtered, na.rm = TRUE),
      Dpm = sum(Dpm, na.rm = TRUE),
      Angle = median(Angle, na.rm = TRUE),
      Lost_minutes = ifelse(any(Lost_minutes == 1), 1, 0),
      Number_clicks_total = mean(Number_clicks_total, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(Quality = "Hi+mod")
  
  # 6. CONVERT DPM AND RECORDED TO 0/1 
  # Dpm and Recorded can only be 0 or 1 per minute 
  pod_imis <- pod_imis %>% 
    dplyr::mutate(Dpm = ifelse(is.na(Dpm) | Dpm == 0, 0, 1), Recorded = ifelse(is.na(Recorded) | Recorded == 0, 0, 1))
  
  # 7. REMOVE TEMPERATURE COLUMNS 
  # Temperature is not part of the final IMIS minute-dataset format
  temperature_columns <- intersect(c("Temperature_min", "Temperature_max"), names(pod_imis)) 
  if (length(temperature_columns) > 0) { 
    pod_imis <- pod_imis %>% 
      dplyr::select(-dplyr::all_of(temperature_columns))}
  
  # 8. REMOVE DUPLICATES 
  pod_imis <- pod_imis %>% dplyr::distinct()
  
  
  # 9. REORDER COLUMNS
  pod_imis <- pod_imis %>% 
    dplyr::select(Projectname, Projectcode, IMIS_dataset_ID, Station, Latitude, Longitude, Mooring_type, 
                   Species, Receiver, Quality, Datetime..UTC., Milliseconds, Number_clicks_filtered, Number_clicks_total, 
                   Lost_minutes, Recorded, Dpm, Angle, Deployment_fk, Deploy_date_time, Recover_date_time, Valid_data_until_datetime)
  
  # 10. FORMAT DATETIME
  pod_imis <- pod_imis %>% dplyr::mutate(Datetime..UTC. = format(Datetime..UTC., "%Y-%m-%d %H:%M:%S")) # make sure midnight is with 00:00

  message( "IMIS dataset prepared successfully!")
  message( "Final records: ", nrow(pod_imis))
  
  return(pod_imis)}

