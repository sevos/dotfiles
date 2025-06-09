#!/bin/bash

# System Cleanup and Final Steps
# Performs final system cleanup and displays completion summary

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "System Cleanup and Final Steps"

# Final cleanup
print_status "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

# Summary
print_header "🎉 Installation Complete!"

print_success "All software has been installed successfully!"
echo
print_info "📝 Next steps:"
echo "   • Restart your terminal or run: source ~/.bashrc"
echo "   • Log out and back in for Docker permissions"
echo "   • Run 'claude' to set up Claude Code authentication"
echo "   • Run 'mise doctor' to verify Mise setup"
echo "   • Test SSH connection: ssh -T git@github.com"
echo "   • If Claude Code installation failed, restart terminal and run: npm install -g @anthropic-ai/claude-code"
echo "   • Configuration files have been symlinked to ~/.config/"
echo "   • Dark mode is now configured system-wide for GTK apps and legacy X11 applications"
echo "   • Chrome will use dark mode flags from ~/.config/chrome-flags.conf"
echo "   • VS Code will use Tokyo Night theme from symlinked settings"
echo
print_info "🛠️  Installed software:"
echo "   • GDM3 Display Manager (gdm3)"
echo "   • VS Code (code) with dark theme settings"
echo "   • Google Chrome (google-chrome) with dark mode flags"
echo "   • Font Awesome & Dark Theme packages"
echo "   • Mise with Ruby 3 & Node 24"
echo "   • Claude Code (claude)"
echo "   • 1Password (1password) with SSH agent configured"
echo "   • polkit-kde-authentication-agent-1 for Niri"
echo "   • SSH agent conflicts permanently resolved"
echo "   • Preload (system optimization)"
echo "   • Docker (docker)"
echo "   • Ollama (ollama)"
echo "   • Flatpak with Slack"
echo "   • Additional tools: zoxide, bat, fzf"
echo "   • GTK3/4 dark theme configuration"
echo "   • System-wide dark mode environment variables"
echo
echo -e "${GREEN}🚀 Happy coding!${NC}"