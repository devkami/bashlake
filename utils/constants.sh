#!/bin/bash

# Define Lists of Options for datasource.sh script
# Data Source Types
declare -a SOURCE_TYPE_NAMES=("mysql_db" "public_api" "private_api")
declare -a SOURCE_TYPE_DESCRIPTIONS=("MySQL database" "Public API" "Private API")
#Sync Targets
declare -a SYNC_TARGET_NAMES=("List Selection" "Direct Input" "Update All")
declare -a SYNC_TARGET_DESCRIPTIONS=("Select from a list (Not Implemented Yet)" "Type directly in the format \"asset_name\":[\"target_1\", \"target_2\", ...]" "Update the entire data source")
# Sync Periods
declare -a SYNC_PERIOD_NAMES=("secs" "mins" "hours" "days")
declare -a SYNC_PERIOD_DESCRIPTIONS=("Seconds" "Minutes" "Hours" "Days")

# Define color codes
declare -a RED='\033[0;31m'
declare -a GREEN='\033[0;32m'
declare -a NC='\033[0m' # No Color