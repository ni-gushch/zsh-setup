#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for headless mode
if [ "$AUTO_INSTALL" = "y" ] || [ "$HEADLESS" = "true" ]; then
	HEADLESS_MODE=true
	echo "Running in headless mode..."
else
	HEADLESS_MODE=false
fi

echo -e "${BLUE}🚀 Starting automated Zsh + Oh My Zsh + Powerlevel10k setup...${NC}"

# Function to check if command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to install package based on OS
install_package() {
	local package=$1
	if command_exists apt-get; then
		# Debian/Ubuntu
		sudo apt-get install -y "$package" >/dev/null 2>&1
	elif command_exists yum; then
		# RHEL/CentOS
		sudo yum install -y "$package" >/dev/null 2>&1
	elif command_exists dnf; then
		# Fedora
		sudo dnf install -y "$package" >/dev/null 2>&1
	elif command_exists brew; then
		# macOS
		brew install "$package" >/dev/null 2>&1
	else
		echo -e "${RED}Could not detect package manager. Please install $package manually.${NC}"
		return 1
	fi
}

# Check and install Zsh if not installed
if ! command_exists zsh; then
	echo -e "${YELLOW}Zsh not found. Installing...${NC}"
	if ! install_package zsh; then
		echo -e "${RED}Failed to install zsh${NC}"
		exit 1
	fi
else
	echo -e "${GREEN}✓ Zsh is already installed${NC}"
fi

# Check and install Git if not installed
if ! command_exists git; then
	echo -e "${YELLOW}Git not found. Installing...${NC}"
	if ! install_package git; then
		echo -e "${RED}Failed to install git${NC}"
		exit 1
	fi
else
	echo -e "${GREEN}✓ Git is already installed${NC}"
fi

# Install Oh My Zsh (unattended)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
	if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >/dev/null 2>&1; then
		echo -e "${RED}Failed to install Oh My Zsh${NC}"
		exit 1
	fi
else
	echo -e "${GREEN}✓ Oh My Zsh is already installed${NC}"
fi

# Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
	echo -e "${YELLOW}Installing Powerlevel10k theme...${NC}"
	if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" >/dev/null 2>&1; then
		echo -e "${RED}Failed to install Powerlevel10k${NC}"
		exit 1
	fi
else
	echo -e "${GREEN}✓ Powerlevel10k is already installed${NC}"
fi

# Install zsh-autosuggestions plugin
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
	echo -e "${YELLOW}Installing zsh-autosuggestions plugin...${NC}"
	if ! git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" >/dev/null 2>&1; then
		echo -e "${RED}Failed to install zsh-autosuggestions${NC}"
		exit 1
	fi
else
	echo -e "${GREEN}✓ zsh-autosuggestions is already installed${NC}"
fi

# Install zsh-syntax-highlighting plugin
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
	echo -e "${YELLOW}Installing zsh-syntax-highlighting plugin...${NC}"
	if ! git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" >/dev/null 2>&1; then
		echo -e "${RED}Failed to install zsh-syntax-highlighting${NC}"
		exit 1
	fi
else
	echo -e "${GREEN}✓ zsh-syntax-highlighting is already installed${NC}"
fi

# Backup existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
	echo -e "${YELLOW}Backing up existing .zshrc to .zshrc.backup...${NC}"
	cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

# Create optimized .zshrc configuration
echo -e "${YELLOW}Creating optimized .zshrc configuration...${NC}"

cat >~/.zshrc <<'EOL'
# Enable Powerlevel10k instant prompt (should stay at the top of ~/.zshrc)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.png" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.png"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
	git
	web-search
	sudo
	zsh-autosuggestions
	zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='nano'
else
	export EDITOR='nano'
fi

# Aliases
alias cls='clear'
alias zshconfig='nano ~/.zshrc'
alias ohmyzsh='nano ~/.oh-my-zsh'
alias update='sudo apt update && sudo apt upgrade -y'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Color support for ls
if command -v dircolors >/dev/null 2>&1; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
elif [[ "$OSTYPE" == "darwin"* ]]; then
	export CLICOLOR=1
	export LSCOLORS=ExFxBxDxCxegedabagacad
fi

# Set default p10k configuration (lean style with some useful elements)
if [[ ! -f ~/.p10k.zsh ]]; then
	echo "#
# This file is auto-generated by the setup script.
# You can run 'p10k configure' to customize it later.
#
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
typeset -g POWERLEVEL9K_MODE=ascii
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'" > ~/.p10k.zsh
fi

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOL

# Set Zsh as default shell (if not already)
CURRENT_SHELL="$(basename "$SHELL")"
if [ "$CURRENT_SHELL" != "zsh" ] && [ "$HEADLESS_MODE" = "false" ]; then
	echo -e "${YELLOW}Setting Zsh as default shell...${NC}"
	chsh -s "$(which zsh)"
	echo -e "${GREEN}✓ Zsh set as default shell. Changes will take effect after restarting your terminal.${NC}"
else
	echo -e "${GREEN}✓ Zsh is already the default shell or running in headless mode${NC}"
fi

# Source the new configuration for current session if possible
if [ "$CURRENT_SHELL" = "zsh" ] && [ -f "$HOME/.zshrc" ]; then
	# shellcheck source=/dev/null
	source "$HOME/.zshrc" >/dev/null 2>&1
	echo -e "${GREEN}✓ Sourced new .zshrc configuration${NC}"
fi

# Verification function
verify_installation() {
	echo -e "${BLUE}🔍 Verifying installation...${NC}"

	local errors=0

	# Check if zsh is installed
	if ! command_exists zsh; then
		echo -e "${RED}✗ Zsh not found${NC}"
		errors=$((errors + 1))
	else
		echo -e "${GREEN}✓ Zsh installed${NC}"
	fi

	# Check if Oh My Zsh is installed
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		echo -e "${RED}✗ Oh My Zsh not found${NC}"
		errors=$((errors + 1))
	else
		echo -e "${GREEN}✓ Oh My Zsh installed${NC}"
	fi

	# Check if plugins are installed
	if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
		echo -e "${RED}✗ zsh-autosuggestions not found${NC}"
		errors=$((errors + 1))
	else
		echo -e "${GREEN}✓ zsh-autosuggestions installed${NC}"
	fi

	if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
		echo -e "${RED}✗ zsh-syntax-highlighting not found${NC}"
		errors=$((errors + 1))
	else
		echo -e "${GREEN}✓ zsh-syntax-highlighting installed${NC}"
	fi

	# Check if theme is installed
	if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
		echo -e "${RED}✗ Powerlevel10k not found${NC}"
		errors=$((errors + 1))
	else
		echo -e "${GREEN}✓ Powerlevel10k installed${NC}"
	fi

	# Check if .zshrc exists
	if [ ! -f "$HOME/.zshrc" ]; then
		echo -e "${RED}✗ .zshrc not found${NC}"
		errors=$((errors + 1))
	else
		echo -e "${GREEN}✓ .zshrc created${NC}"
	fi

	# Test zsh syntax
	if zsh -n ~/.zshrc 2>/dev/null; then
		echo -e "${GREEN}✓ .zshrc syntax is valid${NC}"
	else
		echo -e "${RED}✗ .zshrc syntax is invalid${NC}"
		errors=$((errors + 1))
	fi

	if [ $errors -eq 0 ]; then
		echo -e "${GREEN}🎉 All verifications passed! Installation successful!${NC}"
		return 0
	else
		echo -e "${RED}❌ Installation completed with $errors error(s)${NC}"
		return 1
	fi
}

# Run verification
verify_installation
EXIT_CODE=$?

if [ "$HEADLESS_MODE" = "true" ]; then
	exit $EXIT_CODE
else
	echo -e "${BLUE}Next steps:${NC}"
	echo -e "1. ${YELLOW}Restart your terminal${NC}"
	echo -e "2. Run ${YELLOW}p10k configure${NC} if you want to customize the theme appearance"
	echo -e "3. Install a ${YELLOW}Nerd Font${NC} (like Meslo) in your terminal settings for icons"
	echo -e "4. Enjoy your super-powered terminal! 🚀"

	exit $EXIT_CODE
fi
