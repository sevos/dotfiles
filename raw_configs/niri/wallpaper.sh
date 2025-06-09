#!/bin/bash

# Function to set wallpaper using swaybg
set_wallpaper() {
    # Kill existing swaybg
    pkill swaybg

    # Read wallpaper from nitrogen config
    local WALLPAPER=$(grep "file=" ~/.config/nitrogen/bg-saved.cfg 2>/dev/null | head -1 | cut -d'=' -f2)

    # Fallback if no nitrogen config
    if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
        WALLPAPER="$HOME/Pictures/wallpaper.png"
    fi

    # Start swaybg
    swaybg -i "$WALLPAPER" &
}

# Execute the function
set_wallpaper