#!/bin/bash

# Description:
# This script is an integral component of a data management system, primarily focused on setting up and managing database sources for a data lake. It provides a suite of functions that facilitate the integration of various types of databases, such as MySQL, into the data lake environment. The script employs encrypted keychains for secure storage of database credentials and utilizes utilities for database manipulation.
#
# The script includes functionalities to:
# - Test database connections for various database types.
# - Generate database names based on source JSON information.
# - Add new MySQL databases to the data lake, handling both database and user creation.
# - Add new database type data sources to the data lake, supporting various database types.
#
# Functions:
#  checkDataSourceDBConnection: Tests the database connection for a given data source.
#  getDatasourceDbName: Generates a database name based on the data source's JSON information.
#  addMySQLDBToDataLake: Adds a new MySQL database to the data lake, including database and user creation.
#  addDatasourceDBToDataLake: Adds a new database type data source to the data lake, supporting different database types.
#
# Usage:
# This script should be sourced in environments where managing database sources for a data lake is required. It provides robust tools for database integration and management, ensuring secure and efficient operations.
# The script relies on 'security/security.sh' for secure handling of credentials and 'database/mysql_lib.sh' for specific MySQL operations.
#
# Prerequisites:
# - jq must be installed on the system for JSON manipulation.
# - OpenSSL must be installed for handling encryption and decryption operations.
# - The scripts 'security/security.sh' and 'database/mysql_lib.sh' must be present and sourced for underlying database operations.
#
# Author: Maicon de Menezes
# Creation Date: 08/01/2024
# Version: 0.1.0

# Imports
source ../database/mysql_lib.sh
source ../datasource/security.sh

# getDatasourceDbName: Gets the database name from the source JSON for the new datasource.
# Arguments: source_json: A JSON string representing the data source.
# Returns: Success (0) and The database name or failure (1).
function getDatasourceDbName() {
  local source_json=$1
  local origin=$(echo "$source_json" | jq -r '.source.origin')
  local company=$(echo "$source_json" | jq -r '.source.company')
  local source_type=$(echo "$source_json" | jq -r '.source.type')
  source_type="${source_type##*_}"
  local database_name="${origin}_${company}_${source_type}"
  
  if [ -z "$database_name" ]; then
    echo "Unable to create a database name with the data source information provided" >&2
    return 1
  fi
  
  echo "$database_name"
}

# checkDataSourceDBConnection: Tests the database connection of a database type of datasource.
# Arguments: source_json: A JSON string representing the data source with auth details.
# Returns: Success (0) or failure (1) and the error message.
function checkDataSourceDBConnection() {
  local source_json=$1
  local public_key=$2
  local decrypted_source_json=$(decryptDatasourcePassword "$source_json" "$public_key")
  
  echo "source_json: $source_json"
  echo "public_key: $public_key"
  echo "decrypted: $decrypted_source_json"
  local db_conn=$(echo "$decrypted_source_json" | jq -r '.source.auth')  
  
  if checkMySQLConnection "$db_conn" >&2 > /dev/null ; then      
    return 0
  else
    echo "Failed to connect to the database." >&2
    return 1
  fi  
}

# addDataSourceDBToDataLake: Adds a new database type datasource to the data lake.
# Arguments: 
#   source_json: A JSON string representing the data source.
#   public_key: The public key used to decrypt database password.
# Returns: Success (0) or failure (1) and the error message.
function addMySQLDBToDataLake() {
  local source_json=$1
  local public_key=$2
  local database_name=$(getDatasourceDbName "$source_json")
  local decrypted_source_json=$(decryptDatasourcePassword "$source_json" "$public_key")
  local db_conn=$(echo "$decrypted_source_json" | jq -r '.source.auth')

  if ! dropAndCreateDatabase "$database_name"; then
    echo "Failed to create the database: $database_name." >&2
    return 1
  fi

  if ! createMysqlUser "$db_conn" "$database_name"; then  
    echo "Failed to create the user." >&2
    return 1
  fi

  return 0
}

# addDataSourceDBToDataLake: Adds a new database type datasource to the data lake.
# Arguments: source_json: A JSON string representing the data source.
# Returns: Success (0) or failure (1) and the error message.
function addDatasourceDBToDataLake() {
  local source_json=$1
  local public_key=$2
  local source_type=$(echo "$source_json" | jq -r '.source.type')
  
  case $source_type in
    "mysql_db")
      if ! addMySQLDBToDataLake "$source_json" "$public_key"; then
        echo "Failed to add the data source to the data lake." >&2
        return 1
      fi ;;
    *) echo "Data source type not supported." >&2
       return 1 ;;
  esac
  
  return 0
}