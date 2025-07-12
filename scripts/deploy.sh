#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server Deployment Script
# Automated deployment with validation and safety checks

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly CONFIG_DIR="$PROJECT_DIR/config"
readonly DOCKER_DIR="$PROJECT_DIR/docker"

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
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Validate prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    local missing_deps=()

    # Check for required commands
    local required_commands=(
        "docker"
        "docker-compose"
        "openssl"
        "curl"
    )

    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install missing dependencies and try again"
        exit 1
    fi

    # Check Docker daemon
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running or not accessible"
        exit 1
    fi

    log_info "Prerequisites check passed"
}

# Load environment configuration
load_environment() {
    log_info "Loading environment configuration..."

    local env_file="$PROJECT_DIR/.env"

    if [[ ! -f "$env_file" ]]; then
        log_warn "Environment file not found: $env_file"
        log_info "Creating default environment file..."

        if [[ -f "$PROJECT_DIR/examples/env.example" ]]; then
            cp "$PROJECT_DIR/examples/env.example" "$env_file"
            log_warn "Please edit $env_file with your configuration"
            log_warn "Minimum required: PROSODY_DOMAIN and PROSODY_ADMINS"
            return 1
        else
            log_error "Example environment file not found"
            exit 1
        fi
    fi

    # Source environment file
    set -a
    source "$env_file"
    set +a

    log_info "Environment configuration loaded"
}

# Validate environment configuration
validate_environment() {
    log_info "Validating environment configuration..."

    local errors=0

    # Check required variables
    if [[ -z "${PROSODY_DOMAIN:-}" ]]; then
        log_error "PROSODY_DOMAIN is required"
        errors=$((errors + 1))
    fi

    if [[ -z "${PROSODY_ADMINS:-}" ]]; then
        log_error "PROSODY_ADMINS is required"
        errors=$((errors + 1))
    fi

    # Validate domain format
    if [[ -n "${PROSODY_DOMAIN:-}" ]]; then
        if ! [[ "$PROSODY_DOMAIN" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.[a-zA-Z]{2,}$ ]]; then
            log_error "Invalid domain format: $PROSODY_DOMAIN"
            errors=$((errors + 1))
        fi
    fi

    # Validate admin email format
    if [[ -n "${PROSODY_ADMINS:-}" ]]; then
        IFS=',' read -ra ADMIN_ARRAY <<<"$PROSODY_ADMINS"
        for admin in "${ADMIN_ARRAY[@]}"; do
            admin=$(echo "$admin" | xargs) # trim whitespace
            if ! [[ "$admin" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                log_error "Invalid admin email format: $admin"
                errors=$((errors + 1))
            fi
        done
    fi

    # Validate storage backend
    if [[ -n "${PROSODY_STORAGE:-}" ]]; then
        case "$PROSODY_STORAGE" in
        sqlite | sql)
            log_debug "Storage backend: $PROSODY_STORAGE"
            ;;
        *)
            log_error "Invalid storage backend: $PROSODY_STORAGE"
            errors=$((errors + 1))
            ;;
        esac
    fi

    # Validate database configuration if using SQL
    if [[ "${PROSODY_STORAGE:-sqlite}" == "sql" ]]; then
        if [[ -z "${PROSODY_DB_PASSWORD:-}" ]]; then
            log_error "PROSODY_DB_PASSWORD is required for SQL storage"
            errors=$((errors + 1))
        fi
    fi

    if [[ $errors -gt 0 ]]; then
        log_error "Environment validation failed with $errors errors"
        exit 1
    fi

    log_info "Environment validation passed"
}

# Setup SSL certificates
setup_ssl_certificates() {
    log_info "Setting up SSL certificates..."

    local cert_dir="$PROJECT_DIR/certs"
    local cert_file="$cert_dir/${PROSODY_DOMAIN}.crt"
    local key_file="$cert_dir/${PROSODY_DOMAIN}.key"

    # Create certificates directory
    mkdir -p "$cert_dir"

    # Check if certificates exist
    if [[ ! -f "$cert_file" ]] || [[ ! -f "$key_file" ]]; then
        log_warn "SSL certificates not found, generating self-signed certificates..."

        # Generate self-signed certificate
        openssl req -x509 -newkey rsa:4096 -keyout "$key_file" -out "$cert_file" \
            -days 365 -nodes -subj "/CN=${PROSODY_DOMAIN}" \
            -addext "subjectAltName=DNS:${PROSODY_DOMAIN},DNS:*.${PROSODY_DOMAIN}" \
            2>/dev/null

        log_warn "Self-signed certificates generated"
        log_warn "For production, please replace with proper certificates from Let's Encrypt or a CA"
    else
        log_info "SSL certificates found"

        # Check certificate validity
        if ! openssl x509 -in "$cert_file" -noout -checkend 86400 >/dev/null 2>&1; then
            log_warn "SSL certificate expires within 24 hours"
        fi
    fi

    # Set proper permissions
    chmod 600 "$key_file"
    chmod 644 "$cert_file"
}

# Build Docker images
build_images() {
    log_info "Building Docker images..."

    cd "$PROJECT_DIR"

    # Build main prosody image
    docker build -f docker/Dockerfile -t professional-prosody:latest .

    log_info "Docker images built successfully"
}

# Deploy services
deploy_services() {
    log_info "Deploying services..."

    cd "$PROJECT_DIR"

    # Determine compose files to use
    local compose_files=("-f" "docker/docker-compose.yml")

    # Add profile-specific compose files
    if [[ -n "${COMPOSE_PROFILES:-}" ]]; then
        IFS=',' read -ra PROFILE_ARRAY <<<"$COMPOSE_PROFILES"
        for profile in "${PROFILE_ARRAY[@]}"; do
            profile=$(echo "$profile" | xargs) # trim whitespace
            local profile_file="docker/docker-compose.${profile}.yml"
            if [[ -f "$profile_file" ]]; then
                compose_files+=("-f" "$profile_file")
            else
                log_warn "Profile compose file not found: $profile_file"
            fi
        done
    fi

    # Deploy services
    docker-compose "${compose_files[@]}" up -d

    log_info "Services deployed successfully"
}

# Wait for services to be ready
wait_for_services() {
    log_info "Waiting for services to be ready..."

    local max_attempts=30
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        if docker-compose ps | grep -q "Up"; then
            log_info "Services are starting up..."
            break
        fi

        attempt=$((attempt + 1))
        sleep 2
    done

    # Wait for health checks
    log_info "Waiting for health checks to pass..."
    sleep 30

    # Check service health
    if docker-compose ps | grep -q "unhealthy"; then
        log_error "Some services are unhealthy"
        docker-compose ps
        return 1
    fi

    log_info "Services are ready"
}

# Run post-deployment tasks
post_deployment_tasks() {
    log_info "Running post-deployment tasks..."

    # Create admin users
    log_info "Creating admin users..."
    IFS=',' read -ra ADMIN_ARRAY <<<"$PROSODY_ADMINS"
    for admin in "${ADMIN_ARRAY[@]}"; do
        admin=$(echo "$admin" | xargs) # trim whitespace
        log_info "Creating admin user: $admin"

        # Use docker-compose exec to create user
        docker-compose exec -T prosody prosodyctl adduser "$admin" || true
    done

    log_info "Post-deployment tasks completed"
}

# Display deployment summary
display_summary() {
    log_info "Deployment Summary"
    echo "===================="
    echo "Domain: $PROSODY_DOMAIN"
    echo "Admins: $PROSODY_ADMINS"
    echo "Storage: ${PROSODY_STORAGE:-sqlite}"
    echo "Security: ${PROSODY_ENABLE_SECURITY:-true}"
    echo "Modern Features: ${PROSODY_ENABLE_MODERN:-true}"
    echo "HTTP Services: ${PROSODY_ENABLE_HTTP:-false}"
    echo ""
    echo "Services:"
    docker-compose ps
    echo ""
    echo "XMPP Ports:"
    echo "  Client (C2S): ${PROSODY_C2S_PORT:-5222}"
    echo "  Server (S2S): ${PROSODY_S2S_PORT:-5269}"
    if [[ "${PROSODY_ENABLE_HTTP:-false}" == "true" ]]; then
        echo "  HTTP: ${PROSODY_HTTP_PORT:-5280}"
        echo "  HTTPS: ${PROSODY_HTTPS_PORT:-5281}"
    fi
    echo ""
    echo "Next Steps:"
    echo "1. Configure your DNS to point to this server"
    echo "2. Set up proper SSL certificates (Let's Encrypt recommended)"
    echo "3. Configure firewall rules to allow XMPP ports"
    echo "4. Test connectivity with an XMPP client"
    echo "5. Monitor logs: docker-compose logs -f prosody"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    # Add any cleanup tasks here
}

# ============================================================================
# MAIN DEPLOYMENT FUNCTION
# ============================================================================

main() {
    log_info "Starting Professional Prosody XMPP Server deployment..."

    # Setup cleanup trap
    trap cleanup EXIT

    # Pre-deployment checks
    check_root
    check_prerequisites

    # Load and validate configuration
    if ! load_environment; then
        log_error "Please configure the environment file and run again"
        exit 1
    fi

    validate_environment

    # Setup SSL certificates
    setup_ssl_certificates

    # Build and deploy
    build_images
    deploy_services

    # Wait for services and run post-deployment tasks
    wait_for_services
    post_deployment_tasks

    # Display summary
    display_summary

    log_info "Deployment completed successfully!"
    log_info "Your Prosody XMPP server is now running at $PROSODY_DOMAIN"
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --debug)
        DEBUG=true
        shift
        ;;
    --help)
        echo "Usage: $0 [--debug] [--help]"
        echo ""
        echo "Options:"
        echo "  --debug    Enable debug output"
        echo "  --help     Show this help message"
        exit 0
        ;;
    *)
        log_error "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Run main function
main "$@"
