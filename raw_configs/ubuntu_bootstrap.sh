#!/bin/bash

# Ubuntu Bootstrap System
# Modular Ubuntu development environment setup script
# 
# This script runs a series of specialized bootstrap scripts to set up
# a complete Ubuntu development environment with proper error handling
# and progress tracking.

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="$SCRIPT_DIR/bootstrap.d"

# Source common functions
source "$BOOTSTRAP_DIR/00_common.sh"

# Welcome message
print_header "🚀 Ubuntu Bootstrap System - Installing Development Environment"

# Validate environment
validate_environment

# Parse command line arguments
SELECTED_CATEGORIES=()
RUN_ALL=true
SKIP_CONFIRMATION=false
INTERACTIVE_MODE=true

show_help() {
    echo "Usage: $0 [OPTIONS] [CATEGORIES...]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -y, --yes               Skip confirmation prompts"
    echo "  --list                  List all available categories"
    echo "  --no-interactive        Disable interactive progress display"
    echo ""
    echo "Categories (can specify multiple):"
    echo "  system                  System updates and basic packages (10-19)"
    echo "  development             Development tools and version managers (20-29)"
    echo "  applications            Desktop applications (30-39)"
    echo "  services                System services and agents (40-49)"
    echo "  theming                 Themes and configuration (50-59)"
    echo "  cleanup                 Final cleanup and summary (60-69)"
    echo ""
    echo "Examples:"
    echo "  $0                      # Run all bootstrap scripts with interactive progress"
    echo "  $0 system development   # Run only system and development categories"
    echo "  $0 -y applications      # Run applications category without confirmation"
    echo "  $0 --no-interactive     # Run all scripts without interactive progress"
    echo ""
}

list_categories() {
    echo "Available bootstrap scripts:"
    echo ""
    echo "System (10-19):"
    echo "  10_system_update.sh        - System updates and basic dependencies"
    echo "  11_display_manager.sh      - GDM3 display manager setup"
    echo ""
    echo "Development (20-29):"
    echo "  20_development_tools.sh    - Mise, Ruby, Node installation"
    echo "  21_version_managers.sh     - Additional dev tools (zoxide, bat, fzf)"
    echo ""
    echo "Applications (30-39):"
    echo "  30_vscode.sh              - VS Code installation"
    echo "  31_chrome.sh              - Google Chrome installation"
    echo "  32_1password.sh           - 1Password installation"
    echo "  33_docker.sh              - Docker installation"
    echo "  34_ollama.sh              - Ollama AI installation"
    echo "  35_flatpak_apps.sh        - Flatpak and Slack installation"
    echo "  36_claude_code.sh         - Claude Code installation"
    echo ""
    echo "Services (40-49):"
    echo "  40_polkit_agent.sh        - Polkit authentication agent"
    echo "  41_ssh_agent_config.sh    - SSH agent configuration"
    echo "  42_system_services.sh     - System services (Preload)"
    echo ""
    echo "Theming (50-59):"
    echo "  50_theme_packages.sh      - Font Awesome and theme packages"
    echo "  51_gtk_theming.sh         - GTK dark theme configuration"
    echo "  52_config_symlinks.sh     - Configuration symlinks"
    echo "  53_chrome_theming.sh      - Chrome dark mode configuration"
    echo ""
    echo "Cleanup (60-69):"
    echo "  60_cleanup.sh             - System cleanup and summary"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --list)
            list_categories
            exit 0
            ;;
        -y|--yes)
            SKIP_CONFIRMATION=true
            shift
            ;;
        --no-interactive)
            INTERACTIVE_MODE=false
            shift
            ;;
        system|development|applications|services|theming|cleanup)
            SELECTED_CATEGORIES+=("$1")
            RUN_ALL=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to get scripts for category
get_scripts_for_category() {
    local category="$1"
    case "$category" in
        system)
            echo "10_system_update.sh 11_display_manager.sh"
            ;;
        development)
            echo "20_development_tools.sh 21_version_managers.sh"
            ;;
        applications)
            echo "30_vscode.sh 31_chrome.sh 32_1password.sh 33_docker.sh 34_ollama.sh 35_flatpak_apps.sh 36_claude_code.sh"
            ;;
        services)
            echo "40_polkit_agent.sh 41_ssh_agent_config.sh 42_system_services.sh"
            ;;
        theming)
            echo "50_theme_packages.sh 51_gtk_theming.sh 52_config_symlinks.sh 53_chrome_theming.sh"
            ;;
        cleanup)
            echo "60_cleanup.sh"
            ;;
    esac
}

# Build list of scripts to run
SCRIPTS_TO_RUN=()

if [ "$RUN_ALL" = true ]; then
    # Run all scripts in order
    SCRIPTS_TO_RUN=($(find "$BOOTSTRAP_DIR" -name "[0-9][0-9]_*.sh" | sort))
else
    # Run only selected categories
    for category in "${SELECTED_CATEGORIES[@]}"; do
        scripts=$(get_scripts_for_category "$category")
        for script in $scripts; do
            if [ -f "$BOOTSTRAP_DIR/$script" ]; then
                SCRIPTS_TO_RUN+=("$BOOTSTRAP_DIR/$script")
            else
                print_warning "Script not found: $script"
            fi
        done
    done
fi

# Remove duplicates and sort
SCRIPTS_TO_RUN=($(printf '%s\n' "${SCRIPTS_TO_RUN[@]}" | sort -u))

# Show what will be executed
if [ ${#SCRIPTS_TO_RUN[@]} -eq 0 ]; then
    print_error "No scripts to execute!"
    exit 1
fi

echo ""
print_info "Scripts to be executed:"
for script in "${SCRIPTS_TO_RUN[@]}"; do
    echo "  • $(basename "$script")"
done

# Set total scripts for progress tracking
set_total_scripts ${#SCRIPTS_TO_RUN[@]}

# Confirmation
if [ "$SKIP_CONFIRMATION" = false ]; then
    echo ""
    echo -n "Do you want to continue? [y/N]: "
    read -r response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Bootstrap cancelled."
        exit 0
    fi
fi

echo ""

# Execute scripts
FAILED_SCRIPTS=()
for script in "${SCRIPTS_TO_RUN[@]}"; do
    script_name=$(basename "$script")
    
    if [ -f "$script" ] && [ -x "$script" ]; then
        if [ "$INTERACTIVE_MODE" = true ]; then
            if execute_with_progress "bash '$script'" "Executing $script_name"; then
                print_success "$script_name completed successfully"
            else
                FAILED_SCRIPTS+=("$script_name")
            fi
        else
            # Non-interactive mode - traditional execution
            if bash "$script"; then
                print_success "✅ $script_name completed successfully"
            else
                print_error "❌ $script_name failed"
                FAILED_SCRIPTS+=("$script_name")
            fi
        fi
    else
        print_error "❌ $script_name not found or not executable"
        FAILED_SCRIPTS+=("$script_name")
    fi
    echo ""
done

# Final summary
echo ""
if [ ${#FAILED_SCRIPTS[@]} -eq 0 ]; then
    print_header "🎉 Bootstrap completed successfully!"
    print_success "All ${#SCRIPTS_TO_RUN[@]} scripts executed without errors."
else
    print_header "⚠️  Bootstrap completed with errors"
    print_warning "${#FAILED_SCRIPTS[@]} out of ${#SCRIPTS_TO_RUN[@]} scripts failed:"
    for failed_script in "${FAILED_SCRIPTS[@]}"; do
        echo "  • $failed_script"
    done
    echo ""
    print_info "You can re-run individual categories or scripts to fix issues."
fi

echo ""
print_info "To see available options: $0 --help"
print_info "To list all scripts: $0 --list"