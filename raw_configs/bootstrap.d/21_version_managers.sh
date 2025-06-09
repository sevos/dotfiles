#!/bin/bash

# Additional Development and Utility Tools
# Installs zoxide, bat, fzf and other productivity tools

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Additional Development Tools"

# Install zoxide for directory navigation
print_status "Installing zoxide..."
if ! command_exists "zoxide"; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    print_success "zoxide installed!"
    
    # Add zoxide initialization to bashrc
    if add_to_file_if_missing ~/.bashrc 'eval "$(zoxide init bash)"' 'zoxide init bash'; then
        print_success "Added zoxide initialization to ~/.bashrc"
    else
        print_info "zoxide initialization already in ~/.bashrc"
    fi
else
    print_info "zoxide is already installed"
fi

# Install bat (better cat)
print_status "Installing bat..."
if ! package_installed "bat"; then
    sudo apt install -y bat
    # Ubuntu installs bat as batcat, create alias
    if add_to_file_if_missing ~/.bashrc 'alias cat=batcat' 'alias cat='; then
        print_success "Added cat alias to ~/.bashrc"
    else
        print_info "cat alias already in ~/.bashrc"
    fi
    print_success "bat installed!"
else
    print_info "bat is already installed"
fi

# Install fzf (fuzzy finder)
print_status "Installing fzf..."
if ! package_installed "fzf"; then
    sudo apt install -y fzf
    print_success "fzf installed!"
else
    print_info "fzf is already installed"
fi