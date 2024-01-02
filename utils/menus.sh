#!/bin/bash
#
# Description: This script provides utility functions for validating numeric inputs and enabling interactive selection of options in a Bash environment. It includes functions to check if an input is a valid number, whether it falls within a specified range, and to present a selection menu for choosing from an array of options. Ideal for scripts that require user input validation or interactive selection interfaces.
#
# Usage:
#   1. Source this script in your main script.
#   2. Use the `isValidNumber`, `isInRange`, and `selectOption` functions as needed to validate user inputs and create selection menus.
#
# Functions:
#   isValidNumber: Checks if the provided input is a valid number.
#   isInRange: Verifies if a number falls within a specified range.
#   selectOption: Presents a selection menu and returns the chosen option.
#
# Author: Maicon de Menezes
# Creation Date: 29/12/2023
# Version: 0.1.0

# isValidNumber: Checks if the provided input is a valid number (positive integer).
# Arguments:
#   $1: The input string to validate.
# Usage: isValidNumber "123"
# Returns: True (0) if the input is a valid number, False (1) otherwise.
function isValidNumber() {
    local input=$1
    [[ $input =~ ^[0-9]+$ ]]
}

# isInRange: Verifies if a given number falls within a specified range.
# Arguments:
#   $1: The number to check.
#   $2: The upper limit of the range.
# Usage: isInRange "5" "10"
# Returns: True (0) if the number is within the range, False (1) otherwise.
function isInRange() {
    local number=$1
    local range=$2
    [[ $number -ge 1 && $number -le $range ]]
}

# selectOption: Presents a user-interactive selection menu based on provided arrays of names and descriptions. Returns the name corresponding to the user's choice.
# Arguments:
#   $1: The name of the array containing option names (passed by reference).
#   $2: The name of the array containing option descriptions (passed by reference).
# Usage: selectOption "options_names" "options_descriptions"
# Outputs: The chosen option name from the options_names array.
function selectOption() {
    local -n options_names=$1
    local -n options_descriptions=$2

    PS3="Selecione uma opção (1-${#options_descriptions[@]}): "

    select choice in "${options_descriptions[@]}"; do
        if isValidNumber "$REPLY" && isInRange "$REPLY" "${#options_descriptions[@]}"; then
            echo "${options_names[$REPLY-1]}"
            break
        else
            echo "Opção inválida. Por favor, selecione um número de 1 a ${#options_descriptions[@]}." >&2
        fi
    done
}
