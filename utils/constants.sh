#!/bin/bash

# Define Lists of Options for fields

# Data Source
## Types
declare -a SOURCE_TYPE_NAMES=("mysql_db" "public_api" "private_api")
declare -a SOURCE_TYPE_DESCRIPTIONS=("MySQL database" "Public API" "Private API")

# Syncs
declare -a SYNC_SCHEDULE_FIELDS=("type" "time" "dow" "dom" "enabled")
declare -a SYNC_INTERVAL_FIELDS=("value" "unit")
## Types
declare -a SYNC_TYPE_NAMES=("daily" "weekly" "monthly" "interval")
declare -a SYNC_TYPE_DESCRIPTIONS=("Daily" "Weekly" "Monthly" "Interval")
## Days of Week
declare -a SYNC_DOW_NAMES=("mon" "tue" "wed" "thu" "fri" "sat" "sun")
declare -a SYNC_DOW_DESCRIPTIONS=("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")
## Interval Units
declare -a SYNC_INTERVAL_NAMES=("min" "hrs")
declare -a SYNC_INTERVAL_DESCRIPTIONS=("Minutes" "Hours")
## Target Types
declare -a SYNC_TARGET_NAMES=("List Selection" "Direct Input" "Update All")
declare -a SYNC_TARGET_DESCRIPTIONS=("Select from a list (Not Implemented Yet)" "Type directly in the format \"asset_name\":[\"target_1\", \"target_2\", ...]" "Update the entire data source")

# Define color codes
declare -a RED='\033[0;31m'
declare -a GREEN='\033[0;32m'
declare -a NC='\033[0m' # No Color