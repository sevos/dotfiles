#!/bin/bash

# Polkit Authentication Agent Setup
# Installs and configures polkit-kde-authentication-agent for Niri

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Polkit Authentication Agent Setup"

# Install and configure polkit authentication agent for Niri
print_status "Configuring polkit authentication agent for Niri..."

# Install polkit-kde-authentication-agent-1
if ! package_installed "polkit-kde-agent-1"; then
    sudo apt install -y polkit-kde-agent-1
    print_success "Installed polkit-kde-authentication-agent-1"
else
    print_info "polkit-kde-authentication-agent-1 already installed"
fi

# Create autostart directory
mkdir -p ~/.config/autostart

# Create autostart entry for polkit agent
cat > ~/.config/autostart/polkit-kde-authentication-agent-1.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=polkit-kde-authentication-agent-1
Comment=PolicyKit Authentication Agent
Exec=/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1
OnlyShowIn=niri;
StartupNotify=false
NoDisplay=true
EOF

print_success "Created polkit authentication agent autostart entry"

# Add polkit agent to Niri startup configuration
if [ -f ~/.config/niri/config.kdl ]; then
    if ! grep -q "polkit-kde-authentication-agent-1" ~/.config/niri/config.kdl; then
        # Find the line with xwayland-satellite and add polkit agent after it
        sed -i '/spawn-at-startup "xwayland-satellite"/a\\n// Start polkit authentication agent for password prompts\nspawn-at-startup "/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1"' ~/.config/niri/config.kdl
        print_success "Added polkit agent to Niri startup configuration"
    else
        print_info "polkit agent already configured in Niri"
    fi
else
    print_warning "Niri config not found, polkit agent added to autostart only"
fi

# Start polkit agent immediately if not running
if ! pgrep -f "polkit-kde-authentication-agent-1" >/dev/null; then
    nohup /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1 >/dev/null 2>&1 &
    print_success "Started polkit authentication agent"
else
    print_info "polkit authentication agent already running"
fi