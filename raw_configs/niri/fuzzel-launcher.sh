#!/bin/bash

# Niri App Launcher & Window Switcher
# Usage: ./niri-launcher.sh [mode]

MODE="${1:-auto}"
DEBUG="${DEBUG:-0}"

debug_log() {
    if [ "$DEBUG" = "1" ]; then
        echo "DEBUG: $*" >&2
    fi
}

get_applications() {
    debug_log "Getting applications..."
    
    # Explicitly check all directories
    for dir in /usr/share/applications /usr/local/share/applications "$HOME/.local/share/applications"; do
        if [ -d "$dir" ]; then
            debug_log "Checking directory: $dir"
            find "$dir" -maxdepth 1 -name "*.desktop" -type f 2>/dev/null
        else
            debug_log "Directory does not exist: $dir"
        fi
    done | while IFS= read -r desktop_file; do
        debug_log "Processing: $desktop_file"
        
        name=$(timeout 1 grep "^Name=" "$desktop_file" 2>/dev/null | head -1 | cut -d= -f2-)
        exec=$(timeout 1 grep "^Exec=" "$desktop_file" 2>/dev/null | head -1 | cut -d= -f2- | sed 's/%[fFuUdDnNickvm]//g')
        icon=$(timeout 1 grep "^Icon=" "$desktop_file" 2>/dev/null | head -1 | cut -d= -f2-)
        hidden=$(timeout 1 grep "^Hidden=true" "$desktop_file" 2>/dev/null)
        nodisplay=$(timeout 1 grep "^NoDisplay=true" "$desktop_file" 2>/dev/null)
        
        if [ -z "$hidden" ] && [ -z "$nodisplay" ] && [ -n "$name" ] && [ -n "$exec" ]; then
            # Format: APP:exec_command:display_name:icon_name
            echo "APP:$exec:$name:$icon"
        fi
    done | sort -t: -k3
}

get_applications_simple() {
    debug_log "Using simple application detection..."
    
    # Check all directories for simple method too
    for dir in /usr/share/applications /usr/local/share/applications "$HOME/.local/share/applications"; do
        if [ -d "$dir" ]; then
            ls "$dir"/*.desktop 2>/dev/null
        fi
    done | head -50 | while read -r file; do
        name=$(grep "^Name=" "$file" | head -1 | cut -d= -f2-)
        exec=$(grep "^Exec=" "$file" | head -1 | cut -d= -f2- | awk '{print $1}')
        icon=$(grep "^Icon=" "$file" | head -1 | cut -d= -f2-)
        
        if [ -n "$name" ] && [ -n "$exec" ]; then
            echo "APP:$exec:$name:$icon"
        fi
    done
}

get_windows() {
    debug_log "Getting windows..."
    niri msg windows 2>/dev/null | awk '
        /^Window ID/ { 
            id = $3
            gsub(/:/, "", id)
        }
        /Title:/ { 
            title = $0
            gsub(/.*Title: "/, "", title)
            gsub(/".*/, "", title)
        }
        /App ID:/ {
            app = $3
            gsub(/"/, "", app)
            # Format: WIN:window_id:display_title
            print "WIN:" id ":" title
        }
    '
}

launch_app() {
    local cmd="$1"
    debug_log "Launching: $cmd"
    nohup sh -c "$cmd" >/dev/null 2>&1 &
}

focus_window() {
    local window_id="$1"
    debug_log "Focusing window: $window_id"
    niri msg action focus-window --id "$window_id"
}

format_for_display() {
    local entries="$1"
    echo "$entries" | while IFS=: read -r type data name icon_name; do
        case "$type" in
            APP)
                # For apps: show just the name (fuzzel doesn't support custom icons)
                echo "$name"
                ;;
            WIN)
                # For windows: show just the title
                echo "$name"
                ;;
            *)
                # Pass through separators and other content
                echo "$type:$data:$name:$icon_name"
                ;;
        esac
    done
}

show_menu() {
    local entries="$1"
    debug_log "Showing menu with $(echo "$entries" | wc -l) entries"
    formatted_entries=$(format_for_display "$entries")
    
    # Use fuzzel without icon flags (not supported)
    echo "$formatted_entries" | fuzzel --dmenu
}

main() {
    debug_log "Mode: $MODE"
    
    case "$MODE" in
        apps)
            debug_log "Getting applications only..."
            entries=$(timeout 10 get_applications)
            if [ -z "$entries" ]; then
                debug_log "No entries from complex method, trying simple..."
                entries=$(get_applications_simple)
            fi
            debug_log "Found $(echo "$entries" | wc -l) applications"
            ;;
        windows)
            entries=$(get_windows)
            ;;
        auto)
            window_entries=$(get_windows)
            app_entries=$(timeout 10 get_applications)
            if [ -z "$app_entries" ]; then
                app_entries=$(get_applications_simple)
            fi
            
            entries=$(printf "%s\n--- RUNNING WINDOWS ---\n%s\n--- APPLICATIONS ---\n%s" \
                "" "$window_entries" "$app_entries")
            ;;
        *)
            echo "Usage: $0 [apps|windows|auto]"
            exit 1
            ;;
    esac
    
    if [ -z "$entries" ]; then
        debug_log "No entries found, exiting"
        exit 1
    fi
    
    selection=$(show_menu "$entries")
    
    if [ -z "$selection" ]; then
        debug_log "No selection made"
        exit 0
    fi
    
    if echo "$selection" | grep -q "^---"; then
        exit 0
    fi
    
    # Find original entry by matching the display name
    original_entry=$(echo "$entries" | while IFS=: read -r type data name icon; do
        if [ "$name" = "$selection" ]; then
            echo "$type:$data:$name:$icon"
            break
        fi
    done)
    
    if [ -z "$original_entry" ]; then
        debug_log "Could not find original entry for: $selection"
        exit 1
    fi
    
    entry_type=$(echo "$original_entry" | cut -d: -f1)
    
    case "$entry_type" in
        APP)
            cmd=$(echo "$original_entry" | cut -d: -f2)
            launch_app "$cmd"
            ;;
        WIN)
            window_id=$(echo "$original_entry" | cut -d: -f2)
            focus_window "$window_id"
            ;;
    esac
}

main "$@"