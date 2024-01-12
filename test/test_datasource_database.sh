#!/bin/bash

source ../datasource/database.sh
source ../datasource/security.sh

function preTest() {
  public_key="mock_public_key"
  local datasource_json='{
    "source":{
      "origin":"test_origin",
      "company":"test_company",
      "type":"mysql_db",
      "auth":{
        "host":"localhost",
        "port":"3306",
        "user":"test_user",
        "password":"test_password",
        "database":"test_database"
      }
    }
  }'

  local database_name=$(echo "$datasource_json" | jq -r '.source.auth.database')
  local db_user=$(echo "$datasource_json" | jq -r '.source.auth.user')
  local db_password=$(echo "$datasource_json" | jq -r '.source.auth.password')

  mysql -u "$MYSQL_MASTER_USER" -p"$MYSQL_MASTER_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $database_name;" 2>/dev/null

  mysql -u "$MYSQL_MASTER_USER" -p"$MYSQL_MASTER_PASSWORD" -e "CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_password';" 2>/dev/null

  source_json=$(encryptDatasourcePassword "$datasource_json" "$public_key")
}

function testCheckDataSourceDBConnection() {
  if checkDataSourceDBConnection "$source_json" "$public_key" > /dev/null; then
    return 0
  else
    return 1
  fi
}

function testGetDatasourceDbName() {
  local origin=$(echo "$source_json" | jq -r '.source.origin')
  local company=$(echo "$source_json" | jq -r '.source.company')
  local source_type=$(echo "$source_json" | jq -r '.source.type')
  source_type="${source_type##*_}"
  local expected_database_name="${origin}_${company}_${source_type}"
  local actual_database_name=$(getDatasourceDbName "$source_json")
  if [ "$actual_database_name" == "$expected_database_name" ]; then
    return 0
  else
    return 1
  fi
}

function testAddMySQLDBToDataLake() {
  if addMySQLDBToDataLake "$source_json" "$public_key" > /dev/null; then
    return 0
  else
    return 1
  fi
}

function testAddDatasourceDBToDataLake() {
  if addDatasourceDBToDataLake "$source_json" "$public_key" > /dev/null; then
    return 0
  else
    return 1
  fi
}

function postTest() {
  local database_name=$(getDatasourceDbName "$source_json")
  local db_user=$(echo "$source_json" | jq -r '.source.auth.user')

  mysql -u "$MYSQL_MASTER_USER" -p"$MYSQL_MASTER_PASSWORD" -e "DROP DATABASE IF EXISTS $database_name;" 2>/dev/null

  mysql -u "$MYSQL_MASTER_USER" -p"$MYSQL_MASTER_PASSWORD" -e "DROP USER IF EXISTS '$db_user'@'%';" 2>/dev/null

  unset source_json
  unset public_key
  rm -rf keychains
}

function run() {
  source test_lib.sh
  preTest
  runAllTests
  postTest
}

run

