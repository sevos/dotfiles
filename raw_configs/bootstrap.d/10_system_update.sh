#!/bin/bash

# System Update and Basic Dependencies
# Handles system updates and installs fundamental packages

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "System Update and Basic Dependencies"

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System updated!"

# Install basic dependencies
print_status "Installing basic dependencies..."
install_packages "${BASIC_PACKAGES[@]}"
print_success "Basic dependencies installed!"