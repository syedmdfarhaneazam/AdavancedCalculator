#!/bin/bash

# Color & Style Setup
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
REPO_URL="https://github.com/syedmdfarhaneazam/AdavancedCalculator.git"
REPO_DIR="$HOME/.local/share/advanced-calculator-repo"
INSTALL_DIR="$HOME/.local/share/advanced-calculator"
SYMLINK_DIR="$HOME/.local/bin"
SYMLINK="$SYMLINK_DIR/calculate"
UPDATE_SCRIPT="/usr/local/bin/update-advanced-calculator.sh"
APT_HOOK="/etc/apt/apt.conf.d/99-advanced-calculator-update"

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

# Function: Check Dependencies
check_dependencies() {
    echo -e "${CYAN}${BOLD}Checking dependencies...${RESET}"
    if ! command -v bc &> /dev/null; then
        echo -e "${YELLOW}Installing bc...${RESET}"
        sudo apt update && sudo apt install -y bc
        progress_bar 2
    else
        echo -e "${GREEN}✓ bc is installed${RESET}"
    fi
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}Installing git...${RESET}"
        sudo apt update && sudo apt install -y git
        progress_bar 2
    else
        echo -e "${GREEN}✓ git is installed${RESET}"
    fi
}

# Function: Clone or Update Repository
clone_or_update_repo() {
    echo -e "${CYAN}Checking for repository updates...${RESET}"
    if [ -d "$REPO_DIR" ]; then
        cd "$REPO_DIR"
        git pull origin main
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to update repository${RESET}"
            exit 1
        fi
        progress_bar 1
    else
        git clone "$REPO_URL" "$REPO_DIR"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to clone repository${RESET}"
            exit 1
        fi
        progress_bar 1
    fi
}

# Function: Install Calculator
install_calculator() {
    echo -e "${CYAN}Installing calculator script...${RESET}"
    mkdir -p "$INSTALL_DIR" "$SYMLINK_DIR"
    cp "$REPO_DIR/src/calculator.sh" "$INSTALL_DIR/"
    cp "$REPO_DIR/bin/calculate" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/calculate" "$INSTALL_DIR/calculator.sh"
    ln -sf "$INSTALL_DIR/calculate" "$SYMLINK"
    progress_bar 1
}

# Function: Configure APT Hook
configure_apt_hook() {
    echo -e "${CYAN}${BOLD}Configuring APT update hook...${RESET}"
    sudo bash -c "cat > $UPDATE_SCRIPT" << EOF
#!/bin/bash
REPO_DIR="$HOME/.local/share/advanced-calculator-repo"
INSTALL_DIR="$HOME/.local/share/advanced-calculator"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"
if [ -d "\$REPO_DIR" ]; then
    cd "\$REPO_DIR"
    git pull origin main
    if [ \$? -eq 0 ]; then
        cp "\$REPO_DIR/src/calculator.sh" "\$INSTALL_DIR/"
        cp "\$REPO_DIR/bin/calculate" "\$INSTALL_DIR/"
        chmod +x "\$INSTALL_DIR/calculate" "\$INSTALL_DIR/calculator.sh"
        echo -e "\${GREEN}Advanced Calculator updated successfully\${RESET}"
    else
        echo -e "\${RED}Failed to update Advanced Calculator\${RESET}"
    fi
fi
EOF
    sudo chmod +x "$UPDATE_SCRIPT"
    sudo bash -c "cat > $APT_HOOK" << EOF
DPkg::Post-Invoke {"/bin/bash $UPDATE_SCRIPT";};
EOF
    echo -e "${GREEN}✓ APT hook configured at $APT_HOOK${RESET}"
}

# Function: Configure Shell PATH
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

# Main Flow
check_dependencies
clone_or_update_repo
install_calculator
configure_apt_hook
configure_shell_env

# Done
echo -e "${BLUE}${BOLD}═════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}        Installation Complete! 🚀        ${RESET}"
echo -e "${BLUE}${BOLD}═════════════════════════════════════════════════${RESET}"
echo -e "${YELLOW}${BOLD}You can now run the calculator by typing: ${WHITE}calculate${RESET}"
echo -e "${YELLOW}The calculator will update automatically with 'sudo apt update'${RESET}"
echo ""
