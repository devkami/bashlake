#!/bin/bash

# Import test_lib and the script to be tested
source ../security/security.sh

function preTest(){    
  public_key="mock_public_key"
  test_keychain_file="test_keychain.kc"
  test_password="TestPassword123"
}

function testCreateKeychain(){  
  createKeychain "$test_keychain_file" "$public_key"
  if [ -e "$test_keychain_file" ]; then
    return 0
  else
    return 1
  fi
}

function testOpenKeychain(){  
  openKeychain "$test_keychain_file" "$public_key"
  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

function testEncryptPassword(){  
  local encrypted_password
  encrypted_password=$(encryptPassword "$test_password" "$public_key")
  if [ ! -z "$encrypted_password" ]; then
    return 0
  else
    return 1
  fi
}

function testGeneratePrivateKey(){  
  local private_key
  private_key=$(generatePrivateKey)
  if [ ! -z "$private_key" ]; then
    return 0
  else
    return 1
  fi
}

function testStorePasswordInKeychain(){  
  local returned_key=$(storePasswordInKeychain "$test_password" "$test_keychain_file" "$public_key")  
  if [ ! -z "$returned_key" ]; then
    return 0
  else
    return 1
  fi
}

function testDecryptPassword(){  
  local encryption_key=$(generatePrivateKey)
  local encrypted_password=$(encryptPassword "$test_password" "$encryption_key")
  local decrypted_password=$(decryptPassword "$encrypted_password" "$encryption_key")
  
  if [ "$decrypted_password" == "$test_password" ]; then
    return 0
  else
    return 1
  fi
}

function testRetrievePasswordFromKeychain(){
  local encryption_key=$(storePasswordInKeychain "$test_password" "$test_keychain_file" "$public_key")  
  local retrieved_password=$(retrievePasswordFromKeychain "$encryption_key" "$test_keychain_file" "$public_key")    
  if [ "$retrieved_password" == "$test_password" ]; then
    return 0
  else
    return 1
  fi
}

function testVerifyKeychainEncryption(){  
  if verifyKeychainEncryption "$test_keychain_file" "$public_key"; then
    return 0
  else
    return 1
  fi
}

function postTest(){
  rm "$test_keychain_file"
  unset test_keychain_file test_password public_key  
  
}

function run(){
  source test_lib.sh
  preTest
  runAllTests
  postTest
}

run