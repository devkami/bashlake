#!/bin/bash

# Source the test library and the datasource_validation script
source ../datasource/validation.sh

function preTest() {  
  valid_data='{
    "ipv4": "192.168.1.1",
    "ipv6": "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
    "domain": "example.com",
    "host": "localhost",
    "digits": "12345",
    "text": "ValidText_123",
    "singleWord": "Word123",    
    "field": "{\"field_name\": \"auth.port\", \"field_value\": \"8080\"}",
    "json": "{\"key\": \"value\"}",
    "dayTime": "14:30",
    "dayOfMonth": "15",
    "boolean": "true",
    "syncSchedule": "{\"type\": \"daily\", \"time\": \"14:30\", \"dow\": \"mon\", \"dom\": \"1\", \"enabled\": \"true\"}",
    "syncScheduleInterval": "{\"value\": \"30\", \"unit\": \"min\"}",
    "sync": "{\"title\": \"DailySync\", \"schedule\": {\"type\": \"daily\", \"time\": \"14:30\", \"dow\": \"mon\", \"dom\": \"1\", \"interval\": {\"value\": \"30\", \"unit\": \"min\"},\"enabled\": \"true\"}}"
  }'  
  invalid_data='{
    "ipv4": "256.256.256.256",
    "ipv6": "not:a:valid:ipv6:address",
    "domain": "invalid_domain@.com",
    "host": "invalid_host_address",
    "digits": "notdigits123",
    "text": "Invalid Text!",
    "singleWord": "Two words",    
    "field": "{\"field_name\": \"source.auth.port\", \"field_value\": \"invalid\"}",
    "json": "Not a JSON",
    "dayTime": "25:61",
    "dayOfMonth": "32",
    "boolean": "maybe",
    "syncSchedule": "{\"type\": \"invalid\", \"time\": \"25:61\", \"dow\": \"noday\", \"dom\": \"32\", \"enabled\": \"maybe\"}",
    "syncScheduleInterval": "{\"value\": \"invalid\", \"unit\": \"unknown\"}",
    "sync": "{\"title\": \"\", \"schedule\": {\"type\": \"invalid\", \"time\": \"25:61\", \"dow\": \"noday\", \"dom\": \"32\", \"enabled\": \"maybe\"}, \"interval\": {\"value\": \"invalid\", \"unit\": \"unknown\"}}"
  }'
}

function testValidateIPv4Address() {  
  local valid_ipv4=$(echo "$valid_data" | jq -r '.ipv4')
  local invalid_ipv4=$(echo "$invalid_data" | jq -r '.ipv4')
  
  validateIPv4Address "$valid_ipv4" && \
  ! validateIPv4Address "$invalid_ipv4" && \
  return 0 || return 1
}

function testValidateIPv6Address() {  
  local valid_ipv6=$(echo "$valid_data" | jq -r '.ipv6')
  local invalid_ipv6=$(echo "$invalid_data" | jq -r '.ipv6')
  
  validateIPv6Address "$valid_ipv6" && \
  ! validateIPv6Address "$invalid_ipv6" && \
  return 0 || return 1
}

function testValidateDomainName() {  
  local valid_domain=$(echo "$valid_data" | jq -r '.domain')
  local invalid_domain=$(echo "$invalid_data" | jq -r '.domain')
  
  validateDomainName "$valid_domain" && \
  ! validateDomainName "$invalid_domain" && \
  return 0 || return 1
}

function testValidateHostAddress() {  
  local valid_host=$(echo "$valid_data" | jq -r '.host')
  local invalid_host=$(echo "$invalid_data" | jq -r '.host')
  
  validateHostAddress "$valid_host" && \
  ! validateHostAddress "$invalid_host" && \
  return 0 || return 1
}

function testValidateOnlyDigits() {  
  local valid_digits=$(echo "$valid_data" | jq -r '.digits')
  local invalid_digits=$(echo "$invalid_data" | jq -r '.digits')
  
  validateOnlyDigits "$valid_digits" && \
  ! validateOnlyDigits "$invalid_digits" && \
  return 0 || return 1
}

function testValidateOnlyText() {  
  local valid_text=$(echo "$valid_data" | jq -r '.text')
  local invalid_text=$(echo "$invalid_data" | jq -r '.text')
  
  validateOnlyText "$valid_text" && \
  ! validateOnlyText "$invalid_text" && \
  return 0 || return 1
}

function testValidateSingleWord() {  
  local valid_singleWord=$(echo "$valid_data" | jq -r '.singleWord')
  local invalid_singleWord=$(echo "$invalid_data" | jq -r '.singleWord')
  
  validateSingleWord "$valid_singleWord" && \
  ! validateSingleWord "$invalid_singleWord" && \
  return 0 || return 1
}

function testValidateInputInList() {  
  local valid_input="apple"
  local invalid_input="grape"
  local list="apple banana orange"
  
  validateInputInList "$valid_input" "$list" && \
  ! validateInputInList "$invalid_input" "$list" && \
  return 0 || return 1
}

function testValidateJsonObject() {  
  local valid_json=$(echo "$valid_data" | jq -r '.json')
  local invalid_json=$(echo "$invalid_data" | jq -r '.json')
  
  validateJsonObject "$valid_json" && \
  ! validateJsonObject "$invalid_json" && \
  return 0 || return 1
}

function testValidateJsonObject(){
  local valid_json=$(echo "$valid_data" | jq -r '.json')
  local invalid_json=$(echo "$invalid_data" | jq -r '.json')
  
  validateJsonObject "$valid_json" && \
  ! validateJsonObject "$invalid_json" && \
  return 0 || return 1
}

function testValidateDayTime() {  
  local valid_dayTime=$(echo "$valid_data" | jq -r '.dayTime')
  local invalid_dayTime=$(echo "$invalid_data" | jq -r '.dayTime')
  
  validateDayTime "$valid_dayTime" && \
  ! validateDayTime "$invalid_dayTime" && \
  return 0 || return 1
}

function testValidateDayOfMonth() {  
  local valid_dayOfMonth=$(echo "$valid_data" | jq -r '.dayOfMonth')
  local invalid_dayOfMonth=$(echo "$invalid_data" | jq -r '.dayOfMonth')
  
  validateDayOfMonth "$valid_dayOfMonth" && \
  ! validateDayOfMonth "$invalid_dayOfMonth" && \
  return 0 || return 1
}

function testValidateBoolean() {  
  local valid_boolean=$(echo "$valid_data" | jq -r '.boolean')
  local invalid_boolean=$(echo "$invalid_data" | jq -r '.boolean')
  
  validateIsBoolean "$valid_boolean" && \
  ! validateIsBoolean "$invalid_boolean" && \
  return 0 || return 1
}

function testValidateField() { 
  local valid_field=$(echo "$valid_data" | jq -r '.field')
  local invalid_field=$(echo "$invalid_data" | jq -r '.field')
  
  validateField "$valid_field" && \
  ! validateField "$invalid_field" && \
  return 0 || return 1
}

function testValidateSyncSchedule() {  
  local valid_syncSchedule=$(echo "$valid_data" | jq -r '.syncSchedule')
  local invalid_syncSchedule=$(echo "$invalid_data" | jq -r '.syncSchedule')
  
  validateSyncSchedule "$valid_syncSchedule" && \
  ! validateSyncSchedule "$invalid_syncSchedule"  2>/dev/null && \
  return 0 || return 1
}

function testValidateSyncScheduleInterval() {  
  local valid_syncScheduleInterval=$(echo "$valid_data" | jq -r '.syncScheduleInterval')  
  local invalid_syncScheduleInterval=$(echo "$invalid_data" | jq -r '.syncScheduleInterval')
  
  validateSyncScheduleInterval "$valid_syncScheduleInterval" && \
  ! validateSyncScheduleInterval "$invalid_syncScheduleInterval" 2>/dev/null && \
  return 0 || return 1
}

function testValidateSync() {  
  local valid_sync=$(echo "$valid_data" | jq -r '.sync')
  local invalid_sync=$(echo "$invalid_data" | jq -r '.sync')
  
  validateSync "$valid_sync" && \
  ! validateSync "$invalid_sync" 2>/dev/null && \
  return 0 || return 1
}

function postTest(){
  unset valid_data
  unset invalid_data
  return 0
}

function run(){
  source test_lib.sh
  preTest
  runAllTests
  postTest
}

run
