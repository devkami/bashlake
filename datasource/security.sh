#!/bin/bash

# Description:
# This script, part of a broader security system, is specialized for handling encrypted keychains
# related to various data sources. It provides a set of functions tailored for managing keychain files
# that store encrypted passwords for different data sources, using AES-256-CBC encryption.
# The script includes functionalities to:
# - Create or verify keychain files specific to data sources.
# - Retrieve and set private keys used for password encryption in data sources.
# - Decrypt passwords stored in the keychain and update source JSON with decrypted data.
#
# Functions:
#  getDatasourceKeychainFilepath: Retrieves the filepath for a keychain file associated with a given data source.
#  setDatasourceKeychain: Creates or verifies a keychain file for a specific data source, ensuring its integrity.
#  getDatasourcePrivateKey: Obtains the encryption key for a specific password in a data source keychain.
#  decryptDatasourcePassword: Decrypts a password stored in a data source keychain and updates the source JSON with the decrypted password.
#
# Usage:
# This script should be sourced in your bash environment to enable its functionalities.
# Utilize these functions to manage encryption keys and passwords for various data sources securely.
# This script relies on the functions defined in 'security/security.sh', so ensure it is accessible.
#
# Prerequisites:
# - jq must be installed on the system for JSON manipulation.
# - OpenSSL must be installed for handling encryption and decryption operations.
# - The script 'security/security.sh' must be present and sourced for underlying security operations.
#
# Author: Maicon de Menezes
# Creation Date: 08/01/2024
# Version: 0.1.0

# Import security script:
source ../security/security.sh

# getDatasourceKeychainFilepath: Gets the keychain file name/path for a specific data source.
# Arguments:
#   source_json: A JSON string representing the current state of the data source.
# Returns:
#   0 and The name/path of the keychain file on success.
#   1 on failure.
function getDatasourceKeychainFilepath(){
  local source_json=$1
  local origin=$(echo "$source_json" | jq -r '.source.origin')
  local company=$(echo "$source_json" | jq -r '.source.company')
  local type=$(echo "$source_json" | jq -r '.source.type')  
  local keychain_file="keychains/${origin}_${company}_${type##*_}.kc"
  
  if [ -n "$keychain_file" ]; then
    echo "$keychain_file"
    return 0
  else
    echo "Unable to create a keychain file name with the data source information provided" >&2
    return 1
  fi
}

# getDatasourceKeychainFilepath: Gets the keychain file name/path for a specific data source.
# Arguments:
#  source_json: A JSON string representing the data source.
#  public_key: The master key used to encrypt the keychain file.
# Returns: Success (0) and path of the keychain or failure (1) and the error message.
function setDatasourceKeychain(){
  local source_json=$1
  local public_key=$2  
  local keychain_filepath="$(getDatasourceKeychainFilepath "$source_json")"
  
  if [ -f "$keychain_filepath" ]; then
    
    if verifyKeychainEncryption "$keychain_filepath" "$public_key"; then
      echo "$keychain_filepath" 
      return 0
    else
      echo "Existing keychain file is not encrypted with the provided master key." >&2
      return 1
    fi

  else

    if createKeychain "$keychain_filepath" "$public_key"; then 
      echo "$keychain_filepath"
      return 0
    else 
      echo "Failed to create the keychain file." >&2
      return 1
    fi

  fi
}

# getDatasourcePrivateKey: Gets the encryption key for a password in a specific data source.
# Arguments: source_json: A JSON string representing the data source.
# Returns: The encryption key for the password.
function getDatasourcePrivateKey() {
  local source_json=$1  
  local public_key=$2
  
  keychain_file=$(setDatasourceKeychain "$source_json" "$public_key")

  local private_key="$(storePasswordInKeychain "$password" "$keychain_file" "$public_key")"
  if [ -n "$private_key" ]; then
    echo "$private_key"
    return 0
  else
    echo "Failed to store the password in the keychain file." >&2
    return 1
  fi  
}

# decryptDatasourcePassword: Updates the source JSON with the decrypted password.
# Arguments: source_json: A JSON string representing the data source with 'password' field.
# Returns: The source JSON with the decrypted password.
function decryptDatasourcePassword() {
  local source_json=$1
  local public_key=$2
  local encryption_key=$(echo "$source_json" | jq -r '.source.auth.password')
  local keychain_file=$(getDatasourceKeychainFilepath "$source_json")  
  local db_password=$(retrievePasswordFromKeychain "$encryption_key" "$keychain_file" "$public_key")
  updated_source_json=$(echo "$source_json" | jq --arg decrypted_password "$db_password" '.source.auth.password = $decrypted_password')
  echo "$updated_source_json"
}
