#!/bin/bash

# Chrome Desktop File and Dark Mode Configuration
# Creates Chrome desktop file override with dark mode flags

# Source common functions
source "$(dirname "$0")/00_common.sh"

next_script "Chrome Dark Mode Configuration"

# Create Chrome desktop file override with dark mode flags
print_status "Creating Chrome desktop file override with dark mode flags..."
mkdir -p ~/.local/share/applications

if [ -f "$SCRIPT_DIR/chrome-flags.conf" ]; then
    # Read Chrome flags from file and convert to command line args
    CHROME_FLAGS=$(grep -v '^#' "$SCRIPT_DIR/chrome-flags.conf" | grep -v '^$' | tr '\n' ' ')
    
    cat > ~/.local/share/applications/google-chrome.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Google Chrome
GenericName=Web Browser
Comment=Access the Internet
Exec=/usr/bin/google-chrome-stable ${CHROME_FLAGS} %U
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
Actions=new-window;new-private-window;

[Desktop Action new-window]
Name=New Window
Exec=/usr/bin/google-chrome-stable ${CHROME_FLAGS}

[Desktop Action new-private-window]
Name=New Incognito Window
Exec=/usr/bin/google-chrome-stable --incognito ${CHROME_FLAGS}
EOF

    print_success "Chrome desktop file override created with dark mode flags!"
else
    print_warning "chrome-flags.conf not found, skipping Chrome desktop file override"
fi