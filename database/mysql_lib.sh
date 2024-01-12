#!/bin/bash

# Description: This library script contains functions for managing MySQL databases. It includes
# functions for installing MySQL, checking its installation, running MySQL, setting up security,
# managing users, performing database backups, restoring databases, and more. The script is 
# designed for use with Ubuntu 18.04 or higher and relies on the `expect` utility for automated 
# inputs in secure installation.
#
# Functions:
#   checkMySqlInstall: Checks if the MySQL server is installed.
#   createMysqlUsers: Creates a new MySQL user with specified credentials.
#   dropCreateDatabase: Drops and creates a new local MySQL database.
#
# Authors: Maicon de Menezes
# Creation Date: 19/11/2023
# Last Modified: 11/01/2024
# Version: 0.2.2

# Imports
source ../log/log_lib.sh 

# checkMySqlInstall: Checks if the MySQL server is already installed.
# Returns true if installed, false otherwise.
# Usage: checkMySqlInstall
function checkMySqlInstall() {    
    if type /usr/bin/mysql >/dev/null 2>&1; then        
        return 0
    else
        logMess "MySQL Server is not installed."
        return 1
    fi
}

# createMysqlUser: Creates a new MySQL user with specified username and password from a json auth.
# Arguments:
#    db_connection_json: A JSON string representing the database connection details.
#    db_name: The name of the database to create the user for.
# Returns: Success (0) or failure (1).
function createMysqlUser() {
    local db_connection_json=$1
    local db_name=$2    
    local db_user=$(echo "$db_connection_json" | jq -r '.user')
    local db_pass=$(echo "$db_connection_json" | jq -r '.password')

    checkMySqlInstall || return 1

    local SQL_QUERY="CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_pass';"
    SQL_QUERY+="GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%' WITH GRANT OPTION;"    
    SQL_QUERY+="FLUSH PRIVILEGES;"
    
    mysql -u "$MYSQL_MASTER_USER" -p"$MYSQL_MASTER_PASSWORD" -e "$SQL_QUERY" 2>/dev/null || return 1
    return 0

}

# checkMySQLConnection: Tries to connect to a MySQL database using auth details from a datasource.
# Arguments: source_json: A JSON string representing the data source with auth details.
# Returns: Success (0) or failure (1) with error message.
function checkMySQLConnection() {
    local source_json=$1

    local db_user=$(echo "$source_json" | jq -r '.user')
    local db_pass=$(echo "$source_json" | jq -r '.password')
    local db_host=$(echo "$source_json" | jq -r '.host')
    local db_port=$(echo "$source_json" | jq -r '.port')
    local db_name=$(echo "$source_json" | jq -r '.database')    
    
    if mysql -h "$db_host" -P "$db_port" -u "$db_user" -p"$db_pass" -e "SELECT 1" 2>/dev/null; then    
        return 0
    else
        logMess "Failed to connect to the database ${db_name}."
        return 1
    fi
}

# dropCreateDatabase: Drop if exists and create new local MySQL database
# Arguments: new_database: The name of the new database.
# Returns: Success (0) or failure (1).
function dropAndCreateDatabase() {    
    local new_database=$1
   
    if mysql -u "$MYSQL_MASTER_USER" -p"$MYSQL_MASTER_PASSWORD" -e "USE $new_database;" 2>/dev/null ; then
        mysql -u "$MYSQL_MASTER_USER" -p"$MYSQL_MASTER_PASSWORD" -e "DROP DATABASE $new_database;" 2>/dev/null
    fi    
    
    mysql -u "$MYSQL_MASTER_USER" -p"$MYSQL_MASTER_PASSWORD" -e "CREATE DATABASE $new_database;" 2>/dev/null
    if [ $? -eq 0 ]; then        
        return 0
    else
        logMess "Failed to create local database $new_database."
        return 1
    fi
}