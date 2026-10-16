# save clean pod dataset as .csv and .RData

save_pod_data <- function(pod_dataset, start_date, stop_date, dataset_name = "", quality, folder) {
  
  quality_label <- paste(quality, collapse = "_")
  
  # RData pod dataset
  r_folder <- "outputs/RData"
  r_filename <- file.path(r_folder, paste0(dataset_name,   "_",  start_date,   "_to_",  stop_date,  "_quality_",  quality_label,  ".RData"  ))
  
  #if folder doesn't exist, create one
  if (!dir.exists(r_folder)) {
    dir.create(r_folder, recursive = TRUE)}
   
  save(pod_dataset, file = r_filename)

  message("RData saved successfully: ", r_filename)

  # CSV pod dataset
  csv_folder <- "outputs/csv"
  csv_filename <- file.path( csv_folder, paste0(  dataset_name,  "_",  start_date,  "_to_",  stop_date,  "_quality_",  quality_label,  ".csv"  ) )
  
  # if folder doesn't exist, create one
  if (!dir.exists(csv_folder)) {
    dir.create(csv_folder, recursive = TRUE)}
  
  write.csv(  pod_dataset,  csv_filename,  row.names = FALSE )
  
  message("CSV saved successfully: ", csv_filename)
  
  # Return both paths
  # return(list( rdata = r_filename,csv = csv_filename))
}

#  save formatted dataset ready for IMIS upload

save_imis_data <- function(pod_dataset, start_date, stop_date, dataset_name = "", quality, folder) {
  
  quality_label <- paste(quality, collapse = "_")
  
  # RData IMIS dataset
  # r_folder <- "outputs/IMIS"
  # r_filename <- file.path(r_folder,paste0("IMIS_",start_date,"_to_",stop_date,"_",dataset_name,"_quality_",quality_label,".RData"))
  # 
  # 
  # if (!dir.exists(r_folder)) {
  #   dir.create(r_folder, recursive = TRUE)}
  # 
  # save(pod_dataset, file = r_filename)
  # 
  # message("IMIS RData saved successfully:", r_filename)
  # 
  
  # CSV IMIS dataset
  csv_folder <- "outputs/IMIS"
  csv_filename <- file.path(csv_folder,paste0("IMIS_",start_date,"_to_",stop_date,"_",dataset_name,"_quality_",quality_label,".csv"))
  
  if (!dir.exists(csv_folder)) {
    dir.create(csv_folder, recursive = TRUE)}
  
  write.csv(pod_dataset, csv_filename, row.names = FALSE)
  
  message("IMIS CSV saved successfully: ", csv_filename)
  
  # return(list(rdata = r_filename,csv = csv_filename))
}