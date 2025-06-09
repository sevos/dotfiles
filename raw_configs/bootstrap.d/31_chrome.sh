#!/bin/bash

# Google Chrome Installation
# Sets up Google Chrome browser with repository

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Google Chrome Installation"

# Check and install Google Chrome
print_status "Setting up Google Chrome..."
if ! command_exists "google-chrome"; then
    # Special handling for Google Chrome repository (uses apt-key)
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable
    print_success "Google Chrome installed!"
else
    print_info "Google Chrome is already installed"
fi