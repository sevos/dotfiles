#!/bin/bash
# wallpaper_watcher.sh: Watches for changes in nitrogen config and restarts wallpaper.sh

CONFIG_FILE="$HOME/.config/nitrogen/bg-saved.cfg"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SCRIPT_PATH="$SCRIPT_DIR/wallpaper.sh"

# Immediately reset the wallpaper at start
"$SCRIPT_PATH"

# Start watchman if not running
type watchman >/dev/null 2>&1 || { echo "watchman is not installed."; exit 1; }

# Set up a watchman trigger
echo "Setting up watchman trigger for $CONFIG_FILE..."

watchman watch "$(dirname "$CONFIG_FILE")"

watchman -- trigger "$(dirname "$CONFIG_FILE")" wallpaper-reload "$(basename "$CONFIG_FILE")" -- \
    "$SCRIPT_PATH"

# Keep the script running to maintain the trigger
echo "Wallpaper watcher is running. Press Ctrl+C to stop."
while true; do sleep 3600; done
