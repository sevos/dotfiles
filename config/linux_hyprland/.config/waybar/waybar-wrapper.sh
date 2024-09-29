#!/bin/bash

# Path to Waybar config and style.css
CONFIG="$HOME/.config/waybar/config"
STYLE="$HOME/.config/waybar/style.css"

# Function to kill and restart Waybar
restart_waybar() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Config or style.css modified. Restarting Waybar..."
  pkill -x waybar
  waybar &
}

# Check if files exist
if [[ ! -f "$CONFIG" ]]; then
  echo "Config file not found: $CONFIG"
  exit 1
fi

if [[ ! -f "$STYLE" ]]; then
  echo "Style file not found: $STYLE"
  exit 1
fi

# Initial start of Waybar
echo "Starting Waybar..."
waybar &

# Watch for modify events using inotifywait
echo "Watching for modify events in $CONFIG and $STYLE..."

# Function to monitor file changes in a separate process
monitor_files() {
  while true; do
    # Listen only for 'modify' events
    inotifywait -e delete_self -e modify "$1"
    status=$?

    # If modify event occurred (exit code 0), restart Waybar
    if [[ $status -eq 0 ]]; then
      restart_waybar
    # If exit status is 1, continue monitoring (ignore non-error events)
    elif [[ $status -eq 1 ]]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Ignoring non-error event for $1"
    else
      echo "$(date '+%Y-%m-%d %H:%M:%S') - inotifywait encountered an unexpected error with $1 (exit code: $status)."
      exit 1
    fi
  done
}

# Start two processes to watch both files
monitor_files "$CONFIG" &
monitor_files "$STYLE" &

# Wait for background processes to finish
wait

pkill waybar
