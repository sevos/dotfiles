#!/bin/bash

# GTK Dark Theme Configuration
# Sets up GTK3/4 dark themes and system-wide preferences

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "GTK Dark Theme Configuration"

# Configure GTK settings for dark theme
print_status "Configuring GTK dark theme settings..."
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0

# GTK 3 settings
cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Cantarell 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF

# GTK 4 settings
cat > ~/.config/gtk-4.0/settings.ini << 'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Cantarell 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
EOF

print_success "GTK dark theme configured!"

# Set system-wide dark theme preferences using gsettings (if available)
if command_exists "gsettings"; then
    print_status "Configuring system-wide dark theme preferences..."
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false 2>/dev/null || true
    print_success "System-wide dark theme preferences set!"
else
    print_warning "gsettings not available, skipping system-wide theme configuration"
fi