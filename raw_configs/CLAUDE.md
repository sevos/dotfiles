# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository containing configuration files and setup scripts for a Linux development environment. The repository focuses on:

- Terminal and shell configuration (Alacritty and Bash)
- Window manager configuration (Niri - a modern Wayland compositor)
- System setup automation for Ubuntu systems

## System Setup

Run the Ubuntu installation script to set up a complete development environment:
```bash
./ubuntu_install_script.sh
```

This script installs essential development tools including VS Code, Chrome, Docker, Ollama, Claude Code, Node.js, Ruby, and various system utilities. It also automatically symlinks the `alacritty/` and `niri/` configuration directories to `~/.config/`.

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

The setup script configures:
- Mise for runtime version management (Ruby 3, Node 24)
- Docker with user permissions
- VS Code with Microsoft repository
- Font Awesome for icon support
- Claude Code CLI tool

When working with this repository, you'll primarily be editing configuration files in TOML and KDL formats.

## Memories

- I always want configuration directories to be symlinked. Let's make sure that the solution in the setup script is scalable for this