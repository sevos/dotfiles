#!/bin/bash

# Configuration Symlinks Setup
# Creates symlinks for all configuration directories and files

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Configuration Symlinks Setup"

# Setup configuration symlinks
print_status "Setting up configuration symlinks..."
mkdir -p ~/.config

# Symlink all configuration directories
for config_dir in "${CONFIG_DIRS[@]}"; do
    symlink_config "$config_dir"
done

# Symlink individual configuration files
for config_file in "${CONFIG_FILES[@]}"; do
    symlink_config_file "$config_file"
done

# Symlink environment file for dark mode
print_status "Setting up environment configuration..."
ENVIRONMENT_SOURCE="$SCRIPT_DIR/environment"
ENVIRONMENT_TARGET="$HOME/.config/environment"

if [ -f "$ENVIRONMENT_SOURCE" ]; then
    if [ -L "$ENVIRONMENT_TARGET" ]; then
        rm "$ENVIRONMENT_TARGET"
    elif [ -f "$ENVIRONMENT_TARGET" ]; then
        create_backup "$ENVIRONMENT_TARGET"
    fi
    ln -sf "$ENVIRONMENT_SOURCE" "$ENVIRONMENT_TARGET"
    print_success "Symlinked environment config"
    
    # Add environment sourcing to bashrc if not already present
    if add_to_file_if_missing ~/.bashrc "source ~/.config/environment" "source.*/.config/environment"; then
        echo "# Source dark mode environment variables" >> ~/.bashrc
        print_success "Added environment sourcing to ~/.bashrc"
    else
        print_info "Environment sourcing already in ~/.bashrc"
    fi
else
    print_warning "Environment config file not found in $SCRIPT_DIR"
fi

print_success "Configuration symlinks completed!"