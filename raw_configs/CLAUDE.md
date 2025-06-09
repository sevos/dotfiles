# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository containing configuration files and setup scripts for a Linux development environment. The repository focuses on:

- Terminal and shell configuration (Alacritty and Bash)
- Window manager configuration (Niri - a modern Wayland compositor)
- System setup automation for Ubuntu systems

## System Setup

Run the Ubuntu bootstrap script to set up a complete development environment:
```bash
./ubuntu_bootstrap.sh
```

### Bootstrap System Architecture

The bootstrap system is a **modular, categorized installation framework** using numbered scripts (00-69) to control execution order:

**System Foundation (10-19):**
- System updates and basic dependencies
- GDM3 display manager configuration

**Development Tools (20-29):**
- Mise version manager with Ruby 3 and Node 24
- Development utilities (zoxide, bat, fzf)

**Applications (30-39):**
- VS Code, Chrome, 1Password, Docker, Ollama
- Flatpak with Slack (Wayland-optimized)
- Claude Code CLI tool

**System Services (40-49):**
- Polkit authentication agent for Niri
- 1Password SSH agent with conflict resolution
- System optimization (preload)

**Theming & Configuration (50-59):**
- Dark mode themes and icons
- Configuration directory symlinks
- Chrome dark mode integration

**Cleanup (60-69):**
- System cleanup and installation summary

### Installation Options

```bash
# Full installation with interactive progress
./ubuntu_bootstrap.sh

# Category-specific installation
./ubuntu_bootstrap.sh development applications

# Non-interactive mode
./ubuntu_bootstrap.sh --no-interactive
```

The system automatically symlinks all configuration directories (`alacritty/`, `niri/`, `waybar/`) and files (`bashrc`, `chrome-flags.conf`, `vscode-settings.json`) to appropriate system locations.

## Configuration Structure

### Alacritty Terminal
- Main config: `alacritty/alacritty.toml`
- Theme: Uses Tokyo Night theme from `alacritty/themes/tokyo_night.toml`
- Font: CaskaydiaCove Nerd Font Mono at 18pt
- Key bindings: Ctrl+Shift+N for new window

### Niri Window Manager
- Main config: `niri/config.kdl` 
- Uses KDL format configuration
- Key features:
  - Column-based tiling layout with gaps (24px)
  - Focus follows mouse with 0% scroll tolerance
  - Window shadows and rounded corners (16px radius)
  - VS Code gets 75% column width by default
  - 4K display support (DP-2 at 3840x2160@144Hz, scale 2)

### Niri Helper Scripts
- `niri/fuzzel-launcher.sh`: App launcher and window switcher using fuzzel
- `niri/wallpaper.sh`: Wallpaper management using swaybg
- `niri/wallpaper_watcher.sh`: Automatically updates wallpaper when nitrogen config changes

### Waybar System Bar
- Config: `waybar/config` and `waybar/style.css`
- Tokyo Night-themed system bar with bluetooth, audio, clock, tray modules
- Positioned at top with 32px height, CaskaydiaCove Nerd Font Mono

## Key Bindings (Niri)

Essential shortcuts defined in `niri/config.kdl`:
- `Super+Return`: Terminal (alacritty)
- `Super+Space`: App launcher (fuzzel)
- `Super+Shift+Space`: Window switcher
- `Super+Shift+C`: Claude Desktop
- `Super+B`: Google Chrome
- `Super+Q`: Close window
- `Super+O`: Overview mode
- `Super+Shift+S`: Screenshot

## Development Environment

The bootstrap system configures a comprehensive development environment:

### Runtime Management
- **Mise** for version management (Ruby 3, Node 24)
- **Docker** with proper user permissions and group setup
- **Ollama** AI platform with systemd service for boot startup

### Development Tools
- **VS Code** with Microsoft repository and Tokyo Night theme
- **Claude Code** CLI tool via npm
- **Chrome/Chromium** with Wayland optimization and dark mode
- **1Password** for secure credential management

### System Utilities
- **zoxide** for smart directory navigation
- **bat** as enhanced cat with syntax highlighting  
- **fzf** for fuzzy finding
- **Font Awesome** and various GTK themes

### Dark Mode System
The environment implements comprehensive dark mode support:
- **GTK3/4** themes via gsettings
- **Chrome flags** for WebUI dark mode (`chrome-flags.conf`)
- **VS Code** Tokyo Night theme configuration
- **System-wide environment variables** for Electron, Qt, Java applications

When working with this repository, you'll primarily be editing configuration files in TOML and KDL formats, along with shell scripts for the bootstrap system.

## 1Password SSH Agent Configuration

This environment uses 1Password's SSH agent for secure SSH key management. Key configuration notes:

### Niri Compatibility
1Password's authorization dialog system has compatibility issues with the Niri Wayland compositor. To resolve this:

1. **Disable authorization prompts** in 1Password settings:
   - Settings → Developer → SSH Agent → Disable per-request authorization
   - Or manually set: `"sshAgent.authPromptsV2.enabled": false` in `~/.config/1Password/settings/settings.json`

2. **Ensure proper SSH agent configuration**:
   ```bash
   export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
   ```

3. **SSH client configuration** in `~/.ssh/config`:
   ```
   Host *
       IdentityAgent ~/.1password/agent.sock
   ```

### SSH Agent Conflict Resolution
The bootstrap system automatically resolves SSH agent conflicts by:
- **Permanently disabling** GCR ssh-agent socket (GNOME Credential Manager)
- **Masking** GPG agent SSH emulation
- **Disabling** GNOME keyring SSH service
- **Configuring** proper 1Password SSH agent integration

### Troubleshooting
- If SSH authentication hangs at "sign_and_send_pubkey", check 1Password authorization settings
- Use `~/agent-debug.sh` for comprehensive SSH agent diagnostics
- Ensure polkit-kde-authentication-agent-1 is running for system authentication (configured automatically by bootstrap)

### Security Notes
- Authorization bypass maintains security through 1Password's account-level authentication
- SSH agent requires 1Password GUI to be running and unlocked
- Native 1Password installation required (not Flatpak/Snap)

## Key Configuration Files

### Chrome Optimization (`chrome-flags.conf`)
```
--enable-features=WebUIDarkMode
--force-dark-mode  
--enable-features=VaapiVideoDecoder
--use-gl=egl
--ozone-platform=wayland
--gtk-version=4
```

### Environment Variables (`environment`)
- Comprehensive dark mode support for GTK, Qt, Electron, Java applications
- Wayland-first configuration with proper backend selection
- 1Password SSH agent integration
- Application-specific optimizations

### VS Code Settings (`vscode-settings.json`)
- Tokyo Night theme with custom title bar colors
- CaskaydiaCove Nerd Font Mono at 16px
- Material icon theme with semantic highlighting

## Memories

- The bootstrap system uses a scalable symlink approach for all configuration directories and files
- Ollama requires manual systemd service creation as it doesn't provide one by default
- 1Password SSH agent works with Niri but requires authorization prompt bypass configuration due to dialog compatibility issues
- All applications are configured for Wayland-first operation with dark mode support