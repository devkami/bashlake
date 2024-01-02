#!/bin/bash

# Description:
# This script provides a set of functions for creating, managing, and accessing encrypted keychain files.
# It allows users to securely store and retrieve passwords using AES-256-CBC encryption. The script
# includes functionalities to create a new keychain file, open and verify an existing keychain, 
# encrypt/decrypt passwords, and store/retrieve encrypted passwords from the keychain.

# Functions:
# checkMasterKey: Checks if the KDLSEC_MASTER_KEY environment variable is set. Exits the script with an error message if not set.
# createKeychain: Creates a new keychain file encrypted with a provided master key. Returns 0 on success, 1 if the file already exists.
# openKeychain: Opens and verifies a keychain file encrypted with a master key. Returns 0 and outputs the content if successful, 1 if verification fails.
# encryptPassword: Encrypts a given password using the AES-256-CBC encryption algorithm and the specified encryption key. Returns the encrypted password.
# generatePrivateKey: Generates a new random private key using base64 encoding.
# storePasswordInKeychain: Encrypts and stores a password with a randomly generated encryption key in a keychain file. Returns the encryption key on success.
# decryptPassword: Decrypts a given encrypted password using the specified decryption key. Returns the decrypted password.
# retrievePasswordFromKeychain: Searches for and decrypts a password stored in a keychain file using the associated encryption key. Returns the decrypted password on success.

# Usage:
# Source this script in your bash environment to access its functionalities.
# Use the functions to create keychain files, store and retrieve passwords, and manage encryption keys.
# Ensure that the KDLSEC_MASTER_KEY environment variable is set before using these functions.

# Prerequisites:
# OpenSSL must be installed on your system as it is used for encryption and decryption operations.
# The environment variable KDLSEC_MASTER_KEY should be set to your master encryption key.

# Author: Maicon de Menezes
# Creation Date: 02/01/2024
# Version: 0.1.0

#create folder to store keychain files
mkdir -p keychains

# checkMasterKey: Checks if the KDLSEC_MASTER_KEY environment variable is set.
# Exits the script with an error message if not set.
function checkMasterKey() {    
    if [ -z "$KDLSEC_MASTER_KEY" ]; then
        echo "Make sure to set the KDLSEC_MASTER_KEY environment variable."
        exit 1
    fi
}

# createKeychain: Creates a new keychain file encrypted with a provided master key.
# Arguments:
#     keychain_file: name/path of the keychain file
#     master_key: key used for the keychain file encryption
# Returns:
#     0 on success
#     1 if the file already exists.
function createKeychain() {    
    local keychain_file="$1"
    local master_key="$2"  

    if [ -e "$keychain_file" ]; then
        echo "The keychain file already exists."
        return 1
    fi

    local encrypted_content
    encrypted_content=$(echo "$keychain_file" | openssl enc -aes-256-cbc -a -pbkdf2 -pass pass:"$master_key" | base64 -w 0)

    echo "$encrypted_content" > "$keychain_file"
    return 0
}

# openKeychain: Opens and verifies a keychain file encrypted with a master key.
# Arguments: keychain_file (name/path of the keychain file),
#     keychain_file: name/path of the keychain file
#     master_key: key used for the keychain file encryption
# Returns:
#     0 and outputs the content if successful
#     1 if verification fails.
function openKeychain() {    
    local keychain_file="$1"
    local master_key="$2"  

    if [ ! -e "$keychain_file" ]; then
        echo "The keychain file does not exist."
        return 1
    fi

    local file_private_key
    read -r file_private_key < "$keychain_file"

    local decrypted_content
    decrypted_content=$(echo "$file_private_key" | base64 --decode | openssl enc -aes-256-cbc -d -a -pbkdf2 -pass pass:"$master_key")

    if [[ "$decrypted_content" == "$keychain_file" ]]; then
        tail -n +2 "$keychain_file"
        return 0
    else
        echo "File verification failed."
        return 1
    fi
}

# encryptPassword: This function encrypts a given password using the AES-256-CBC encryption algorithm.
# Arguments:
#     password: The plain text password that needs to be encrypted.
#     encryption_key: The encryption key used for encrypting the password.
# Returns:
#     Encrypted password, which is the Base64 encoded string of the encrypted binary data.
function encryptPassword() {    
    local password="$1"
    local encryption_key="$2"
    echo "$password" | openssl enc -aes-256-cbc -a -pbkdf2 -pass pass:"$encryption_key"
}

# generatePrivateKey: Generates a new random private key.
# Returns: New random base64 encode key.
function generatePrivateKey() { 
  openssl rand -base64 32 
}

# storePasswordInKeychain: Encrypt and store a password with it's random generated 
# encryption key in a keychain file.
# Arguments:
#     password: The plain text password that needs to be stored.
#     keychain_file: name/path of a existing keychain file to store the password.
#     master_key: key used for the keychain file encryption
# Returns:
#     0 and the random generated encryption key on success for future decryption.
#     1 on failure.
function storePasswordInKeychain() {    
    local password="$1"
    local keychain_file="$2"
    local master_key="$3"

    local private_key
    private_key=$(generatePrivateKey)

    local encrypted_password
    encrypted_password=$(encryptPassword "$password" "$private_key")

    if openKeychain "$keychain_file" "$master_key" >> /dev/null ; then
        echo "$private_key $encrypted_password" >> "$keychain_file"
        echo "$private_key"
        return 0
    else
        echo "Failed to store the password in the keychain." >&2
        return 1
    fi    
}

# decryptPassword: Decrypts a given encrypted password using a specified key.
# Arguments:
#     encrypted_password: The encrypted password that needs to be decrypted.
#     decryption_key: The key used for decryption.
# Returns:
#     The decrypted password.
function decryptPassword() {
    local encrypted_password="$1"
    local decryption_key="$2"
    echo "$encrypted_password" | openssl enc -aes-256-cbc -d -a -pbkdf2 -pass pass:"$decryption_key"
}

# retrievePasswordFromKeychain: Searches and decrypts a password stored in a keychain file.
# Arguments:
#     encryption_key: The encryption key associated with the stored password.
#     keychain_file: The name/path of the existing keychain file.
#     master_key: The key used for keychain file encryption.
# Returns:
#     0 and the decrypted password on success.
#     1 and an error message on failure.
function retrievePasswordFromKeychain() {
    local encryption_key="$1"
    local keychain_file="$2"
    local master_key="$3"

    # Get keychain file content
    local keychain_content
    keychain_content=$(openKeychain "$keychain_file" "$master_key")
    if [ $? -ne 0 ]; then
        echo "Failed to open the keychain file."
        return 1
    fi

     # Search for the encryption key and decrypt the password
    while IFS=' ' read -r key encrypted_password; do
        if [[ "$key" == "$encryption_key" ]]; then
            decryptPassword "$encrypted_password" "$encryption_key"
            return 0
        fi
    done <<< "$keychain_content"

    echo "Failed to retrieve the password from the keychain."
    return 1
}

# Main script execution
checkMasterKey  # Check if KDLSEC_MASTER_KEY is set
