#!/bin/bash

# Description:
# This script offers a suite of validation functions for various types of inputs related to network addresses, domain names, and general input formats. It's designed to ensure the integrity and correctness of data inputs, particularly in configurations related to data sources and network settings. The script is essential for enforcing validation rules on user inputs or configurations before processing or storing them.
#
# The script includes functionalities to:
# - Validate IPv4 addresses.
# - Validate IPv6 addresses.
# - Validate domain names.
# - Validate host addresses.
# - Validate inputs containing only digits.
# - Validate inputs containing only alphanumeric characters and underscores.
# - Validate inputs containing only single words, alphanumeric, and beginning with a letter.
# - Validate inputs against a list of items.
# - Validate inputs based on a field criteria using a JSON input format.
# - Validate JSON objects.
# - Validate inputs as valid time in the format HH:MM.
# - Validates inputs as valid day of month 1-31.
# - Validates inputs as valid boolean values.
#
# Functions:
# - validateIPv4Address: Checks if a given string is a valid IPv4 address.
# - validateIPv6Address: Verifies if an input string conforms to the IPv6 address format.
# - validateDomainName: Determines if a string is a valid domain name.
# - validateHostAddress: Validates whether a string is a valid host address, including IPv4, IPv6, domain names, or localhost.
# - validateOnlyDigits: Ensures an input string contains only numerical digits.
# - validateOnlyText: Checks if an input contains only alphanumeric characters and underscores.
# - validateSingleWord: Confirms that an input is a single word, alphanumeric, and begins with a letter.
# - validateInputInList: Validates whether a given input is present in a provided list of items.
# - validateField: Validates a user input based on the specified field criteria using a JSON input format.
# - validateJsonObject: Validates if the input is a valid JSON string.
# - validateDayTime: Validates if the input is a valid time in the format HH:MM.
# - validateDayOfMonth: Validates if the input is a valid day of month.
# - validateIsBoolean: Validates if the input is a valid boolean value.
#
# Usage:
# The script can be sourced in any Bash environment where input validation is required. It's especially useful in scenarios involving network configurations, user input validation, or data source management. Each function is designed to be independently called with specific arguments, returning a success or failure status.
#
# Prerequisites:
# - jq must be installed on the system for parsing and handling JSON formatted data.
# - Familiarity with regular expressions and Bash scripting is recommended for effective use of the script.
#
# Author: Maicon de Menezes
# Creation Date: 06/01/2024
# Last Modified: 15/01/2024
# Version: 0.2.0

# Imports
source ../utils/constants.sh

# validateIPv4Address: Validates if the input is a valid IPv4 address.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateIPv4Address() {
  local input=$1
  local ipv4_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

  if [[ $input =~ $ipv4_regex ]]; then
    for octet in ${input//./ }; do
      if ((octet > 255)); then
        return 1
      fi
    done
    return 0
  else
    return 1
  fi
}

# validateIPv6Address: Validates if the input is a valid IPv6 address.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateIPv6Address() {
  local input=$1
  local ipv6_regex="^([0-9a-fA-F:]+:+)+[0-9a-fA-F]{1,4}$"

  if [[ $input =~ $ipv6_regex ]]; then
    return 0
  else
    return 1
  fi
}

# validateDomainName: Validates if the input is a valid domain name as url.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateDomainName() {
  local input=$1
  local domain_regex="^([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"

  if [[ $input =~ $domain_regex ]]; then
    return 0
  else
    return 1
  fi
}

# validateHostAddress: Validates if the input is a valid host address.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateHostAddress() {
  local input=$1

  if validateIPv4Address "$input" ||\
     validateIPv6Address "$input" ||\
     validateDomainName "$input" ||\
     [[ $input == "localhost" ]]; then
    return 0
  else
    return 1
  fi
}

# validateOnlyDigits: Validates if input contains only digits.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateOnlyDigits() {
  local input=$1
  [[ $input =~ ^[0-9]+$ ]]
}

# validateOnlyText: Validates if input contains only letters, numbers, and '_'.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateOnlyText() {
  local input=$1
  [[ $input =~ ^[a-zA-Z0-9_]*$ ]]
}

# validateSingleWord: Validates if input is a single word, alphanumeric, and starts with a letter.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateSingleWord() {
  local input=$1
  [[ $input =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]
}

# validateInputInList: Validates if the provided input is in the specified list.
# Arguments:
#   input: The input to be validated.
#   list: A string containing list items separated by space.
# Returns: Success (0) or failure (1).
function validateInputInList() {
  local input=$1
  local list=($2)
  
  for item in "${list[@]}"; do
    if [[ "$item" == "$input" ]]; then
      return 0
    fi
  done
  return 1
}

# validateJsonObject: Validates if the input is a valid JSON string.
# Arguments: json_string: The input to be validated.
# Returns: Success (0) or failure (1).
function validateJsonObject() {
  local json_string=$1
  jq -e . >/dev/null 2>&1 <<<"$json_string"
}

# validateDayTime: Validates if the input is a valid time in the format HH:MM.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateDayTime() {
  local input=$1
  local time_regex="^([0-1][0-9]|2[0-3]):[0-5][0-9]$"

  if [[ $input =~ $time_regex ]]; then
    return 0
  else
    return 1
  fi
}

# validateDayOfMonth: Validates if the input is a valid day of month.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateDayOfMonth() {
  local input=$1  
  
  validateOnlyDigits "$input" && \
  ((input >= 1 && input <= 31)) && \
  return 0 || return 1
}

# validateIsBoolean: Validates if the input is a valid boolean value.
# Arguments: input: The input to be validated.
# Returns: Success (0) or failure (1).
function validateIsBoolean() {
  local input=$1
  local boolean_regex="^(true|false|1|0)$"
  
  [[ $input =~ $boolean_regex ]] && return 0 || return 1
}

# validateField: Validates user input based on the specified field.
# Arguments: field_json: A JSON string {"field_name": "name of the field", "field_value": "value"}.
# Returns: Success (0) or failure (1).
function validateField() {
  local field_json=$1
  local field_name=$(echo "$field_json" | jq -r '.field_name')
  local field_value=$(echo "$field_json" | jq -r '.field_value')

  case $field_name in
    "source.origin"|"source.company")
      if validateSingleWord "$field_value"; then
        return 0
      else
        return 1
      fi ;;
    "auth.port"|"interval.value")
      if validateOnlyDigits "$field_value"; then
        return 0
      else
        return 1
      fi ;;
    "auth.host")
      if validateHostAddress "$field_value"; then
        return 0
      else
        return 1
      fi ;;
    "syncs.title")
      if validateOnlyText "$field_value"; then
        return 0
      else
        return 1
      fi ;;
    "schedule.type")
      if validateInputInList "$field_value" "$SYNC_TYPE_NAMES"; then
        return 0
      else
        return 1
      fi ;;
    "schedule.time")
      if validateDayTime "$field_value"; then
        return 0
      else
        return 1
      fi ;;
    "schedule.dow")
      if validateInputInList "$field_value" "$SYNC_DOW_NAMES"; then
        return 0
      else
        return 1
      fi ;;
    "schedule.dom")
      if validateDayOfMonth "$field_value"; then
        return 0
      else
        return 1
      fi ;;    
    "schedule.enabled")
      if validateIsBoolean "$field_value"; then
        return 0
      else
        return 1
      fi ;;
    "interval.unit")
      if validateInputInList "$field_value" "$SYNC_INTERVAL_NAMES"; then
        return 0
      else
        return 1
      fi ;;
    *)      
      return 1
      ;;
  esac
}

# validateSyncSchedule: Validates a sync schedule.
# Arguments: schedule_json: A JSON string representing the sync schedule.
# Returns: Success (0) or failure (1).
function validateSyncSchedule() {
  local schedule_json=$1

  if ! validateJsonObject "$schedule_json"; then
    echo "schedule_json is not a valid JSON." >&2
    return 1
  fi

  for field in "${SYNC_SCHEDULE_FIELDS[@]}"; do
    local value=$(echo "$schedule_json" | jq -r ".$field // empty")
    local field_json="{\"field_name\": \"schedule.$field\", \"field_value\": \"$value\"}"
    if ! validateField "$field_json"; then
      echo "Invalid or missing value for '$field' in schedule_json." >&2
      return 1
    fi
  done
}

# validateSyncScheduleInterval: Validates a sync schedule interval.
# Arguments: interval_json: A JSON string representing the sync schedule interval.
# Returns: Success (0) or failure (1).
function validateSyncScheduleInterval() {
  local interval_json=$1

  if ! validateJsonObject "$interval_json"; then
    echo "interval_json is not a valid JSON." >&2
    return 1
  fi

  for field in "${SYNC_INTERVAL_FIELDS[@]}"; do
    local value=$(echo "$interval_json" | jq -r ".$field // empty")
    local field_json="{\"field_name\": \"interval.$field\", \"field_value\": \"$value\"}"
    if ! validateField "$field_json"; then
      echo "Invalid or missing value for '$field' in interval_json." >&2
      return 1
    fi
  done
}

# validateSync: Validates a sync configuration.
# Arguments: sync_json: A JSON string representing the sync configuration.
# Returns: Success (0) or failure (1).
function validateSync() {
  local sync_json=$1
  
  if ! validateJsonObject "$sync_json"; then
    echo "sync_json is not a valid JSON." >&2
    return 1
  fi

  local sync_title=$(echo "$sync_json" | jq -r '.title')
  local sync_schedule=$(echo "$sync_json" | jq -r '.schedule')
  local sync_schedule_interval=$(echo "$sync_schedule" | jq -r '.interval')

  if ! validateField "{\"field_name\": \"syncs.title\", \"field_value\": \"$sync_title\"}"; then
    echo "Invalid or missing value for Sync Title in Sync." >&2
    return 1
  fi

  if ! validateSyncSchedule "$sync_schedule"; then
    echo "Invalid or missing value for Sync Schedule in Sync." >&2
    return 1
  fi

  if ! validateSyncScheduleInterval "$sync_schedule_interval"; then
    echo "Invalid or missing value for Sync Schedule Interval in Sync." >&2
    return 1
  fi

  return 0
}