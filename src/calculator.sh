#!/bin/bash

# colours
RESET="\033[0m"
GREEN="\033[1;32m"  # success
RED="\033[1;31m"    # error
CYAN="\033[1;36m"   # user Input
YELLOW="\033[1;33m" # warnings

# global variables
result=0
declare -A variables

# mathematical constants
PI=3.14159265358979323846
E=2.71828182845904523536

#help section
display_help() {
    echo -e "${YELLOW}=== Scientific Calculator Help ===${RESET}"
    echo -e "${CYAN}Basic Operations: + - * / % ^${RESET}"
    echo -e "${CYAN}Functions: sin, cos, tan, sqrt, log, ln, exp, abs, floor, ceil, round${RESET}"
    echo -e "${CYAN}Inverse Functions: asin, acos, atan${RESET}"
    echo -e "${CYAN}Constants: pi, e${RESET}"
    echo -e "${CYAN}Commands:${RESET}"
    echo -e "${CYAN}  save [name] - Save current result to variable${RESET}"
    echo -e "${CYAN}  save [name] [value] - Save specific value to variable${RESET}"
    echo -e "${CYAN}  recall - Show all saved variables${RESET}"
    echo -e "${CYAN}  recall [name] - Show specific variable value${RESET}"
    echo -e "${CYAN}  clear - Reset current result to 0${RESET}"
    echo -e "${CYAN}  exit - Quit the calculator${RESET}"
    echo -e "${CYAN}  help - Display this help${RESET}"
}

# function to convert degrees to radians
deg_to_rad() {
    echo "scale=10; $1 * $PI / 180" | bc -l
}

# function to convert radians to degrees
rad_to_deg() {
    echo "scale=10; $1 * 180 / $PI" | bc -l
}

# mathe functions
math_sin() {
    local angle_rad=$(deg_to_rad $1)
    echo "scale=10; s($angle_rad)" | bc -l
}

math_cos() {
    local angle_rad=$(deg_to_rad $1)
    echo "scale=10; c($angle_rad)" | bc -l
}

math_tan() {
    local angle_rad=$(deg_to_rad $1)
    echo "scale=10; s($angle_rad)/c($angle_rad)" | bc -l
}

math_sqrt() {
    if (( $(echo "$1 < 0" | bc -l) )); then
        echo "Error: Cannot take square root of negative number" >&2
        return 1
    fi
    echo "scale=10; sqrt($1)" | bc -l
}

math_log() {
    if (( $(echo "$1 <= 0" | bc -l) )); then
        echo "Error: Cannot take log of non-positive number" >&2
        return 1
    fi
    echo "scale=10; l($1)/l(10)" | bc -l
}

math_ln() {
    if (( $(echo "$1 <= 0" | bc -l) )); then
        echo "Error: Cannot take ln of non-positive number" >&2
        return 1
    fi
    echo "scale=10; l($1)" | bc -l
}

math_exp() {
    echo "scale=10; e($1)" | bc -l
}

math_abs() {
    if (( $(echo "$1 < 0" | bc -l) )); then
        echo "scale=10; -($1)" | bc -l
    else
        echo "scale=10; $1" | bc -l
    fi
}

math_floor() {
    echo "scale=0; $1/1" | bc -l
}

math_ceil() {
    local int_part=$(echo "scale=0; $1/1" | bc -l)
    if (( $(echo "$1 > $int_part" | bc -l) )); then
        echo "scale=0; $int_part + 1" | bc -l
    else
        echo "$int_part"
    fi
}

math_round() {
    echo "scale=0; ($1 + 0.5)/1" | bc -l
}

math_asin() {
    if (( $(echo "$1 < -1 || $1 > 1" | bc -l) )); then
        echo "Error: Argument for asin must be in range [-1, 1]" >&2
        return 1
    fi
    
    # Handle special cases
    if (( $(echo "$1 == 1" | bc -l) )); then
        echo "90"
        return
    elif (( $(echo "$1 == -1" | bc -l) )); then
        echo "-90"
        return
    elif (( $(echo "$1 == 0" | bc -l) )); then
        echo "0"
        return
    fi
    
    # use the identity: asin(x) = atan(x/sqrt(1-x²))
    local denominator=$(echo "scale=10; sqrt(1-$1*$1)" | bc -l)
    local result_rad=$(echo "scale=10; a($1/$denominator)" | bc -l)
    rad_to_deg $result_rad
}

math_acos() {
    if (( $(echo "$1 < -1 || $1 > 1" | bc -l) )); then
        echo "Error: Argument for acos must be in range [-1, 1]" >&2
        return 1
    fi
    
    # Handle special cases
    if (( $(echo "$1 == 1" | bc -l) )); then
        echo "0"
        return
    elif (( $(echo "$1 == -1" | bc -l) )); then
        echo "180"
        return
    elif (( $(echo "$1 == 0" | bc -l) )); then
        echo "90"
        return
    fi
    
    # use the identity: acos(x) = atan(sqrt(1-x²)/x) for x > 0
    # for x < 0: acos(x) = 180 + atan(sqrt(1-x²)/x)
    local numerator=$(echo "scale=10; sqrt(1-$1*$1)" | bc -l)
    local result_rad=$(echo "scale=10; a($numerator/$1)" | bc -l)
    
    if (( $(echo "$1 < 0" | bc -l) )); then
        result_rad=$(echo "scale=10; $PI + $result_rad" | bc -l)
    fi
    
    rad_to_deg $result_rad
}

math_atan() {
    local result_rad=$(echo "scale=10; a($1)" | bc -l)
    rad_to_deg $result_rad
}

# function to replace variables and constants
replace_variables() {
    local expr="$1"
    
    # replace constants
    expr="${expr//pi/$PI}"
    expr="${expr//e/$E}"
    
    # replace user variables
    for var in "${!variables[@]}"; do
        expr="${expr//$var/${variables[$var]}}"
    done
    
    echo "$expr"
}

# function to evaluate mathematical functions
evaluate_function() {
    local func_name="$1"
    local arg="$2"
    
    case "$func_name" in
        "sin") math_sin "$arg" ;;
        "cos") math_cos "$arg" ;;
        "tan") math_tan "$arg" ;;
        "sqrt") math_sqrt "$arg" ;;
        "log") math_log "$arg" ;;
        "ln") math_ln "$arg" ;;
        "exp") math_exp "$arg" ;;
        "abs") math_abs "$arg" ;;
        "floor") math_floor "$arg" ;;
        "ceil") math_ceil "$arg" ;;
        "round") math_round "$arg" ;;
        "asin") math_asin "$arg" ;;
        "acos") math_acos "$arg" ;;
        "atan") math_atan "$arg" ;;
        *) echo "Error: Unknown function: $func_name" >&2; return 1 ;;
    esac
}

# function to find matching parenthesis
find_matching_paren() {
    local expr="$1"
    local start="$2"
    local count=1
    local i=$((start + 1))
    
    while [[ $i -lt ${#expr} ]]; do
        if [[ "${expr:$i:1}" == "(" ]]; then
            ((count++))
        elif [[ "${expr:$i:1}" == ")" ]]; then
            ((count--))
            if [[ $count -eq 0 ]]; then
                echo "$i"
                return
            fi
        fi
        ((i++))
    done
    
    echo "-1"
}

# function to parse and evaluate expressions (BODMAS order)
evaluate_expression() {
    local expr="$1"
    
    # remove spaces
    expr="${expr// /}"
    
    # handle empty expression
    if [[ -z "$expr" ]]; then
        echo "Error: Empty expression" >&2
        return 1
    fi
    
    # replace variables
    expr=$(replace_variables "$expr")
    
    # handle functions first
    while [[ "$expr" =~ ([a-zA-Z]+)\( ]]; do
        local func_name="${BASH_REMATCH[1]}"
        local func_start=$(echo "$expr" | grep -b -o -E "$func_name\(" | head -1 | cut -d: -f1)
        local paren_start=$((func_start + ${#func_name}))
        local paren_end=$(find_matching_paren "$expr" "$paren_start")
        
        if [[ $paren_end -eq -1 ]]; then
            echo "Error: Mismatched parentheses" >&2
            return 1
        fi
        
        local arg_expr="${expr:$((paren_start + 1)):$((paren_end - paren_start - 1))}"
        local arg_value=$(evaluate_expression "$arg_expr")
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        local func_result=$(evaluate_function "$func_name" "$arg_value")
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        expr="${expr:0:$func_start}${func_result}${expr:$((paren_end + 1))}"
    done
    
    # handle parentheses
    while [[ "$expr" =~ \( ]]; do
        local paren_start=$(echo "$expr" | grep -b -o "(" | tail -1 | cut -d: -f1)
        local paren_end=$(find_matching_paren "$expr" "$paren_start")
        
        if [[ $paren_end -eq -1 ]]; then
            echo "Error: Mismatched parentheses" >&2
            return 1
        fi
        
        local sub_expr="${expr:$((paren_start + 1)):$((paren_end - paren_start - 1))}"
        local sub_result=$(evaluate_expression "$sub_expr")
        
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        
        expr="${expr:0:$paren_start}${sub_result}${expr:$((paren_end + 1))}"
    done
    
    # now evaluate using bc with proper operator precedence
    local bc_expr="scale=10; $expr"
    local result=$(echo "$bc_expr" | bc -l 2>/dev/null)
    
    if [[ $? -ne 0 ]] || [[ -z "$result" ]]; then
        echo "Error: Invalid expression" >&2
        return 1
    fi
    
    echo "$result"
}

# function to save variables
save_variable() {
    local input="$1"
    local parts=($input)
    local var_name="${parts[0]}"
    
    # validate variable name
    if [[ ! "$var_name" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        echo -e "${RED}Invalid variable name! Start with a letter, use only letters and numbers.${RESET}"
        return 1
    fi
    
    if [[ ${#parts[@]} -gt 1 ]]; then
        # save specific value
        local value_expr="${input#* }"
        local value=$(evaluate_expression "$value_expr")
        
        if [[ $? -eq 0 ]]; then
            variables["$var_name"]="$value"
            echo -e "${GREEN}Saved: $var_name = $value${RESET}"
        else
            echo -e "${RED}Error evaluating expression${RESET}"
        fi
    else
        # save current result
        variables["$var_name"]="$result"
        echo -e "${GREEN}Saved: $var_name = $result${RESET}"
    fi
}

# function to recall variables
recall_variable() {
    local var_name="$1"
    
    if [[ -n "${variables[$var_name]}" ]]; then
        result="${variables[$var_name]}"
        echo -e "${GREEN}Recalled: $var_name = ${variables[$var_name]}${RESET}"
    else
        echo -e "${RED}Error: Variable not found!${RESET}"
    fi
}

# function to display all variables
display_all_variables() {
    if [[ ${#variables[@]} -eq 0 ]]; then
        echo -e "${RED}No saved variables!${RESET}"
    else
        echo -e "${GREEN}Saved Variables:${RESET}"
        for var in "${!variables[@]}"; do
            echo -e "${CYAN}$var = ${variables[$var]}${RESET}"
        done
    fi
}

# main function
main() {
    echo -e "${YELLOW}Welcome to Advanced Scientific Calculator!${RESET}"
    echo -e "${YELLOW}Enter expressions (type 'exit' to quit)${RESET}"
    echo -e "${YELLOW}Examples: sin(80)+cos(60), 5+4+9, (5+4)*(6/7)${RESET}"
    echo -e "${YELLOW}Functions: sin, cos, tan, sqrt, log, ln, exp, abs, floor, ceil, round${RESET}"
    echo -e "${YELLOW}Advanced Functions: save, recall, help, clear${RESET}"
    
    while true; do
        echo -ne "${CYAN}> ${RESET}"
        read -r input
        
        # trim whitespace
        input="${input#"${input%%[![:space:]]*}"}"
        input="${input%"${input##*[![:space:]]}"}"
        
        case "$input" in
            "exit")
                echo -e "${YELLOW}Exiting Calculator... Bye! 🚀${RESET}"
                break
                ;;
            "clear")
                result=0
                echo -e "${GREEN}Result Cleared!${RESET}"
                ;;
            "help")
                display_help
                ;;
            "recall")
                display_all_variables
                ;;
            "recall "*)
                recall_variable "${input#recall }"
                ;;
            "save "*)
                save_variable "${input#save }"
                ;;
            "")
                echo -e "${RED}Invalid input! Please enter an expression.${RESET}"
                ;;
            *)
                # handle expressions starting with operators (use previous result)
                if [[ "$input" =~ ^[+\-*/%^] ]]; then
                    input="${result}${input}"
                fi
                
                # evaluate expression
                local new_result=$(evaluate_expression "$input")
                
                if [[ $? -eq 0 ]]; then
                    result="$new_result"
                    # format result to remove trailing zeros
                    result=$(echo "$result" | sed 's/\.0*$//' | sed 's/\.\([0-9]*[1-9]\)0*/.\1/')
                    echo -e "${GREEN}Result: $result${RESET}"
                else
                    echo -e "${RED}Error: Invalid expression${RESET}"
                fi
                ;;
        esac
    done
}

# check if bc is available
if ! command -v bc &> /dev/null; then
    echo -e "${RED}Error: 'bc' calculator is required but not installed.${RESET}"
    echo -e "${YELLOW}Please install bc: sudo apt-get install bc (Ubuntu/Debian) or brew install bc (macOS)${RESET}"
    exit 1
fi

# starting the calculator
main
