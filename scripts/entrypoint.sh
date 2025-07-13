#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server Entrypoint
# Modern Docker initialization script for production deployment

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

readonly PROSODY_USER="prosody"
readonly PROSODY_CONFIG_DIR="/etc/prosody"
readonly PROSODY_DATA_DIR="/var/lib/prosody"
readonly PROSODY_LOG_DIR="/var/log/prosody"
readonly PROSODY_CERT_DIR="/etc/prosody/certs"
readonly PROSODY_UPLOAD_DIR="/var/lib/prosody/uploads"
readonly PROSODY_CONFIG_FILE="${PROSODY_CONFIG_DIR}/prosody.cfg.lua"
readonly PROSODY_PID_FILE="/var/run/prosody/prosody.pid"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

log_debug() {
    if [[ "${PROSODY_LOG_LEVEL:-info}" == "debug" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
    fi
}

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

validate_environment() {
    log_info "Validating environment configuration..."

    # Validate required domain
    if [[ -z "${PROSODY_DOMAIN:-}" ]]; then
        log_error "PROSODY_DOMAIN is required but not set"
        exit 1
    fi

    # Validate domain format
    if [[ ! "${PROSODY_DOMAIN}" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        log_error "Invalid domain format: ${PROSODY_DOMAIN}"
        exit 1
    fi

    # Set default admin if not provided
    if [[ -z "${PROSODY_ADMINS:-}" ]]; then
        export PROSODY_ADMINS="admin@${PROSODY_DOMAIN}"
        log_info "Using default admin: ${PROSODY_ADMINS}"
    fi

    # Validate database configuration for SQL storage
    if [[ "${PROSODY_STORAGE:-sql}" == "sql" ]]; then
        local required_vars=(
            "PROSODY_DB_DRIVER"
            "PROSODY_DB_NAME"
            "PROSODY_DB_USER"
            "PROSODY_DB_PASSWORD"
            "PROSODY_DB_HOST"
        )

        for var in "${required_vars[@]}"; do
            if [[ -z "${!var:-}" ]]; then
                log_error "Database variable ${var} is required for SQL storage"
                exit 1
            fi
        done
    fi

    log_info "Environment validation complete"
}

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

setup_directories() {
    log_info "Setting up directories..."

    local dirs=(
        "$PROSODY_DATA_DIR"
        "$PROSODY_LOG_DIR"
        "$PROSODY_CERT_DIR"
        "$PROSODY_UPLOAD_DIR"
        "$(dirname "$PROSODY_PID_FILE")"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_debug "Creating directory: $dir"
            mkdir -p "$dir"
        fi

        # Ensure proper ownership
        chown -R "$PROSODY_USER:$PROSODY_USER" "$dir" 2>/dev/null || true
    done

    log_info "Directory setup complete"
}

setup_certificates() {
    log_info "Setting up SSL certificates..."

    local cert_file="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}.crt"
    local key_file="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}.key"

    # Check for Let's Encrypt certificates (preferred)
    local le_cert="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}/fullchain.pem"
    local le_key="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}/privkey.pem"

    if [[ -f "$le_cert" && -f "$le_key" ]]; then
        log_info "Let's Encrypt certificates found for ${PROSODY_DOMAIN}"
        return 0
    fi

    # Check for standard certificates
    if [[ -f "$cert_file" && -f "$key_file" ]]; then
        log_info "Standard certificates found for ${PROSODY_DOMAIN}"

        # Check certificate validity
        if openssl x509 -in "$cert_file" -noout -checkend 86400 >/dev/null 2>&1; then
            log_info "Certificate is valid for at least 24 hours"
        else
            log_warn "Certificate expires within 24 hours - consider renewal"
        fi
        return 0
    fi

    # Generate self-signed certificate for development/testing
    log_warn "No certificates found, generating self-signed certificate for ${PROSODY_DOMAIN}"
    log_warn "This is suitable for development only - use proper certificates in production"

    # Generate private key
    openssl genrsa -out "$key_file" 4096 2>/dev/null

    # Generate certificate with proper Subject Alternative Names
    openssl req -new -x509 -key "$key_file" -out "$cert_file" -days 365 \
        -subj "/CN=${PROSODY_DOMAIN}" \
        -addext "subjectAltName=DNS:${PROSODY_DOMAIN},DNS:*.${PROSODY_DOMAIN},DNS:conference.${PROSODY_DOMAIN},DNS:upload.${PROSODY_DOMAIN}" \
        2>/dev/null

    # Set proper permissions
    chown "$PROSODY_USER:$PROSODY_USER" "$cert_file" "$key_file"
    chmod 644 "$cert_file"
    chmod 600 "$key_file"

    log_info "Self-signed certificate generated successfully"
}

wait_for_database() {
    if [[ "${PROSODY_STORAGE:-sql}" != "sql" ]]; then
        log_debug "Not using SQL storage, skipping database wait"
        return 0
    fi

    local host="${PROSODY_DB_HOST}"
    local port="${PROSODY_DB_PORT:-5432}"
    local max_attempts=30
    local attempt=1

    log_info "Waiting for database connection to ${host}:${port}..."

    while [[ $attempt -le $max_attempts ]]; do
        if timeout 5 bash -c "</dev/tcp/${host}/${port}" 2>/dev/null; then
            log_info "Database connection established"
            return 0
        fi

        log_debug "Database not ready, attempt ${attempt}/${max_attempts}"
        sleep 2
        ((attempt++))
    done

    log_error "Database connection timeout after ${max_attempts} attempts"
    exit 1
}

validate_configuration() {
    log_info "Validating Prosody configuration..."

    # Check if config file exists
    if [[ ! -f "$PROSODY_CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $PROSODY_CONFIG_FILE"
        exit 1
    fi

    # Validate configuration using prosodyctl
    if ! prosodyctl check config 2>/dev/null; then
        log_error "Prosody configuration validation failed"
        log_error "Please check your configuration file: $PROSODY_CONFIG_FILE"
        exit 1
    fi

    log_info "Configuration validation successful"
}

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

# shellcheck disable=SC2317  # Function is called by signal handlers
cleanup() {
    log_info "Received shutdown signal, stopping Prosody..."

    if [[ -n "${PROSODY_PID:-}" ]] && kill -0 "$PROSODY_PID" 2>/dev/null; then
        # Send SIGTERM for graceful shutdown
        kill -TERM "$PROSODY_PID" 2>/dev/null || true

        # Wait for graceful shutdown (max 30 seconds)
        local timeout=30
        while kill -0 "$PROSODY_PID" 2>/dev/null && [[ $timeout -gt 0 ]]; do
            sleep 1
            ((timeout--))
        done

        # Force kill if still running
        if kill -0 "$PROSODY_PID" 2>/dev/null; then
            log_warn "Prosody did not shut down gracefully, forcing termination"
            kill -KILL "$PROSODY_PID" 2>/dev/null || true
        fi
    fi

    log_info "Prosody shutdown complete"
    exit 0
}

# Setup signal handlers
trap cleanup SIGTERM SIGINT SIGQUIT

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    log_info "Starting Professional Prosody XMPP Server..."

    # Display version information
    local prosody_version
    prosody_version=$(prosody --version 2>/dev/null | head -n1 || echo "Unknown")
    log_info "Prosody version: $prosody_version"

    # Environment and setup
    validate_environment
    setup_directories
    setup_certificates
    wait_for_database
    validate_configuration

    # Display configuration summary
    log_info "Configuration summary:"
    log_info "  Domain: ${PROSODY_DOMAIN}"
    log_info "  Admins: ${PROSODY_ADMINS}"
    log_info "  Storage: ${PROSODY_STORAGE:-sql}"
    log_info "  Log level: ${PROSODY_LOG_LEVEL:-info}"
    log_info "  Allow registration: ${PROSODY_ALLOW_REGISTRATION:-false}"

    if [[ "${PROSODY_STORAGE:-sql}" == "sql" ]]; then
        log_info "  Database: ${PROSODY_DB_DRIVER} on ${PROSODY_DB_HOST}:${PROSODY_DB_PORT:-5432}"
    fi

    # Start Prosody
    log_info "Starting Prosody XMPP server..."

    # Switch to prosody user and start in foreground
    exec su-exec "$PROSODY_USER" prosody \
        --config="$PROSODY_CONFIG_FILE" \
        --foreground &

    PROSODY_PID=$!
    log_info "Prosody started with PID: $PROSODY_PID"

    # Wait for Prosody process
    wait $PROSODY_PID
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        log_info "Prosody exited normally"
    else
        log_error "Prosody exited with code: $exit_code"
    fi

    exit $exit_code
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Ensure we're running as root initially (for setup)
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root for initial setup"
    exit 1
fi

# Execute main function
main "$@"
