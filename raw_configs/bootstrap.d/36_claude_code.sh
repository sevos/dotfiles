#!/bin/bash

# Claude Code Installation
# Installs Anthropic's Claude Code CLI tool via npm

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Claude Code Installation"

# Install Claude Code
print_status "Installing Claude Code..."
if ! command_exists "claude"; then
    # Force reload mise environment multiple times to ensure node/npm are available
    export PATH="$HOME/.local/bin:$PATH"
    eval "$($HOME/.local/bin/mise activate bash)" 2>/dev/null || true
    
    # Add mise shims to PATH
    if [ -d "$HOME/.local/share/mise/shims" ]; then
        export PATH="$HOME/.local/share/mise/shims:$PATH"
    fi
    
    # Try to find npm after mise activation
    if command_exists "npm" || [ -f "$HOME/.local/share/mise/shims/npm" ]; then
        # Use the npm that mise provides
        NPM_CMD="npm"
        if [ -f "$HOME/.local/share/mise/shims/npm" ]; then
            NPM_CMD="$HOME/.local/share/mise/shims/npm"
        fi
        
        $NPM_CMD install -g @anthropic-ai/claude-code
        print_success "Claude Code installed!"
    else
        print_warning "npm not available yet. Installing with alternative method..."
        # Try installing through mise's node directly
        if [ -f "$HOME/.local/share/mise/shims/node" ]; then
            $HOME/.local/share/mise/shims/node --version > /dev/null 2>&1 && \
            $HOME/.local/share/mise/shims/npx --yes @anthropic-ai/claude-code@latest --version > /dev/null 2>&1 || \
            print_error "Claude Code installation failed. Run after terminal restart: npm install -g @anthropic-ai/claude-code"
        else
            print_error "Node/npm not ready. Run after terminal restart: npm install -g @anthropic-ai/claude-code"
        fi
    fi
else
    print_info "Claude Code is already installed"
fi