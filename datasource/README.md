# Datasource Configuration Script

## Overview

This script, `datasource.sh`, provides a comprehensive solution for managing data source configurations, specifically tailored for MySQL databases. It features interactive prompts and functions to gather, validate, and securely store essential information about various data sources. Key capabilities include handling connection details, authentication credentials, synchronization settings, and secure password storage using keychain encryption.

## Functions

The script includes several functions, each with a specific role:

- ### `validateInput`: Validates user input based on specified criteria, ensuring data consistency and format adherence

- ### `getSingleWordInput`: Interactively gathers single-word inputs from the user, enforcing specific validation rules

- ### `chooseDataSourceType`: Offers a selection menu for the user to choose the type of data source

- ### `chooseSyncTargetMode`: Provides options for selecting synchronization target mode for data updates

- ### `chooseSyncPeriod`: Displays choices for synchronization period units, enabling the user to select a preferred option

- ### `getSourceDetails`: Collects and compiles basic details about the data source, such as title, origin, and company

- ### `getKeychainFilepath`: Determines and constructs the filepath for the keychain file based on the data source information

- ### `setKeychain`: Initializes and sets up the keychain file for storing sensitive data source information securely

- ### `getAuthDetails`: Gathers authentication details like host, port, and credentials, relevant to the MySQL database source

- ### `validateNumericInput`: Checks if the given input is a valid numeric value, crucial for settings like port numbers

- ### `validateSyncPeriod`: Validates the synchronization period input to ensure it aligns with predefined options

- ### `validateSyncTargetMode`: Ensures the chosen synchronization target mode is valid and recognized

- ### `getSyncDetails`: Collects synchronization-related settings, tailoring the data source configuration for updates

- ### `testConnection`: Attempts to establish a connection with the MySQL database using the provided credentials to verify their validity

- ### `buildDataSourceJson`: Constructs a comprehensive JSON configuration for the data source, encapsulating all gathered details

- ### `saveDataSourceJson`: Persists the constructed JSON configuration to a file, naming it according to the data source attributes

## Usage

Run the script in a Bash environment, and follow the interactive prompts to configure a MySQL data source. The script guides you through each step, ensuring all necessary details are correctly gathered and encrypted for security. Upon completion, a JSON file with the data source configuration is saved in a designated directory.

For detailed information on all possible technical specifications for a data source defined in JSON format by this script, please refer to the [Data Source Structure Specifications - JSON](specifications.md) documentation.

## Prerequisites

- jq must be installed for JSON parsing and manipulation.
- OpenSSL is required for encryption and decryption operations, particularly for secure password management.
- The script assumes MySQL-related utilities are available for database interactions.

### Author: [Maicon de Menezes](https://github.com/maicondmenezes)

### Creation Date: 26/12/2023

### Version: 0.1.0
