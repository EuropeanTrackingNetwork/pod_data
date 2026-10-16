# Clean POD dataset and apply project, station, species and quality filters

clean_pod_data <- function(pod_dataset, stop_date, species, project_name, quality) {
  
  original_n <- nrow(pod_dataset)
  
  message("CLEANING DIAGNOSTICS")
  message("Original records: ", original_n)
  
  # 1. REMOVE EXACT DUPLICATES
  pod_clean <- pod_dataset %>%
    dplyr::distinct()
  
  message("After removing duplicates: ", nrow(pod_clean))
  
    # 2. CONVERT DATES (so R can read them, and interprets them as UTC time)
  pod_clean <- pod_clean %>%
    dplyr::mutate(time = as.POSIXct(time, tz = "UTC"), valid_data_until_datetime = as.POSIXct(valid_data_until_datetime,  tz = "UTC"))
  
  # 3. DATE RANGE (make sure times are within the desired range)
  pod_clean <- pod_clean %>%
    dplyr::filter(as.Date(time) <= as.Date(stop_date))
  
  message("After date filter: ", nrow(pod_clean))
  
  # 4. PROJECT FILTER
  if (length(project_name) > 0 && project_name[1] != "") {  # Only perform the project filter if the user actually supplied a project
    # message("Projects selected: ", paste(project_name, collapse = ", "))
    pod_clean <- pod_clean %>%
      dplyr::filter(projectname %in% project_name )
    
    message(  "Records after project filter: ",  nrow(pod_clean))}
  
  # 5. STATIONS FILTER
  # if (!is.null(stations_remove) && stations_remove != "") {  # Only perform the station filter if the user actually supplied a project.
  #   pod_clean <- pod_clean %>%
  #     dplyr::filter(!stringr::str_detect(station, stations_remove)) #Keep stations that do not match the removal pattern
  #   
  #   message("Stations removed: ", stations_remove)
  #   message( "Records after station filter: ", nrow(pod_clean))}
  
  # 5. SPECIES FILTER
  message( "Species requested: ", paste(species, collapse = ", "))
  message("Species present: ", paste(unique(pod_clean$species), collapse = ", "))
  
  pod_clean <- pod_clean %>%
    dplyr::filter(species == .env$species) # keep only requested spp
  
  message("After species filter: ", nrow(pod_clean))
  
  # 6. QUALITY FILTER (precautionary measure)
  message( "Quality requested: ", paste(quality, collapse = ", "))
  message("Quality present: ", paste(sort(unique(pod_clean$quality)),collapse = ", ")) # sort numerically
  
  pod_clean <- pod_clean %>%
    dplyr::filter(quality %in% .env$quality) # keep only requested qualities
  
  message("After quality filter: ", nrow(pod_clean))
  
  # 7. VALID DATA PERIOD (drop detections recorded after the valid date period)
  pod_clean <- pod_clean %>%
    dplyr::filter(time < valid_data_until_datetime) # remove detections whose time is after or the same as valid_date_until_datetime
  
  message("After valid-data-period filter: ", nrow(pod_clean))
  
  # 8. REMOVE UNRECORDED MINUTES
  pod_clean <- pod_clean %>%
    dplyr::filter(recorded != 0) # remove rows where in the recorded column have a value of 0 
  
  message("After unrecorded minutes filter: ", nrow(pod_clean))
  
  # 9. INTERACTIVE STATION SELECTION
  available_stations <- sort(unique(pod_clean$station))
  
  message("")
  message("AVAILABLE STATIONS:")

  print(available_stations)
  stations_input <- readline("\nWhich stations would you like to remove? Separate multiple stations with commas, or press Enter to keep all: ")
  
  if (trimws(stations_input) != "") {
    stations_remove <- trimws(unlist(strsplit(stations_input, ",")))
    
    pod_clean <- pod_clean %>%
      dplyr::filter(!station %in% stations_remove)
    
    message("")
    message("Stations removed: ", paste(stations_remove, collapse = ", "))
    message("Records after station filter: ", nrow(pod_clean))
  } else {
    message("")
    message("No stations removed")}
  
  # Final results
  message("")
  message("FINAL CLEANING RESULTS")
  message("Original records: ", original_n)
  message("Records removed: ",original_n - nrow(pod_clean))
  message("Final records: ", nrow(pod_clean))

  return(pod_clean)}
