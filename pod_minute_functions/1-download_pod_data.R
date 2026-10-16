# Download specified quality data in 10 day intervals within a given time range. 
# Unwanted data (species, station and project) is filtered out in the next step

download_pod_data <- function(start_date, stop_date, quality, interval_days = 10, usr, pwd) {
  # Read credentials from .Renviron
  usr <- Sys.getenv("userid")
  pwd <- Sys.getenv("pw")
  
  # Check that credentials are available
  if (usr == "" || pwd == "") {
    stop("Missing ETN credentials. Check your .Renviron file")}
  
  # read date intervals
  date_interval <- seq(as.Date(start_date), as.Date(stop_date), by = paste(interval_days, "days"))
  
  # handle instances when a 10 day grouping is not possible
  if (tail(date_interval, 1) < as.Date(stop_date)) {
    date_interval <- c(date_interval, as.Date(stop_date))}
  
  # create empty dataframe
  pod_dataset <- data.frame()
  
  # 10 day interval download loop
  for (i in 1:(length(date_interval) - 1)) {
    current_start <- date_interval[i]
    current_stop <- date_interval[i + 1]
    # message("Downloading: ", current_start, " to ",   current_stop)
    
    # Download each requested quality separately
    for (current_quality in quality) {
      message("Downloading: ", current_start," to ",current_stop)
      message("Quality: ", current_quality)
      podData <- lwdataexplorer::getCpodData(
        startdate = as.character(current_start),
        stopdate = as.character(current_stop),
        processing = "Raw",
        quality = current_quality,
        by = "1 min",
        usr = usr,
        pwd = pwd)
      # add downloaded chunk to dataset
      pod_dataset <- dplyr::bind_rows(pod_dataset, podData)
      message("Records downloaded so far: ", nrow(pod_dataset))}}
  
  return(pod_dataset)
}