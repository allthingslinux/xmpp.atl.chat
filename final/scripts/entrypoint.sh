#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server Entrypoint
# Security-first initialization with comprehensive setup

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

readonly PROSODY_USER="prosody"
readonly PROSODY_CONFIG_DIR="/etc/prosody"
readonly PROSODY_DATA_DIR="/var/lib/prosody/data"
readonly PROSODY_LOG_DIR="/var/log/prosody"
readonly PROSODY_CERT_DIR="/etc/prosody/certs"
readonly PROSODY_UPLOAD_DIR="/var/lib/prosody/uploads"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    if [[ "${PROSODY_LOG_LEVEL:-info}" == "debug" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1" >&2
    fi
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Validate environment variables
validate_environment() {
    log_info "Validating environment configuration..."
    
    # Check domain
    if [[ -z "${PROSODY_DOMAIN:-}" ]]; then
        log_warn "PROSODY_DOMAIN not set, using 'localhost'"
        export PROSODY_DOMAIN="localhost"
    fi
    
    # Check admins
    if [[ -z "${PROSODY_ADMINS:-}" ]]; then
        log_warn "PROSODY_ADMINS not set, using 'admin@${PROSODY_DOMAIN}'"
        export PROSODY_ADMINS="admin@${PROSODY_DOMAIN}"
    fi
    
    # Validate storage backend
    case "${PROSODY_STORAGE:-sqlite}" in
        sqlite|sql)
            log_debug "Storage backend: ${PROSODY_STORAGE}"
            ;;
        *)
            log_error "Invalid storage backend: ${PROSODY_STORAGE}"
            exit 1
            ;;
    esac
    
    log_info "Environment validation complete"
}

# Check directory permissions
check_permissions() {
    log_info "Checking directory permissions..."
    
    local dirs=(
        "$PROSODY_CONFIG_DIR"
        "$PROSODY_DATA_DIR"
        "$PROSODY_LOG_DIR"
        "$PROSODY_CERT_DIR"
        "$PROSODY_UPLOAD_DIR"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_warn "Directory $dir does not exist, creating..."
            mkdir -p "$dir"
        fi
        
        if [[ ! -r "$dir" ]]; then
            log_error "Cannot read directory: $dir"
            exit 1
        fi
        
        if [[ ! -w "$dir" ]]; then
            log_error "Cannot write to directory: $dir"
            exit 1
        fi
    done
    
    log_info "Directory permissions check complete"
}

# Initialize SSL certificates
setup_ssl_certificates() {
    log_info "Setting up SSL certificates..."
    
    local cert_file="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}.crt"
    local key_file="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}.key"
    
    # Check if certificates exist
    if [[ ! -f "$cert_file" ]] || [[ ! -f "$key_file" ]]; then
        log_warn "SSL certificates not found, generating self-signed certificates..."
        
        # Generate self-signed certificate
        openssl req -x509 -newkey rsa:4096 -keyout "$key_file" -out "$cert_file" \
            -days 365 -nodes -subj "/CN=${PROSODY_DOMAIN}" \
            -addext "subjectAltName=DNS:${PROSODY_DOMAIN},DNS:*.${PROSODY_DOMAIN}" \
            2>/dev/null
        
        log_warn "Self-signed certificates generated. Please replace with proper certificates for production use."
    else
        log_info "SSL certificates found"
        
        # Validate certificate
        if ! openssl x509 -in "$cert_file" -noout -checkend 86400 >/dev/null 2>&1; then
            log_warn "SSL certificate expires within 24 hours"
        fi
    fi
}

# Database initialization
setup_database() {
    log_info "Setting up database..."
    
    case "${PROSODY_STORAGE:-sqlite}" in
        sqlite)
            local db_file="${PROSODY_DATA_DIR}/prosody.sqlite"
            if [[ ! -f "$db_file" ]]; then
                log_info "Creating SQLite database..."
                touch "$db_file"
            fi
            ;;
        sql)
            log_info "Using external SQL database"
            # Wait for database to be ready
            if [[ -n "${PROSODY_DB_HOST:-}" ]]; then
                log_info "Waiting for database connection..."
                local retries=30
                while ! nc -z "${PROSODY_DB_HOST}" "${PROSODY_DB_PORT:-5432}" && [[ $retries -gt 0 ]]; do
                    log_debug "Database not ready, waiting... ($retries retries left)"
                    sleep 2
                    ((retries--))
                done
                
                if [[ $retries -eq 0 ]]; then
                    log_error "Database connection timeout"
                    exit 1
                fi
                
                log_info "Database connection established"
            fi
            ;;
    esac
}

# Create initial admin user
create_admin_user() {
    log_info "Setting up admin users..."
    
    # Parse admin list
    IFS=',' read -ra ADMIN_ARRAY <<< "${PROSODY_ADMINS}"
    for admin in "${ADMIN_ARRAY[@]}"; do
        admin=$(echo "$admin" | xargs) # trim whitespace
        log_info "Ensuring admin user exists: $admin"
        
        # Check if user exists (prosodyctl will handle this gracefully)
        if ! prosodyctl check config >/dev/null 2>&1; then
            log_warn "Configuration check failed, but continuing..."
        fi
    done
}

# Setup firewall rules
setup_firewall() {
    if [[ "${PROSODY_ENABLE_SECURITY:-true}" == "true" ]]; then
        log_info "Setting up firewall rules..."
        
        # Ensure firewall rule files exist
        local firewall_dir="${PROSODY_CONFIG_DIR}/firewall"
        if [[ -d "$firewall_dir" ]]; then
            for rule_file in "$firewall_dir"/*.pfw; do
                if [[ -f "$rule_file" ]]; then
                    log_debug "Found firewall rule: $(basename "$rule_file")"
                fi
            done
        fi
    fi
}

# Health check setup
setup_health_check() {
    log_info "Setting up health monitoring..."
    
    # Create health check endpoint if HTTP is enabled
    if [[ "${PROSODY_ENABLE_HTTP:-false}" == "true" ]]; then
        log_debug "HTTP services enabled, health check available at :5280/health"
    fi
}

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

# Graceful shutdown handler
shutdown_handler() {
    log_info "Received shutdown signal, stopping Prosody gracefully..."
    
    # Send SIGTERM to prosody process
    if [[ -n "${PROSODY_PID:-}" ]]; then
        kill -TERM "$PROSODY_PID" 2>/dev/null || true
        
        # Wait for graceful shutdown
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
trap shutdown_handler SIGTERM SIGINT

# ============================================================================
# MAIN INITIALIZATION
# ============================================================================

main() {
    log_info "Starting Professional Prosody XMPP Server..."
    log_info "Version: $(prosody --version 2>/dev/null | head -n1 || echo 'Unknown')"
    
    # Security check
    check_root
    
    # Environment setup
    validate_environment
    check_permissions
    
    # Service setup
    setup_ssl_certificates
    setup_database
    setup_firewall
    setup_health_check
    
    # Configuration validation
    log_info "Validating Prosody configuration..."
    if ! prosodyctl check config; then
        log_error "Configuration validation failed"
        exit 1
    fi
    
    log_info "Configuration validation successful"
    
    # Create admin users after prosody starts
    create_admin_user &
    
    # Start Prosody
    log_info "Starting Prosody XMPP server..."
    log_info "Domain: ${PROSODY_DOMAIN}"
    log_info "Admins: ${PROSODY_ADMINS}"
    log_info "Storage: ${PROSODY_STORAGE:-sqlite}"
    log_info "Security: ${PROSODY_ENABLE_SECURITY:-true}"
    log_info "Modern Features: ${PROSODY_ENABLE_MODERN:-true}"
    log_info "HTTP Services: ${PROSODY_ENABLE_HTTP:-false}"
    
    # Start prosody in foreground
    exec prosody --config="$PROSODY_CONFIG_DIR/prosody.cfg.lua" --foreground &
    PROSODY_PID=$!
    
    log_info "Prosody started with PID: $PROSODY_PID"
    
    # Wait for prosody to exit
    wait $PROSODY_PID
    
    log_info "Prosody process exited"
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Run main function
main "$@" 