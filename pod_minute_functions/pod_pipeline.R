# POD pipeline

pod_pipeline <- function(start_date, stop_date, dataset_name, species, project_name, quality) {
  
  message("===================================")
  message("STARTING POD PIPELINE INPUT")
  message("Period: ", start_date, " to ", stop_date)
  message("Species: ", paste(species, collapse = ", "))
  message("Quality: ", paste(quality, collapse = ", "))
  message("===================================")
  
  # message("")
  # message("===================================")
  # message("1. ACESSING PROJECTS YOU HAVE ACCESS TO")
  # message("===================================")
  # 
  # projects <- lwdataexplorer::listEtnProjects()
  # projects
  # View(projects)
  #  print(projects)
  
  # Download pod data (only specified qualities + all spp, stations and projects)
  message("")
  message("===================================")
  message("1. DOWNLOADING SPECIFIED QUALITIES")
  message("===================================")
  
  # Convert numeric quality codes to getpodData labels
  quality_map <- c("1" = "Lo",  "2" = "Mod", "3" = "Hi")
  download_quality <- unname(quality_map[as.character(quality)]) 
  
  pod_dataset <- download_pod_data(
    start_date = start_date,
    stop_date = stop_date,
    quality = download_quality, # only download qualities defined in run_pod.R
    usr = Sys.getenv("ETN_USER"), # ETN credentials
    pwd = Sys.getenv("ETN_PASSWORD")) # ETN credentials
  
  # Filter (drop undesired spp, stations and projects) and clean (drop duplicates, convert dates, etc.)
  message("")
  message("===================================")
  message(" 2. FILTERING SPP, STATIONS AND PROJECTS, AND CLEANING")
  message("===================================")
  
  pod_dataset <- clean_pod_data(
    pod_dataset = pod_dataset,
    stop_date = stop_date,
    species = species,
    project_name = project_name,
    #stations_remove = stations_remove,
    quality = quality)
  
  # Quality control
  message("")
  message("===================================")
  message("3. CHECKING QUALITY")
  message("===================================")
  
  qc_passed <- check_pod_data(pod_dataset)
  
  message("")
  if (!qc_passed) {
    stop("Final QC checks failed. ", "The dataset was not saved.")}
  message("QC completed successfully!")
  
  # Save cleaned, filtered and checked pod dataset
  message("")
  message("===================================")
  message("4. SAVING POD DATASET")
  message("===================================")
  
  clean_dataset_output <- save_pod_data(
    pod_dataset = pod_dataset,
    start_date = start_date,
    stop_date = stop_date,
    dataset_name = dataset_name,
    quality = quality)
 
  # Format and agreggate pod dataset for IMIS upload
  message("")
  message("===================================")
  message("5. FORMATTING FOR IMIS")
  message("===================================")
  
  imis_dataset <- prepare_imis_data(pod_dataset)
  
  # Save formatted IMIS dataset 
  message("")
  message("===================================")
  message("6. SAVING IMIS DATASET")
  message("===================================")
  imis_output <- save_imis_data(
    pod_dataset = imis_dataset,
    start_date = start_date,
    stop_date = stop_date,
    dataset_name = dataset_name,
    quality = quality)
}
  