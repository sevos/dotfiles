#!/bin/bash

# 1Password Installation
# Sets up 1Password password manager

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "1Password Installation"

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