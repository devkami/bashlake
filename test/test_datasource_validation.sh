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
        "field": "{\"field_name\": \"source.auth.port\", \"field_value\": \"8080\"}"
    }'    
    invalid_data='{
        "ipv4": "256.256.256.256",
        "ipv6": "not:a:valid:ipv6:address",
        "domain": "invalid_domain@.com",
        "host": "invalid_host_address",
        "digits": "notdigits123",
        "text": "Invalid Text!",
        "singleWord": "Two words",        
        "field": "{\"field_name\": \"source.auth.port\", \"field_value\": \"invalid\"}"
    }'
}

function testValidateIPv4Address() {    
    local valid_ipv4=$(echo "$valid_data" | jq -r '.ipv4')
    local invalid_ipv4=$(echo "$invalid_data" | jq -r '.ipv4')
    
    if validateIPv4Address "$valid_ipv4" && ! validateIPv4Address "$invalid_ipv4"; then
        return 0
    else        
        return 1
    fi
}

function testValidateIPv6Address() {    
    local valid_ipv6=$(echo "$valid_data" | jq -r '.ipv6')
    local invalid_ipv6=$(echo "$invalid_data" | jq -r '.ipv6')
    
    if validateIPv6Address "$valid_ipv6" && ! validateIPv6Address "$invalid_ipv6"; then
        return 0
    else        
        return 1
    fi
}

function testValidateDomainName() {    
    local valid_domain=$(echo "$valid_data" | jq -r '.domain')
    local invalid_domain=$(echo "$invalid_data" | jq -r '.domain')
    
    if validateDomainName "$valid_domain" && ! validateDomainName "$invalid_domain"; then
        return 0
    else        
        return 1
    fi
}

function testValidateHostAddress() {    
    local valid_host=$(echo "$valid_data" | jq -r '.host')
    local invalid_host=$(echo "$invalid_data" | jq -r '.host')
    
    if validateHostAddress "$valid_host" && ! validateHostAddress "$invalid_host"; then
        return 0
    else        
        return 1
    fi
}

function testValidateOnlyDigits() {    
    local valid_digits=$(echo "$valid_data" | jq -r '.digits')
    local invalid_digits=$(echo "$invalid_data" | jq -r '.digits')
    
    if validateOnlyDigits "$valid_digits" && ! validateOnlyDigits "$invalid_digits"; then
        return 0
    else        
        return 1
    fi
}

function testValidateOnlyText() {    
    local valid_text=$(echo "$valid_data" | jq -r '.text')
    local invalid_text=$(echo "$invalid_data" | jq -r '.text')
    
    if validateOnlyText "$valid_text" && ! validateOnlyText "$invalid_text"; then
        return 0
    else        
        return 1
    fi
}

function testValidateSingleWord() {    
    local valid_singleWord=$(echo "$valid_data" | jq -r '.singleWord')
    local invalid_singleWord=$(echo "$invalid_data" | jq -r '.singleWord')
    
    if validateSingleWord "$valid_singleWord" && ! validateSingleWord "$invalid_singleWord"; then
        return 0
    else        
        return 1
    fi
}

function testValidateInputInList() {    
    local valid_input="apple"
    local invalid_input="grape"
    local list="apple banana orange"
    
    if validateInputInList "$valid_input" "$list" && ! validateInputInList "$invalid_input" "$list";then
        return 0
    else        
        return 1
    fi
}

function testValidateField() { 
    local valid_field=$(echo "$valid_data" | jq -r '.field')
    local invalid_field=$(echo "$invalid_data" | jq -r '.field')
    
    if validateField "$valid_field" && ! validateField "$invalid_field"; then
        return 0
    else        
        return 1
    fi
}

function postTest(){
    return 0
}

function run(){
    source test_lib.sh
    preTest
    runAllTests
    postTest
}

run
