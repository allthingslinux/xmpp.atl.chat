#!/bin/bash
set -euo pipefail

# Generate DH Parameters for Enhanced TLS Security
# Required for TLS 1.3 and forward secrecy compliance

readonly CERT_DIR="/etc/prosody/certs"
readonly DHPARAM_FILE="${CERT_DIR}/dhparam.pem"
readonly DHPARAM_SIZE=4096

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as prosody user
check_user() {
    if [[ "$(id -u)" -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Ensure certificate directory exists
setup_cert_dir() {
    if [[ ! -d "$CERT_DIR" ]]; then
        log_info "Creating certificate directory: $CERT_DIR"
        mkdir -p "$CERT_DIR"
    fi
}

# Generate DH parameters
generate_dhparam() {
    log_info "Generating DH parameters (${DHPARAM_SIZE}-bit)..."
    log_warn "This may take several minutes..."

    if openssl dhparam -out "$DHPARAM_FILE" "$DHPARAM_SIZE"; then
        log_info "DH parameters generated successfully: $DHPARAM_FILE"

        # Set proper permissions
        chmod 600 "$DHPARAM_FILE"

        # Verify the generated parameters
        if openssl dhparam -in "$DHPARAM_FILE" -check -noout; then
            log_info "DH parameters validation: PASSED"
        else
            log_error "DH parameters validation: FAILED"
            exit 1
        fi
    else
        log_error "Failed to generate DH parameters"
        exit 1
    fi
}

# Main execution
main() {
    log_info "=== DH Parameter Generation ==="
    log_info "Target file: $DHPARAM_FILE"
    log_info "Key size: $DHPARAM_SIZE bits"
    echo

    check_user
    setup_cert_dir

    # Check if DH parameters already exist
    if [[ -f "$DHPARAM_FILE" ]]; then
        log_warn "DH parameters already exist at: $DHPARAM_FILE"
        read -p "Do you want to regenerate them? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing DH parameters"
            exit 0
        fi
    fi

    generate_dhparam

    log_info "=== Generation Complete ==="
    log_info "DH parameters are ready for use"
    log_info "Restart Prosody to apply the new parameters"
}

main "$@"
