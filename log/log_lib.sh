#!/bin/bash

# Description: This script provides logging utilities for outputting messages
# to both the console (stderr) and a log file. It supports logging simple messages with timestamps and tracking the execution time of functions.
# The script is designed to log messages to stderr without interfering with stdout and append them to a log file.
#
# Usage:
#   Source this script in your main script and call the log functions as required.
#   Ensure that the LOGS_FILENAME environment variable is set to the desired log file path.
#
# Functions:
#   logMess: Logs a message with a timestamp to stderr and appends it to the log file.
#   logFunc: Logs the execution time of a function and its result to the log file.
#   log: Decides whether to log a message or a function execution based on the flag provided.
#
# Author: Maicon de Menezes
# Creation Date: 19/11/2023
# Version: 0.2.0

mkdir -p "logs" 
LOGS_FILENAME="logs/$(date +\%Y-\%m-\%d).log"
touch "${LOGS_FILENAME}"
export LOGS_FILENAME

# logMess: Logs a simple message with a timestamp to the console (stderr) and to the log file.
# Usage: logMess "Your log message"
function logMess() {
    local message=$1
    local timestamp
    timestamp=$(date +"[%H:%M:%S]")    
    local log_entry="${timestamp} : ${message}"

    # Display the message on stderr
    echo "$log_entry" >&2
    # Append the message to the log file
    echo "$log_entry" >> "${LOGS_FILENAME}"
}



# logFunc: Executes a function, logs its runtime, and appends the result to the log file.
# Usage: logFunc "functionName"
function logFunc() {
    local func_name=$1
    local start_time=$SECONDS
    local timestamp
    timestamp=$(date +"[%H:%M:%S]")

    # Log the start time of the function
    echo "${timestamp} : Starting ${func_name}..." | tee -a "${LOGS_FILENAME}"

    # Call the function
    $func_name
    local ret_value=$?
    
    local end_time=$((SECONDS - start_time))
    timestamp=$(date +"[%H:%M:%S]")

    # Log the end time and outcome of the function
    if [ $ret_value -eq 0 ]; then
        echo "${timestamp} : ${func_name} : run time: ${end_time}s" | tee -a "${LOGS_FILENAME}"
    else
        echo "${timestamp} : ${func_name} failed after ${end_time}s" | tee -a "${LOGS_FILENAME}"
    fi
    return $ret_value
}

# log: Decides whether to log a message or a function execution based on the flag provided.
# Usage: log true "functionName" OR log false "Your log message"
function log() {
    local log_func=$1
    shift
    if [ "${log_func}" = true ]; then
        logFunc "$@"
    else
        logMess "$@"
    fi
}