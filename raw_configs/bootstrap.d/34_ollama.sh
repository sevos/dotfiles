#!/bin/bash

# Ollama AI Installation
# Sets up Ollama AI platform

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Ollama AI Installation"

# Install CUDA runtime and nvidia-open for Ubuntu 24.04 compatibility
print_status "Installing CUDA runtime and nvidia-open..."
if ! dpkg -l | grep -q libcudart; then
    sudo apt-get update
    sudo apt-get install -y nvidia-cuda-toolkit-gcc nvidia-open
    print_success "CUDA runtime and nvidia-open installed!"
else
    print_info "CUDA runtime is already installed"
fi

# Install Ollama
print_status "Installing Ollama..."
if ! command_exists "ollama"; then
    curl -fsSL https://ollama.com/install.sh | sh
    print_success "Ollama installed!"
else
    print_info "Ollama is already installed"
fi

# Create Ollama systemd service
print_status "Creating Ollama systemd service..."
sudo tee /etc/systemd/system/ollama.service > /dev/null << EOF
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=$USER
Group=users
Restart=always
RestartSec=3
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="OLLAMA_HOST=0.0.0.0"
Environment="CUDA_VISIBLE_DEVICES="
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_LOADED_MODELS=1"

[Install]
WantedBy=default.target
EOF

# Create ollama user if it doesn't exist
if ! id "ollama" &>/dev/null; then
    print_status "Creating ollama user..."
    sudo useradd -r -s /bin/false -m -d /usr/share/ollama ollama
fi

# Add ollama user to GPU access groups
print_status "Adding ollama user to GPU access groups..."
sudo usermod -a -G render,video ollama

# Fix CUDA library permissions
print_status "Fixing CUDA library permissions..."
sudo chmod -R 755 /usr/local/lib/ollama/

# Reload systemd and enable/start service
print_status "Enabling and starting Ollama service..."
sudo systemctl daemon-reload
sudo systemctl stop ollama 2>/dev/null || true
if sudo systemctl enable ollama && sudo systemctl start ollama; then
    print_success "Ollama service enabled and started!"
else
    print_warning "Failed to enable/start Ollama service"
fi