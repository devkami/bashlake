# Security Script

## Overview

`security.sh` is a Bash script designed for secure management of encrypted keychain files. It facilitates the creation, opening, and verification of keychain files and handles the encryption and decryption of sensitive data such as passwords. The script primarily uses AES-256-CBC encryption for securing data and offers a suite of functions for handling keychain-related operations

## Functions

The script includes a range of functions, each tailored for specific security and encryption tasks:

- ### `checkMasterKey`: Checks if the `KDLSEC_MASTER_KEY` environment variable is set. Exits the script with an error message if not set

- ### `createKeychain`: Creates a new keychain file encrypted with a provided master key. Returns 0 on success, 1 if the file already exists

- ### `openKeychain`: Opens and verifies a keychain file encrypted with a master key. Returns 0 and outputs the content if successful, 1 if verification fails

- ### `encryptPassword`: Encrypts a given password using the AES-256-CBC encryption algorithm and the specified encryption key. Returns the encrypted password

- ### `generatePrivateKey`: Generates a new random private key using base64 encoding

- ### `storePasswordInKeychain`: Encrypts and stores a password with a randomly generated encryption key in a keychain file. Returns the encryption key on success

- ### `decryptPassword`: Decrypts a given encrypted password using the specified decryption key. Returns the decrypted password

- ### `retrievePasswordFromKeychain`: Searches for and decrypts a password stored in a keychain file using the associated encryption key. Returns the decrypted password on success

## Usage

To utilize this script's functionalities, source it in your Bash environment. It provides the capability to create keychain files, store and retrieve passwords, and manage encryption keys. Before using the functions, ensure that the `KDLSEC_MASTER_KEY` environment variable is set to your master encryption key

## Prerequisites

- OpenSSL must be installed on your system, as it is used for encryption and decryption operations

- The `KDLSEC_MASTER_KEY` environment variable should be set to your master encryption key

### Author: [Maicon de Menezes](https://github.com/maicondmenezes)

### Creation Date: 02/01/2024

### Version: 0.1.0
