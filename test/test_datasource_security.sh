#!/bin/bash


source ../datasource/security.sh

function preTest() {
  public_key="public_key"
  valid_source_json='{
    "source": {
      "origin": "valid_origin",
      "company": "valid_company",
      "type": "mysql_db",
      "auth": {"password": "valid_password"}
    }
  }'
  origin=$(echo "$valid_source_json" | jq -r '.source.origin')
  company=$(echo "$valid_source_json" | jq -r '.source.company')
  type=$(echo "$valid_source_json" | jq -r '.source.type')  
  valid_keychain_file="keychains/${origin}_${company}_${type##*_}.kc"  
}

function testGetDatasourceKeychainFilepath() {
  local valid_keychain_path=$(getDatasourceKeychainFilepath "$valid_source_json")  
  if [ "$valid_keychain_path" == "$valid_keychain_file" ]; then
    return 0
  else
    return 1
  fi
}

function testSetDatasourceKeychain() {  
  if setDatasourceKeychain "$valid_source_json" "$public_key" > /dev/null; then
    return 0
  else
    return 1
  fi
}

function testEncryptDatasourcePassword() {
  local private_key=$(encryptDatasourcePassword "$valid_source_json" "$public_key")
  
  if [ -n "$private_key" ]; then
    return 0
  else
    return 1
  fi
}

function testDecryptDatasourcePassword() {  
  local encrypted_datasource=$(encryptDatasourcePassword "$valid_source_json" "$public_key")    
  local decrypted_json=$(decryptDatasourcePassword "$encrypted_datasource" "$public_key")  
  local expcted_password=$(echo "$valid_source_json" | jq -r '.source.auth.password')
  local actual_password=$(echo "$decrypted_json" | jq -r '.source.auth.password')  
  
  if [[ $actual_password == $expcted_password ]]; then
      return 0
  else
    return 1
  fi
}

function postTest() {
  unset   valid_source_json  
  rm -rf keychains
  
  return 0
}

function run() {
  source test_lib.sh
  preTest
  runAllTests
  postTest
}

run