#!/bin/bash

# Theme Packages Installation
# Installs Font Awesome and various theme packages

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Theme Packages Installation"

# Install Font Awesome and theme packages
print_status "Installing Font Awesome and dark theme packages..."
install_packages "${THEME_PACKAGES[@]}"
print_success "Theme packages installed!"