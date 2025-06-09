#!/bin/bash

# Ollama AI Installation
# Sets up Ollama AI platform

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Ollama AI Installation"

# # Check for NVIDIA GPU
# NVIDIA_PRESENT=false
# if lspci | grep -i nvidia > /dev/null 2>&1; then
#     NVIDIA_PRESENT=true
#     print_info "NVIDIA GPU detected - configuring CUDA support"
# else
#     print_info "No NVIDIA GPU detected - installing CPU-only version"
# fi

# # Install NVIDIA drivers and CUDA toolkit if NVIDIA GPU is present
# if [ "$NVIDIA_PRESENT" = true ]; then
#     print_status "Installing NVIDIA drivers and CUDA toolkit..."
    
#     # Clean previous installations
#     print_status "Cleaning previous NVIDIA installations..."
#     sudo apt-get remove --purge 'libnvidia-*' -y 2>/dev/null || true
#     sudo apt-get remove --purge 'nvidia-*' -y 2>/dev/null || true
#     sudo apt-get remove --purge 'cuda-*' -y 2>/dev/null || true
#     sudo apt-get remove --purge 'tuxedo-nvidia-*' -y 2>/dev/null || true
#     sudo apt-get remove --purge 'xserver-xorg-video-nvidia-*' -y 2>/dev/null || true
#     sudo apt clean
#     sudo apt autoremove -y
    
#     # Add graphics drivers PPA and install NVIDIA driver
#     print_status "Installing NVIDIA driver..."
#     sudo add-apt-repository ppa:graphics-drivers/ppa --yes
#     sudo apt-get update
#     update-pciids 2>/dev/null || true
#     sudo apt-get install nvidia-driver-570 -y
#     sudo apt-get reinstall linux-headers-$(uname -r) -y
#     sudo update-initramfs -u
    
#     # Install CUDA toolkit
#     print_status "Installing CUDA toolkit..."
#     if [ ! -f "/tmp/cuda-keyring_1.1-1_all.deb" ]; then
#         wget -O /tmp/cuda-keyring_1.1-1_all.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
#     fi
#     sudo dpkg -i /tmp/cuda-keyring_1.1-1_all.deb
#     sudo apt-get update
#     sudo apt-get install cuda-toolkit -y
#     sudo apt-get install nvidia-gds -y
    
#     # Set reboot flag for main bootstrap scriptcurl -fsSL https://ollama.com/install.sh | sh
    
#     print_success "NVIDIA drivers and CUDA toolkit installed! Reboot will be required."
# else
#     print_info "Skipping NVIDIA driver installation - no GPU detected"
# fi

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
Environment="OLLAMA_HOST=0.0.0.0:11434"
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