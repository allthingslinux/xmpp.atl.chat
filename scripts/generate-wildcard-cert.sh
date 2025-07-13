#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server - Wildcard Certificate Generator
# Generates Let's Encrypt wildcard certificates for *.atl.chat and atl.chat

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly DOMAIN="${PROSODY_DOMAIN:-atl.chat}"
readonly CERT_DIR="${PROSODY_CERT_DIR:-/etc/prosody/certs}"
readonly LETSENCRYPT_DIR="/etc/letsencrypt"
readonly PROSODY_USER="${PROSODY_USER:-prosody}"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
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

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

show_help() {
    cat <<EOF
${BOLD}Professional Prosody XMPP Server - Wildcard Certificate Generator${NC}

${BOLD}USAGE:${NC}
    $SCRIPT_NAME [OPTIONS] COMMAND

${BOLD}COMMANDS:${NC}
    create          Generate new wildcard certificate
    renew           Renew existing wildcard certificate
    install         Install certificate to Prosody directory
    check           Check certificate validity
    help            Show this help message

${BOLD}OPTIONS:${NC}
    -d, --domain DOMAIN     Domain for certificate (default: atl.chat)
    -c, --cert-dir DIR      Certificate directory (default: /etc/prosody/certs)
    -e, --email EMAIL       Email for Let's Encrypt registration
    -p, --dns-provider PROVIDER  DNS provider for validation (cloudflare, route53, etc.)
    -t, --test              Use Let's Encrypt staging environment
    -f, --force             Force certificate creation even if valid cert exists
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

${BOLD}EXAMPLES:${NC}
    # Create wildcard certificate with manual DNS validation
    $SCRIPT_NAME create -e admin@atl.chat

    # Create certificate with Cloudflare DNS provider
    $SCRIPT_NAME create -e admin@atl.chat -p cloudflare

    # Renew existing certificate
    $SCRIPT_NAME renew

    # Check certificate validity
    $SCRIPT_NAME check

    # Install certificate to Prosody directory
    $SCRIPT_NAME install

${BOLD}DNS PROVIDERS:${NC}
    cloudflare      Cloudflare DNS (requires API token)
    route53         AWS Route53 (requires AWS credentials)
    digitalocean    DigitalOcean DNS (requires API token)
    manual          Manual DNS validation (default)

${BOLD}ENVIRONMENT VARIABLES:${NC}
    PROSODY_DOMAIN          Domain for certificate (default: atl.chat)
    PROSODY_CERT_DIR        Certificate directory (default: /etc/prosody/certs)
    PROSODY_USER            Prosody user (default: prosody)
    CERTBOT_EMAIL           Email for Let's Encrypt registration
    CLOUDFLARE_API_TOKEN    Cloudflare API token (for cloudflare provider)
    AWS_ACCESS_KEY_ID       AWS access key (for route53 provider)
    AWS_SECRET_ACCESS_KEY   AWS secret key (for route53 provider)
    DO_API_TOKEN            DigitalOcean API token (for digitalocean provider)

${BOLD}NOTES:${NC}
    - Wildcard certificates require DNS validation
    - Manual DNS validation requires adding TXT records during the process
    - Automatic DNS validation requires API credentials for your DNS provider
    - Certificates are valid for both *.atl.chat and atl.chat domains
    - Generated certificates work for: atl.chat, muc.atl.chat, upload.atl.chat, etc.

EOF
}

check_requirements() {
    log_step "Checking requirements..."

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi

    # Check if certbot is installed
    if ! command -v certbot >/dev/null 2>&1; then
        log_error "certbot is not installed"
        log_info "Install with: apt-get install certbot (Ubuntu/Debian) or yum install certbot (CentOS/RHEL)"
        exit 1
    fi

    # Check if domain is valid
    if [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        log_error "Invalid domain format: $DOMAIN"
        exit 1
    fi

    # Create certificate directory if it doesn't exist
    if [[ ! -d "$CERT_DIR" ]]; then
        log_info "Creating certificate directory: $CERT_DIR"
        mkdir -p "$CERT_DIR"
    fi

    log_success "Requirements check passed"
}

check_dns_provider() {
    local provider="$1"

    case "$provider" in
    cloudflare)
        if ! python3 -c "import certbot_dns_cloudflare" 2>/dev/null; then
            log_error "Cloudflare DNS plugin not installed"
            log_info "Install with: pip3 install certbot-dns-cloudflare"
            exit 1
        fi
        if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
            log_error "CLOUDFLARE_API_TOKEN environment variable is required"
            exit 1
        fi
        ;;
    route53)
        if ! python3 -c "import certbot_dns_route53" 2>/dev/null; then
            log_error "Route53 DNS plugin not installed"
            log_info "Install with: pip3 install certbot-dns-route53"
            exit 1
        fi
        if [[ -z "${AWS_ACCESS_KEY_ID:-}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
            log_error "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables are required"
            exit 1
        fi
        ;;
    digitalocean)
        if ! python3 -c "import certbot_dns_digitalocean" 2>/dev/null; then
            log_error "DigitalOcean DNS plugin not installed"
            log_info "Install with: pip3 install certbot-dns-digitalocean"
            exit 1
        fi
        if [[ -z "${DO_API_TOKEN:-}" ]]; then
            log_error "DO_API_TOKEN environment variable is required"
            exit 1
        fi
        ;;
    manual)
        log_info "Using manual DNS validation"
        ;;
    *)
        log_error "Unsupported DNS provider: $provider"
        log_info "Supported providers: cloudflare, route53, digitalocean, manual"
        exit 1
        ;;
    esac
}

create_dns_credentials() {
    local provider="$1"
    local creds_file="/tmp/dns-credentials-$$"

    case "$provider" in
    cloudflare)
        cat >"$creds_file" <<EOF
dns_cloudflare_api_token = ${CLOUDFLARE_API_TOKEN}
EOF
        ;;
    digitalocean)
        cat >"$creds_file" <<EOF
dns_digitalocean_token = ${DO_API_TOKEN}
EOF
        ;;
    esac

    chmod 600 "$creds_file"
    echo "$creds_file"
}

create_certificate() {
    local email="$1"
    local dns_provider="$2"
    local test_mode="$3"
    local force="$4"

    log_step "Creating wildcard certificate for *.$DOMAIN and $DOMAIN"

    # Check if certificate already exists and is valid
    if [[ "$force" != "true" ]]; then
        if certificate_exists && certificate_valid; then
            log_warn "Valid certificate already exists for $DOMAIN"
            log_info "Use --force to recreate certificate"
            return 0
        fi
    fi

    # Build certbot command
    local certbot_cmd="certbot certonly"
    local staging_flag=""

    if [[ "$test_mode" == "true" ]]; then
        staging_flag="--staging"
        log_warn "Using Let's Encrypt staging environment (test mode)"
    fi

    # Configure DNS provider
    case "$dns_provider" in
    manual)
        certbot_cmd="$certbot_cmd --manual --preferred-challenges dns"
        ;;
    cloudflare)
        local creds_file
        creds_file=$(create_dns_credentials cloudflare)
        certbot_cmd="$certbot_cmd --dns-cloudflare --dns-cloudflare-credentials $creds_file"
        ;;
    route53)
        certbot_cmd="$certbot_cmd --dns-route53"
        ;;
    digitalocean)
        local creds_file
        creds_file=$(create_dns_credentials digitalocean)
        certbot_cmd="$certbot_cmd --dns-digitalocean --dns-digitalocean-credentials $creds_file"
        ;;
    esac

    # Add common parameters
    certbot_cmd="$certbot_cmd $staging_flag --email $email --agree-tos --no-eff-email"
    certbot_cmd="$certbot_cmd -d *.$DOMAIN -d $DOMAIN"

    log_info "Running: $certbot_cmd"

    # Execute certbot
    if eval "$certbot_cmd"; then
        log_success "Certificate created successfully"

        # Clean up credentials file
        if [[ -n "${creds_file:-}" ]] && [[ -f "$creds_file" ]]; then
            rm -f "$creds_file"
        fi

        return 0
    else
        log_error "Certificate creation failed"

        # Clean up credentials file
        if [[ -n "${creds_file:-}" ]] && [[ -f "$creds_file" ]]; then
            rm -f "$creds_file"
        fi

        return 1
    fi
}

renew_certificate() {
    log_step "Renewing wildcard certificate for $DOMAIN"

    if ! certificate_exists; then
        log_error "No certificate found for $DOMAIN"
        log_info "Use 'create' command to generate a new certificate"
        return 1
    fi

    if certbot renew --cert-name "$DOMAIN"; then
        log_success "Certificate renewed successfully"
        return 0
    else
        log_error "Certificate renewal failed"
        return 1
    fi
}

install_certificate() {
    log_step "Installing certificate to Prosody directory"

    if ! certificate_exists; then
        log_error "No certificate found for $DOMAIN"
        log_info "Use 'create' command to generate a certificate first"
        return 1
    fi

    local le_cert_dir="$LETSENCRYPT_DIR/live/$DOMAIN"
    local prosody_cert="$CERT_DIR/$DOMAIN.crt"
    local prosody_key="$CERT_DIR/$DOMAIN.key"

    # Copy certificate files
    log_info "Copying certificate files..."
    cp "$le_cert_dir/fullchain.pem" "$prosody_cert"
    cp "$le_cert_dir/privkey.pem" "$prosody_key"

    # Set proper ownership and permissions
    log_info "Setting permissions..."
    chown "$PROSODY_USER:$PROSODY_USER" "$prosody_cert" "$prosody_key"
    chmod 644 "$prosody_cert"
    chmod 600 "$prosody_key"

    # Create Let's Encrypt directory structure for Prosody auto-discovery
    local prosody_le_dir="$CERT_DIR/$DOMAIN"
    mkdir -p "$prosody_le_dir"
    ln -sf "$le_cert_dir/fullchain.pem" "$prosody_le_dir/fullchain.pem"
    ln -sf "$le_cert_dir/privkey.pem" "$prosody_le_dir/privkey.pem"
    chown -R "$PROSODY_USER:$PROSODY_USER" "$prosody_le_dir"

    log_success "Certificate installed successfully"
    log_info "Certificate files:"
    log_info "  - Certificate: $prosody_cert"
    log_info "  - Private key: $prosody_key"
    log_info "  - Let's Encrypt format: $prosody_le_dir/"

    return 0
}

certificate_exists() {
    [[ -d "$LETSENCRYPT_DIR/live/$DOMAIN" ]]
}

certificate_valid() {
    local cert_file="$LETSENCRYPT_DIR/live/$DOMAIN/fullchain.pem"

    if [[ ! -f "$cert_file" ]]; then
        return 1
    fi

    # Check if certificate expires within 30 days
    if openssl x509 -in "$cert_file" -noout -checkend 2592000 >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_certificate() {
    log_step "Checking certificate validity for $DOMAIN"

    if ! certificate_exists; then
        log_error "No certificate found for $DOMAIN"
        return 1
    fi

    local cert_file="$LETSENCRYPT_DIR/live/$DOMAIN/fullchain.pem"

    # Get certificate information
    local expiry_date
    expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)

    local subject
    subject=$(openssl x509 -in "$cert_file" -noout -subject | cut -d= -f2-)

    local san
    san=$(openssl x509 -in "$cert_file" -noout -text | grep -A1 "Subject Alternative Name" | tail -1 | sed 's/^[[:space:]]*//')

    log_info "Certificate information:"
    log_info "  - Subject: $subject"
    log_info "  - Expires: $expiry_date"
    log_info "  - SAN: $san"

    # Check validity
    if certificate_valid; then
        log_success "Certificate is valid (expires in more than 30 days)"
        return 0
    else
        log_warn "Certificate expires within 30 days or is already expired"
        return 1
    fi
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    local command=""
    local email="${CERTBOT_EMAIL:-}"
    local dns_provider="manual"
    local test_mode="false"
    local force="false"
    local verbose="false"

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
        -e | --email)
            email="$2"
            shift 2
            ;;
        -p | --dns-provider)
            dns_provider="$2"
            shift 2
            ;;
        -t | --test)
            test_mode="true"
            shift
            ;;
        -f | --force)
            force="true"
            shift
            ;;
        -v | --verbose)
            verbose="true"
            shift
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        create | renew | install | check | help)
            command="$1"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        esac
    done

    # Show help if no command provided
    if [[ -z "$command" ]]; then
        show_help
        exit 1
    fi

    # Enable verbose output if requested
    if [[ "$verbose" == "true" ]]; then
        set -x
    fi

    # Check requirements
    check_requirements

    # Execute command
    case "$command" in
    create)
        if [[ -z "$email" ]]; then
            log_error "Email is required for certificate creation"
            log_info "Use -e/--email option or set CERTBOT_EMAIL environment variable"
            exit 1
        fi

        check_dns_provider "$dns_provider"

        if create_certificate "$email" "$dns_provider" "$test_mode" "$force"; then
            log_info "Installing certificate to Prosody directory..."
            install_certificate
        else
            exit 1
        fi
        ;;
    renew)
        if renew_certificate; then
            log_info "Installing renewed certificate to Prosody directory..."
            install_certificate
        else
            exit 1
        fi
        ;;
    install)
        install_certificate
        ;;
    check)
        check_certificate
        ;;
    help)
        show_help
        ;;
    *)
        log_error "Unknown command: $command"
        show_help
        exit 1
        ;;
    esac
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Execute main function with all arguments
main "$@"
