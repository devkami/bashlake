# MySQL Library Script

## Overview

This `mysql_lib.sh` script is a Bash library designed for comprehensive management of MySQL databases. It encompasses a wide array of functionalities, including installing MySQL, verifying installation, starting MySQL services, setting up security configurations, user management, database backups, restoration, and more. Targeted primarily for Ubuntu 22.04 or higher, the script leverages the `expect` utility for automated inputs during secure installations

## Functions

The script contains various functions, each serving a specific purpose in MySQL database management:

- ### `getLocalDbName`: Gets the local database name using the `DB_NAME` environment variable

- ### `getBkpFilename`: Determines the backup filename for a given database name

- ### `checkMySqlInstall`: Checks whether the MySQL server is installed on the system

- ### `installMysql`: Installs the MySQL server, specifically designed for Ubuntu 22.04 or higher

- ### `checkMysqlRun`: Verifies if the MySQL service is running and attempts to start it if not

- ### `setMysqlSec`: Automates the `mysql_secure_installation` process using `expect`, setting a strong password and applying security enhancements

- ### `createMysqlUsers`: Creates a new MySQL user with specified credentials and grants privileges

- ### `prepareMySqlDB`: Prepares the MySQL database environment by installing MySQL, starting services, and setting up security configurations

- ### `deleteBackupFiles`: Deletes all SQL files generated during the database dump process

- ### `backupMySQLBDViews`: Performs a backup of MySQL database views

- ### `backupMySQLDBRoutines`: Backs up MySQL database routines, such as stored procedures and functions

- ### `backupMySQLDBTablesAndData`: Performs a comprehensive backup of MySQL database tables and data

- ### `backupMysqlDB`: Executes a complete backup of a MySQL database, including tables, views, and routines

- ### `dropCreateDatabase`: Drops and creates a new local MySQL database

- ### `restoreBackupDatabase`: Restores a MySQL database from a backup into a new local database

- ### `createEgestorSalesTableSQL`: Generates an SQL script to create a new table for egestor sales

- ### `executeSqlQuery`: Executes a specified SQL query on the MySQL database

- ### `importCsvFileToTable`: Imports data from a CSV file into a specific MySQL table

## Usage

Source this script into your main script to access its functions. Ensure that the necessary environment variables (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`) are set before using the script

## Prerequisites

- MySQL server and client should be installed on the system
- The `expect` utility must be available for automating interactions in scripts
- Ensure that the necessary environment variables are set for database connectivity

### Author: [Maicon de Menezes](https://github.com/maicondmenezes)

### Creation Date: 19/11/2023

### Version: 0.2.1
