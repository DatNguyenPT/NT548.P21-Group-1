#!/bin/bash

# Set the parent directory where the modules are located
MODULES_DIR="./Modules"

# Iterate through each folder in the Modules directory
for folder in "$MODULES_DIR"/*/; do
  if [ -d "$folder" ]; then
    echo "Processing folder: $folder"
    
    # Clear the rpdk.log file if it exists
    LOG_FILE="$folder/rpdk.log"
    if [ -f "$LOG_FILE" ]; then
      > "$LOG_FILE"  # Clears the log file
      echo "Cleared rpdk.log for $folder"
    else
      echo "No rpdk.log found in $folder"
    fi
    
  fi
done``
