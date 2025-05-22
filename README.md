# Advanced Scientific Calculator

A powerful command-line scientific calculator written in Bash.

## Features

- Basic arithmetic operations (+, -, \*, /, %, ^)
- Trigonometric functions (sin, cos, tan)
- Inverse trigonometric functions (asin, acos, atan)
- Other math functions (sqrt, log, ln, exp, abs, floor, ceil, round)
- Variable storage and recall
- Mathematical constants (pi, e)
- Expression parsing with proper operator precedence (BODMAS)
- Support for parentheses and nested expressions
- Color-coded output
- Automatic updates with `sudo apt update`

## Installation

### Automatic Installation (Ubuntu/Debian)

1. Clone this repository:

    ```bash
    git clone https://github.com/syedmdfarhaneazam/AdavancedCalculator
    cd AdavancedCalculator/scripts
    ```

2. Run the installation script:

    ```bash
    sudo ./install.sh
    ```

3. Source your shell configuration to apply PATH changes:

    ```bash
    source ~/.bashrc  # or ~/.zshrc, ~/.config/fish/config.fish
    ```

4. Use the calculator from any terminal:

    ```bash
    calculate
    ```

**Note**: The installation script requires `sudo` to install dependencies (`bc`, `git`) and configure an APT hook for automatic updates. The calculator will update from the GitHub repository whenever you run `sudo apt update`.

### Manual Installation

1.  Clone the repository:

    ```bash
    git clone https://github.com/syedmdfarhaneazam/AdavancedCalculator
    cd AdavancedCalculator
    ```

2.  Copy the calculator script and wrapper to the installation directory:

    ```bash
    mkdir -p ~/.local/share/advanced-calculator
    cp src/calculator.sh ~/.local/share/advanced-calculator/
    cp bin/calculate ~/.local/share/advanced-calculator/
    chmod +x ~/.local/share/advanced-calculator/calculate
    chmod +x ~/.local/share/advanced-calculator/calculator.sh
    ```

3.  Create a symlink to make the calculator accessible:

    ```bash
    mkdir -p ~/.local/bin
    ln -s ~/.local/share/advanced-calculator/calculate ~/.local/bin/calculate
    ```

4.  Ensure `~/.local/bin` is in your PATH. Add to your shell configuration (e.g., `~/.bashrc`, `~/.zshrc`):

    ```bash
    export PATH="$HOME/.local/bin:$PATH"
    ```

5.  Source your shell configuration:

    ```bash
    source ~/.bashrc  # or ~/.zshrc, etc.
    ```

6.  (Optional) Set up automatic updates with `sudo apt update`:

        ```bash
        sudo bash -c 'cat > /etc/apt/apt.conf.d/99-advanced-calculator-update' << EOF

    #!/bin/bash
    REPO_DIR="$HOME/.local/share/advanced-calculator-repo"
INSTALL_DIR="$HOME/.local/share/advanced-calculator"
    if [ -d "\$REPO_DIR" ]; then
    cd "\$REPO_DIR"
    git pull origin main
    if [ \$? -eq 0 ]; then
    cp "\$REPO_DIR/src/calculator.sh" "\$INSTALL_DIR/"
    cp "\$REPO_DIR/bin/calculate" "\$INSTALL_DIR/"
    chmod +x "\$INSTALL_DIR/calculate" "\$INSTALL_DIR/calculator.sh"
    echo -e "\033[1;32mAdvanced Calculator updated successfully\033[0m"
    else
    echo -e "\033[1;31mFailed to update Advanced Calculator\033[0m"
    fi
    fi
    EOF
    sudo chmod +x /etc/apt/apt.conf.d/99-advanced-calculator-update
    ```

## Usage

Run the calculator:

```bash
calculate
```

### Example Commands

- Basic calculations:

    ```bash
    > 5+4+9
    > (5+4)*(6/7)
    ```

- Trigonometric functions:

    ```bash
    > sin(80)+cos(60)
    > tan(45)
    ```

- Other functions:

    ```bash
    > sqrt(16)
    > log(100)
    ```

- Using constants:

    ```bash
    > pi*2
    > e^2
    ```

- Variable management:

    ```bash
    > save x 10
    > save y 20
    > x+y
    > recall
    ```

### Commands

- `exit` - Quit the calculator
- `clear` - Reset current result to 0
- `save [name]` - Save current result to variable
- `save [name] [expression]` - Evaluate expression and save to variable
- `recall` - Show all saved variables
- `recall [name]` - Show specific variable value
- `help` - Display help menu

## Updating

The calculator updates automatically when you run:

```bash
sudo apt update
```

This pulls the latest code from the GitHub repository and updates the installed files.

## Requirements

- Bash (available by default on most Linux/macOS systems)
- `bc` with math library (`-l` flag, typically included with `bc`)
- `git` (for cloning and updating the repository)
- Ubuntu/Debian-based system (for APT integration)

## License

MIT License
