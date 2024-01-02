#!/bin/bash

# Description: This library script contains functions for managing MySQL databases. It includes
# functions for installing MySQL, checking its installation, running MySQL, setting up security,
# managing users, performing database backups, restoring databases, and more. The script is 
# designed for use with Ubuntu 18.04 or higher and relies on the `expect` utility for automated 
# inputs in secure installation.
#
# Functions:
#   getLocalDbName: Gets the local database name.
#   getBkpFilename: Gets the backup filename.
#   checkMySqlInstall: Checks if the MySQL server is installed.
#   installMysql: Installs the MySQL server for Ubuntu 22.04 or higher.
#   checkMysqlRun: Ensures the MySQL service is running.
#   setMysqlSec: Automates inputs in `mysql_secure_installation` using `expect`.
#   createMysqlUsers: Creates a new MySQL user with specified credentials.
#   prepareMySqlDB: Prepares the MySQL database environment.
#   deleteBackupFiles: Deletes all SQL files of the dump process.
#   backupMySQLBDViews: Performs a backup of MySQL database views.
#   backupMySQLDBRoutines: Performs a backup of MySQL database routines.
#   backupMySQLDBTablesAndData: Performs a backup of the entire MySQL database.
#   backupMysqlDB: Performs a complete backup of a MySQL database.
#   dropCreateDatabase: Drops and creates a new local MySQL database.
#   restoreBackupDatabase: Restores a backup into a new local MySQL database.
#   createEgestorSalesTableSQL: Generates SQL script to create a new table for egestor sales.
#   executeSqlQuery: Executes a given SQL query on the MySQL database.
#   importCsvFileToTable: Imports a CSV file into a MySQL table.
#
# Usage:
#   Source this script in your main script and call its functions as required.
#   Ensure that the following environment variables are set before sourcing:
#     DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS
#
# Authors: Maicon de Menezes
# Creation Date: 19/11/2023
# Version: 0.2.1

# Import logging functions
source ../log/log_lib.sh
# Import environment checking functions
source ../utils/sysadmin_lib.sh

# getLocalDbName: Get the local database name
# To do that it's need ("DB_NAME") enviroment vars.
function getLocalDbName() {
    # Check that required environment variables are set
    local required_vars=("DB_NAME")
    if ! checkEnvironmentVars "${required_vars[@]}" >/dev/null 2>&1; then
        return 1
    fi
    # Compose the local database name
    local db_name="bkp_${db_name}"
    echo "${db_name}"
}

# getBkpFilename: Get the backup filename
# To do that it's need getLocalDbName function.
function getBkpFilename() {
    local db_name=$1
    # Ensure that the backup directory exists
    local bkpDir="bkp_db"
    mkdir -p "${bkpDir}"
    
    # Compose the full backup filename
    local bkpFilename="${bkpDir}/${db_name}"
    echo "${bkpFilename}"
}

# checkMySqlInstall: Checks if the MySQL server is already installed.
# Returns true if installed, false otherwise.
# Usage: checkMySqlInstall
function checkMySqlInstall() {
    logMess "Checking if MySQL server is already installed..."
    if type /usr/bin/mysql >/dev/null 2>&1; then
        logMess "MySQL Server is already installed."
        return 0  # true in bash script
    else
        logMess "MySQL Server is not installed."
        return 1  # false in bash script
    fi
}

# installMysql: Installs the MySQL server only for Ubuntu 22.04.
# Usage: installMysql
function installMysql() {
    checkSystemVersion || return 1
    logMess "Installing MySQL server..."
    sudo apt update && sudo apt install mysql-server -y
    return $?
}

# checkMysqlRun: Ensures the MySQL service is running.
# Usage: checkMysqlRun
function checkMysqlRun() {
    logMess "Checking if MySQL service is running..."
    if systemctl is-active --quiet mysql; then
        logMess "MySQL is running."
        return 0
    else
        logMess "MySQL is not running. Attempting to start MySQL..."
        sudo systemctl start mysql
        # Check again to confirm that MySQL has started
        if systemctl is-active --quiet mysql; then
            logMess "MySQL has been started."
            return 0
        else
            logMess "Failed to start MySQL."
            return 1
        fi
    fi
}

# setMysqlSec: Runs `mysql_secure_installation` using `expect` to automate inputs.
# It sets a strong password for the MySQL root user and applies security improvements.
# Usage: setMysqlSec
function setMysqlSec() {
    local connection_json=$1
    # Extracting database connection details from the connection JSON
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')

    checkExpectInstall || return 1
        
    local SECURE_MYSQL=$(expect -c "
    set timeout 10
    spawn mysql_secure_installation

    expect \"Press y|Y for Yes, any other key for No:\"
    send \"y\r\"

    expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:\"
    send \"2\r\"

    expect \"New password:\"
    s'end \"$db_pass\r\"

    expect \"Re-enter new password:\"
    s'end \"$db_pass\r\"

    expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
    send \"y\r\"

    expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
    send \"y\r\"

    expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
    send \"n\r\"

    expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
    send \"y\r\"

    expect eof
    ")

    echo "$SECURE_MYSQL"
}

# createMysqlUsers: Creates a new MySQL user with specified username and password.
# It grants all privileges to the new user for local and remote access.
# Usage: createMysqlUsers
function createMysqlUsers() {
    local connection_json=$1

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')

    checkMySqlInstall || return 1    

    # SQL command to create a new user with privileges in local database
    local LOCAl_SQL_QUERY="CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';"        
    LOCAl_SQL_QUERY+="GRANT ALL PRIVILEGES ON *.* TO '${db_user}'@'%' WITH GRANT OPTION;"    
    LOCAl_SQL_QUERY+="FLUSH PRIVILEGES;"   

    # Execute SQL command to create user in local database
    logMess "Creating MySQL local user '${db_user}'..."
    sudo mysql -u root -p"${LOCAL_DB_ROOT_PASS}" -e "${LOCAl_SQL_QUERY}"    
    logMess "User '${db_user}' local creation completed."

}

# prepareMySqlDB: Prepare the MySQL database environment
# Usage: prepareMySqlDB
function prepareMySqlDB() {
    if ! checkMySqlInstall; then
        installMysql && logMess "MySQL Server has been installed."
    fi

    checkMysqlRun && logMess "MySQL service is running."
    setMysqlSec && logMess "MySQL secure installation is set."
    createMysqlUsers && logMess "MySQL user has been created."
}

# checkMySQLConnection: Tries to connect to a MySQL database using credentials from source_json.
# Usage: checkMySQLConnection source_json
function checkMySQLConnection() {
    local source_json=$1

    # Extracting database connection details from the source_json's auth section
    local db_user=$(echo "$source_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$source_json" | jq -r '.source.auth.password')
    local db_host=$(echo "$source_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$source_json" | jq -r '.source.auth.port')
    local db_name=$(echo "$source_json" | jq -r '.source.auth.database')

    logMess "Attempting to connect to the database ${db_name}..."
    
    # Attempting a simple query to check the connection
    if mysql -h "${db_host}" -P "${db_port}" -u "${db_user}" -p"${db_pass}" -e "SELECT 1" &> /dev/null; then
        logMess "Successfully connected to the database ${db_name}."
        return 0
    else
        logMess "Failed to connect to the database ${db_name}."
        return 1
    fi
}

# deleteBackupFiles: delete all sql files of the dump process;
# To do that it's need ("DB_HOST" "DB_PORT") enviroment vars.
function deleteBackupFiles() {
  local connection_json=$1
  # Extracting database connection details from the connection JSON
  local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
  local BKP_FILENAME=$(getBkpFilename "${db_name}")
  
  if rm -f "${BKP_FILENAME}"*.sql; then
      logMess "Partial backup files removed."
      return 0
  else
      logMess "Fail when try to delete backup files..."
      return 1
  fi

}

# backupMySQLBDViews: Perform VIEWS backup of a MySQL database
# It save new backup on '{BKP_FILENAME}_views.sql';
# To do that it's need ("DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASS") enviroment vars.
function backupMySQLBDViews(){    
    local connection_json=$1

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    local db_host=$(echo "$connection_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$connection_json" | jq -r '.source.auth.port')

    local BKP_FILENAME="$(getBkpFilename "${db_name}")_views.sql"

    checkPvInstall
    logMess "Starting backup VIEWS from ${db_name}..."
    # Get the list of views from the database
    VIEWS=$(mysql -h "${db_host}" -P "${db_port}" -u "${db_user}" -p"${db_ç}" -D "${db_name}" -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = '${db_name}';" -s -N)    
    
    for VIEW in $VIEWS
    do
        mysqldump  \
        -h "${db_host}" \
        -P "${db_port}" \
        -u "${db_user}" \
        -p"${db_pass}" \
        --no-data --skip-triggers --opt \
        "${db_name}" "${VIEW}" 2>> "${LOGS_FILENAME}" \
        >> "${BKP_FILENAME}" &&
        logMess "Dumping ${VIEW} in ${BKP_FILENAME}"
    done
}

# backupMySQLDBRoutines: Perform ROUTINES backup of a MySQL database
# It save new backup on '{BKP_FILENAME}_routines.sql';
function backupMySQLDBRoutines() {    
    local connection_json=$1

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    local db_host=$(echo "$connection_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$connection_json" | jq -r '.source.auth.port')
    local BKP_FILENAME="$(getBkpFilename "${db_name}")_routines.sql"

    
    checkPvInstall
    logMess "Starting backup of routines from ${db_name}..."

    mysqldump  \
        -h "${db_host}" \
        -P "${db_port}" \
        -u "${db_user}" \
        -p"${db_pass}" \
        --routines --no-create-info --no-data --skip-triggers --skip-opt \
        "${db_name}" 2>> "${LOGS_FILENAME}"| \
        pv -p -t -e -r > "${BKP_FILENAME}"

    if [ $? -eq 0 ]; then
        logMess "Backup of routines from ${db_name} completed successfully."
    else
        logMess "Backup of routines from ${db_name} failed."
        return 1
    fi
}

# backupMySQLDBTablesAndData: Perform database backup of a entire MySQL 
# database without VIEWS and ROUTINES It save new backup on '{BKP_FILENAME}_tables.sql';
# To do that it's need ("DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASS") enviroment vars.
function backupMySQLDBTablesAndData() {    
    local connection_json=$1

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    local db_host=$(echo "$connection_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$connection_json" | jq -r '.source.auth.port')

    local BKP_FILENAME="$(getBkpFilename ${db_name})_tables.sql"

    checkPvInstall
    logMess "Starting backup of tables and triggers from ${db_name}..."

    mysqldump  \
        -h "${db_host}" \
        -P "${db_port}" \
        -u "${db_user}" \
        -p"${db_pass}" \
        --skip-routines --skip-triggers --events --opt \
        "${db_name}" 2>> "${LOGS_FILENAME}" | \
        pv -p -t -e -r > "${BKP_FILENAME}"

    if [ $? -eq 0 ]; then
        logMess "Backup of tables and triggers from ${db_name} completed successfully."
    else
        logMess "Backup of tables and triggers from ${db_name} failed."
        return 1
    fi
}

# backupMySQLDBTriggers: Perform a backup of all triggers in a MySQL database.
# The backup is saved to '{BKP_FILENAME}_triggers.sql'.
# Requires environment variables: "DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASS".
function backupMySQLDBTriggers() {    
    local connection_json=$1

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    local db_host=$(echo "$connection_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$connection_json" | jq -r '.source.auth.port')

    local BKP_FILENAME="$(getBkpFilename ${db_name})_triggers.sql"

    checkPvInstall
    logMess "Starting backup of triggers from ${db_name}..."

    mysqldump \
        -h "${db_host}" \
        -P "${db_port}" \
        -u "${db_user}" \
        -p"${db_pass}" \
        --triggers --no-create-info --no-data --no-create-db --skip-opt \
        "${db_name}" 2>> "${LOGS_FILENAME}" | \
        pv -p -t -e -r > "${BKP_FILENAME}"

    if [ $? -eq 0 ]; then
        logMess "Backup of triggers from ${db_name} completed successfully."
    else
        logMess "Backup of triggers from ${db_name} failed."
        return 1
    fi
}

# backupMySQLDBEvents: Perform a backup of all events in a MySQL database.
# The backup is saved to '{BKP_FILENAME}_events.sql'.
# Requires environment variables: "DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASS".
function backupMySQLDBEvents() {    
    local connection_json=$1

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    local db_host=$(echo "$connection_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$connection_json" | jq -r '.source.auth.port')

    local BKP_FILENAME="$(getBkpFilename ${db_name})_events.sql"

    checkPvInstall
    logMess "Starting backup of events from ${db_name}..."

    mysqldump \
        -h "${db_host}" \
        -P "${db_port}" \
        -u "${db_user}" \
        -p"${db_pass}" \
        --events --no-create-info --no-data --no-create-db --skip-opt \
        "${db_name}" 2>> "${LOGS_FILENAME}" | \
        pv -p -t -e -r > "${BKP_FILENAME}"

    if [ $? -eq 0 ]; then
        logMess "Backup of events from ${db_name} completed successfully."
    else
        logMess "Backup of events from ${db_name} failed."
        return 1
    fi
}

# backupMySQLDBIndexes: Generates SQL statements to recreate all indexes in a MySQL database.
# The backup is saved to '{BKP_FILENAME}_indexes.sql'.
# Requires environment variables: "DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASS".
function backupMySQLDBIndexes() {    
    local connection_json=$1

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    local db_host=$(echo "$connection_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$connection_json" | jq -r '.source.auth.port')

    local BKP_FILENAME="$(getBkpFilename ${db_name})_indexes.sql"

    checkPvInstall
    logMess "Starting backup of indexes from ${db_name}..."

    # Connect to the database and extract index definitions
    mysql -h "${db_host}" -P "${db_port}" -u "${db_user}" -p"${db_pass}" -N -B -e \
    "SELECT CONCAT('ALTER TABLE ', TABLE_NAME, ' ADD ', IF(NON_UNIQUE = 1, 'INDEX', 'UNIQUE INDEX'), ' ', INDEX_NAME, '(', GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX), ');') FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = '${db_name}' GROUP BY TABLE_NAME, INDEX_NAME;" > "${BKP_FILENAME}"

    if [ $? -eq 0 ]; then
        logMess "Backup of indexes from ${db_name} completed successfully."
    else
        logMess "Backup of indexes from ${db_name} failed."
        return 1
    fi
}

# backupMysqlDB: Perform database backup of a entire MySQL database
# It save new backup on 3 diferent sql files one for view, one for routines and the last one for the entire database using getBkpFilename as reference to create those filenames;
# To do that it's need ("DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASS") enviroment vars.
function backupMysqlDB() {
    local connection_json=$1

    # Extracting database connection details from the connection JSON
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    logMess "Starting ${db_name} backup..."
        
    if backupMySQLDBRoutines "${connection_json}" && \
    backupMySQLDBTablesAndData "${connection_json}" && \
    backupMySQLBDViews "${connection_json}"; then
        logMess "Backup of ${db_name} completed successfully."
        return 0
    else
        logMess "Backup of ${db_name} failed. Cleaning up partial backup files..."
        deleteBackupFiles "${connection_json}"   
        return 1
    fi
}

# dropCreateDatabase: Drop if exists and create new local MySQL database
# It will create or recreate database with the name bkp_${db_name}
# To do that it's need ("DB_NAME", "DB_USER", "DB_PASS") enviroment vars.
function dropAndCreateDatabase() {
    local connection_json=$1
    local new_database=$2

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_host=$(echo "$connection_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$connection_json" | jq -r '.source.auth.port')
    logMess "Checking if ${new_database} exists..."

    if mysql -u "${db_user}" -p"${db_pass}" -e "USE ${new_database}"; then
        logMess "Database ${new_database} exists. Dropping database..."
        mysql -u "${db_user}" -p"${db_pass}" -e "DROP DATABASE ${new_database};"
    fi
    logMess "Creating new local database ${new_database}..."
    mysql -u "${db_user}" -p"${db_pass}" -e "CREATE DATABASE ${new_database};"
    if [ $? -eq 0 ]; then
        logMess "Local database ${new_database} was created."
        return 0
    else
        logMess "Failed to create local database ${new_database}."
        return 1
    fi
}

# restoreBackupDatabase: Import the backuped database as sql file into the new local database
# To do that it's need ("DB_USER", "DB_PASS")
function restoreBackupDatabase() {
    local BKP_FILENAME=$(getBkpFilename)
    local connection_json=$1
    
    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    
    checkPvInstall
    logMess "Restoring the ${db_name} backup..."
    
    logMess "Restoring the ${db_name} tables and data..."
    pv "${BKP_FILENAME}_tables.sql" | mysql -u "${db_user}" -p"${db_pass}" "${db_name}" 2>> "${LOGS_FILENAME}"
    
    logMess "Restoring the ${db_name} routines (functions and procedures)..."
    pv "${BKP_FILENAME}_routines.sql" | mysql -u "${db_user}" -p"${db_pass}" "${db_name}" 2>> "${LOGS_FILENAME}"
    
    logMess "Restoring the ${db_name} views..."
    pv "${BKP_FILENAME}_views.sql" | mysql -u "${db_user}" -p"${db_pass}" "${db_name}" 2>> "${LOGS_FILENAME}"

    if [ $? -eq 0 ]; then
        logMess "Import into local database completed successfully."
        return 0
    else
        logMess "Import into local database failed."
        return 1
    fi
}

# executeSqlQuery: Executes a given SQL query on the MySQL database.
# Usage: executeSqlQuery sql_query
function executeSqlQuery() {
    local connection_json=$1
    local sql_query=$2

    # Extracting database connection details from the connection JSON
    local db_user=$(echo "$connection_json" | jq -r '.source.auth.user')
    local db_pass=$(echo "$connection_json" | jq -r '.source.auth.password')
    local db_name=$(echo "$connection_json" | jq -r '.source.auth.database')
    local db_host=$(echo "$connection_json" | jq -r '.source.auth.host')
    local db_port=$(echo "$connection_json" | jq -r '.source.auth.port')
    
    
    logMess "Executing SQL query on database ${db_name}..."

    # Run the query
    local query_result=$(mysql -u "${db_user}" -p"${db_pass}" -h "${db_host}" -P "${db_port}" "${db_name}" -e "${sql_query}")

    # Check the execution status
    if [[ $? -ne 0 ]]; then
        logMess "Query execution failed."
        echo "$query_result"
        return 1
    else
        logMess "Query executed successfully."
        echo "$query_result"
        return 0
    fi
}

# Extracts column names from the first JSON object in the file
function extractJsonColumns() {
    local json_file=$1
    jq -r 'first | keys[]' "$json_file" | tr '[:upper:]' '[:lower:]'
}

# Constructs the SQL INSERT query for a record
function createInsertQuery() {
    local table_name=$1
    local columns=("${@:2}")
    local record=$3
    local insert_values=()

    for column in "${columns[@]}"; do
        local value
        value=$(echo "$record" | jq -r ".[\"$column\"]")
        insert_values+=("'$value'")
    done

    local column_list
    column_list=$(IFS=,; echo "${columns[*]}")
    local value_list
    value_list=$(IFS=,; echo "${insert_values[*]}")
    echo "INSERT INTO $table_name ($column_list) VALUES ($value_list);"
}

function importJsonFileToDatabase() {
    local connection_json=$1
    local json_file=$2
    local table_name=$3
    local table_structure=$4
    

    if [[ ! -f "$json_file" ]]; then
        logMess "JSON file not found: $json_file"
        return 1
    fi
    local total_records
    total_records=$(jq '. | length' "$json_file")
    local processed_records=0
    
    jq -c '.[]' "$json_file" | while read -r record; do
        insertJsonRecordInTable "$record" "$table_name" "$table_structure" "$connection_json"
        ((processed_records++))
        local percent_count=$((processed_records * 100 / total_records))
        echo -ne "Importing data: $percent_count% completed ($processed_records of $total_records records)\r" >&2
    done

    echo -ne "\n"
    logMess "JSON data successfully imported into $table_name"
    return 0
}

#getNestedFields takes a table structure JSON string and returns a JSON string listing nested fields, specifying each field's name, type (JSON or string array), and structure.
function getNestedFields() {
    local table_structure=$1
    # Extrair e formatar campos aninhados usando jq
    echo "$table_structure" | jq '[.[] | select(.data_type | contains("array"))]'
}

# checkRecordExists
#
# Checks if a given value exists in a specific table and field.
#
# Arguments:
#   db_connection: A JSON string with database connection details.
#   table_name: Name of the table to check.
#   field_name: The name of the field within the table to check the value against.
#   value: The value to check for in the table.
#
# Returns:
#   The ID of the existing value if found, or an empty string if not found.
#
function checkRecordExists() {
    local db_connection=$1
    local table_name=$2
    local field_name=$3
    local value=$4

    local query="SELECT id FROM $table_name WHERE $field_name='$value';"
    local result
    result=$(executeSqlQuery "$db_connection" "$query")

    echo "$result"
}

function getRecordIdbyField() {
    local connection_json=$1
    local field_structure=$2
    local field_record=$3
    local primary_key_field_name=$4

    local check_query="SELECT $primary_key_field_name FROM ${field_structure['reference_table']} WHERE ${field_structure['lookup_field']} = '$field_record';"

    executeSqlQuery "$connection_json" "$check_query"
}

function createNewRecord() {
    local connection_json=$1
    local field_structure=$2
    local field_record=$3

    local insert_query="INSERT INTO ${field_structure['reference_table']} (${field_structure['lookup_field']}) VALUES ('$field_record');"
    executeSqlQuery "$connection_json" "$insert_query"

    local new_record_id
    new_record_id=$(executeSqlQuery "$connection_json" "SELECT LAST_INSERT_ID();")

    if [[ -z "$new_record_id" ]]; then
        return 1
    fi
    
    echo "$new_record_id"
    return 0
}

function getOrCreateRecord() {
    local connection_json=$1
    local field_structure=$2
    local field_record=$3
    local primary_key_field_name="id"  
    local record_id
    record_id=$(getRecordIdbyField "$connection_json" "$field_structure" "$field_record" "$primary_key_field_name")

    if [[ -z "$record_id" ]]; then
        record_id=$(createNewRecord "$connection_json" "$field_structure" "$field_record")
        if [[ -z "$record_id" ]]; then            
            return 1
        fi
    fi
    echo "$record_id"
    return 0
}

function processNonCodField() {
    local connection_json=$1
    local field_structure=$2
    local field_record=$3
    local parent_id=$4

    local existing_id
    existing_id=$(getOrCreateRecord "$connection_json" "$field_structure" "$field_record" "codigo")

    if [[ -z "$existing_id" ]]; then
        logMess "Failed to get or create record in reference table."
        return 1
    fi

    local relationship_table=${field_structure['table_name']}
    local insert_rel_query="INSERT INTO $relationship_table (cod${field_structure['reference_table']}, cod${field_structure['parent_table']}) VALUES ($existing_id, $parent_id);"

    if ! executeSqlQuery "$connection_json" "$insert_rel_query"; then
        logMess "Failed to insert relationship into table $relationship_table."
        return 1
    fi

    return 0
}

function processCodField() {
    local connection_json=$1
    local field_structure=$2
    local field_record=$3
    local parent_id=$4

    local existing_id
    existing_id=$(getRecordIdbyField "$connection_json" "$field_structure" "$field_record" "${field_structure['lookup_field']}")

    if [[ -z "$existing_id" ]]; then
        logMess "Record with ID $field_record does not exist in ${field_structure['reference_table']}."
        return 1
    fi

    local relationship_table=${field_structure['table_name']}
    local insert_rel_query="INSERT INTO $relationship_table (cod${field_structure['parent_table']}, cod${field_structure['reference_table']}) VALUES ($parent_id, $field_record);"

    if ! executeSqlQuery "$connection_json" "$insert_rel_query"; then
        logMess "Failed to insert relationship into table $relationship_table."
        return 1
    fi
    return 0
}

function processSimpleArrayField() {
    local connection_json=$1
    local field_structure=$2
    local field_records=$3
    local parent_id=$4

    echo "$field_records" | while read -r field_record; do    
        if [[ ${field_structure['field_name']} == cod* ]]; then
            processCodField "$connection_json" "$field_structure" "$field_record" "$parent_id"
        else
            processNonCodField "$connection_json" "$field_structure" "$field_record" "$parent_id"
        fi
    done
}

function processSimpleArrayFields() {
    local connection_json=$1
    local simple_array_fields_structure=$2
    local json_record=$3
    local parent_id
    parent_id=$(echo "$json_record" | jq -r '.codigo')
    
    echo "$simple_array_fields_structure" | jq -c '.[] | select(.data_type == "simple_array")' | while read -r field_structure; do
        local field_name
        field_name=$(echo "$field_structure" | jq -r '.field_name')
        local field_records
        field_records=$(echo "$json_record" | jq -c ".[\"$field_name\"][]")
        processSimpleArrayField "$connection_json" "$field_structure" "$field_records" "$parent_id"
    done
}

function filterFieldsStructureByType() {
    local fields_list=$1
    local data_type=$2

    echo "$fields_list" | jq -c --arg type "$data_type" '.[] | select(.data_type == $type)'
}

# processNestedFields
#
# Processes nested fields in a JSON record by handling "str_array" type fields.
# It checks or creates entries in the corresponding tables and links them to the main record.
#
# Arguments:
#   db_connection: A JSON string with database connection details.
#   record: A JSON string representing the main record.
#   nested_fields: A JSON string listing nested fields with their names, types, and structures.
#
function processNestedFields() {
    local connection_json=$1
    local json_record=$2
    local nested_fields=$3

    simple_array_fields=$(filterFieldsStructureByType "$nested_fields" "simple_array")
   processSimpleArrayFields "$connection_json" "$json_record" "$simple_array_fields"
    
    return 0
}

# insertJsonRecordInTable
#
# This function is responsible for inserting a record represented by a JSON object into a MySQL table, as specified in the table descriptor. It handles the insertion of both the primary record and any nested records, if present, into their respective tables. The function relies on a JSON string that describes the structure of the table, including the table name and its column definitions.
#
# Arguments:
#   db_connection: A JSON string containing the database connection details (host, user, password, etc.).
#   record: A JSON string representing a single record to be inserted into the table.
#   table_descriptor: A JSON string that describes the table structure. It contains the 'table_name' and 'table_structure'.
#
# Return:
#   Returns 0 (success) if the record and all nested records are successfully inserted into the database.
#   Returns 1 (error) if any part of the insertion process fails.
#
# Example Usage:
#   insertJsonRecordInTable "$db_connection" "$record" "$table_descriptor"
function insertJsonRecordInTable() {
    local db_connection=$1
    local record=$2
    local table_descriptor=$3

    # Extract table name and table structure from the table descriptor
    local table_name
    local table_structure
    table_name=$(echo "$table_descriptor" | jq -r '.table_name')
    table_structure=$(echo "$table_descriptor" | jq -r '.table_structure')

    # Construct and execute the SQL insertion query
    local insert_query
    insert_query=$(constructInsertQueryFromJson "$record" "$table_name" "$table_structure")
    if ! executeSqlQuery "$db_connection" "$insert_query"; then
        logMess "Error inserting record into table $table_name"
        return 1
    fi

    # Process nested fields within the JSON record
    local nested_fields
    nested_fields=$(getNestedFields "$table_structure")
    if [ -n "$nested_fields" ]; then
        if ! processNestedFields "$record" "$nested_fields" "$db_connection"; then
            logMess "Error processing nested fields for table $table_name"
            return 1
        fi
    fi

    return 0
}

function parseJsonForSqlInsert() {
    local json_record=$1
    local table_structure=$2      
    local -n _columns=$3          
    local -n _values=$4           

    # Itera por todas as chaves (nomes de colunas) da estrutura da tabela.
    for column in $(echo "$table_structure" | jq -r ". | keys[]"); do
        # Extrai o tipo de dado para a coluna atual da estrutura da tabela.
        local column_type=$(echo "$table_structure" | jq -r ".\"$column\"")

        # Verifica se o tipo de dado NÃO é um objeto JSON.
        if ! echo "$column_type" | jq -e . >/dev/null 2>&1; then
            # Se não for um objeto JSON, adiciona o nome da coluna ao array _columns.
            _columns+=("$column")

            # Extrai o valor correspondente para esta coluna do registro JSON.
            local value=$(echo "$json_record" | jq -r ".\"$column\"")

            # Adiciona o valor ao array _values.
            _values+=("$value")
        fi
    done
}

# Function to build an INSERT SQL query from a JSON record
function constructInsertQueryFromJson() {
    local json_record=$1
    local table=$2
    local table_structure=$3

    local sql_query="INSERT INTO $table ("
    local columns=""
    local values=""

    for column in $(echo "$table_structure" | jq -r ". | keys[]"); do
        local value
        value=$(echo "$json_record" | jq -r ".\"$column\"")
        column_type=$(echo "$table_structure" | jq -r ".\"$column\"")

        if echo "$column_type" | jq -e . >/dev/null 2>&1; then
            continue
        else
            if [ -n "$columns" ]; then
                columns+=", "
                values+=", "
            fi
            columns+="$column"
            
            if [[ "$value" == "true" ]]; then
                values+=1
            elif [[ "$value" == "false" ]]; then
                values+=0
            elif [ -z "$value" ] || [ "$value" == "null" ]; then
                values+="NULL"
            else
                values+="'$value'"
            fi
        fi
    done
    sql_query+="$columns) VALUES ($values);"
    echo "$sql_query"
}

function createSourceTableForSimpleList() {
    local connection_json=$1
    local field_name=$2
    local source_table_structure=$3

    local desc_field="${field_name%?}"

    local modified_table_structure
    modified_table_structure=$(echo "$source_table_structure" | \
                               jq --arg fn "$field_name" --arg df "$desc_field" \
                                  '.table_name = $fn | 
                                   .lookup_field = $df | 
                                   .fields[1].field_name = $df')
    
    createTableFromStructure "$connection_json" "$modified_table_structure"
}

function createRelationalTableForSimpleList() {
    local connection_json=$1
    local parent_table=$2
    local field_name=$3
    local relational_table_structure=$4
    
    local modified_table_structure
    modified_table_structure=$(echo "$relational_table_structure" | \
        jq --arg pt "$parent_table" --arg rf "$field_name" \
        --arg Pt "${parent_table^}" --arg Rf "${field_name^}" \
        '.table_name = ($pt + "_" + $rf) | 
        .fields[1].field_name = "cod" + $Pt | 
        .fields[1].definitions.reference.table = $pt | 
        .fields[2].field_name = "cod" + $Rf | 
        .fields[2].definitions.reference.table = $rf')

    createTableFromStructure "$connection_json" "$modified_table_structure"
}

function processSimpleListField() {
    local connection_json=$1
    local parent_table=$2
    local field_name=$3
    local source_table_structure=$4
    local relational_table_structure=$5

    createSourceTableForSimpleList "$connection_json" "$field_name" "$source_table_structure"

    createRelationalTableForSimpleList "$connection_json" "$parent_table" "$field_name" "$relational_table_structure"
}

function createTableFromStructure() {
    local connection_json=$1
    local table_structure=$2
    local parent_table
    parent_table=$(echo "$table_structure" | jq -r '.table_name')
    
    local create_table_sql
    create_table_sql=$(generateCreateTableSql "$table_structure")

    # Processar campos do tipo 'simple_list'
    for field in $(echo "$table_structure" | jq -c '.fields[] | select(.data_type == "simple_list")'); do
        local field_name
        field_name=$(echo "$field" | jq -r '.field_name')
        local source_table_structure=$(echo "$field" | jq -r '.definitions.table_reference')
        local relational_table_structure=$(echo "$field" | jq -r '.definitions.relational_table')

        processSimpleListField "$connection_json" "$parent_table" "$field_name" "$source_table_structure" "$relational_table_structure"
    done

    # Executar o script SQL para criar a tabela principal
    if ! executeSqlQuery "$connection_json" "$create_table_sql"; then
        logMess "Failed to create table $parent_table"
        return 1
    fi

    logMess "Table $parent_table created successfully"
    return 0
}

