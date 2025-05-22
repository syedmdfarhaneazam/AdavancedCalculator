# Advanced Scientific Calculator

A powerful command-line scientific calculator written in Bash.

## Features

- Basic arithmetic operations (+, -, \*, /, %, ^)
- Trigonometric functions (sin, cos, tan)
- Inverse trigonometric functions (asin, acos, atan)
- Other math functions (sqrt, log, ln, exp, abs, floor, ceil, round)
- Variable storage and recall
- Mathematical constants (pi, e)
- Expression parsing with proper operator precedence
- Support for parentheses and nested expressions
- Color-coded output

## Installation

### Automatic Installation (Linux/macOS)

1. Clone this repository:

    ```
    git clone https://github.com/syedmdfarhaneazam/bashCalculator
    cd bashCalculator/scripts
    ```

2. Run the installation script:

    ```
    ./install.sh
    ```

3. Use the calculator from any terminal:

    ```
    calculate
    ```

### Manual Installation

1. Copy the calculator script and wrapper to the installation directory:

    ```
    mkdir -p ~/.local/share/advanced-calculator
    cp src/calculator.sh ~/.local/share/advanced-calculator/
    cp bin/calculate ~/.local/share/advanced-calculator/
    chmod +x ~/.local/share/advanced-calculator/calculate
    chmod +x ~/.local/share/advanced-calculator/calculator.sh
    ```

2. Create a symlink to make the calculator accessible:

    ```
    mkdir -p ~/.local/bin
    ln -s ~/.local/share/advanced-calculator/calculate ~/.local/bin/calculate
    ```

3. Ensure `~/.local/bin` is in your PATH. Add to your shell configuration (e.g., `~/.bashrc`, `~/.zshrc`):

    ```
    export PATH="$HOME/.local/bin:$PATH"
    ```

4. Source your shell configuration:

    ```
    source ~/.bashrc  # or ~/.zshrc, etc.
    ```

## Usage

Run the calculator:

```
calculate
```

### Example Commands

- Basic calculations:

    ```
    > 5+4+9
    > (5+4)*(6/7)
    ```

- Trigonometric functions:

    ```
    > sin(80)+cos(60)
    > tan(45)
    ```

- Other functions:

    ```
    > sqrt(16)
    > log(100)
    ```

- Using constants:

    ```
    > pi*2
    > e^2
    ```

- Variable management:

    ```
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

## Requirements

- Bash (available by default on most Linux/macOS systems)
- `bc` with math library (`-l` flag, typically included with `bc`)

## License

MIT License
