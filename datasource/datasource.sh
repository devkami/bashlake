#!/bin/bash

# Description:
# This script provides a comprehensive solution for managing data source configurations, 
# specifically tailored for MySQL databases. It includes a series of interactive prompts and 
# functions to gather, validate, and securely store essential information about various data 
# sources, such as connection details, authentication credentials, synchronization settings, and 
# more. The script utilizes keychain encryption for secure password storage and includes validation 
# logic to ensure data integrity.
#
# Functions:
#   validateInput: Validates user input based on specified criteria, ensuring data
#     consistency and format adherence.
#   getSingleWordInput: Interactively gathers single-word inputs from the user,
#     enforcing specific validation rules.
#   chooseDataSourceType: Offers a selection menu for the user to choose the type
#     of data source.
#   chooseSyncTargetMode: Provides options for selecting synchronization target mode
#     for data updates.
#   chooseSyncPeriod: Displays choices for synchronization period units, enabling
#     the user to select a preferred option.
#   getSourceDetails: Collects and compiles basic details about the data source, such
#     as title, origin, and company.
#   getKeychainFilepath: Determines and constructs the filepath for the keychain file
#     based on the data source information.
#   setKeychain: Initializes and sets up the keychain file for storing sensitive data
#     source information securely.
#   getAuthDetails: Gathers authentication details like host, port, and credentials,
#     relevant to the MySQL database source.
#   validateNumericInput: Checks if the given input is a valid numeric value, crucial
#     for settings like port numbers.
#   validateSyncPeriod: Validates the synchronization period input to ensure it aligns
#     with predefined options.
#   validateSyncTargetMode: Ensures the chosen synchronization target mode is valid
#     and recognized.
#   getSyncDetails: Collects synchronization-related settings, tailoring the data source
#     configuration for updates.
#   testConnection: Attempts to establish a connection with the MySQL database using
#     the provided credentials to verify their validity.
#   buildDataSourceJson: Constructs a comprehensive JSON configuration for the data
#     source, encapsulating all gathered details.
#   saveDataSourceJson: Persists the constructed JSON configuration to a file, naming
#     it according to the data source attributes.
#
# Usage:
#   Run the script in a Bash environment, and follow the interactive prompts.
#   The script guides you through each step, ensuring all necessary details are correctly gathered 
#   and encrypted for security.
#   Upon completion, a JSON file with the data source configuration is saved in a designated 
#   directory.
#
# Prerequisites:
#   jq must be installed for JSON parsing and manipulation.
#   OpenSSL is required for encryption and decryption operations, particularly for secure password 
#   management.
#   The script assumes MySQL-related utilities are available for database interactions.

# Authors: Maicon de Menezes
# Creation Date: 26/12/2023
# Version: 0.1.0

# Importing necessary scripts
source ../database/mysql_lib.sh
source ../utils/constants.sh
source ../utils/menus.sh
source ../security/security.sh


# validateInput: Validates user input based on the specified type.
# Arguments:
#     input_json: A JSON string containing the 'type' of input and the 'input' itself.
# Returns:
#     A JSON string with the validated input if validation is successful.
function validateInput() {
    local input_json=$1
    local type
    type=$(echo "$input_json" | jq -r '.type')
    local input
    input=$(echo "$input_json" | jq -r '.input')

    case $type in
        "origin"|"company")
            if [[ $input =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
                echo "{\"$type\":\"$input\"}"
            fi
            ;;
        "port")
            if [[ $input =~ ^[0-9]+$ ]]; then
                echo "{\"$type\":\"$input\"}"
            fi
            ;;
        *)
            echo "{\"$type\":\"$input\"}"
            ;;
    esac
}

# getSingleWordInput: Prompts the user for input and validates it as a single word according to the specified input type.
# Arguments:
#     prompt_message: Message to display when asking for input.
#     input_type: The type of input to validate (e.g., 'origin', 'company').
# Returns:
#     The validated input if successful.
function getSingleWordInput() {
    local prompt_message=$1
    local input_type=$2
    while true; do
        read -p "$prompt_message" input
        validation_json=$(validateInput "{\"type\":\"$input_type\",\"input\":\"$input\"}")
        if [[ $validation_json ]]; then
            echo "$input"
            break
        fi
        echo "Invalid input for $input_type."
    done
}

# chooseDataSourceType: Displays options for selecting the data source type and allows the user to choose one.
# Returns:
#     The selected data source type.
function chooseDataSourceType() {
    echo "Select the type of data source:" >&2
    selectOption SOURCE_TYPE_NAMES SOURCE_TYPE_DESCRIPTIONS
}

# chooseSyncTargetMode: Displays options for choosing the synchronization target mode and allows the user to choose one.
# Returns:
#     The selected synchronization target mode.
function chooseSyncTargetMode() {
    echo "Choose how to specify targets:" >&2
    selectOption SYNC_TARGET_NAMES SYNC_TARGET_DESCRIPTIONS
}

# chooseSyncPeriod: Displays options for choosing the synchronization period and allows the user to choose one.
# Returns:
#     The selected synchronization period.
function chooseSyncPeriod() {
    echo "Choose the period unit of time:" >&2
    selectOption SYNC_PERIOD_NAMES SYNC_PERIOD_DESCRIPTIONS
}

# getSourceDetails: Gathers details about the data source from the user.
# Returns:
#     A JSON string with the details of the data source.
function getSourceDetails() {
    echo "Enter details for the data source:" >&2
    read -p "Title (Descriptive title): " title >&2
    read -p "Description (Short description, optional): " description >&2
    local origin
    origin=$(getSingleWordInput "Origin (Single word, alphanumeric, starts with a letter): " "origin")
    local company
    company=$(getSingleWordInput "Company (Single word, alphanumeric, starts with a letter): " "company")
    local type
    type=$(chooseDataSourceType)

    echo "{\"source\":{\"title\":\"$title\",\"description\":\"$description\",\"origin\":\"$origin\",\"company\":\"$company\",\"type\":\"$type\"}}"
}

# getKeychainFilepath: Gets the keychain file name/path for a specific data source.
# Arguments:
#     source_json: A JSON string representing the current state of the data source.
# Returns:
#     0 and The name/path of the keychain file on success.
#     1 on failure.
function getKeychainFilepath(){
    local source_json=$1
    local origin
    origin=$(echo "$source_json" | jq -r '.source.origin')
    local company
    company=$(echo "$source_json" | jq -r '.source.company')
    local type
    type=$(echo "$source_json" | jq -r '.source.type')    
    local keychain_file="keychains/${origin}_${company}_${type}.kc"
    
    if [ -n "$keychain_file" ]; then
        echo "$keychain_file"
        return 0
    else
        echo "Unable to create a keychain file name with the data source information provided" >&2
        return 1
    fi
}

# setKeychain: Sets the keychain file for store data source sensitive data.
# Arguments:
#     source_json: A JSON string representing the current state of the data source.
# Returns:
#     0 and keychain_file: The name/path of the created keychain file.
#     1 on failure.
function setKeychain(){
    local source_json=$1
    mkdir -p keychains    
    keychain_filepath="$(getKeychainFilepath "$source_json")" && \
    createKeychain "$keychain_filepath" "$KDLSEC_MASTER_KEY"
    
    if [ $? -eq 0 ]; then
        return 0
    else
        echo "Failed to create the keychain file." >&2
        return 1
    fi
}

# getAuthDetails: Gathers authentication details for a specific data source.
# Arguments:
#     source_json: A JSON string representing the current state of the data source.
# Returns:
#     A JSON string updated with the authentication details for the data source.
function getAuthDetails() {
    local source_json=$1
    local source_type
    source_type=$(echo "$source_json" | jq -r '.source.type')

    if [ "$source_type" != "mysql_db" ]; then
        echo "Only MySQL database sources are accepted for now. Exiting." >&2
        exit 1
    fi
    
    read -p "Host (Server host address): " host >&2
    while true; do
        read -p "Port (Numeric port number): " port >&2
        if [[ $port =~ ^[0-9]+$ ]]; then
            break
        fi
        echo "Invalid input for Port." >&2
    done
    read -p "User (Database username): " user >&2
    read -s -p "Password (Database password): " password >&2
    echo >&2
    read -p "Database (Database name): " database >&2     

    keychain_file=$(getKeychainFilepath "$source_json")
    if ! openKeychain "$keychain_file" "$KDLSEC_MASTER_KEY" >> /dev/null; then
        setKeychain "$source_json"
    fi

    local encryption_key
    encryption_key="$(storePasswordInKeychain "$password" "$keychain_file" "$KDLSEC_MASTER_KEY")"
    
    # Constructing the auth JSON
    local auth_json
    auth_json=$(jq -n \
        --arg host "$host" \
        --arg port "$port" \
        --arg user "$user" \
        --arg password "$encryption_key" \
        --arg database "$database" \
        '{host: $host, port: ($port | tonumber), user: $user, password: $password, database: $database}')

    # Adding auth JSON to source_json
    local updated_source_json
    updated_source_json=$(echo "$source_json" | jq --argjson auth "$auth_json" '.source.auth = $auth')

    echo "$updated_source_json"
}

# validateNumericInput: Validates if the provided input is a numeric value.
# Arguments:
#     input: The input to be validated.
# Returns:
#     0 if the input is a valid numeric value, 1 otherwise.
function validateNumericInput() {
    local input=$1
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a numeric value."
        return 1
    fi
    return 0
}

# validateSyncPeriod: Validates if the provided input is a valid synchronization period.
# Arguments:
#     input: The synchronization period to be validated.
# Returns:
#     The valid synchronization period if successful, or exits with 1 on failure.
function validateSyncPeriod() {
    local input=$1
    local valid_period=$(echo "$sync_period_types" | jq -r "to_entries | .[] | select(.key == \"$input\") | .value.name")
    if [ -n "$valid_period" ]; then
        echo "$valid_period"
    else
        return 1
    fi
}

# validateSyncTargetMode: Validates if the provided input is a valid synchronization target mode.
# Arguments:
#     input: The synchronization target mode to be validated.
# Returns:
#     The valid synchronization target mode if successful, or exits with 1 on failure.
function validateSyncTargetMode() {
    local input=$1
    local valid_target_mode=$(echo "$sync_targets_options" | jq -r "to_entries | .[] | select(.key == \"$input\") | .key")
    if [ -n "$valid_target_mode" ]; then
        echo "$valid_target_mode"
    else
        return 1
    fi
}

# getSyncDetails: Gathers synchronization details for a MySQL database data source.
# Arguments:
#     source_json_ref: A reference to a JSON string representing the current state of the data source.
# Returns:
#     A JSON string updated with the synchronization details for the data source.
function getSyncDetails() {
    local source_json_ref=$1
    local source_type
    source_type=$(echo "${source_json_ref}" | jq -r '.source.type')

    if [ "$source_type" == "mysql_db" ]; then
        echo "Enter Synchronization details for the Data Source:" >&2

        # Validar e obter a frequência
        local frequency
        while true; do
            read -p "Frequency (How often to update, numeric): " frequency >&2
            if isValidNumber "$frequency"; then
                break
            fi
            echo "Invalid input. Please enter a numeric value." >&2
        done

        # Escolher o período de sincronização e o modo de definição dos alvos
        local period_type
        period_type=$(chooseSyncPeriod)
        local target_mode
        target_mode=$(chooseSyncTargetMode)

        local targets=""
        case $target_mode in
            "List Selection")
                echo "Option to select from a list is not implemented yet." >&2
                ;;
            "Direct Input")
                read -p "Type the targets directly: " targets >&2
                ;;
            "Update All")
                targets='"*"'
                ;;
            *)
                echo "Invalid target mode. Please try again." >&2
                exit 1
                ;;
        esac
        
        local sync_json="{\"frequency\":$frequency,\"period\":\"$period_type\",\"targets\":$targets}"
        source_json_ref=$(echo "${source_json_ref}" | jq --argjson sync "$sync_json" '. + {sync: $sync}')

        echo "${source_json_ref}"
        return 0
    else
        echo "Only MySQL database sources are accepted for now. Exiting." >&2
        return 1
    fi
}

# testConnection: Tests the database connection using the provided details.
# Arguments:
#     source_json: A JSON string containing the connection details to be tested.
# Returns:
#     The source JSON if the connection is successful, or prompts for re-entry of details if failed.
function testConnection() {
    local source_json=$1
    local encryption_key
    encryption_key=$(echo "$source_json" | jq -r '.source.auth.password')
    local keychain_file
    keychain_file=$(getKeychainFilepath "$source_json")    
    local db_password
    db_password=$(retrievePasswordFromKeychain "$encryption_key" "$keychain_file" "$KDLSEC_MASTER_KEY")
    updated_source_json=$(echo "$source_json" | jq --arg decrypted_password "$db_password" '.auth.password = $decrypted_password')

    if ! checkMySQLConnection "$updated_source_json"; then
        read -p "Connection failed. Recreate connection details? (yes/no): " choice >&2         
        if [ "$choice" == "yes" ]; then
            local new_auth_json
            new_auth_json=$(getAuthDetails "$updated_source_json")
            # Replace the auth part in the source_json and retest the connection
            local updated_source_json
            updated_source_json=$(echo "$updated_source_json" | jq --argjson newAuth "$new_auth_json" '.auth = $newAuth')
            testConnection "$updated_source_json"
        else
            exit 1
        fi
    else
      echo "$updated_source_json"
    fi
}

# saveDataSourceJson: Saves the provided data source JSON to a file.
# Arguments:
#     data_source_json: The JSON string representing the data source to be saved.
# Returns:
#     A message indicating the filename where the data source JSON is saved.
function buildDataSourceJson() {
    local source_details_json
    source_details_json=$(getSourceDetails)
    local auth_details_json
    auth_details_json=$(getAuthDetails "$source_details_json")
    local updated_source_json
    updated_source_json=$(testConnection "$auth_details_json")
    updated_source_json=$(getSyncDetails "$updated_source_json")

    # Add an empty schema object to the updated_source_json
    updated_source_json=$(echo "$updated_source_json" | jq '. + {"schema": {}}')

    # Return the final datasource JSON
    echo "$updated_source_json"
}

# saveDataSourceJson: Saves the provided data source JSON to a file.
# Arguments:
#     data_source_json: The JSON string representing the data source to be saved.
# Returns:
#     A message indicating the filename where the data source JSON is saved.
function saveDataSourceJson() {
    local data_source_json=$1
    local origin
    origin=$(echo "$data_source_json" | jq -r '.source.origin')
    local company
    company=$(echo "$data_source_json" | jq -r '.source.company')
    local type
    type=$(echo "$data_source_json" | jq -r '.source.type')
    local filename="sources/${origin}_${company}_${type}.json"
    echo "$data_source_json" > "$filename"
    echo "Data source JSON file saved as $filename"
}