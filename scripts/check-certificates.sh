#!/bin/bash
set -euo pipefail

# Certificate Health Check Script for Prosody XMPP Server
# Validates certificates, permissions, and expiry dates

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

readonly CERT_DIR="/etc/prosody/certs"
readonly DOMAIN="${PROSODY_DOMAIN:-localhost}"
readonly WARNING_DAYS=30
readonly CRITICAL_DAYS=7

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
# CERTIFICATE VALIDATION FUNCTIONS
# ============================================================================

check_certificate_exists() {
    local domain="$1"
    local cert_found=false

    # Check for standard certificate format
    if [[ -f "${CERT_DIR}/${domain}.crt" ]] && [[ -f "${CERT_DIR}/${domain}.key" ]]; then
        log_info "Standard certificate found: ${CERT_DIR}/${domain}.crt"
        echo "${CERT_DIR}/${domain}.crt"
        cert_found=true
        return 0
    fi

    # Check for Let's Encrypt format
    if [[ -f "${CERT_DIR}/${domain}/fullchain.pem" ]] && [[ -f "${CERT_DIR}/${domain}/privkey.pem" ]]; then
        log_info "Let's Encrypt certificate found: ${CERT_DIR}/${domain}/fullchain.pem"
        echo "${CERT_DIR}/${domain}/fullchain.pem"
        cert_found=true
        return 0
    fi

    if [[ "$cert_found" == false ]]; then
        log_error "No certificate found for domain: $domain"
        return 1
    fi
}

check_certificate_expiry() {
    local cert_file="$1"
    local domain="$2"

    # Check if certificate expires within warning period
    if openssl x509 -in "$cert_file" -noout -checkend $((WARNING_DAYS * 86400)) >/dev/null 2>&1; then
        log_info "Certificate valid for >$WARNING_DAYS days"
    else
        # Check if it's critical (expires within 7 days)
        if openssl x509 -in "$cert_file" -noout -checkend $((CRITICAL_DAYS * 86400)) >/dev/null 2>&1; then
            log_warn "Certificate expires within $WARNING_DAYS days"
        else
            log_error "Certificate expires within $CRITICAL_DAYS days - CRITICAL!"
            return 1
        fi
    fi

    # Show exact expiry date
    local expiry_date
    expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
    log_debug "Certificate expires: $expiry_date"
}

check_certificate_domain() {
    local cert_file="$1"
    local domain="$2"

    # Check subject
    local subject
    subject=$(openssl x509 -in "$cert_file" -noout -subject)
    if echo "$subject" | grep -q "CN=$domain"; then
        log_info "Certificate subject matches domain"
    else
        log_warn "Certificate subject may not match domain"
        log_debug "Subject: $subject"
    fi

    # Check Subject Alternative Names (SAN)
    local san
    san=$(openssl x509 -in "$cert_file" -noout -text | grep -A 1 "Subject Alternative Name" | tail -1 || true)
    if [[ -n "$san" ]] && echo "$san" | grep -q "$domain"; then
        log_info "Certificate SAN includes domain"
        log_debug "SAN: $san"
    elif [[ -n "$san" ]]; then
        log_warn "Certificate SAN may not include domain"
        log_debug "SAN: $san"
    fi
}

check_private_key() {
    local domain="$1"
    local key_found=false
    local key_file=""

    # Check for standard key format
    if [[ -f "${CERT_DIR}/${domain}.key" ]]; then
        key_file="${CERT_DIR}/${domain}.key"
        key_found=true
    elif [[ -f "${CERT_DIR}/${domain}/privkey.pem" ]]; then
        key_file="${CERT_DIR}/${domain}/privkey.pem"
        key_found=true
    fi

    if [[ "$key_found" == false ]]; then
        log_error "No private key found for domain: $domain"
        return 1
    fi

    log_info "Private key found: $key_file"

    # Check permissions
    local perms
    perms=$(stat -c %a "$key_file")
    if [[ "$perms" == "640" ]] || [[ "$perms" == "600" ]]; then
        log_info "Private key permissions correct ($perms)"
    else
        log_warn "Private key permissions should be 640 or 600 (current: $perms)"
    fi

    # Check ownership
    local owner
    owner=$(stat -c %U:%G "$key_file")
    if [[ "$owner" == "root:prosody" ]] || [[ "$owner" == "prosody:prosody" ]]; then
        log_info "Private key ownership correct ($owner)"
    else
        log_warn "Private key ownership should be root:prosody or prosody:prosody (current: $owner)"
    fi

    echo "$key_file"
}

check_certificate_key_match() {
    local cert_file="$1"
    local key_file="$2"

    # Extract modulus from certificate and key
    local cert_modulus key_modulus
    cert_modulus=$(openssl x509 -noout -modulus -in "$cert_file" 2>/dev/null | openssl md5)
    key_modulus=$(openssl rsa -noout -modulus -in "$key_file" 2>/dev/null | openssl md5)

    if [[ "$cert_modulus" == "$key_modulus" ]]; then
        log_info "Certificate and private key match"
    else
        log_error "Certificate and private key do not match!"
        return 1
    fi
}

check_certificate_chain() {
    local cert_file="$1"

    # Verify certificate chain
    if openssl verify -CApath /etc/ssl/certs "$cert_file" >/dev/null 2>&1; then
        log_info "Certificate chain validation: PASSED"
    else
        log_warn "Certificate chain validation: FAILED (may be self-signed or missing intermediate)"
    fi

    # Check if it's self-signed
    local issuer subject
    issuer=$(openssl x509 -in "$cert_file" -noout -issuer | cut -d= -f2-)
    subject=$(openssl x509 -in "$cert_file" -noout -subject | cut -d= -f2-)

    if [[ "$issuer" == "$subject" ]]; then
        log_warn "Certificate is self-signed"
    else
        log_info "Certificate is CA-signed"
        log_debug "Issuer: $issuer"
    fi
}

check_certificate_algorithms() {
    local cert_file="$1"

    # Check signature algorithm
    local sig_alg
    sig_alg=$(openssl x509 -in "$cert_file" -noout -text | grep "Signature Algorithm" | head -1 | awk '{print $3}')

    case "$sig_alg" in
    sha256WithRSAEncryption | sha384WithRSAEncryption | sha512WithRSAEncryption)
        log_info "Certificate signature algorithm: $sig_alg (secure)"
        ;;
    sha1WithRSAEncryption)
        log_warn "Certificate uses SHA-1 signature (deprecated)"
        ;;
    *)
        log_debug "Certificate signature algorithm: $sig_alg"
        ;;
    esac

    # Check key size
    local key_size
    key_size=$(openssl x509 -in "$cert_file" -noout -text | grep "Public-Key:" | awk '{print $2}' | tr -d '()')

    if [[ -n "$key_size" ]]; then
        local key_bits="${key_size%bit*}"
        if [[ "$key_bits" -ge 2048 ]]; then
            log_info "Certificate key size: $key_size (secure)"
        else
            log_warn "Certificate key size: $key_size (should be ≥2048 bits)"
        fi
    fi
}

# ============================================================================
# PROSODY INTEGRATION
# ============================================================================

check_prosody_certificate_config() {
    log_info "Running Prosody certificate check..."

    if command -v prosodyctl >/dev/null 2>&1; then
        if prosodyctl check certs >/dev/null 2>&1; then
            log_info "Prosody certificate check: PASSED"
        else
            log_warn "Prosody certificate check: FAILED"
            # Show detailed output
            prosodyctl check certs 2>&1 | while read -r line; do
                log_debug "$line"
            done
        fi
    else
        log_warn "prosodyctl not available - skipping Prosody certificate check"
    fi
}

test_certificate_permissions() {
    local cert_file="$1"
    local key_file="$2"

    # Test if prosody user can read certificates
    if sudo -u prosody cat "$cert_file" >/dev/null 2>&1; then
        log_info "Prosody user can read certificate"
    else
        log_error "Prosody user cannot read certificate"
    fi

    if sudo -u prosody cat "$key_file" >/dev/null 2>&1; then
        log_info "Prosody user can read private key"
    else
        log_error "Prosody user cannot read private key"
    fi

    # Test that nobody user cannot read private key
    if ! sudo -u nobody cat "$key_file" >/dev/null 2>&1; then
        log_info "Private key properly secured (nobody cannot read)"
    else
        log_error "Private key is not properly secured (world readable)"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    local exit_code=0

    echo "========================================="
    echo "🔐 Certificate Health Check"
    echo "========================================="
    echo "Domain: $DOMAIN"
    echo "Certificate Directory: $CERT_DIR"
    echo ""

    # Check if certificate directory exists
    if [[ ! -d "$CERT_DIR" ]]; then
        log_error "Certificate directory does not exist: $CERT_DIR"
        exit 1
    fi

    # Find and validate certificate
    local cert_file
    if cert_file=$(check_certificate_exists "$DOMAIN"); then
        echo ""
        echo "📄 Certificate Validation"
        echo "-------------------------"

        # Basic certificate checks
        check_certificate_expiry "$cert_file" "$DOMAIN" || exit_code=1
        check_certificate_domain "$cert_file" "$DOMAIN"
        check_certificate_algorithms "$cert_file"
        check_certificate_chain "$cert_file"

        # Find and validate private key
        echo ""
        echo "🔑 Private Key Validation"
        echo "-------------------------"

        local key_file
        if key_file=$(check_private_key "$DOMAIN"); then
            check_certificate_key_match "$cert_file" "$key_file" || exit_code=1

            echo ""
            echo "🔒 Permission Validation"
            echo "------------------------"
            test_certificate_permissions "$cert_file" "$key_file" || exit_code=1
        else
            exit_code=1
        fi

    else
        exit_code=1
    fi

    # Prosody-specific checks
    echo ""
    echo "🚀 Prosody Integration"
    echo "----------------------"
    check_prosody_certificate_config

    # Summary
    echo ""
    echo "========================================="
    if [[ $exit_code -eq 0 ]]; then
        log_info "Certificate health check completed successfully"
    else
        log_error "Certificate health check completed with issues"
    fi
    echo "========================================="

    exit $exit_code
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    -d | --domain)
        DOMAIN="$2"
        shift 2
        ;;
    -c | --cert-dir)
        CERT_DIR="$2"
        shift 2
        ;;
    -h | --help)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -d, --domain DOMAIN     Domain to check (default: \$PROSODY_DOMAIN or localhost)"
        echo "  -c, --cert-dir DIR      Certificate directory (default: /etc/prosody/certs)"
        echo "  -h, --help              Show this help message"
        echo ""
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Run main function
main "$@"
