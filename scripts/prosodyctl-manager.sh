#!/bin/bash
set -euo pipefail

# ============================================================================
# PROSODYCTL MANAGEMENT SCRIPT
# ============================================================================
# Comprehensive wrapper for prosodyctl commands with enhanced functionality
# Based on: https://prosody.im/doc/prosodyctl

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly CONFIG_DIR="$PROJECT_DIR/config"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Default configuration
readonly DEFAULT_CONFIG="/etc/prosody/prosody.cfg.lua"
readonly PROSODY_USER="${PROSODY_USER:-prosody}"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "\n${BOLD}${CYAN}=== $1 ===${NC}"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if prosodyctl is available
check_prosodyctl() {
    if ! command -v prosodyctl >/dev/null 2>&1; then
        log_error "prosodyctl not found - ensure Prosody is installed"
        exit 1
    fi
}

# Get prosodyctl command with proper config
get_prosodyctl_cmd() {
    local config_arg=""
    if [[ -n "${PROSODY_CONFIG:-}" ]]; then
        config_arg="--config $PROSODY_CONFIG"
    fi
    echo "prosodyctl $config_arg"
}

# Execute prosodyctl command with proper error handling
exec_prosodyctl() {
    local cmd="$1"
    local description="$2"
    local prosodyctl_cmd
    prosodyctl_cmd=$(get_prosodyctl_cmd)

    log_info "$description"
    if $prosodyctl_cmd $cmd; then
        log_success "$description completed successfully"
        return 0
    else
        log_error "$description failed"
        return 1
    fi
}

# ============================================================================
# USER MANAGEMENT FUNCTIONS
# ============================================================================

# Add a new user
add_user() {
    local jid="$1"
    if [[ -z "$jid" ]]; then
        log_error "JID is required for user creation"
        echo "Usage: $0 adduser user@domain.com"
        return 1
    fi

    exec_prosodyctl "adduser $jid" "Adding user $jid"
}

# Change user password
change_password() {
    local jid="$1"
    if [[ -z "$jid" ]]; then
        log_error "JID is required for password change"
        echo "Usage: $0 passwd user@domain.com"
        return 1
    fi

    exec_prosodyctl "passwd $jid" "Changing password for user $jid"
}

# Delete user
delete_user() {
    local jid="$1"
    if [[ -z "$jid" ]]; then
        log_error "JID is required for user deletion"
        echo "Usage: $0 deluser user@domain.com"
        return 1
    fi

    log_warn "This will permanently delete user $jid"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        exec_prosodyctl "deluser $jid" "Deleting user $jid"
    else
        log_info "User deletion cancelled"
    fi
}

# ============================================================================
# PROCESS MANAGEMENT FUNCTIONS
# ============================================================================

# Check Prosody status
check_status() {
    log_header "Prosody Status Check"
    exec_prosodyctl "status" "Checking Prosody status"
}

# Reload Prosody configuration
reload_config() {
    log_header "Reloading Configuration"
    exec_prosodyctl "reload" "Reloading Prosody configuration and reopening log files"
}

# ============================================================================
# COMPREHENSIVE CHECK FUNCTIONS
# ============================================================================

# Run all available checks
run_comprehensive_check() {
    log_header "Comprehensive Prosody Health Check"

    local failed_checks=0
    local prosodyctl_cmd
    prosodyctl_cmd=$(get_prosodyctl_cmd)

    # Configuration check
    log_info "Checking configuration..."
    if $prosodyctl_cmd check config; then
        log_success "Configuration check passed"
    else
        log_error "Configuration check failed"
        ((failed_checks++))
    fi

    # Features check
    log_info "Checking features..."
    if $prosodyctl_cmd check features; then
        log_success "Features check passed"
    else
        log_warn "Some features may be missing or unconfigured"
    fi

    # DNS check
    if [[ -n "${PROSODY_DOMAIN:-}" ]]; then
        log_info "Checking DNS records for $PROSODY_DOMAIN..."
        if $prosodyctl_cmd check dns; then
            log_success "DNS check passed"
        else
            log_warn "DNS configuration issues detected"
        fi
    fi

    # Certificate check
    log_info "Checking certificates..."
    if $prosodyctl_cmd check certs; then
        log_success "Certificate check passed"
    else
        log_warn "Certificate issues detected"
    fi

    # Connectivity check (if domain is configured)
    if [[ -n "${PROSODY_DOMAIN:-}" ]]; then
        log_info "Checking external connectivity for $PROSODY_DOMAIN..."
        if $prosodyctl_cmd check connectivity; then
            log_success "Connectivity check passed"
        else
            log_warn "External connectivity issues detected"
        fi
    fi

    # Disabled components check
    log_info "Checking for disabled components..."
    if $prosodyctl_cmd check disabled; then
        log_success "No disabled components found"
    else
        log_info "Some components are disabled (this may be intentional)"
    fi

    # TURN configuration check (if TURN is configured)
    if [[ "${PROSODY_ENABLE_TURN:-false}" == "true" ]]; then
        log_info "Checking TURN configuration..."
        if $prosodyctl_cmd check turn; then
            log_success "TURN configuration check passed"
        else
            log_warn "TURN configuration issues detected"
        fi
    fi

    echo
    if [[ $failed_checks -eq 0 ]]; then
        log_success "All critical checks passed!"
    else
        log_error "$failed_checks critical check(s) failed"
        return 1
    fi
}

# Individual check functions
check_config() {
    log_header "Configuration Check"
    exec_prosodyctl "check config" "Performing configuration sanity checks"
}

check_features() {
    log_header "Features Check"
    exec_prosodyctl "check features" "Checking for missing/unconfigured features"
}

check_dns() {
    log_header "DNS Check"
    exec_prosodyctl "check dns" "Checking DNS records match configured domains and ports"
}

check_certs() {
    log_header "Certificate Check"
    exec_prosodyctl "check certs" "Checking certificate validity and expiration"
}

check_connectivity() {
    log_header "Connectivity Check"
    exec_prosodyctl "check connectivity" "Checking external connectivity via observe.jabber.network"
}

check_disabled() {
    log_header "Disabled Components Check"
    exec_prosodyctl "check disabled" "Reporting disabled VirtualHosts and Components"
}

check_turn() {
    log_header "TURN Configuration Check"
    if [[ -n "${STUN_SERVER:-}" ]]; then
        exec_prosodyctl "check turn --ping=$STUN_SERVER" "Testing TURN configuration with $STUN_SERVER"
    else
        exec_prosodyctl "check turn" "Testing TURN configuration"
    fi
}

# ============================================================================
# CERTIFICATE MANAGEMENT FUNCTIONS
# ============================================================================

# Certificate management wrapper
manage_certs() {
    local action="$1"
    shift

    case "$action" in
    "generate")
        local domain="${1:-$PROSODY_DOMAIN}"
        if [[ -z "$domain" ]]; then
            log_error "Domain is required for certificate generation"
            return 1
        fi
        exec_prosodyctl "cert generate $domain" "Generating certificate for $domain"
        ;;
    "import")
        local domain="${1:-$PROSODY_DOMAIN}"
        local cert_path="$2"
        if [[ -z "$domain" || -z "$cert_path" ]]; then
            log_error "Domain and certificate path are required for import"
            return 1
        fi
        exec_prosodyctl "cert import $domain $cert_path" "Importing certificate for $domain"
        ;;
    *)
        log_error "Unknown certificate action: $action"
        echo "Available actions: generate, import"
        return 1
        ;;
    esac
}

# ============================================================================
# PLUGIN MANAGEMENT FUNCTIONS
# ============================================================================

# Install plugin
install_plugin() {
    local plugin="$1"
    if [[ -z "$plugin" ]]; then
        log_error "Plugin name is required"
        echo "Usage: $0 install mod_plugin_name"
        return 1
    fi

    exec_prosodyctl "install $plugin" "Installing plugin $plugin"
}

# Remove plugin
remove_plugin() {
    local plugin="$1"
    if [[ -z "$plugin" ]]; then
        log_error "Plugin name is required"
        echo "Usage: $0 remove mod_plugin_name"
        return 1
    fi

    exec_prosodyctl "remove $plugin" "Removing plugin $plugin"
}

# List installed plugins
list_plugins() {
    log_header "Installed Plugins"
    exec_prosodyctl "list" "Listing installed plugins"
}

# ============================================================================
# INFORMATION FUNCTIONS
# ============================================================================

# Show Prosody information
show_about() {
    log_header "Prosody Installation Information"
    exec_prosodyctl "about" "Showing installation information"
}

# Open Prosody console shell
open_shell() {
    log_header "Opening Prosody Console Shell"
    log_info "Type 'quit' to exit the console"
    local prosodyctl_cmd
    prosodyctl_cmd=$(get_prosodyctl_cmd)
    $prosodyctl_cmd shell
}

# ============================================================================
# USAGE FUNCTION
# ============================================================================

usage() {
    echo "Prosody Management Script - Enhanced prosodyctl wrapper"
    echo
    echo "Usage: $0 COMMAND [OPTIONS]"
    echo
    echo "User Management:"
    echo "  adduser JID                    - Create a new user account"
    echo "  passwd JID                     - Change user password"
    echo "  deluser JID                    - Delete user account (with confirmation)"
    echo
    echo "Process Management:"
    echo "  status                         - Check Prosody status"
    echo "  reload                         - Reload configuration and reopen logs"
    echo
    echo "Health Checks:"
    echo "  check                          - Run comprehensive health check"
    echo "  check-config                   - Check configuration only"
    echo "  check-features                 - Check features only"
    echo "  check-dns                      - Check DNS configuration"
    echo "  check-certs                    - Check certificates"
    echo "  check-connectivity             - Check external connectivity"
    echo "  check-disabled                 - Check disabled components"
    echo "  check-turn                     - Check TURN configuration"
    echo
    echo "Certificate Management:"
    echo "  cert generate [DOMAIN]         - Generate self-signed certificate"
    echo "  cert import DOMAIN PATH        - Import certificate from file"
    echo
    echo "Plugin Management:"
    echo "  install PLUGIN                 - Install a plugin"
    echo "  remove PLUGIN                  - Remove a plugin"
    echo "  list-plugins                   - List installed plugins"
    echo
    echo "Information:"
    echo "  about                          - Show installation information"
    echo "  shell                          - Open Prosody console shell"
    echo
    echo "Environment Variables:"
    echo "  PROSODY_CONFIG                 - Alternative config file path"
    echo "  PROSODY_DOMAIN                 - Primary domain for checks"
    echo "  PROSODY_ENABLE_TURN            - Enable TURN checks (true/false)"
    echo "  STUN_SERVER                    - STUN server for TURN testing"
    echo
    echo "Examples:"
    echo "  $0 adduser admin@example.com"
    echo "  $0 check"
    echo "  $0 cert generate example.com"
    echo "  PROSODY_DOMAIN=example.com $0 check-dns"
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    # Check if prosodyctl is available
    check_prosodyctl

    # Parse command
    local command="${1:-}"

    if [[ -z "$command" ]]; then
        usage
        exit 1
    fi

    case "$command" in
    # User management
    "adduser")
        add_user "${2:-}"
        ;;
    "passwd")
        change_password "${2:-}"
        ;;
    "deluser")
        delete_user "${2:-}"
        ;;

    # Process management
    "status")
        check_status
        ;;
    "reload")
        reload_config
        ;;

    # Health checks
    "check")
        run_comprehensive_check
        ;;
    "check-config")
        check_config
        ;;
    "check-features")
        check_features
        ;;
    "check-dns")
        check_dns
        ;;
    "check-certs")
        check_certs
        ;;
    "check-connectivity")
        check_connectivity
        ;;
    "check-disabled")
        check_disabled
        ;;
    "check-turn")
        check_turn
        ;;

    # Certificate management
    "cert")
        manage_certs "${2:-}" "${3:-}" "${4:-}"
        ;;

    # Plugin management
    "install")
        install_plugin "${2:-}"
        ;;
    "remove")
        remove_plugin "${2:-}"
        ;;
    "list-plugins")
        list_plugins
        ;;

    # Information
    "about")
        show_about
        ;;
    "shell")
        open_shell
        ;;

    # Help
    "help" | "-h" | "--help")
        usage
        ;;

    *)
        log_error "Unknown command: $command"
        echo
        usage
        exit 1
        ;;
    esac
}

# Run main function
main "$@"
