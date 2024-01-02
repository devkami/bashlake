#!/bin/bash

# Description: This library script provides system administration utilities, including
# checking system version, installing necessary packages (like 'expect', 'pv', 'jq', and 'jshon'),
# managing cron jobs, and verifying environment variables for backup scripts.
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
#
# Author: Maicon de Menezes
# Creation Date: 19/11/2023
# Version: 0.2.0

# Import the logging functions from log_lib.sh
source ../log/log_lib.sh

# checkSystemVersion: Verifies that the script is running on Ubuntu 22.04.
# Usage: checkSystemVersion
function checkSystemVersion() {
    logMess "Checking system version..."
    local os_name=$(lsb_release -is)
    local os_version=$(lsb_release -rs)

    # Using sort and version sort to compare the version is greater or equal to 18.04
    if [[ "$os_name" == "Ubuntu" && "$(printf '%s\n' "18.04" "$os_version" | sort -V | head -n1)" == "18.04" ]]; then
        logMess "System version check passed."
        return 0
    else
        logMess "This script is for Ubuntu 18.04 or higher."
        exit 1
    fi
}

# checkExpectInstall: Checks for the `expect` utility and installs it if not present.
# Usage: checkExpectInstall
function checkExpectInstall() {
    logMess "Checking for 'expect' utility..."
    if ! command -v expect &> /dev/null; then
        logMess "expect is not installed. Installing expect..."
        sudo apt update
        sudo apt install expect -y
        return $?
    else
        logMess "expect is already installed."
        return 0
    fi
}

# checkPvInstall: Checks and installs 'pv' if needed for progress visualization.
# Usage: checkPvInstall
function checkPvInstall() {
    logMess "Checking for 'pv' utility..."
    if ! command -v pv &> /dev/null; then
        logMess "pv could not be found, attempting to install..."
        sudo apt-get update && sudo apt-get install -y pv
        return $?
    else
        logMess "pv is already installed."
        return 0
    fi
}

# checkCronJob: Checks if a specific cron job exists.
# Usage: checkCronJob "cron job string"
function checkCronJob() {
    local cron_job="$1"
    if crontab -l | grep -q "$cron_job"; then
        return 0
    else
        return 1
    fi
}

# createCronJob: Adds a cron job if it does not exist.
# Usage: createCronJob "cron job string"
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
# Usage: checkEnvironmentVars "VAR1" "VAR2" "VAR3"
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
        logMess "All required environment variables are set."
        return 0
    else
        return 1
    fi
}

# getDiskSpace: Calculate disk space before cleanup
function getDiskSpace() {
    df / | tail -n 1 | awk '{print $4}'
}

# logDiskSpaceFreed: Log the amount of disk space freed
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
# Usage: checkJqInstall
function checkJqInstall() {
    logMess "Checking for 'jq' utility..."
    if ! command -v jq &> /dev/null; then
        logMess "'jq' could not be found, attempting to install..."
        sudo apt update && sudo apt install -y jq
        local install_status=$?
        if [ $install_status -eq 0 ]; then
            logMess "'jq' installed successfully."
        else
            logMess "Failed to install 'jq'."
        fi
        return $install_status
    else
        logMess "'jq' is already installed."
        return 0
    fi
}