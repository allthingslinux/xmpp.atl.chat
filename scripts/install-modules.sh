#!/bin/bash

# Automated Community Modules Installer for Prosody XMPP Server
# Usage: ./install-modules.sh [module1] [module2] ...
# Example: ./install-modules.sh mod_cloud_notify mod_muc_notifications
#
# This script implements a hybrid approach:
# 1. First tries prosodyctl install (like our original approach)
# 2. Falls back to downloading prosody-modules repo (like SaraSmiseth's approach)
# 3. Automatically enables modules in configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default modules to install if none specified
DEFAULT_MODULES=(
    "mod_cloud_notify"
    "mod_cloud_notify_extensions"
    "mod_muc_notifications"
    "mod_muc_offline_delivery"
    "mod_vcard_muc"
    "mod_http_status"
    "mod_compliance_latest"
    "mod_s2s_status"
    "mod_log_slow_events"
    "mod_pastebin"
    "mod_reload_modules"
    "mod_pubsub_subscription"
)

# Configuration
MAX_RETRIES=3
RETRY_DELAY=5
MODULES_SERVER="https://modules.prosody.im/rocks/"
PROSODY_MODULES_SRC="/tmp/prosody-modules"
PROSODY_MODULES_DEST="/usr/local/lib/prosody/community-modules"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to install a single module with retry logic and fallback
install_module() {
    local module="$1"
    local mod_name="${module#mod_}" # Remove 'mod_' prefix
    local attempt=1

    # First try: prosodyctl install (our original approach)
    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "Installing $module via prosodyctl (attempt $attempt/$MAX_RETRIES)..."

        if prosodyctl install --server="$MODULES_SERVER" "$module"; then
            log_success "Successfully installed $module via prosodyctl"
            return 0
        else
            log_warning "Failed to install $module via prosodyctl (attempt $attempt/$MAX_RETRIES)"

            if [ $attempt -lt $MAX_RETRIES ]; then
                log_info "Retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            fi
        fi

        ((attempt++))
    done

    # Second try: Fallback to downloading prosody-modules repo (SaraSmiseth's approach)
    log_info "prosodyctl failed, trying fallback method with prosody-modules repo..."

    # Download prosody-modules repo if not already downloaded
    if [[ ! -d "$PROSODY_MODULES_SRC" ]]; then
        log_info "Downloading prosody-modules repository..."
        mkdir -p "$PROSODY_MODULES_SRC"
        local tmp_tar="/tmp/prosody-modules.tar.gz"

        if curl -fsSL --retry 5 --retry-delay 5 -o "$tmp_tar" "https://hg.prosody.im/prosody-modules/archive/tip.tar.gz"; then
            tar -xzf "$tmp_tar" -C "$PROSODY_MODULES_SRC" --strip-components=1
            rm -f "$tmp_tar"
            log_success "Downloaded prosody-modules repository"
        else
            log_error "Failed to download prosody-modules repository"
            return 1
        fi
    fi

    # Copy the module from the downloaded repo
    local srcdir="$PROSODY_MODULES_SRC/mod_$mod_name"
    if [[ -d "$srcdir" ]]; then
        log_info "Copying mod_$mod_name from prosody-modules source tree..."
        mkdir -p "$PROSODY_MODULES_DEST"
        rsync -a --exclude='lib/luarocks' "$srcdir" "$PROSODY_MODULES_DEST/"
        log_success "Successfully installed $module via fallback method"
        return 0
    else
        log_error "Module mod_$mod_name not found in prosody-modules repository"
        return 1
    fi
}

# Function to check if module is already installed
is_module_installed() {
    local module="$1"
    local module_name="${module#mod_}" # Remove 'mod_' prefix

    # Check if module file exists in community modules directory
    if [ -f "/usr/local/lib/prosody/community-modules/$module.lua" ]; then
        return 0
    fi

    # Check if module is available via luarocks
    if luarocks list | grep -q "^$module_name"; then
        return 0
    fi

    return 1
}

# Function to enable module in Prosody configuration
enable_module_in_config() {
    local module="$1"
    local mod_name="${module#mod_}" # Remove 'mod_' prefix
    local config_file="/etc/prosody/conf.d/01-modules.cfg.lua"

    # Skip certain modules that shouldn't be auto-enabled (like SaraSmiseth does)
    if [[ "$mod_name" == "http_upload" ]] || [[ "$mod_name" == "vcard_muc" ]]; then
        log_info "Skipping auto-enabling $module (as per SaraSmiseth's logic)"
        return 0
    fi

    if [[ -f "$config_file" ]]; then
        log_info "Enabling $module in Prosody configuration..."

        # Use Perl to add module to modules_enabled array (SaraSmiseth's approach)
        local new_config
        new_config=$(perl -0pe 's/(modules_enabled[ ]*=[ ]*{[^}]*)};/$1\n\t"'$mod_name'";\n};/' "$config_file")

        if [[ $? -eq 0 ]] && [[ "$new_config" != "$(cat "$config_file")" ]]; then
            echo "$new_config" > "$config_file"
            log_success "Enabled $module in configuration"
        else
            log_warning "Could not enable $module in configuration (already enabled or config not found)"
        fi
    else
        log_warning "Prosody config file not found at $config_file, skipping auto-enable"
    fi
}

# Main installation function
install_modules() {
    local modules_to_install=("$@")
    local installed_count=0
    local failed_count=0
    local skipped_count=0

    log_info "Starting installation of ${#modules_to_install[@]} community modules..."
    echo "Modules to install: ${modules_to_install[*]}"
    echo

    for module in "${modules_to_install[@]}"; do
        if is_module_installed "$module"; then
            log_warning "Module $module is already installed, skipping"
            ((skipped_count++))
            continue
        fi

        if install_module "$module"; then
            ((installed_count++))
            # Enable the module in configuration after successful installation
            enable_module_in_config "$module"
        else
            ((failed_count++))
        fi

        # Small delay between installations to be respectful
        sleep 1
    done

    echo
    log_info "Installation Summary:"
    echo "  - Successfully installed: $installed_count"
    echo "  - Failed: $failed_count"
    echo "  - Skipped (already installed): $skipped_count"
    echo "  - Total modules processed: $((installed_count + failed_count + skipped_count))"

    if [ $installed_count -gt 0 ]; then
        log_success "Community modules installation completed!"
        echo
        log_info "Next steps:"
        echo "  1. Restart Prosody to load the new modules:"
        echo "     prosodyctl restart"
        echo "  2. Or reload configuration without restart:"
        echo "     prosodyctl reload"
        echo "  3. Check Prosody logs for any issues:"
        echo "     tail -f /var/log/prosody/prosody.log"
        echo "  4. Verify modules are loaded:"
        echo "     prosodyctl shell"
        echo "     > module:load('your_module_name')"
    fi

    if [ $failed_count -gt 0 ]; then
        log_warning "Some modules failed to install. You can retry later with:"
        echo "  ./install-modules.sh [failed_module_names]"
    fi

    return $failed_count
}

# Function to show usage information
show_usage() {
    cat << EOF
Automated Community Modules Installer for Prosody XMPP Server

USAGE:
    $0 [module1] [module2] ... [moduleN]    Install specific modules
    $0 --default                           Install default recommended modules
    $0 --list                              List available community modules
    $0 --help                              Show this help message

EXAMPLES:
    # Install specific modules
    $0 mod_cloud_notify mod_muc_notifications

    # Install default recommended modules
    $0 --default

    # Install modules for iOS push notifications
    $0 mod_cloud_notify mod_cloud_notify_extensions

    # Install MUC (group chat) enhancements
    $0 mod_muc_notifications mod_muc_offline_delivery mod_vcard_muc

DEFAULT MODULES INSTALLED WITH --default:
$(printf '  - %s\n' "${DEFAULT_MODULES[@]}")

NOTES:
- This script includes retry logic to handle rate limiting
- Modules are installed from: $MODULES_SERVER
- Installation may take several minutes depending on network conditions
- Restart Prosody after installation to load new modules

EOF
}

# Function to list available community modules
list_available_modules() {
    log_info "Fetching available community modules..."
    echo
    echo "Popular community modules:"
    echo "  Core Features:"
    echo "    - mod_cloud_notify (Push notifications)"
    echo "    - mod_cloud_notify_extensions (iOS push)"
    echo "    - mod_muc_notifications (Group chat notifications)"
    echo "    - mod_muc_offline_delivery (Offline group messages)"
    echo
    echo "  Security & Anti-Spam:"
    echo "    - mod_anti_spam"
    echo "    - mod_admin_blocklist"
    echo "    - mod_spam_reporting"
    echo
    echo "  Monitoring & Debugging:"
    echo "    - mod_http_status"
    echo "    - mod_log_slow_events"
    echo "    - mod_reload_modules"
    echo
    echo "  Group Chat (MUC) Enhancements:"
    echo "    - mod_vcard_muc (Group avatars)"
    echo "    - mod_pastebin (Long message handling)"
    echo "    - mod_compliance_latest (XEP compliance)"
    echo
    echo "For the complete list, visit: https://modules.prosody.im/"
}

# Main script logic
main() {
    local modules=()

    # Parse command line arguments
    case "${1:-}" in
        --help | -h)
            show_usage
            exit 0
            ;;
        --default)
            modules=("${DEFAULT_MODULES[@]}")
            ;;
        --list)
            list_available_modules
            exit 0
            ;;
        "")
            # No arguments provided
            log_info "No modules specified. Use --default to install recommended modules."
            echo
            show_usage
            exit 1
            ;;
        *)
            # Specific modules provided
            modules=("$@")
            ;;
    esac

    # Check if running as root (required for prosodyctl)
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (or with sudo) to install modules"
        exit 1
    fi

    # Check if prosodyctl is available
    if ! command -v prosodyctl &> /dev/null; then
        log_error "prosodyctl not found. Make sure you're running this inside the Prosody container."
        exit 1
    fi

    log_info "Community Modules Installer for Prosody"
    echo "=========================================="
    echo "Installing ${#modules[@]} module(s)..."
    echo

    # Install the modules
    install_modules "${modules[@]}"

    exit $?
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
