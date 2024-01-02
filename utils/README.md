# Utils Module

## Overview

The `utils` module in Bash scripting offers a set of utility scripts (`constants.sh`, `menus.sh`, `sysadmin_lib.sh`) that provide essential functionalities for scripting tasks. These include defining constants, interactive menus, system administration tasks, and more. This module is designed to enhance the efficiency and interactivity of Bash scripts, especially in projects requiring user input, system checks, and environment management

## Scripts in this Module

### `constants.sh`

- **Creation Date:** _29/12/2023_
- **Version:** _0.1.0_

Defines various constants and lists used across scripts, particularly in `datasource.sh`. This includes option names and descriptions for data source types, synchronization targets, periods, and ANSI color codes for output styling

### `menus.sh`

- **Creation Date:** _29/12/2023_
- **Version:** _0.1.0_

Provides utility functions for input validation and interactive option selection. It includes functions to check if an input is a valid number, verify if a number is within a specified range, and present a user-interactive selection menu

### `sysadmin_lib.sh`

- **Creation Date:** _19/11/2023_
- **Version:** _0.2.0_

A comprehensive library for system administration tasks. It includes functions for checking system compatibility, installing necessary packages, managing cron jobs, and verifying environmental variables. Ideal for scripts involving system-level operations and maintenance tasks

## Usage

Each script can be sourced independently based on the requirement:

1. Source `constants.sh` for accessing predefined constants and lists
2. Use `menus.sh` for input validation and interactive menus in scripts
3. Incorporate `sysadmin_lib.sh` for system administration tasks in your scripts

## Functions

### In `menus.sh`

- `isValidNumber`: Validates if the input is a valid number
- `isInRange`: Checks if a number is within a specified range
- `selectOption`: Displays a selection menu and captures user choice

### In `sysadmin_lib.sh`

- `checkSystemVersion`: Ensures compatibility with the system version
- `checkExpectInstall`, `checkPvInstall`, `checkJqInstall`: Verifies and installs necessary packages
- `checkCronJob`, `createCronJob`: Manages cron jobs
- `checkEnvironmentVars`: Validates the presence of required environment variables
- `getDiskSpace`, `logDiskSpaceFreed`: Monitors and logs disk space usage

### Author: [Maicon de Menezes](https://github.com/maicondmenezes)

## Notes

- Each script is designed to be lightweight and modular, easily integrated into larger projects
- `constants.sh` can be customized to fit the specific constants required in your project
- `menus.sh` and `sysadmin_lib.sh` require `log_lib.sh` from the `log` module for logging functionalities
