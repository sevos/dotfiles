#!/bin/bash

# Ubuntu Software Installation Script
# Installs: VS Code, Chrome, Awesome Fonts, Mise, Ruby/Node, Claude Code, 1Password, Docker, Ollama, Preload

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed
package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Welcome message
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    🚀 Ubuntu Setup Script                    ║"
echo "║              Installing Development Environment              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System updated!"

# Install basic dependencies
print_status "Installing basic dependencies..."
sudo apt install -y wget curl gpg software-properties-common apt-transport-https
print_success "Basic dependencies installed!"

# Check and install VS Code
print_status "Setting up VS Code repository..."
if ! package_installed "code"; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y code
    print_success "VS Code installed!"
else
    print_info "VS Code is already installed"
fi

# Check and install Google Chrome
print_status "Setting up Google Chrome..."
if ! command_exists "google-chrome"; then
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable
    print_success "Google Chrome installed!"
else
    print_info "Google Chrome is already installed"
fi

# Install Font Awesome
print_status "Installing Font Awesome..."
if ! package_installed "fonts-font-awesome"; then
    sudo apt install -y fonts-font-awesome
    print_success "Font Awesome installed!"
else
    print_info "Font Awesome is already installed"
fi

# Install Mise
print_status "Installing Mise version manager..."
if ! command_exists "mise"; then
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
    print_success "Mise installed!"
else
    print_info "Mise is already installed"
fi

# Install Ruby build dependencies
print_status "Installing Ruby build dependencies..."
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev libyaml-dev libffi-dev libncurses5-dev libgdbm-dev libgdbm-compat-dev
print_success "Ruby build dependencies installed!"

# Install Ruby and Node with Mise
print_status "Installing Ruby 3 and Node 24 with Mise..."
if command_exists "mise" || [ -f "$HOME/.local/bin/mise" ]; then
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check if mise activation is already in bashrc
    if ! grep -q 'mise activate bash' ~/.bashrc; then
        echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
        print_success "Added Mise activation to ~/.bashrc"
    fi
    
    # Source bashrc to activate mise in current session
    source ~/.bashrc 2>/dev/null || eval "$($HOME/.local/bin/mise activate bash)" 2>/dev/null || true
    
    $HOME/.local/bin/mise install ruby@3 2>/dev/null || print_warning "Ruby 3 installation skipped (may already exist)"
    $HOME/.local/bin/mise install node@24 2>/dev/null || print_warning "Node 24 installation skipped (may already exist)"
    $HOME/.local/bin/mise global ruby@3 node@24 2>/dev/null || true
    print_success "Ruby 3 and Node 24 configured with Mise!"
    
    # Reload environment to ensure mise-installed node/npm are available
    source ~/.bashrc 2>/dev/null || eval "$($HOME/.local/bin/mise activate bash)" 2>/dev/null || true
fi

# Install Claude Code
print_status "Installing Claude Code..."
if ! command_exists "claude"; then
    # Force reload mise environment multiple times to ensure node/npm are available
    export PATH="$HOME/.local/bin:$PATH"
    eval "$($HOME/.local/bin/mise activate bash)" 2>/dev/null || true
    
    # Add mise shims to PATH
    if [ -d "$HOME/.local/share/mise/shims" ]; then
        export PATH="$HOME/.local/share/mise/shims:$PATH"
    fi
    
    # Try to find npm after mise activation
    if command_exists "npm" || [ -f "$HOME/.local/share/mise/shims/npm" ]; then
        # Use the npm that mise provides
        NPM_CMD="npm"
        if [ -f "$HOME/.local/share/mise/shims/npm" ]; then
            NPM_CMD="$HOME/.local/share/mise/shims/npm"
        fi
        
        $NPM_CMD install -g @anthropic-ai/claude-code
        print_success "Claude Code installed!"
    else
        print_warning "npm not available yet. Installing with alternative method..."
        # Try installing through mise's node directly
        if [ -f "$HOME/.local/share/mise/shims/node" ]; then
            $HOME/.local/share/mise/shims/node --version > /dev/null 2>&1 && \
            $HOME/.local/share/mise/shims/npx --yes @anthropic-ai/claude-code@latest --version > /dev/null 2>&1 || \
            print_error "Claude Code installation failed. Run after terminal restart: npm install -g @anthropic-ai/claude-code"
        else
            print_error "Node/npm not ready. Run after terminal restart: npm install -g @anthropic-ai/claude-code"
        fi
    fi
else
    print_info "Claude Code is already installed"
fi

# Install 1Password
print_status "Setting up 1Password..."
if ! package_installed "1password"; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list
    sudo apt update
    sudo apt install -y 1password
    print_success "1Password installed!"
else
    print_info "1Password is already installed"
fi

# Install Preload
print_status "Installing and configuring Preload..."
if ! package_installed "preload"; then
    sudo apt install -y preload
    sudo systemctl enable preload
    sudo systemctl start preload
    print_success "Preload installed and started!"
else
    print_info "Preload is already installed"
    if ! systemctl is-enabled preload >/dev/null 2>&1; then
        sudo systemctl enable preload
        print_success "Preload service enabled!"
    fi
    if ! systemctl is-active preload >/dev/null 2>&1; then
        sudo systemctl start preload
        print_success "Preload service started!"
    fi
fi

# Install Docker
print_status "Setting up Docker..."
if ! command_exists "docker"; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    print_success "Docker installed! (Logout/login required for user permissions)"
else
    print_info "Docker is already installed"
    if ! groups $USER | grep -q docker; then
        sudo usermod -aG docker $USER
        print_success "Added user to docker group!"
    fi
fi

# Install Ollama
print_status "Installing Ollama..."
if ! command_exists "ollama"; then
    curl -fsSL https://ollama.com/install.sh | sh
    print_success "Ollama installed!"
else
    print_info "Ollama is already installed"
fi

# Setup configuration symlinks
print_status "Setting up configuration symlinks..."
mkdir -p ~/.config

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to symlink a config directory
symlink_config() {
    local config_name="$1"
    local source_dir="$SCRIPT_DIR/$config_name"
    local target_dir="$HOME/.config/$config_name"
    
    if [ -d "$source_dir" ]; then
        if [ -L "$target_dir" ]; then
            rm "$target_dir"
        elif [ -d "$target_dir" ]; then
            mv "$target_dir" "$target_dir.backup.$(date +%Y%m%d_%H%M%S)"
            print_warning "Backed up existing $config_name config"
        fi
        ln -sf "$source_dir" "$target_dir"
        print_success "Symlinked $config_name config"
    else
        print_warning "$config_name config directory not found in $SCRIPT_DIR"
    fi
}

# List of configuration directories to symlink
CONFIG_DIRS=(
    "alacritty"
    "niri"
    "waybar"
)

# Symlink all configuration directories
for config_dir in "${CONFIG_DIRS[@]}"; do
    symlink_config "$config_dir"
done

# Final cleanup
print_status "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

# Summary
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    🎉 Installation Complete!                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

print_success "All software has been installed successfully!"
echo
print_info "📝 Next steps:"
echo "   • Restart your terminal or run: source ~/.bashrc"
echo "   • Log out and back in for Docker permissions"
echo "   • Run 'claude' to set up Claude Code authentication"
echo "   • Run 'mise doctor' to verify Mise setup"
echo "   • If Claude Code installation failed, restart terminal and run: npm install -g @anthropic-ai/claude-code"
echo "   • Configuration files have been symlinked to ~/.config/"
echo
print_info "🛠️  Installed software:"
echo "   • VS Code (code)"
echo "   • Google Chrome (google-chrome)"
echo "   • Font Awesome"
echo "   • Mise with Ruby 3 & Node 24"
echo "   • Claude Code (claude)"
echo "   • 1Password (1password)"
echo "   • Preload (system optimization)"
echo "   • Docker (docker)"
echo "   • Ollama (ollama)"
echo
echo -e "${GREEN}🚀 Happy coding!${NC}"