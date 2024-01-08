#!/bin/bash

# Description:
# This script provides a comprehensive suite of functions for managing encrypted keychain files.
# It enables secure storage and retrieval of passwords using AES-256-CBC encryption.
# The script includes capabilities to:
# - Create new keychain files encrypted with a given public key.
# - Open and verify existing keychain files using their corresponding public key.
# - Encrypt and decrypt passwords.
# - Store passwords in a keychain with unique encryption keys and retrieve them securely.
#
# Functions:
#  createKeychain: Generates a new keychain file encrypted with a specified public key.
#  openKeychain: Opens a keychain file and verifies its integrity using the provided public key.
#  encryptPassword: Encrypts a password using AES-256-CBC algorithm and a provided encryption key.
#  generatePrivateKey: Creates a new random private key using base64 encoding.
#  storePasswordInKeychain: Encrypts a password and stores it in a keychain file.
#  decryptPassword: Decrypts an encrypted password and returns the original password.
#  retrievePasswordFromKeychain: Locates and decrypts a password in a keychain file.
#  verifyKeychainEncryption: Checks if a keychain file is properly encrypted.
#
# Prerequisites:
# - OpenSSL must be installed on the system, as it's used for encryption and decryption operations.
#
# Author: Maicon de Menezes
# Creation Date: 02/01/2024
# Version: 0.2.1

#create folder to store keychain files
mkdir -p keychains

# createKeychain: Creates a new keychain file encrypted with a provided public key.
# Arguments:
#     keychain_file: name/path of the keychain file
#     public_key: key used for the keychain file encryption
# Returns:
#     0 on success
#     1 if the file already exists.
function createKeychain() {    
    local keychain_file="$1"
    local public_key="$2"  
    local keychain_filename="${keychain_file##*/}"; keychain_filename="${keychain_filename%.*}"

    if [ -e "$keychain_file" ]; then
        echo "The keychain file already exists."      
        return 1
    fi
    
    local encrypted_content=$(encryptPassword "$keychain_filename" "$public_key")

    echo "$encrypted_content" > "$keychain_file"
    return 0
}

# openKeychain: Opens and verifies a keychain file encrypted with a public key.
# Arguments:
#     keychain_file: The name/path of the keychain file.
#     public_key: The key used for keychain file encryption.
# Returns:
#     0 and outputs the content if successful
#     1 if verification fails.
function openKeychain() {    
    local keychain_file="$1"
    local public_key="$2"    

    if verifyKeychainEncryption "$keychain_file" "$public_key"; then
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
#     public_key: The encryption key used for encrypting the password.
# Returns:
#     Encrypted password, which is the Base64 encoded string of the encrypted binary data.
function encryptPassword() {    
    local password="$1"
    local public_key="$2"
    echo "$password" | openssl enc -aes-256-cbc -a -pbkdf2 -pass pass:"$public_key" | base64 -w 0
}

# generatePrivateKey: Generates a new random private key.
# Returns: New random base64 encode key.
function generatePrivateKey() { 
  openssl rand -base64 32 
}

# storePasswordInKeychain: Encrypts a password with a uniquely generated encryption key and stores # it in the specified keychain file.
# Arguments:
#     password: The plain text password that needs to be stored.
#     keychain_file: The name/path of an existing keychain file to store the password.
#     public_key: The key used for the keychain file encryption.
# Returns:
#     0 and the random generated encryption key on success for future decryption.
#     1 on failure.
function storePasswordInKeychain() {    
    local password="$1"
    local keychain_file="$2"
    local public_key="$3"
    
    if ! verifyKeychainEncryption "$keychain_file" "$public_key"; then        
        return 1
    fi

    local private_key=$(generatePrivateKey)
    local encrypted_password=$(encryptPassword "$password" "$private_key")
    
    echo "$private_key $encrypted_password" >> "$keychain_file"
    echo "$private_key"
    return 0   
}

# decryptPassword: Decrypts a given encrypted password using a specified key.
# Arguments:
#     encrypted_password: The encrypted password that needs to be decrypted.
#     public_key: The key used for decryption.
# Returns:
#     The decrypted password.
function decryptPassword() {
    local encrypted_password="$1"
    local public_key="$2"
    echo "$encrypted_password" | base64 --decode | openssl enc -aes-256-cbc -d -a -pbkdf2 -pass pass:"$public_key"
}

# retrievePasswordFromKeychain: Searches and decrypts a password stored in a keychain file.
# Arguments:
#     public_key: The encryption key associated with the stored password.
#     keychain_file: The name/path of the existing keychain file.
#     public_key: The key used for keychain file encryption.
# Returns:
#     0 and the decrypted password on success.
#     1 and an error message on failure.
function retrievePasswordFromKeychain() {
    local private_key="$1"
    local keychain_file="$2"
    local public_key="$3"

    local keychain_content=$(openKeychain "$keychain_file" "$public_key")
    if [ $? -ne 0 ]; then
        echo "Failed to open the keychain file."
        return 1
    fi

    while IFS=' ' read -r key encrypted_password; do
        if [[ "$key" == "$private_key" ]]; then
            decryptPassword "$encrypted_password" "$private_key"
            return 0
        fi
    done <<< "$keychain_content"

    echo "Failed to retrieve the password from the keychain."
    return 1
}

# verifyKeychainEncryption: Verifies if a keychain file is encrypted with a specified public key.
# Arguments:
#     keychain_file: The name/path of the keychain file.
#     public_key: The key used for keychain file encryption.
# Returns:
#     0 if the file is correctly encrypted with the key, 1 otherwise.
function verifyKeychainEncryption() {
    local keychain_file="$1"
    local public_key="$2"
    local keychain_filename="${keychain_file##*/}"; keychain_filename="${keychain_filename%.*}"

    if [ ! -e "$keychain_file" ]; then
        echo "The keychain file does not exist."
        return 1
    fi

    local file_private_key
    read -r file_private_key < "$keychain_file"

    local decrypted_content=$(decryptPassword "$file_private_key" "$public_key")

    if [[ "$decrypted_content" == "$keychain_filename" ]]; then
        return 0
    else
        echo "Keychain file verification failed."
        return 1
    fi
}