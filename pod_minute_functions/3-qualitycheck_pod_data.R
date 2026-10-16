# Quality check of downloaded pod dataset (does not remove data)

check_pod_data <- function(pod_dataset) {
  
  # assume at first there are no problems with the data
  checks_passed <- TRUE
  
  # 1. Check for duplicated column names
  if (anyDuplicated(names(pod_dataset)) > 0) {  # get column names and check weather any appear more than once
    message("FAIL: duplicated column names found")
    checks_passed <- FALSE
  } else {
    message("PASS: no duplicated column names")}
  
  # 2. Check for missing values
  # na_count <- sum(is.na(pod_dataset)) # count all NAs in entire dataset
  # if (na_count > 0) {
  #   message("WARNING: ", na_count, " missing values found")
  # } else {
  #   message("PASS: no missing values")}

  # 2. Check for duplicate rows
  duplicate_rows <- sum(duplicated(pod_dataset))
  if (duplicate_rows > 0) {
    message("FAIL: ", duplicate_rows," duplicated rows found" )
    checks_passed <- FALSE
  } else {
    message("PASS: no duplicated rows")}
  
  # 3. Check for missing values
  na_count <- sum(is.na(pod_dataset))
  
  if (na_count > 0) {
    message("WARNING: ", na_count, " missing values found")
    message("")
    message("Missing values found in the following deployments: ")
    
    # Get deployments containing missing values
    deployments_with_na <- unique(pod_dataset$deployment_fk[rowSums(is.na(pod_dataset)) > 0])
    
    # Report missing fields for each deployment
    for (deployment in deployments_with_na) {
      deployment_data <- pod_dataset %>%
        dplyr::filter(deployment_fk == deployment)
      # Find which columns contain at least one NA in this deployment
      missing_fields <- names(deployment_data)[
        sapply(deployment_data, function(x) any(is.na(x)))]
      message("Deployment ID: ", deployment, " | Fields missing: ", paste(missing_fields, collapse = ", "))}
    message("")
  } else {message("PASS: no missing values")}
  
  # 4. Check deployment and recovery dates
  if (all(c("Deploy_date_time","Recover_date_time") %in% names(pod_dataset))) { # checks if both required columns exist
    deploy_date <- as.POSIXct(pod_dataset$Deploy_date_time, tz = "UTC") # convert deploy_date column into R date-time object
    recover_date <- as.POSIXct(pod_dataset$Recover_date_time, tz = "UTC") # convert recover_date column into R date-time object
    invalid_deployments <- sum(deploy_date > recover_date,na.rm = TRUE) # checks if deployment date is later than recovery date
    
    if (invalid_deployments > 0) {
      message( "FAIL: ", invalid_deployments, " records have deployment dates after recovery dates")
      checks_passed <- FALSE
    } else {
      message("PASS: deployment dates are not after recovery dates")}}
  
  # 5. Check records beyond valid-data date
  if (all(c("Datetime..UTC.","Valid_data_until_datetime") %in% names(pod_dataset))) { #check both required columns exist
    datetime <- as.POSIXct( pod_dataset$Datetime..UTC., tz = "UTC")
    valid_until <- as.POSIXct(pod_dataset$Valid_data_until_datetime,  tz = "UTC")
    after_valid_date <- sum(datetime > valid_until,na.rm = TRUE) # checks how many records occurred after valid data period
    
    if (after_valid_date > 0) {
      message( "FAIL: ",  after_valid_date, " records occur after valid_data_until_datetime" )
      checks_passed <- FALSE
    } else {
      message("PASS: no records occur after valid_data_until_datetime")}}
  
    # 6. Check lost minutes
  if (all(c("Receiver", "Number_clicks_total", "Lost_minutes") %in% names(pod_dataset))) {  # check if all required columns exist
    # Records explicitly marked as lost minutes (Lost_minutes == 1)
    confirmed_lost_minutes <- sum(pod_dataset$Lost_minutes == 1,na.rm = TRUE)
    message( "Lost minutes explicitly flagged in data: ", confirmed_lost_minutes)
    
    # Potential lost minutes based on C-POD click count
    potential_lost_minutes <- pod_dataset %>% # create subset of potentially problematic records
      dplyr::filter(grepl("C-POD", Receiver, ignore.case = TRUE), Number_clicks_total < 4095) # counts rows where records are from a C-POD and where the total click count is below 4095
    
    if (nrow(potential_lost_minutes) > 0) {
      message("WARNING: ",nrow(potential_lost_minutes)," potential lost-minute C-POD records ","detected based on Number_clicks_total < 4095.")
    } else {
      message("PASS: no potential C-POD lost minutes detected")}}
  
  # 7. Check temperature continuity
  # Check whether temperature changes by 2°C or more between consecutive minutes within the same deployment
  # Sometimes, there is a jump and this means that the data jumps from correct and current data to old data
  if (all(c("deployment_fk","time","temperature_min") %in% names(pod_dataset))) {  # check necessary columns are present
    deployments <- unique(pod_dataset$deployment_fk) # find all deployments
    temperature_failures <- 0 # start counter
    
    for (deployment_n in deployments) {  # loop through each deployment
      data_deploy <- pod_dataset %>%
        dplyr::filter(deployment_fk == deployment_n) %>% # keep only records from current deployment
        dplyr::arrange(time) #arrange chronologically
      temperatures <- data_deploy$temperature_min
      
      # Remove missing temperatures
      temperatures <- temperatures[!is.na(temperatures)] # keep only temperatures that aren't NA
      
      # Check for temperature jumps of 2degC or more
      if (length(temperatures) >= 2 &&
          any(abs(diff(temperatures)) >= 2)) { # compute differences between two consecutive temperatures. Take absolute valaue
        temperature_failures <- temperature_failures + 1}} # increase ocunter
    
    if (temperature_failures > 0) {
      message("WARNING: ", temperature_failures," deployment(s) showed a temperature jump of 2°C or more" )
    } else {
      message("PASS: no temperature jumps of 2°C or more detected")}}
  
    #View(pod_dataset)
  return(checks_passed)}