#!/bin/bash

# SSH Agent Configuration for 1Password
# Configures 1Password SSH agent and disables conflicting agents

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "SSH Agent Configuration"

# Configure 1Password SSH Agent (disable conflicting agents)
print_status "Configuring 1Password SSH agent..."

# Disable conflicting SSH agents permanently
print_info "Permanently disabling conflicting SSH agents..."

# Disable and mask GCR ssh-agent socket (GNOME Credential Manager)
if systemctl --user list-unit-files | grep -q "gcr-ssh-agent.socket"; then
    systemctl --user stop gcr-ssh-agent.socket 2>/dev/null || true
    systemctl --user disable gcr-ssh-agent.socket 2>/dev/null || true
    systemctl --user mask gcr-ssh-agent.socket 2>/dev/null || true
    print_success "Disabled and masked GCR ssh-agent socket"
else
    print_info "GCR ssh-agent socket not found"
fi

# Disable and mask GPG agent SSH emulation
if systemctl --user list-unit-files | grep -q "gpg-agent-ssh.socket"; then
    systemctl --user stop gpg-agent-ssh.socket 2>/dev/null || true
    systemctl --user disable gpg-agent-ssh.socket 2>/dev/null || true
    systemctl --user mask gpg-agent-ssh.socket 2>/dev/null || true
    print_success "Disabled and masked GPG agent SSH emulation"
else
    print_info "GPG agent SSH emulation not found"
fi

# Mask GNOME keyring SSH service (preventive)
if systemctl --user list-unit-files | grep -q "gnome-keyring-ssh.service"; then
    systemctl --user mask gnome-keyring-ssh.service 2>/dev/null || true
    print_success "Masked GNOME keyring SSH service"
else
    print_info "GNOME keyring SSH service not found"
fi

# Add 1Password SSH agent configuration to bashrc
if add_to_file_if_missing ~/.bashrc 'export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"' 'SSH_AUTH_SOCK.*1password.*agent.sock'; then
    echo "" >> ~/.bashrc
    echo "# 1Password SSH Agent configuration" >> ~/.bashrc
    print_success "Added 1Password SSH agent configuration to ~/.bashrc"
else
    print_info "1Password SSH agent configuration already in ~/.bashrc"
fi

# Add SSH config for 1Password agent
mkdir -p ~/.ssh
if [ ! -f ~/.ssh/config ] || ! grep -q "IdentityAgent" ~/.ssh/config; then
    cat >> ~/.ssh/config << 'EOF'

# 1Password SSH Agent configuration
Host *
	IdentityAgent ~/.1password/agent.sock
EOF
    print_success "Added 1Password SSH agent to SSH config"
else
    print_info "SSH config already contains IdentityAgent setting"
fi

print_success "1Password SSH agent configured!"
print_info "SSH agent conflicts permanently disabled"