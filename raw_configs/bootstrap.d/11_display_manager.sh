#!/bin/bash

# GDM3 Display Manager Installation and Configuration
# Installs and configures GNOME Display Manager

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "GDM3 Display Manager Setup"

# Install and configure GDM (GNOME Display Manager)
print_status "Installing and configuring GDM..."
if ! package_installed "gdm3"; then
    sudo apt install -y gdm3
    print_success "GDM3 installed!"
else
    print_info "GDM3 is already installed"
fi

# Enable and start GDM
enable_service "gdm3"
start_service "gdm3"