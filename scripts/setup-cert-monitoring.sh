#!/bin/bash
# Setup script for enhanced certificate monitoring system
# Installs systemd services, configures monitoring, and sets up automation

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly SYSTEMD_DIR="/etc/systemd/system"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

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

# Check if running as root for systemd installation
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        log_info "Running as root - will install systemd services"
        return 0
    else
        log_warn "Not running as root - systemd services will not be installed"
        return 1
    fi
}

# Install systemd services
install_systemd_services() {
    if ! check_permissions; then
        log_warn "Skipping systemd service installation (requires root)"
        return 0
    fi

    log_info "Installing systemd services for certificate monitoring..."

    # Copy service files
    local services=(
        "prosody-cert-monitor.service"
        "prosody-cert-monitor.timer"
        "prosody-cert-renewal.service"
        "prosody-cert-renewal.timer"
    )

    for service in "${services[@]}"; do
        if [[ -f "$PROJECT_DIR/deployment/systemd/$service" ]]; then
            log_info "Installing $service..."

            # Update paths in service files
            sed "s|/opt/prosody-xmpp-server|$PROJECT_DIR|g" \
                "$PROJECT_DIR/deployment/systemd/$service" > "$SYSTEMD_DIR/$service"

            log_success "Installed $service"
        else
            log_error "Service file not found: $PROJECT_DIR/deployment/systemd/$service"
        fi
    done

    # Reload systemd
    log_info "Reloading systemd daemon..."
    systemctl daemon-reload

    # Enable and start timers
    log_info "Enabling certificate monitoring timer..."
    systemctl enable prosody-cert-monitor.timer
    systemctl start prosody-cert-monitor.timer

    log_info "Enabling certificate renewal timer..."
    systemctl enable prosody-cert-renewal.timer
    systemctl start prosody-cert-renewal.timer

    log_success "Systemd services installed and started"
}

# Setup cron jobs (alternative to systemd)
setup_cron_jobs() {
    log_info "Setting up cron jobs for certificate monitoring..."

    # Create cron jobs
    local cron_file="/tmp/prosody-cert-cron"
    cat > "$cron_file" << EOF
# Prosody Certificate Monitoring
# Check certificates every hour
0 * * * * cd $PROJECT_DIR && ./scripts/certificate-monitor.sh monitor >> .runtime/logs/cert-monitor.log 2>&1

# Auto-renew certificates daily at 3 AM
0 3 * * * cd $PROJECT_DIR && ./scripts/certificate-monitor.sh auto-renew >> .runtime/logs/cert-monitor.log 2>&1

# Generate dashboard daily at 6 AM
0 6 * * * cd $PROJECT_DIR && ./scripts/certificate-monitor.sh dashboard >> .runtime/logs/cert-monitor.log 2>&1
EOF

    # Install cron jobs
    if crontab -l > /dev/null 2>&1; then
        # Append to existing crontab
        (crontab -l; cat "$cron_file") | crontab -
    else
        # Create new crontab
        crontab "$cron_file"
    fi

    rm -f "$cron_file"
    log_success "Cron jobs installed"
}

# Setup log rotation
setup_log_rotation() {
    if ! check_permissions; then
        log_warn "Skipping log rotation setup (requires root)"
        return 0
    fi

    log_info "Setting up log rotation for certificate monitoring..."

    cat > "/etc/logrotate.d/prosody-cert-monitor" << EOF
$PROJECT_DIR/.runtime/logs/cert-monitor.log
$PROJECT_DIR/.runtime/logs/cert-alerts.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 prosody prosody
    postrotate
        # Send HUP signal to any running monitoring processes
        pkill -HUP -f certificate-monitor.sh || true
    endscript
}
EOF

    log_success "Log rotation configured"
}

# Create necessary directories and files
setup_directories() {
    log_info "Creating necessary directories..."

    local dirs=(
        "$PROJECT_DIR/.runtime/logs"
        "$PROJECT_DIR/.runtime/certs"
        "$PROJECT_DIR/.runtime/backups"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    done

    # Create default configuration if it doesn't exist
    if [[ ! -f "$PROJECT_DIR/.runtime/cert-monitor.conf" ]]; then
        log_info "Configuration file already exists"
    else
        log_success "Using existing configuration file"
    fi

    log_success "Directories and files setup complete"
}

# Configure monitoring thresholds
configure_monitoring() {
    log_info "Configuring certificate monitoring..."

    local config_file="$PROJECT_DIR/.runtime/cert-monitor.conf"

    echo "Current certificate monitoring configuration:"
    echo "============================================="

    if [[ -f "$config_file" ]]; then
        grep -E "^CERT_.*=" "$config_file" || true
    else
        echo "No configuration file found"
    fi

    echo ""
    read -p "Do you want to configure monitoring settings interactively? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_interactive
    else
        log_info "Using default configuration"
    fi
}

# Interactive configuration
configure_interactive() {
    local config_file="$PROJECT_DIR/.runtime/cert-monitor.conf"
    local temp_config="/tmp/cert-monitor-config"

    # Load existing config or use defaults
    local warning_threshold=30
    local critical_threshold=7
    local renewal_threshold=30
    local alert_email=""
    local webhook_url=""

    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file"
        warning_threshold="${CERT_WARNING_THRESHOLD:-30}"
        critical_threshold="${CERT_CRITICAL_THRESHOLD:-7}"
        renewal_threshold="${CERT_RENEWAL_THRESHOLD:-30}"
        alert_email="${CERT_ALERT_EMAIL:-}"
        webhook_url="${CERT_WEBHOOK_URL:-}"
    fi

    echo "Configure Certificate Monitoring Settings:"
    echo "=========================================="

    read -p "Warning threshold in days [$warning_threshold]: " input
    warning_threshold="${input:-$warning_threshold}"

    read -p "Critical threshold in days [$critical_threshold]: " input
    critical_threshold="${input:-$critical_threshold}"

    read -p "Auto-renewal threshold in days [$renewal_threshold]: " input
    renewal_threshold="${input:-$renewal_threshold}"

    read -p "Alert email address [$alert_email]: " input
    alert_email="${input:-$alert_email}"

    read -p "Webhook URL for alerts [$webhook_url]: " input
    webhook_url="${input:-$webhook_url}"

    # Write new configuration
    cat > "$temp_config" << EOF
# Certificate Monitoring Configuration
# Generated by setup script on $(date)

# Monitoring thresholds (in days)
CERT_WARNING_THRESHOLD=$warning_threshold
CERT_CRITICAL_THRESHOLD=$critical_threshold
CERT_RENEWAL_THRESHOLD=$renewal_threshold

# Monitoring intervals
CERT_CHECK_INTERVAL=3600  # Check every hour (in seconds)
CERT_RENEWAL_CHECK_INTERVAL=86400  # Check for renewal daily (in seconds)

# Retry configuration for certificate renewal
CERT_RENEWAL_RETRY_COUNT=3
CERT_RENEWAL_RETRY_DELAY=300  # 5 minutes between retries

# Alert configuration
CERT_ALERT_EMAIL="$alert_email"
CERT_WEBHOOK_URL="$webhook_url"

# Logging configuration
CERT_LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR, CRITICAL
CERT_LOG_RETENTION_DAYS=30

# Dashboard configuration
CERT_DASHBOARD_ENABLED=true
CERT_DASHBOARD_AUTO_REFRESH=true
CERT_DASHBOARD_REFRESH_INTERVAL=300  # 5 minutes

# Advanced options
CERT_VALIDATION_STRICT=false  # Enable strict certificate chain validation
CERT_OCSP_CHECK=false  # Enable OCSP stapling validation
CERT_DNS_VALIDATION_TIMEOUT=60  # DNS validation timeout in seconds
EOF

    mv "$temp_config" "$config_file"
    log_success "Configuration saved to $config_file"
}

# Test the monitoring system
test_monitoring() {
    log_info "Testing certificate monitoring system..."

    # Make sure the script is executable
    chmod +x "$PROJECT_DIR/scripts/certificate-monitor.sh"

    # Test basic functionality
    if "$PROJECT_DIR/scripts/certificate-monitor.sh" config; then
        log_success "Configuration test passed"
    else
        log_error "Configuration test failed"
        return 1
    fi

    # Test monitoring
    log_info "Running certificate monitoring test..."
    if "$PROJECT_DIR/scripts/certificate-monitor.sh" monitor; then
        log_success "Monitoring test passed"
    else
        log_warn "Monitoring test failed - this may be normal if no certificates are present"
    fi

    # Generate initial dashboard
    log_info "Generating initial dashboard..."
    if "$PROJECT_DIR/scripts/certificate-monitor.sh" dashboard; then
        log_success "Dashboard generation test passed"
        log_info "Dashboard available at: $PROJECT_DIR/.runtime/cert-dashboard.html"
    else
        log_warn "Dashboard generation failed"
    fi
}

# Show setup summary
show_summary() {
    echo ""
    echo "Certificate Monitoring Setup Complete!"
    echo "======================================"
    echo ""
    echo "Services installed:"
    if check_permissions; then
        echo "  ✓ Systemd services and timers"
        echo "  ✓ Log rotation configuration"
    else
        echo "  ✓ Cron jobs for monitoring"
    fi
    echo "  ✓ Directory structure"
    echo "  ✓ Configuration files"
    echo ""
    echo "Available commands:"
    echo "  ./prosody-manager cert monitor      # Run monitoring check"
    echo "  ./prosody-manager cert auto-renew   # Check and renew certificates"
    echo "  ./prosody-manager cert dashboard    # Generate health dashboard"
    echo "  ./prosody-manager cert status       # Show monitoring status"
    echo ""
    echo "Files created:"
    echo "  Configuration: $PROJECT_DIR/.runtime/cert-monitor.conf"
    echo "  Logs: $PROJECT_DIR/.runtime/logs/cert-monitor.log"
    echo "  Dashboard: $PROJECT_DIR/.runtime/cert-dashboard.html"
    echo ""
    if check_permissions; then
        echo "Systemd services:"
        echo "  systemctl status prosody-cert-monitor.timer"
        echo "  systemctl status prosody-cert-renewal.timer"
        echo ""
    fi
    echo "To view logs:"
    echo "  tail -f $PROJECT_DIR/.runtime/logs/cert-monitor.log"
    echo ""
}

# Main setup function
main() {
    echo "Enhanced Certificate Monitoring Setup"
    echo "====================================="
    echo ""

    # Setup directories and files
    setup_directories

    # Configure monitoring
    configure_monitoring

    # Install services
    if check_permissions; then
        install_systemd_services
        setup_log_rotation
    else
        setup_cron_jobs
    fi

    # Test the system
    test_monitoring

    # Show summary
    show_summary

    log_success "Certificate monitoring setup completed successfully!"
}

# Run main function
main "$@"
