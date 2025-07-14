#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server - Certificate Renewal Script
# Automatically renews Let's Encrypt certificates and reloads Prosody

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly LOG_FILE="/var/log/prosody-cert-renewal.log"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# ============================================================================
# MAIN FUNCTIONS
# ============================================================================

check_requirements() {
    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_DIR/docker-compose.yml" ]]; then
        log_error "docker-compose.yml not found. Please run this script from the project directory."
        exit 1
    fi

    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or not accessible"
        exit 1
    fi

    # Check if Prosody container exists
    if ! docker ps -q --filter "name=prosody" | grep -q .; then
        log_warn "Prosody container not running, certificates will be renewed but not reloaded"
    fi
}

renew_certificates() {
    log_info "Starting certificate renewal process..."

    cd "$PROJECT_DIR"

    # Try to renew certificates
    if docker compose --profile renewal run --rm xmpp-certbot-renew; then
        log_info "Certificate renewal completed successfully"
        return 0
    else
        log_error "Certificate renewal failed"
        return 1
    fi
}

reload_prosody() {
    log_info "Reloading Prosody to use renewed certificates..."

    # Check if Prosody container is running
    if docker ps -q --filter "name=prosody" | grep -q .; then
        if docker compose restart prosody; then
            log_info "Prosody reloaded successfully"
        else
            log_error "Failed to reload Prosody"
            return 1
        fi
    else
        log_warn "Prosody container not running, skipping reload"
    fi
}

cleanup_old_logs() {
    # Keep only last 30 days of logs
    if [[ -f "$LOG_FILE" ]]; then
        # Create a temporary file with recent logs
        tail -n 1000 "$LOG_FILE" >"${LOG_FILE}.tmp" 2>/dev/null || true
        mv "${LOG_FILE}.tmp" "$LOG_FILE" 2>/dev/null || true
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log_info "=== Certificate Renewal Process Started ==="

    # Create log file if it doesn't exist
    touch "$LOG_FILE" 2>/dev/null || true

    # Check requirements
    check_requirements

    # Clean up old logs
    cleanup_old_logs

    # Renew certificates
    if renew_certificates; then
        # Reload Prosody if renewal was successful
        reload_prosody
        log_info "=== Certificate Renewal Process Completed Successfully ==="
        exit 0
    else
        log_error "=== Certificate Renewal Process Failed ==="
        exit 1
    fi
}

# Show usage if help requested
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat <<EOF
Professional Prosody XMPP Server - Certificate Renewal Script

USAGE:
    $0

DESCRIPTION:
    Automatically renews Let's Encrypt certificates and reloads Prosody.
    This script is designed to be run via cron for automated renewal.

REQUIREMENTS:
    - Docker and Docker Compose installed
    - Must be run from the project directory
    - Prosody container should be running for automatic reload

CRON EXAMPLE:
    # Run every day at 3 AM
    0 3 * * * /opt/xmpp.atl.chat/scripts/renew-certificates.sh

LOG FILE:
    Certificate renewal logs are written to: $LOG_FILE

EOF
    exit 0
fi

# Run main function
main "$@"
