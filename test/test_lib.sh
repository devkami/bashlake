#!/bin/bash

# test_lib.sh
# Description: This script offers a comprehensive suite for automated testing in Bash scripts. It includes functions for executing test cases, reporting test results with color-coded outputs, and summarizing the overall test performance. The script enhances readability and clarity of test outcomes through the use of red and green color codes for failures and successes respectively. It's designed to be integrated into Bash-based projects for efficient unit testing.

# Usage:
#   1. Source this script in your test script.
#   2. Define test functions prefixed with 'test'.
#   3. Use the `runAllTests` function to execute all tests and get a summary report.
#   4. Utilize `print_success` and `print_failure` to display colored output for test results.

# Functions:
#   print_success: Outputs a success message in green.
#   print_failure: Outputs a failure message in red.
#   runAllTests: Executes all test functions, tallies successes and failures, and displays a summary.

# Author: Maicon de Menezes
# Creation Date: 02/01/2024
# Version: 0.1.0

# Import Scripts
source ./utils/constants.sh

# print_success: Prints a success message in green color.
# Arguments:
#   $1: The message to display as success.
# Usage: print_success "Test passed successfully."
function print_success() {
    echo -e "${GREEN}$1${NC}"
}

# print_failure: Prints a failure message in red color.
# Arguments:
#   $1: The message to display as failure.
# Usage: print_failure "Test failed."
function print_failure() {
    echo -e "${RED}$1${NC}"
}

# runAllTests: Executes all functions in the script that start with 'test', counts the passed and failed tests, and displays a summary of the results. It calculates the percentage of successful tests and shows the success rate in green if it's 50% or higher, and in red if lower.
# Usage: runAllTests
# No arguments are needed. The function automatically detects and runs all test functions.
function runAllTests() {
    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    for func in $(declare -F | awk '{print $NF}' | grep '^test'); do       
        if $func; then
            ((passed_tests++))
            echo "Test $func: $(print_success PASSED)"
        else
            ((failed_tests++))
            echo "Test $func: $(print_failure FAILED)"
        fi
        ((total_tests++))
    done

    # Display summary
    echo "Test $total_tests functions | Passed: $passed_tests | Failed: $failed_tests"
    # Calculate and display the percentage of success
    local success_percentage=0
    if [ $total_tests -ne 0 ]; then
        success_percentage=$(echo "scale=2; ($passed_tests/$total_tests)*100" | bc)
    fi
    # Print success rate in green if 50% or more, otherwise in red
    if (( $(echo "$success_percentage >= 50" | bc -l) )); then
        echo "Success rate: $(print_success "$success_percentage"%)"
    else
        echo "Success rate: $(print_failure "$success_percentage"%)"
    fi
}