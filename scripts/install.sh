#!/bin/bash

# colours
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
RESET="\033[0m"
BOLD="\033[1m"
WHITE="\033[1;37m"

# ASCII Banner
echo -e "${CYAN}"
cat << "EOF"
   _____      _            _       _             
  / ____|    | |          | |     | |            
 | |     __ _| | ___ _   _| | __ _| |_ ___  _ __  
 | |    / _` | |/ __| | | | |/ _` | __/ _ \| '__|
 | |___| (_| | | (__| |_| | | (_| | || (_) | |   
  \_____\__,_|_|\___|\__,_|_|\__,_|\__\___/|_|
                                                
EOF
echo -e "${RESET}"

echo -e "${BLUE}${BOLD}═════════════════════════════════════════════════${RESET}"
echo -e "${YELLOW}${BOLD}        Advanced Calculator Installation        ${RESET}"
echo -e "${BLUE}${BOLD}═════════════════════════════════════════════════${RESET}"

# Paths & Variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SRC="$PROJECT_ROOT/src/calculator.sh"
WRAPPER="$PROJECT_ROOT/bin/calculate"
INSTALL_DIR="$HOME/.local/share/advanced-calculator"
SYMLINK_DIR="$HOME/.local/bin"
SYMLINK="$SYMLINK_DIR/calculate"

mkdir -p "$INSTALL_DIR" "$SYMLINK_DIR"

# Function: Progress Bar
progress_bar() {
    local duration=$1
    local steps=20
    local delay=$(echo "$duration / $steps" | bc -l)
    echo -ne "${YELLOW}["
    for ((i = 0; i < steps; i++)); do
        echo -ne "${GREEN}#"
        sleep "$delay"
    done
    echo -e "${YELLOW}] ${GREEN}Done!${RESET}"
}

# Function: Install Calculator
install_calculator() {
    echo -e "${CYAN}Installing calculator script...${RESET}"
    cp "$SRC" "$INSTALL_DIR/"
    cp "$WRAPPER" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/calculate"
    chmod +x "$INSTALL_DIR/calculator.sh"
    ln -sf "$INSTALL_DIR/calculate" "$SYMLINK"
    progress_bar 1
}

# Function: Configure Shell
configure_shell_env() {
    echo -e "${CYAN}${BOLD}Configuring shell PATH...${RESET}"

    CURRENT_SHELL=$(basename "$SHELL")
    echo -e "${CYAN}Detected shell: ${WHITE}$CURRENT_SHELL${RESET}"

    case "$CURRENT_SHELL" in
        bash)  RC="$HOME/.bashrc" ;;
        zsh)   RC="$HOME/.zshrc" ;;
        fish)  RC="$HOME/.config/fish/config.fish" ;;
        *)
            read -p "$(echo -e ${MAGENTA}Unknown shell. Use bash/zsh/fish? ${WHITE}[bash/zsh/fish]${RESET}): " CUSTOM_SHELL
            case "$CUSTOM_SHELL" in
                bash) RC="$HOME/.bashrc" ;;
                zsh) RC="$HOME/.zshrc" ;;
                fish) RC="$HOME/.config/fish/config.fish" ;;
                *) echo -e "${RED}Unsupported shell. Exiting.${RESET}"; exit 1 ;;
            esac
            ;;
    esac

    if [[ "$CURRENT_SHELL" == "fish" ]]; then
        mkdir -p "$(dirname "$RC")"
        grep -q "set -x PATH $SYMLINK_DIR" "$RC" 2>/dev/null || echo "set -x PATH $SYMLINK_DIR \$PATH" >> "$RC"
    else
        grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$RC" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"
    fi

    echo -e "${GREEN}✓ Environment updated in: ${WHITE}$RC${RESET}"
    echo -e "${YELLOW}Restart your terminal or run 'source $RC' to apply changes.${RESET}"
}

# starting
install_calculator
configure_shell_env

# after completion 
echo -e "${BLUE}${BOLD}═════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}        Installation Complete! 🚀        ${RESET}"
echo -e "${BLUE}${BOLD}═════════════════════════════════════════════════${RESET}"
echo -e "${YELLOW}${BOLD}You can now run the calculator by typing: ${WHITE}calculate${RESET}"
echo ""
