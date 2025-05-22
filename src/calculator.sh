#!/bin/bash

# Color Codes
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

# Variables
VARIABLES_FILE="$HOME/.local/share/advanced-calculator/variables"
RESULT=0
declare -A variables
[ -f "$VARIABLES_FILE" ] && source "$VARIABLES_FILE"

# Constants
PI=$(echo "scale=10; 4*a(1)" | bc -l)
E=$(echo "scale=10; e(1)" | bc -l)

# Function: Display Help
display_help() {
    echo -e "${YELLOW}=== Scientific Calculator Help ===${RESET}"
    echo -e "${CYAN}Basic Operations: + - * / % ^${RESET}"
    echo -e "${CYAN}Functions: sin, cos, tan, sqrt, log, ln, exp, abs, floor, ceil, round${RESET}"
    echo -e "${CYAN}Inverse Trig Functions: asin, acos, atan${RESET}"
    echo -e "${CYAN}Constants: pi, e${RESET}"
    echo -e "${CYAN}Commands:${RESET}"
    echo -e "${CYAN}  save [name] - Save current result to variable${RESET}"
    echo -e "${CYAN}  save [name] [expression] - Evaluate expression and save to variable${RESET}"
    echo -e "${CYAN}  recall - Show all saved variables${RESET}"
    echo -e "${CYAN}  recall [name] - Show specific variable value${RESET}"
    echo -e "${CYAN}  clear - Reset current result to 0${RESET}"
    echo -e "${CYAN}  exit - Quit the calculator${RESET}"
    echo -e "${CYAN}  help - Display this help${RESET}"
}

# Function: Save Variable
save_variable() {
    local input="$1"
    local var_name="${input%% *}"
    local var_value="${input#* }"

    if ! [[ "$var_name" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        echo -e "${RED}Invalid variable name! Start with a letter, use only letters and numbers.${RESET}"
        return
    fi

    if [ "$var_name" = "$var_value" ]; then
        variables["$var_name"]="$RESULT"
        echo -e "${GREEN}Saved: $var_name = $RESULT${RESET}"
    else
        local value
        value=$(evaluate_expression "$var_value" 2>/dev/null)
        if [ $? -eq 0 ]; then
            variables["$var_name"]="$value"
            echo -e "${GREEN}Saved: $var_name = $value${RESET}"
        else
            echo -e "${RED}Error evaluating expression: $var_value${RESET}"
            return
        fi
    fi

    # Save variables to file
    > "$VARIABLES_FILE"
    for key in "${!variables[@]}"; do
        echo "variables[$key]=${variables[$key]}" >> "$VARIABLES_FILE"
    done
}

# Function: Recall Variable
recall_variable() {
    local var_name="$1"
    if [ -z "$var_name" ]; then
        if [ ${#variables[@]} -eq 0 ]; then
            echo -e "${RED}No saved variables!${RESET}"
        else
            echo -e "${GREEN}Saved Variables:${RESET}"
            for key in "${!variables[@]}"; do
                echo -e "${CYAN}$key = ${variables[$key]}${RESET}"
            done
        fi
    elif [ -n "${variables[$var_name]}" ]; then
        RESULT="${variables[$var_name]}"
        echo -e "${GREEN}Recalled: $var_name = ${variables[$var_name]}${RESET}"
    else
        echo -e "${RED}Error: Variable not found!${RESET}"
    fi
}

# Function: Replace Variables and Constants
replace_variables() {
    local expression="$1"
    expression=$(echo "$expression" | sed -E "s/\bpi\b/$PI/g; s/\be\b/$E/g")
    for key in "${!variables[@]}"; do
        expression=$(echo "$expression" | sed -E "s/\b$key\b/${variables[$key]}/g")
    done
    echo "$expression"
}

# Function: Parse Functions
parse_function() {
    local expr="$1"
    local func_name="${expr%%(*}"
    local arg="${expr#*(}"
    arg="${arg%)}"

    local parsed_arg
    parsed_arg=$(evaluate_expression "$arg" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Invalid function argument" >&2
        return 1
    fi

    case "$func_name" in
        sin)
            echo "s($parsed_arg * $PI / 180)" | bc -l
            ;;
        cos)
            echo "c($parsed_arg * $PI / 180)" | bc -l
            ;;
        tan)
            echo "s($parsed_arg * $PI / 180)/c($parsed_arg * $PI / 180)" | bc -l
            ;;
        sqrt)
            if [ $(echo "$parsed_arg < 0" | bc -l) -eq 1 ]; then
                echo "Cannot take square root of negative number" >&2
                return 1
            fi
            echo "sqrt($parsed_arg)" | bc -l
            ;;
        log)
            if [ $(echo "$parsed_arg <= 0" | bc -l) -eq 1 ]; then
                echo "Cannot take log of non-positive number" >&2
                return 1
            fi
            echo "l($parsed_arg)/l(10)" | bc -l
            ;;
        ln)
            if [ $(echo "$parsed_arg <= 0" | bc -l) -eq 1 ]; then
                echo "Cannot take ln of non-positive number" >&2
                return 1
            fi
            echo "l($parsed_arg)" | bc -l
            ;;
        exp)
            echo "e($parsed_arg)" | bc -l
            ;;
        abs)
            echo "if ($parsed_arg < 0) -$parsed_arg else $parsed_arg" | bc -l
            ;;
        floor)
            echo "scale=0; $parsed_arg/1" | bc -l
            ;;
        ceil)
            echo "scale=0; ($parsed_arg + 0.999999)/1" | bc -l
            ;;
        round)
            echo "scale=0; ($parsed_arg + 0.5)/1" | bc -l
            ;;
        asin)
            if [ $(echo "$parsed_arg < -1 || $parsed_arg > 1" | bc -l) -eq 1 ]; then
                echo "Argument for asin must be in range [-1, 1]" >&2
                return 1
            fi
            echo "a($parsed_arg) * 180 / $PI" | bc -l
            ;;
        acos)
            if [ $(echo "$parsed_arg < -1 || $parsed_arg > 1" | bc -l) -eq 1 ]; then
                echo "Argument for acos must be in range [-1, 1]" >&2
                return 1
            fi
            echo "(a(1) * 2 - a($parsed_arg)) * 180 / $PI" | bc -l
            ;;
        atan)
            echo "a($parsed_arg) * 180 / $PI" | bc -l
            ;;
        *)
            echo "Unknown function: $func_name" >&2
            return 1
            ;;
    esac
}

# Function: Evaluate Expression
evaluate_expression() {
    local expression="$1"
    expression=$(echo "$expression" | tr -d '[:space:]')

    if [ -z "$expression" ]; then
        echo "Invalid input! Please enter an expression." >&2
        return 1
    fi

    # Replace variables and constants
    expression=$(replace_variables "$expression")

    # Handle leading operators using previous result
    if [[ "$expression" =~ ^[+\-*/%^].* ]]; then
        expression="$RESULT$expression"
    fi

    # Parse functions
    while [[ "$expression" =~ ([a-z]+)\(([^\(\)]*)\)(.*) ]]; do
        local func_call="${BASH_REMATCH[0]}"
        local func_name="${BASH_REMATCH[1]}"
        local func_arg="${BASH_REMATCH[2]}"
        local rest="${BASH_REMATCH[3]}"
        local func_result
        func_result=$(parse_function "${func_name}(${func_arg})" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "$func_result" >&2
            return 1
        fi
        expression="${expression/$func_call/$func_result}$rest"
    done

    # Handle parentheses
    while [[ "$expression" =~ \(([^\(\)]*)\)(.*) ]]; do
        local inner="${BASH_REMATCH[1]}"
        local rest="${BASH_REMATCH[2]}"
        local inner_result
        inner_result=$(evaluate_expression "$inner" 2>/dev/null)
        if [ $? -ne 0 ]; then
            return 1
        fi
        expression="${expression/($inner)/$inner_result}$rest"
    done

    # Evaluate with bc
    local result
    result=$(echo "scale=10; $expression" | bc -l 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Invalid expression" >&2
        return 1
    fi
    echo "$result"
}

# Main Loop
echo -e "${YELLOW}Welcome to Advanced Scientific Calculator!${RESET}"
echo -e "${YELLOW}Enter expressions (type 'exit' to quit)${RESET}"
echo -e "${YELLOW}Examples: sin(80)+cos(60), 5+4+9, (5+4)*(6/7)${RESET}"
echo -e "${YELLOW}Functions: sin, cos, tan, sqrt, log, ln, exp, abs, floor, ceil, round${RESET}"
echo -e "${YELLOW}Advanced Functions: save, recall, help, clear${RESET}"

while true; do
    echo -ne "${CYAN}> ${RESET}"
    read -r input
    input=$(echo "$input" | tr -d '[:space:]')

    case "$input" in
        exit)
            echo -e "${YELLOW}Exiting Calculator... Bye! 🚀${RESET}"
            break
            ;;
        clear)
            RESULT=0
            echo -e "${GREEN}Result Cleared!${RESET}"
            ;;
        save*)
            save_variable "${input#save }" 
            ;;
        recall*)
            recall_variable "${input#recall }"
            ;;
        help)
            display_help
            ;;
        *)
            result=$(evaluate_expression "$input" 2>/dev/null)
            if [ $? -eq 0 ]; then
                RESULT="$result"
                echo -e "${GREEN}Result: $result${RESET}"
            else
                echo -e "${RED}Error: $result${RESET}"
            fi
            ;;
    esac
done
