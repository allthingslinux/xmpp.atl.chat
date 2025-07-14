#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server - Initial Setup Script
# Automates all setup steps for a fresh repository clone

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_DIR
readonly ENV_FILE="$PROJECT_DIR/.env"
readonly CLOUDFLARE_CREDS="$PROJECT_DIR/cloudflare-credentials.ini"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ============================================================================
# UTILITY FUNCTIONS
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

log_step() {
    echo -e "${BLUE}${BOLD}[STEP]${NC} $1"
}

prompt_user() {
    local prompt="$1"
    local default="${2:-}"
    local response

    if [[ -n "$default" ]]; then
        read -r -p "$prompt [$default]: " response
        echo "${response:-$default}"
    else
        read -r -p "$prompt: " response
        echo "$response"
    fi
}

prompt_password() {
    local prompt="$1"
    local response

    read -r -s -p "$prompt: " response
    echo
    # Trim leading/trailing whitespace
    response=$(echo "$response" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    echo "$response"
}

check_dependencies() {
    log_step "Checking dependencies..."

    local missing_deps=()

    # Check for required tools
    if ! command -v docker >/dev/null 2>&1; then
        missing_deps+=("docker")
    fi

    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        missing_deps+=("docker-compose")
    fi

    if ! command -v openssl >/dev/null 2>&1; then
        missing_deps+=("openssl")
    fi

    if ! command -v hg >/dev/null 2>&1; then
        missing_deps+=("mercurial")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install them and run this script again."
        exit 1
    fi

    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi

    log_info "All dependencies are available ✓"
}

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

setup_environment() {
    log_step "Setting up environment configuration..."

    if [[ -f "$ENV_FILE" ]]; then
        log_warn "Environment file already exists: $ENV_FILE"
        if ! prompt_user "Do you want to reconfigure it? (y/N)" "n" | grep -qi "^y"; then
            log_info "Skipping environment setup"
            return 0
        fi
    fi

    # Copy example file
    cp "$PROJECT_DIR/examples/env.example" "$ENV_FILE"

    # Gather configuration
    echo
    log_info "Please provide the following configuration:"

    local domain
    domain=$(prompt_user "Your XMPP domain (e.g., example.com)" "atl.chat")

    local admin_email
    admin_email=$(prompt_user "Administrator email for certificates" "admin@allthingslinux.org")

    local admin_jid
    admin_jid=$(prompt_user "Administrator JID" "admin@$domain")

    local db_password
    db_password=$(prompt_password "Database password (will be generated if empty)")
    if [[ -z "$db_password" ]]; then
        db_password=$(openssl rand -base64 32)
        log_info "Generated database password: $db_password"
    fi

    # Update .env file (using awk to safely handle any characters)
    awk -v domain="$domain" -v email="$admin_email" -v jid="$admin_jid" -v password="$db_password" '
        /^PROSODY_DOMAIN=/ { print "PROSODY_DOMAIN=" domain; next }
        /^LETSENCRYPT_EMAIL=/ { print "LETSENCRYPT_EMAIL=" email; next }
        /^PROSODY_ADMINS=/ { print "PROSODY_ADMINS=" jid; next }
        /^PROSODY_DB_PASSWORD=/ { print "PROSODY_DB_PASSWORD=" password; next }
        { print }
    ' "$ENV_FILE" >"$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"

    log_info "Environment configuration saved to $ENV_FILE ✓"
}

setup_cloudflare() {
    log_step "Setting up Cloudflare DNS credentials..."

    if [[ -f "$CLOUDFLARE_CREDS" ]]; then
        log_warn "Cloudflare credentials file already exists: $CLOUDFLARE_CREDS"
        if ! prompt_user "Do you want to reconfigure it? (y/N)" "n" | grep -qi "^y"; then
            log_info "Skipping Cloudflare setup"
            return 0
        fi
    fi

    # Copy example file
    cp "$PROJECT_DIR/examples/cloudflare-credentials.ini.example" "$CLOUDFLARE_CREDS"

    echo
    log_info "Cloudflare API Token Setup:"
    log_info "1. Go to https://dash.cloudflare.com/profile/api-tokens"
    log_info "2. Create a token with permissions: Zone:Zone:Read, Zone:DNS:Edit"
    log_info "3. Enter the token below"
    echo

    local cf_token
    cf_token=$(prompt_password "Cloudflare API Token")

    # Trim whitespace from token
    cf_token=$(echo "$cf_token" | tr -d '[:space:]')

    # Update credentials file (using awk to safely handle any characters)
    awk -v token="$cf_token" '
        /^dns_cloudflare_api_token = / { print "dns_cloudflare_api_token = " token; next }
        { print }
    ' "$CLOUDFLARE_CREDS" >"$CLOUDFLARE_CREDS.tmp" && mv "$CLOUDFLARE_CREDS.tmp" "$CLOUDFLARE_CREDS"

    # Secure the credentials file
    chmod 600 "$CLOUDFLARE_CREDS"

    log_info "Cloudflare credentials configured ✓"
}

generate_certificates() {
    log_step "Generating SSL certificates..."

    # Check if certificates already exist
    local domain
    domain=$(grep "^PROSODY_DOMAIN=" "$ENV_FILE" | cut -d'=' -f2)

    if [[ -f "$PROJECT_DIR/certs/live/$domain/fullchain.pem" ]]; then
        log_warn "Certificates already exist for $domain"
        if ! prompt_user "Do you want to regenerate them? (y/N)" "n" | grep -qi "^y"; then
            log_info "Skipping certificate generation"
            return 0
        fi
    fi

    log_info "Generating wildcard certificate for *.$domain..."
    log_info "This may take a few minutes..."

    cd "$PROJECT_DIR"

    if docker compose --profile letsencrypt run --rm xmpp-certbot; then
        log_info "SSL certificates generated successfully ✓"
    else
        log_error "Certificate generation failed"
        log_error "Please check your Cloudflare credentials and domain configuration"
        exit 1
    fi
}

setup_directories() {
    log_step "Creating required directories..."

    # Create directories that might not exist
    mkdir -p "$PROJECT_DIR/logs"
    mkdir -p "$PROJECT_DIR/certs"

    # Set proper permissions
    chmod 755 "$PROJECT_DIR/logs"
    chmod 755 "$PROJECT_DIR/certs"

    log_info "Directories created ✓"
}

setup_cron() {
    log_step "Setting up automatic certificate renewal..."

    local cron_job="0 3 * * * $PROJECT_DIR/scripts/renew-certificates.sh"

    if crontab -l 2>/dev/null | grep -q "renew-certificates.sh"; then
        log_warn "Certificate renewal cron job already exists"
        if ! prompt_user "Do you want to update it? (y/N)" "n" | grep -qi "^y"; then
            log_info "Skipping cron setup"
            return 0
        fi

        # Remove existing job
        crontab -l 2>/dev/null | grep -v "renew-certificates.sh" | crontab -
    fi

    # Add new job
    (
        crontab -l 2>/dev/null
        echo "$cron_job"
    ) | crontab -

    log_info "Certificate renewal cron job added (runs daily at 3 AM) ✓"
}

start_services() {
    log_step "Starting XMPP services..."

    cd "$PROJECT_DIR"

    log_info "Starting Prosody and database..."
    if docker compose up -d xmpp-prosody xmpp-postgres; then
        log_info "Services started successfully ✓"

        # Wait a moment for services to start
        sleep 5

        # Check service status
        if docker compose ps | grep -q "Up"; then
            log_info "Services are running:"
            docker compose ps
        else
            log_warn "Some services may not be running properly"
            log_warn "Check logs with: docker compose logs"
        fi
    else
        log_error "Failed to start services"
        exit 1
    fi
}

create_admin_user() {
    log_step "Creating administrator user..."

    local admin_jid
    admin_jid=$(grep "^PROSODY_ADMINS=" "$ENV_FILE" | cut -d'=' -f2)

    echo
    log_info "Creating admin user: $admin_jid"
    log_info "Please enter a password for the administrator account:"

    if docker compose exec xmpp-prosody prosodyctl adduser "$admin_jid"; then
        log_info "Administrator user created successfully ✓"
    else
        log_error "Failed to create administrator user"
        log_error "You can create it manually later with:"
        log_error "docker compose exec xmpp-prosody prosodyctl adduser $admin_jid"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

show_banner() {
    echo
    echo -e "${BLUE}${BOLD}============================================${NC}"
    echo -e "${BLUE}${BOLD}  Professional Prosody XMPP Server Setup  ${NC}"
    echo -e "${BLUE}${BOLD}============================================${NC}"
    echo
    echo -e "${GREEN}This script will help you set up a production-ready XMPP server${NC}"
    echo -e "${GREEN}with wildcard SSL certificates and automated renewal.${NC}"
    echo
}

show_completion() {
    echo
    echo -e "${GREEN}${BOLD}============================================${NC}"
    echo -e "${GREEN}${BOLD}           Setup Complete! 🎉            ${NC}"
    echo -e "${GREEN}${BOLD}============================================${NC}"
    echo
    echo -e "${GREEN}Your XMPP server is now running and ready to use!${NC}"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Configure your DNS records (see docs/admin/dns-setup.md)"
    echo "2. Test your server with an XMPP client"
    echo "3. Check logs: docker compose logs"
    echo "4. Monitor services: docker compose ps"
    echo
    echo -e "${YELLOW}Useful commands:${NC}"
    echo "• View logs: docker compose logs -f prosody"
    echo "• Restart services: docker compose restart"
    echo "• Add users: docker compose exec xmpp-prosody prosodyctl adduser user@domain"
    echo "• Renew certificates: ./scripts/renew-certificates.sh"
    echo
    echo -e "${BLUE}Documentation: docs/README.md${NC}"
    echo -e "${BLUE}Support: https://github.com/allthingslinux/xmpp.atl.chat${NC}"
    echo
}

main() {
    show_banner

    # Change to project directory
    cd "$PROJECT_DIR"

    # Run setup steps
    check_dependencies
    setup_directories
    setup_environment
    setup_cloudflare
    generate_certificates
    setup_cron
    start_services
    create_admin_user

    show_completion
}

# Show usage if help requested
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat <<EOF
Professional Prosody XMPP Server - Initial Setup Script

USAGE:
    $0

DESCRIPTION:
    Automates the complete setup process for a fresh repository clone.
    This script will guide you through:
    
    1. Environment configuration (.env file)
    2. Cloudflare API credentials setup
    3. SSL certificate generation
    4. Automatic renewal setup (cron)
    5. Service startup
    6. Administrator user creation

 REQUIREMENTS:
     - Docker and Docker Compose installed
     - OpenSSL for certificate operations
     - Mercurial (hg) for version control operations
     - Cloudflare account with API access
     - Domain name configured in Cloudflare

WHAT IT CREATES:
    - .env file with your configuration
    - cloudflare-credentials.ini with API token
    - SSL certificates in certs/ directory
    - Cron job for automatic renewal
    - Running Prosody and database services

EOF
    exit 0
fi

# Run main function
main "$@"
