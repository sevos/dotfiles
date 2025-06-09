#!/bin/bash

# Development Tools and Version Managers
# Installs Mise, Ruby, Node, and related build dependencies

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Development Tools and Version Managers"

# Install Ruby build dependencies
print_status "Installing Ruby build dependencies..."
install_packages "${RUBY_BUILD_PACKAGES[@]}"
print_success "Ruby build dependencies installed!"

# Install Mise
print_status "Installing Mise version manager..."
if ! command_exists "mise"; then
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
    print_success "Mise installed!"
else
    print_info "Mise is already installed"
fi

# Install Ruby and Node with Mise
print_status "Installing Ruby 3 and Node 24 with Mise..."
if command_exists "mise" || [ -f "$HOME/.local/bin/mise" ]; then
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check if mise activation is already in bashrc
    if add_to_file_if_missing ~/.bashrc 'eval "$(~/.local/bin/mise activate bash)"' 'mise activate bash'; then
        print_success "Added Mise activation to ~/.bashrc"
    else
        print_info "Mise activation already in ~/.bashrc"
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