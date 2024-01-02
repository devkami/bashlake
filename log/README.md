# Log Library Script

## Overview

The `log_lib.sh` script provides robust logging utilities for Bash scripts. It is designed to facilitate logging of messages and tracking the execution time of functions. Messages are outputted to both the console (stderr) and a specified log file. This script is particularly useful for debugging and monitoring script execution, as it appends log entries with timestamps to a log file while ensuring console output (stdout) remains unaffected

## Usage

To use this script's logging capabilities:

1. Source `log_lib.sh` in your main script

1. Set the `LOGS_FILENAME` environment variable to the desired path for your log file

1. Utilize the provided logging functions (`logMess`, `logFunc`, `log`) as required within your script

## Functions

The script includes the following logging functions:

- ### `logMess`: Logs a message with a timestamp to stderr and appends it to the log file

```bash
logMess "Your log message"
```

- ### `logFunc`: Logs the execution time of a specified function and its result to the log file
  
```bash
logFunc "functionName"
```

- ### `log`: Decides whether to log a message or a function's execution, based on the provided flag

```bash
log true "functionName" #for logging a function
log false "Your log  message" #for a simple log message
```

## Additional Notes

- The script automatically creates a `logs` directory and sets the log file name based on the current date
- It exports the `LOGS_FILENAME` variable for use in the main script
- The functions are designed to be flexible, allowing for easy integration into various types of Bash scripts

### Author: [Maicon de Menezes](https://github.com/maicondmenezes)

### Creation Date: 19/11/2023

### Version: 0.2.0
