#!/bin/bash

# Common functions and variables for Ubuntu Bootstrap System
# This file should be sourced by all bootstrap scripts

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}🔧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║ $1"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed
package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Function to install packages with error handling
install_packages() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        if ! package_installed "$package"; then
            print_status "Installing $package..."
            sudo apt install -y "$package" 2>/dev/null || print_warning "Could not install $package"
        else
            print_info "$package is already installed"
        fi
    done
}

# Function to check and enable systemd service
enable_service() {
    local service="$1"
    if ! systemctl is-enabled "$service" >/dev/null 2>&1; then
        sudo systemctl enable "$service"
        print_success "$service service enabled!"
    else
        print_info "$service service is already enabled"
    fi
}

# Function to check and start systemd service
start_service() {
    local service="$1"
    if ! systemctl is-active "$service" >/dev/null 2>&1; then
        sudo systemctl start "$service"
        print_success "$service service started!"
    else
        print_info "$service service is already active"
    fi
}

# Function to add content to file if not already present
add_to_file_if_missing() {
    local file="$1"
    local content="$2"
    local search_pattern="$3"
    
    if [ -z "$search_pattern" ]; then
        search_pattern="$content"
    fi
    
    if [ ! -f "$file" ] || ! grep -q "$search_pattern" "$file"; then
        echo "$content" >> "$file"
        return 0  # Added
    else
        return 1  # Already exists
    fi
}

# Function to create backup of existing file/directory
create_backup() {
    local path="$1"
    local backup_path="$path.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -e "$path" ]; then
        mv "$path" "$backup_path"
        print_warning "Backed up existing $(basename "$path") to $(basename "$backup_path")"
        return 0  # Backup created
    else
        return 1  # Nothing to backup
    fi
}

# Package lists organized by category
BASIC_PACKAGES=(
    "wget"
    "curl" 
    "gpg"
    "software-properties-common"
    "apt-transport-https"
    "build-essential"
)

RUBY_BUILD_PACKAGES=(
    "libssl-dev"
    "libreadline-dev"
    "zlib1g-dev"
    "libyaml-dev"
    "libffi-dev"
    "libncurses5-dev"
    "libgdbm-dev"
    "libgdbm-compat-dev"
)

THEME_PACKAGES=(
    "fonts-font-awesome"
    "adwaita-icon-theme-full"
    "papirus-icon-theme"
    "numix-gtk-theme"
    "arc-theme"
    "gtk2-engines-murrine"
    "gtk2-engines-pixbuf"
    "gnome-themes-extra"
)

UTILITY_PACKAGES=(
    "bat"
    "fzf"
    "preload"
    "flatpak"
    "polkit-kde-agent-1"
)

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$SCRIPT_DIR/bootstrap.d"
CONFIG_DIR="$HOME/.config"

# Configuration directories and files to symlink
CONFIG_DIRS=(
    "alacritty"
    "niri"
    "waybar"
)

CONFIG_FILES=(
    "bashrc:~/.bashrc"
    "chrome-flags.conf:~/.config/chrome-flags.conf"
    "vscode-settings.json:~/.config/Code/User/settings.json"
)

# Function to symlink a config directory
symlink_config() {
    local config_name="$1"
    local source_dir="$SCRIPT_DIR/$config_name"
    local target_dir="$HOME/.config/$config_name"
    
    if [ -d "$source_dir" ]; then
        if [ -L "$target_dir" ]; then
            rm "$target_dir"
        elif [ -d "$target_dir" ]; then
            create_backup "$target_dir"
        fi
        ln -sf "$source_dir" "$target_dir"
        print_success "Symlinked $config_name config"
    else
        print_warning "$config_name config directory not found in $SCRIPT_DIR"
    fi
}

# Function to symlink individual config files
symlink_config_file() {
    local config_spec="$1"
    local source_file="${config_spec%:*}"
    local target_path="${config_spec#*:}"
    
    # Expand tilde in target path
    target_path="${target_path/#\~/$HOME}"
    
    local source_path="$SCRIPT_DIR/$source_file"
    local target_dir="$(dirname "$target_path")"
    
    if [ -f "$source_path" ]; then
        # Create target directory if it doesn't exist
        mkdir -p "$target_dir"
        
        if [ -L "$target_path" ]; then
            rm "$target_path"
        elif [ -f "$target_path" ]; then
            create_backup "$target_path"
        fi
        ln -sf "$source_path" "$target_path"
        print_success "Symlinked $(basename "$source_file")"
    else
        print_warning "$(basename "$source_file") not found in $SCRIPT_DIR"
    fi
}

# Function to setup repository with GPG key
setup_repository() {
    local name="$1"
    local key_url="$2"
    local repo_line="$3"
    local list_file="$4"
    
    print_status "Setting up $name repository..."
    
    # Download and install GPG key
    if [[ "$key_url" == *"gpg --dearmor"* ]]; then
        # Handle keys that need dearmoring
        eval "$key_url"
    else
        # Handle direct key installation
        if [[ "$name" == "Google Chrome" ]]; then
            wget -q -O - "$key_url" | sudo apt-key add -
        else
            wget -qO- "$key_url" | gpg --dearmor > packages.tmp.gpg
            sudo install -o root -g root -m 644 packages.tmp.gpg "/etc/apt/trusted.gpg.d/${name,,}.gpg"
            rm -f packages.tmp.gpg
        fi
    fi
    
    # Add repository
    echo "$repo_line" | sudo tee "/etc/apt/sources.list.d/$list_file"
    sudo apt update
    
    print_success "$name repository configured!"
}

# Validation functions
validate_environment() {
    if [ "$EUID" -eq 0 ]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    if ! command_exists "apt"; then
        print_error "This script requires apt package manager (Ubuntu/Debian)"
        exit 1
    fi
    
    print_info "Environment validation passed"
}

# Progress tracking
TOTAL_SCRIPTS=0
CURRENT_SCRIPT=0

set_total_scripts() {
    TOTAL_SCRIPTS="$1"
}

next_script() {
    CURRENT_SCRIPT=$((CURRENT_SCRIPT + 1))
    local script_name="$1"
    echo -e "${PURPLE}[$CURRENT_SCRIPT/$TOTAL_SCRIPTS] $script_name${NC}"
}

# Export functions for use in other scripts
export -f print_status print_success print_warning print_error print_info print_header
export -f command_exists package_installed install_packages
export -f enable_service start_service add_to_file_if_missing create_backup
export -f symlink_config symlink_config_file setup_repository validate_environment
export -f set_total_scripts next_script