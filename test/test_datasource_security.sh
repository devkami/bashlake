#!/bin/bash


source ../datasource/security.sh

function preTest() {
  public_key="public_key"  

  valid_datasource_json='{
    "source": {
      "origin": "valid_origin",
      "company": "valid_company",
      "type": "mysql_db",
      "auth": {
        "password": "valid_password"
      }
    }
  }'
  
  invalid_datasource_json='{
    "source": {
      "origin": "",
      "company": "",
      "type": "",
      "auth": {
        "password": ""
      }
    }
  }'
}

function testGetDatasourceKeychainFilepath() {
  local valid_keychain_path=$(getDatasourceKeychainFilepath "$valid_datasource_json")
  
  if [ -n "$valid_keychain_path" ]; then
    return 0
  else
    return 1
  fi
}

function testSetDatasourceKeychain() {    
  if setDatasourceKeychain "$valid_datasource_json" "$public_key" > /dev/null; then
    return 0
  else
    return 1
  fi
}

function testGetDatasourcePrivateKey() {
  local private_key=$(getDatasourcePrivateKey "$valid_datasource_json" "$public_key")
  
  if [ -n "$private_key" ]; then
    return 0
  else
    return 1
  fi
}

function testDecryptDatasourcePassword() {
  local decrypted_json=$(decryptDatasourcePassword "$valid_datasource_json" "$public_key")
  
  if [ -n "$decrypted_json" ]; then
    return 0
  else
    return 1
  fi
}

function postTest() {
  unset valid_datasource_json
  unset invalid_datasource_json
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