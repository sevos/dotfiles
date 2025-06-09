#!/bin/bash

# System Services Configuration
# Installs and configures system optimization services like Preload

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "System Services Configuration"

# Install Preload
print_status "Installing and configuring Preload..."
if ! package_installed "preload"; then
    sudo apt install -y preload
    enable_service "preload"
    start_service "preload"
    print_success "Preload installed and started!"
else
    print_info "Preload is already installed"
    enable_service "preload"
    start_service "preload"
fi