#!/bin/bash
set -euo pipefail

# Certificate Installation Script for Prosody XMPP Server
# Handles certificate installation using prosodyctl commands and proper permissions

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

readonly CERT_DIR="/etc/prosody/certs"
readonly DOMAIN="${1:-${PROSODY_DOMAIN:-}}"
readonly CERT_SOURCE="${2:-}"
readonly BACKUP_DIR="/etc/prosody/certs/backups"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

show_usage() {
    cat <<EOF
Usage: $0 <domain> [certificate_source_path] [options]

Arguments:
  domain                  Domain name for certificate (required)
  certificate_source_path Path to certificate source (optional)

Options:
  --letsencrypt PATH     Import from Let's Encrypt directory
  --ca-cert CERT_FILE    Import CA-signed certificate
  --ca-key KEY_FILE      Import CA-signed private key
  --self-signed          Generate self-signed certificate
  --backup               Create backup of existing certificates
  --no-reload            Don't reload Prosody after installation
  --help                 Show this help message

Examples:
  $0 example.com --self-signed
  $0 example.com --letsencrypt /etc/letsencrypt/live/example.com/
  $0 example.com --ca-cert example.com.crt --ca-key example.com.key
  $0 example.com /path/to/certificate/directory/

Environment Variables:
  PROSODY_DOMAIN         Default domain if not provided as argument
  PROSODY_CERT_DIR       Certificate directory (default: /etc/prosody/certs)
  PROSODY_AUTO_BACKUP    Automatically backup existing certificates (default: true)

EOF
}

validate_domain() {
    local domain="$1"

    if [[ -z "$domain" ]]; then
        log_error "Domain is required"
        return 1
    fi

    # Basic domain validation
    if [[ ! "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9\.-]*[a-zA-Z0-9]$ ]]; then
        log_error "Invalid domain format: $domain"
        return 1
    fi

    log_info "Installing certificates for domain: $domain"
}

check_prerequisites() {
    # Check if prosodyctl is available
    if ! command -v prosodyctl >/dev/null 2>&1; then
        log_error "prosodyctl not found - ensure Prosody is installed"
        return 1
    fi

    # Check if openssl is available
    if ! command -v openssl >/dev/null 2>&1; then
        log_error "openssl not found - required for certificate operations"
        return 1
    fi

    # Check if running as root or prosody user
    if [[ $EUID -ne 0 ]] && [[ "$(whoami)" != "prosody" ]]; then
        log_warn "Not running as root or prosody user - permissions may need adjustment"
    fi

    # Ensure certificate directory exists
    if [[ ! -d "$CERT_DIR" ]]; then
        log_info "Creating certificate directory: $CERT_DIR"
        mkdir -p "$CERT_DIR"
    fi

    # Ensure backup directory exists
    mkdir -p "$BACKUP_DIR"
}

backup_existing_certificates() {
    local domain="$1"
    local backup_timestamp
    backup_timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/${domain}_${backup_timestamp}"

    # Check if certificates exist
    local has_certs=false

    if [[ -f "${CERT_DIR}/${domain}.crt" ]] || [[ -f "${CERT_DIR}/${domain}.key" ]]; then
        has_certs=true
    fi

    if [[ -f "${CERT_DIR}/${domain}/fullchain.pem" ]] || [[ -f "${CERT_DIR}/${domain}/privkey.pem" ]]; then
        has_certs=true
    fi

    if [[ "$has_certs" == true ]]; then
        log_info "Backing up existing certificates to: $backup_path"
        mkdir -p "$backup_path"

        # Backup standard format certificates
        if [[ -f "${CERT_DIR}/${domain}.crt" ]]; then
            cp "${CERT_DIR}/${domain}.crt" "$backup_path/"
        fi
        if [[ -f "${CERT_DIR}/${domain}.key" ]]; then
            cp "${CERT_DIR}/${domain}.key" "$backup_path/"
        fi

        # Backup Let's Encrypt format certificates
        if [[ -d "${CERT_DIR}/${domain}" ]]; then
            cp -r "${CERT_DIR}/${domain}" "$backup_path/"
        fi

        log_info "Backup completed successfully"
    else
        log_debug "No existing certificates found to backup"
    fi
}

# ============================================================================
# CERTIFICATE INSTALLATION METHODS
# ============================================================================

install_letsencrypt_certificates() {
    local domain="$1"
    local le_path="$2"

    log_info "Installing Let's Encrypt certificates from: $le_path"

    # Validate Let's Encrypt directory structure
    if [[ ! -f "$le_path/fullchain.pem" ]] || [[ ! -f "$le_path/privkey.pem" ]]; then
        log_error "Invalid Let's Encrypt directory - missing fullchain.pem or privkey.pem"
        return 1
    fi

    # Method 1: Use prosodyctl cert import (preferred)
    log_info "Using prosodyctl cert import..."
    if prosodyctl --root cert import "$domain" "$le_path"; then
        log_info "Certificates imported successfully using prosodyctl"
        return 0
    else
        log_warn "prosodyctl cert import failed, falling back to manual method"
    fi

    # Method 2: Manual installation with Let's Encrypt directory structure
    log_info "Creating Let's Encrypt directory structure..."
    mkdir -p "${CERT_DIR}/${domain}"

    cp "$le_path/fullchain.pem" "${CERT_DIR}/${domain}/"
    cp "$le_path/privkey.pem" "${CERT_DIR}/${domain}/"

    # Also create standard format for compatibility
    cp "$le_path/fullchain.pem" "${CERT_DIR}/${domain}.crt"
    cp "$le_path/privkey.pem" "${CERT_DIR}/${domain}.key"

    log_info "Let's Encrypt certificates installed manually"
}

install_ca_certificates() {
    local domain="$1"
    local cert_file="$2"
    local key_file="$3"

    log_info "Installing CA-signed certificates"
    log_debug "Certificate: $cert_file"
    log_debug "Private key: $key_file"

    # Validate certificate files
    if [[ ! -f "$cert_file" ]]; then
        log_error "Certificate file not found: $cert_file"
        return 1
    fi

    if [[ ! -f "$key_file" ]]; then
        log_error "Private key file not found: $key_file"
        return 1
    fi

    # Validate certificate and key match
    local cert_modulus key_modulus
    cert_modulus=$(openssl x509 -noout -modulus -in "$cert_file" 2>/dev/null | openssl md5)
    key_modulus=$(openssl rsa -noout -modulus -in "$key_file" 2>/dev/null | openssl md5)

    if [[ "$cert_modulus" != "$key_modulus" ]]; then
        log_error "Certificate and private key do not match!"
        return 1
    fi

    # Install certificates
    cp "$cert_file" "${CERT_DIR}/${domain}.crt"
    cp "$key_file" "${CERT_DIR}/${domain}.key"

    log_info "CA-signed certificates installed successfully"
}

generate_self_signed_certificate() {
    local domain="$1"

    log_info "Generating self-signed certificate for domain: $domain"

    # Method 1: Use prosodyctl cert generate (preferred)
    log_info "Using prosodyctl cert generate..."
    if echo | prosodyctl cert generate "$domain" 2>/dev/null; then
        log_info "Self-signed certificate generated successfully using prosodyctl"
        return 0
    else
        log_warn "prosodyctl cert generate failed, falling back to manual method"
    fi

    # Method 2: Manual generation with OpenSSL
    log_info "Generating certificate manually with OpenSSL..."

    # Create a temporary config file for SAN
    local temp_config
    temp_config=$(mktemp)
    cat >"$temp_config" <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = $domain

[v3_req]
basicConstraints = CA:FALSE
keyUsage = keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $domain
DNS.2 = *.$domain
DNS.3 = conference.$domain
DNS.4 = upload.$domain
DNS.5 = proxy.$domain
EOF

    # Generate certificate and key
    openssl req -x509 -newkey rsa:4096 \
        -keyout "${CERT_DIR}/${domain}.key" \
        -out "${CERT_DIR}/${domain}.crt" \
        -days 365 -nodes \
        -config "$temp_config" \
        -extensions v3_req

    # Clean up temp file
    rm -f "$temp_config"

    log_info "Self-signed certificate generated successfully"
    log_warn "Self-signed certificates should only be used for development/testing"
}

install_from_directory() {
    local domain="$1"
    local source_dir="$2"

    log_info "Installing certificates from directory: $source_dir"

    # Check for Let's Encrypt format first
    if [[ -f "$source_dir/fullchain.pem" ]] && [[ -f "$source_dir/privkey.pem" ]]; then
        install_letsencrypt_certificates "$domain" "$source_dir"
        return 0
    fi

    # Check for standard format
    if [[ -f "$source_dir/${domain}.crt" ]] && [[ -f "$source_dir/${domain}.key" ]]; then
        install_ca_certificates "$domain" "$source_dir/${domain}.crt" "$source_dir/${domain}.key"
        return 0
    fi

    # Check for generic certificate files
    local cert_files key_files
    cert_files=($(find "$source_dir" -name "*.crt" -o -name "*.pem" | grep -v "privkey\|key"))
    key_files=($(find "$source_dir" -name "*.key" -o -name "*privkey*"))

    if [[ ${#cert_files[@]} -eq 1 ]] && [[ ${#key_files[@]} -eq 1 ]]; then
        install_ca_certificates "$domain" "${cert_files[0]}" "${key_files[0]}"
        return 0
    fi

    log_error "Could not determine certificate format in directory: $source_dir"
    return 1
}

# ============================================================================
# PERMISSION AND SECURITY
# ============================================================================

set_certificate_permissions() {
    local domain="$1"

    log_info "Setting proper certificate permissions..."

    # Find all certificate files and set permissions
    find "$CERT_DIR" -name "${domain}.crt" -o -name "fullchain.pem" -path "${CERT_DIR}/${domain}/*" | while read -r cert_file; do
        chmod 644 "$cert_file"
        chown root:prosody "$cert_file" 2>/dev/null || chown prosody:prosody "$cert_file" 2>/dev/null || true
        log_debug "Set permissions for certificate: $cert_file"
    done

    # Find all private key files and set permissions
    find "$CERT_DIR" -name "${domain}.key" -o -name "privkey.pem" -path "${CERT_DIR}/${domain}/*" | while read -r key_file; do
        chmod 640 "$key_file"
        chown root:prosody "$key_file" 2>/dev/null || chown prosody:prosody "$key_file" 2>/dev/null || true
        log_debug "Set permissions for private key: $key_file"
    done

    # Set directory permissions
    chmod 750 "$CERT_DIR" 2>/dev/null || true
    chown root:prosody "$CERT_DIR" 2>/dev/null || chown prosody:prosody "$CERT_DIR" 2>/dev/null || true

    if [[ -d "${CERT_DIR}/${domain}" ]]; then
        chmod 750 "${CERT_DIR}/${domain}" 2>/dev/null || true
        chown root:prosody "${CERT_DIR}/${domain}" 2>/dev/null || chown prosody:prosody "${CERT_DIR}/${domain}" 2>/dev/null || true
    fi

    log_info "Certificate permissions set successfully"
}

validate_installation() {
    local domain="$1"

    log_info "Validating certificate installation..."

    # Check if certificates were created
    local cert_found=false

    if [[ -f "${CERT_DIR}/${domain}.crt" ]] && [[ -f "${CERT_DIR}/${domain}.key" ]]; then
        cert_found=true
        log_info "Standard format certificates found"
    fi

    if [[ -f "${CERT_DIR}/${domain}/fullchain.pem" ]] && [[ -f "${CERT_DIR}/${domain}/privkey.pem" ]]; then
        cert_found=true
        log_info "Let's Encrypt format certificates found"
    fi

    if [[ "$cert_found" == false ]]; then
        log_error "No certificates found after installation"
        return 1
    fi

    # Run prosodyctl certificate check
    if command -v prosodyctl >/dev/null 2>&1; then
        if prosodyctl check certs >/dev/null 2>&1; then
            log_info "Prosody certificate validation: PASSED"
        else
            log_warn "Prosody certificate validation: FAILED"
            prosodyctl check certs 2>&1 | while read -r line; do
                log_debug "$line"
            done
        fi
    fi

    return 0
}

reload_prosody() {
    log_info "Reloading Prosody configuration..."

    if command -v prosodyctl >/dev/null 2>&1; then
        if prosodyctl reload >/dev/null 2>&1; then
            log_info "Prosody reloaded successfully"
        else
            log_warn "Failed to reload Prosody - you may need to restart manually"
            return 1
        fi
    else
        log_warn "prosodyctl not available - please restart Prosody manually"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    local auto_backup=true
    local no_reload=false
    local install_method=""
    local cert_file=""
    local key_file=""
    local le_path=""

    # Parse command line arguments
    local args=()
    while [[ $# -gt 0 ]]; do
        case $1 in
        --letsencrypt)
            install_method="letsencrypt"
            le_path="$2"
            shift 2
            ;;
        --ca-cert)
            cert_file="$2"
            shift 2
            ;;
        --ca-key)
            key_file="$2"
            shift 2
            ;;
        --self-signed)
            install_method="self-signed"
            shift
            ;;
        --backup)
            auto_backup=true
            shift
            ;;
        --no-reload)
            no_reload=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            args+=("$1")
            shift
            ;;
        esac
    done

    # Validate arguments
    if [[ -z "$DOMAIN" ]]; then
        log_error "Domain is required"
        show_usage
        exit 1
    fi

    # Set install method based on arguments
    if [[ -n "$cert_file" ]] && [[ -n "$key_file" ]]; then
        install_method="ca-signed"
    elif [[ -n "$CERT_SOURCE" ]] && [[ -z "$install_method" ]]; then
        install_method="directory"
    elif [[ -z "$install_method" ]]; then
        install_method="self-signed"
    fi

    echo "========================================="
    echo "🔐 Certificate Installation"
    echo "========================================="
    echo "Domain: $DOMAIN"
    echo "Method: $install_method"
    echo "Certificate Directory: $CERT_DIR"
    echo ""

    # Check prerequisites
    check_prerequisites || exit 1

    # Validate domain
    validate_domain "$DOMAIN" || exit 1

    # Backup existing certificates
    if [[ "$auto_backup" == true ]]; then
        backup_existing_certificates "$DOMAIN"
    fi

    # Install certificates based on method
    case "$install_method" in
    "letsencrypt")
        install_letsencrypt_certificates "$DOMAIN" "$le_path" || exit 1
        ;;
    "ca-signed")
        install_ca_certificates "$DOMAIN" "$cert_file" "$key_file" || exit 1
        ;;
    "self-signed")
        generate_self_signed_certificate "$DOMAIN" || exit 1
        ;;
    "directory")
        install_from_directory "$DOMAIN" "$CERT_SOURCE" || exit 1
        ;;
    *)
        log_error "Unknown installation method: $install_method"
        exit 1
        ;;
    esac

    # Set proper permissions
    set_certificate_permissions "$DOMAIN"

    # Validate installation
    validate_installation "$DOMAIN" || exit 1

    # Reload Prosody
    if [[ "$no_reload" == false ]]; then
        reload_prosody
    fi

    echo ""
    echo "========================================="
    log_info "Certificate installation completed successfully!"
    echo "========================================="

    # Show next steps
    echo ""
    echo "Next steps:"
    echo "1. Test XMPP connections to verify certificate is working"
    echo "2. Update DNS records if using a new domain"
    echo "3. Configure certificate renewal if using Let's Encrypt"
    echo "4. Run certificate health check: $(dirname "$0")/check-certificates.sh"
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Validate arguments
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

# Run main function
main "$@"
