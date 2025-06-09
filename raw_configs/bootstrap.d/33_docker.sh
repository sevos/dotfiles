#!/bin/bash

# Docker Installation and Configuration
# Sets up Docker container platform with user permissions

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Docker Installation"

# Install Docker
print_status "Setting up Docker..."
if ! command_exists "docker"; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    print_success "Docker installed! (Logout/login required for user permissions)"
else
    print_info "Docker is already installed"
    if ! groups $USER | grep -q docker; then
        sudo usermod -aG docker $USER
        print_success "Added user to docker group!"
    else
        print_info "User already in docker group"
    fi
fi