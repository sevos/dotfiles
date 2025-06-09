#!/bin/bash

# Ollama AI Installation
# Sets up Ollama AI platform

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Ollama AI Installation"

# Install Ollama
print_status "Installing Ollama..."
if ! command_exists "ollama"; then
    curl -fsSL https://ollama.com/install.sh | sh
    print_success "Ollama installed!"
else
    print_info "Ollama is already installed"
fi