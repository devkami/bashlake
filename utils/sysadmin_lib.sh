#!/bin/bash

# Description: This library script provides system administration utilities, including
# checking system version, installing necessary packages (like 'expect', 'pv', 'jq', and 'jshon'),
# managing cron jobs, verifying environment variables for backup scripts, and handling file and
# folder operations.
#
# Usage:
#   Source this script in your main script and call the provided functions as needed.
#   This script is dependent on 'log_lib.sh' for logging output.
#
# Functions:
#   checkSystemVersion: Checks if the script is running on Ubuntu 18.04 or higher.
#   checkExpectInstall: Verifies if 'expect' is installed and installs it if not.
#   checkPvInstall: Checks if 'pv' is installed and installs it if not.
#   checkCronJob: Checks if a specific cron job exists.
#   createCronJob: Adds a cron job if it does not exist.
#   checkEnvironmentVars: Validates that required environment variables are set.
#   getDiskSpace: Calculates disk space before cleanup.
#   logDiskSpaceFreed: Logs the amount of disk space freed.
#   checkJqInstall: Checks and installs 'jq' if needed for JSON parsing.
#   checkJshonInstall: Checks and installs 'jshon' if needed for JSON parsing and manipulation.
#   listFilesInFolder: Lists all filenames (excluding the folder path) in a given folder.
#   listFolderTree: Lists all subdirectories of a given folder.
#   isValidFolder: Checks if the provided path is a valid folder.
#   isFolderProvided: Checks if a folder path is provided.
#
# Author: Maicon de Menezes
# Creation Date: 19/11/2023
# Last Modified: 12/01/2024
# Version: 0.3.1

# Import the logging functions from log_lib.sh
source ../log/log_lib.sh 

# checkSystemVersion: Verifies that the script is running on Ubuntu 22.04.
# Arguments:
#   required_distro: the required Linux distribution (e.g. Ubuntu, Debian, etc.)
#   required_version: the minimum required version (e.g. 18.04, 20.04, etc.)
# Returns: 0 if the system version is supported, terminates the script otherwise
function checkSystemVersion() {
  local required_distro="$1"
  local required_version="$2"
  logMess "Checking system version..."

  local os_name=$(lsb_release -is)
  local os_version=$(lsb_release -rs)

  if [[ "$os_name" == "$required_distro" && "$(printf '%s\n' "$required_version" "$os_version" | sort -V | head -n1)" == "$required_version" ]]; then
    logMess "System version check passed."
    return 0
  else
    logMess "This script requires $required_distro $required_version or higher."
    exit 1
  fi
}

# checkExpectInstall: Checks for the `expect` utility and installs it if not present.
# Returns: 0 if `expect` is already installed, 1 if it was installed successfully, 2 otherwise.
function checkExpectInstall() {
  logMess "Checking for 'expect' utility..."
  if ! command -v expect &> /dev/null; then
    logMess "expect is not installed. Installing expect..."
    apt update
    apt install expect -y
    return $?
  else
    logMess "expect is already installed."
    return 0
  fi
}

# checkPvInstall: Checks and installs 'pv' if needed for progress visualization.
# Returns: 0 if 'pv' is already installed, 1 if it was installed successfully, 2 otherwise.
function checkPvInstall() {
  logMess "Checking for 'pv' utility..."
  if ! command -v pv &> /dev/null; then
    logMess "pv could not be found, attempting to install..."
    apt-get update && apt-get install -y pv
    return $?
  else
    logMess "pv is already installed."
    return 0
  fi
}

# checkCronJob: Checks if a specific cron job exists.
# Arguments: cron_job: the cron job to be checked.
# Returns: Success (0) if the cron job exists, 1 otherwise.
function checkCronJob() {
  local cron_job="$1"
  if crontab -l | grep -q "$cron_job"; then
    return 0
  else
    return 1
  fi
}

# createCronJob: Adds a cron job if it does not exist.
# Arguments: cron_job: the cron job to be added.
# Returns: Success (0) if the cron job was added, 1 otherwise.
function createCronJob() {
  local cron_job="$1"
  if checkCronJob "$cron_job"; then
    logMess "Cron job already exists: $cron_job"
    return 0
  else
    logMess "Adding cron job: $cron_job"
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    logMess "Cron job added: $cron_job"
  fi
}

# checkEnvironmentVars: Checks if each environment variable in the list provided is set.
# Arguments: a list of environment variables to be checked.
# Returns: 0 if all environment variables are set, 1 otherwise.
function checkEnvironmentVars() {
  logMess "Checking required environment variables..."
  local missing_vars=0
  local env_vars=("$@")
  
  for var in "${env_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
      logMess "Error: Environment variable $var is not set."
      missing_vars=1
    fi
  done
  
  if [[ $missing_vars -eq 0 ]]; then    
    return 0
  else
    logMess "Error: Missing environment variables."
    return 1
  fi
}

# getDiskSpace: Calculate disk space before cleanup
# Returns: the amount of disk space available in KB
function getDiskSpace() {
  df / | tail -n 1 | awk '{print $4}'
}

# logDiskSpaceFreed: Log the amount of disk space freed
# Arguments: space_before: the amount of disk space before cleanup
# Returns: the amount of disk space freed in KB
function logDiskSpaceFreed() {
  local space_before=$1
  local space_after=$(getDiskSpace)
  local space_freed=$((space_before - space_after))

  if [ $space_freed -lt 0 ]; then
    space_freed=$((space_freed * -1))
  fi

  log true "Disk space freed: ${space_freed} KB"
}

# checkJqInstall: Checks and installs 'jq' if needed for JSON parsing.
# Returns: 0 if 'jq' is already installed, 1 if it was installed successfully, 2 otherwise.
function checkJqInstall() {
  logMess "Checking for 'jq' utility..."
  if ! command -v jq &> /dev/null; then
    logMess "'jq' could not be found, attempting to install..."
    apt update && apt install -y jq
    local install_status=$?
    if [ $install_status -eq 0 ]; then
      logMess "'jq' installed successfully."
      return 1
    else
      logMess "Failed to install 'jq'."
      return 1
    fi
    return $install_status
  else    
    return 0
  fi
}

# Checks if a folder path is provided
# Arguments: folder: the folder to be checked.
# Returns: 0 if a folder path is provided, 1 otherwise.
function isFolderProvided() {
  local folder=$1
  if [ -z "$folder" ]; then
    logMess "No folder path provided."
    return 1
  fi
  return 0
}

# Checks if the provided path is a valid folder
# Arguments: folder: folder: the folder to be validated
# Returns: 0 if the path is a valid folder, 1 otherwise.
function isValidFolder() {
  local folder=$1
  if [ ! -d "$folder" ]; then
    logMess "The provided path is not a valid folder."
    return 1
  fi
  return 0
}

# listFolderTree: Lists all subdirectories of a given folder.
# Arguments:
#   root_folder: the folder to list subdirectories from.
# Returns:
#   0 and outputs the subdirectories if successful
#   1 if the provided path is not a folder.
function listFolderTree() {
  local root_folder="$1"

  if ! isFolderProvided "$root_folder" || ! isValidFolder "$root_folder"; then
    logMess "The provided path is not a valid folder."
    return 1
  fi

  for dir in $(find "$root_folder" -mindepth 1 -type d); do
    echo "$dir"
  done

  return 0
}

# listFilesInFolder: Lists all files of a given folder.
# Arguments: folder: the folder to list subdirectories from.
# Returns:
#   Success (0) and outputs the files if successful
#   Failure (1) if the provided path is not a folder.
function listFilesInFolder() {
  local folder="$1"

  if ! isFolderProvided "$folder" || ! isValidFolder "$folder"; then
    logMess "The provided path is not a valid folder."
    return 1
  fi

  for filepath in "$folder"/*; do
    if [ -f "$filepath" ]; then
      echo "$(basename "$filepath")"
    fi
  done
  return 0
}
