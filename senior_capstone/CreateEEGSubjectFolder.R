# Base path
base_path <- "/Volumes/ezzyatlab/experiments/NEvent/exp_eeg_v1"

# Loop over the specified range
for (i in 60:70) {
  # Create the subject folder name, e.g., sub-052, sub-053, ...
  subject_folder <- sprintf("sub-%03d", i) # Formats the number with leading zeros
  full_subject_path <- file.path(base_path, subject_folder)
  
  # Create the subject folder
  dir.create(full_subject_path, recursive = TRUE, showWarnings = FALSE)
  
  # Create 'beh' folder within the subject folder
  dir.create(file.path(full_subject_path, "beh"), showWarnings = FALSE)
  
  # Create 'eeg' folder and its subfolders
  eeg_path <- file.path(full_subject_path, "eeg")
  dir.create(eeg_path, showWarnings = FALSE)
  dir.create(file.path(eeg_path, "analysis"), showWarnings = FALSE)
  dir.create(file.path(eeg_path, "postproc"), showWarnings = FALSE)
  dir.create(file.path(eeg_path, "raw"), showWarnings = FALSE)
}

# Output message
cat("Folders created successfully.\n")

