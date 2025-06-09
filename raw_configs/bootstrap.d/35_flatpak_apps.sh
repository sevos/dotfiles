#!/bin/bash

# Flatpak and Applications Installation
# Sets up Flatpak and installs Slack with Wayland support

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Flatpak and Applications"

# Install Flatpak
print_status "Installing Flatpak..."
if ! command_exists "flatpak"; then
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    print_success "Flatpak installed!"
else
    print_info "Flatpak is already installed"
fi

# Install Slack via Flatpak
print_status "Installing Slack via Flatpak..."
if ! flatpak list | grep -q "com.slack.Slack"; then
    flatpak install flathub com.slack.Slack -y
    print_success "Slack installed via Flatpak!"
else
    print_info "Slack is already installed"
fi

# Configure Flatpak permissions for Wayland apps
print_status "Configuring Flatpak Wayland permissions..."
if flatpak list | grep -q "com.slack.Slack"; then
    # Grant Wayland socket access to Slack for proper Wayland integration
    flatpak override --user --socket=wayland com.slack.Slack
    print_success "Slack Wayland permissions configured!"
else
    print_warning "Slack not installed, skipping Wayland permission configuration"
fi