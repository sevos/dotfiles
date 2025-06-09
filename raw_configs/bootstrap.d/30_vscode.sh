#!/bin/bash

# VS Code Installation and Configuration
# Sets up Microsoft Visual Studio Code with repository

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "VS Code Installation"

# Check and install VS Code
print_status "Setting up VS Code repository..."
if ! package_installed "code"; then
    setup_repository "VS Code" \
        "https://packages.microsoft.com/keys/microsoft.asc" \
        "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/vscode.gpg] https://packages.microsoft.com/repos/code stable main" \
        "vscode.list"
    
    sudo apt install -y code
    print_success "VS Code installed!"
else
    print_info "VS Code is already installed"
fi