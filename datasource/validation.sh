#!/bin/bash
#
# Description:
#
# Functions:
#  validateIPv4Address: Validates if the input is a valid IPv4 address.
#  validateIPv6Address: Validates if the input is a valid IPv6 address.
#  validateDomainName: Validates if the input is a valid domain name as url.
#  validateHostAddress: Validates if the input is a valid host address.
#  validateOnlyDigits: Validates if input contains only digits.
#  validateOnlyText: Validates if input contains only letters, numbers, and '_'.
#  validateSingleWord: Validates if input is a single word, alphanumeric, and starts with a letter.
#  validateInputInList: Validates if the provided input is in the specified list.
#  validateField: Validates user input based on the specified field.

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

# validateField: Validates user input based on the specified field.
# Arguments: field_json: A JSON string {"field_name": "name of the field", "field_value": "value"}.
# Returns: Field Value if successful, or returns 1 on failure.
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
    "source.auth.port"|"sync.frequency")
      if validateOnlyDigits "$field_value"; then
        return 0
      else
        return 1
      fi ;;
    "source.auth.host")
      if validateHostAddress "$input"; then
        return 0
      else
        return 1
      fi ;;
    *)      
      return 1
      ;;
  esac
}