# Test Library Script

## Overview

The `test_lib.sh` script is designed to facilitate automated testing in Bash scripts. It provides a suite of functions for running tests, reporting successes and failures, and calculating success rates. Key features include color-coded output for clear visibility of test results and the ability to tally total, passed, and failed tests. This script is particularly useful for developers looking to implement unit testing in their Bash scripting projects.

## Usage

To use this script for testing:

1. Source `test_lib.sh` in your test script.
2. Define your test functions with names starting with `test`.
3. Call `runAllTests` to execute all defined tests and display the summary of results.

## Functions

The script includes the following functions for testing:

- ### `print_success`: Prints a success message in green color

```bash
print_success "Message for successful outcome"
```

- ### `print_failure`: Prints a failure message in red color

```bash
print_failure "Message for failed outcome"
```

- ### `runAllTests`: Runs all functions starting with `test`, counts the number of passed and failed tests, and displays a summary including the success rate

## Color Codes

The script uses ANSI color codes for enhancing the output visibility:

- Green for successful tests.
- Red for failed tests.
- No color (reset) for regular text.

## Additional Notes

- The script is particularly useful for Bash-based projects where unit testing is required.
- The success rate is displayed in green if it's 50% or higher, and in red if it's lower than 50%, providing an immediate visual cue of the overall test performance.

### Author: [Maicon de Menezes](https://github.com/maicondmenezes)

### Creation Date: 02/01/2024

### Version: 0.1.0
