#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server - Development Tools
# Utility functions for development environment testing and management

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_DIR
readonly DEV_COMPOSE_FILE="$PROJECT_DIR/docker-compose.dev.yml"

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

check_dev_environment() {
    if ! docker compose -f "$DEV_COMPOSE_FILE" ps | grep -q "xmpp-prosody-dev"; then
        log_error "Development environment is not running!"
        log_info "Start it with: ./scripts/setup-dev.sh"
        exit 1
    fi
}

# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================

show_status() {
    log_step "Development Environment Status"
    echo

    # Check services
    echo -e "${BLUE}Services Status:${NC}"
    docker compose -f "$DEV_COMPOSE_FILE" ps
    echo

    # Check health
    echo -e "${BLUE}Health Checks:${NC}"
    docker compose -f "$DEV_COMPOSE_FILE" ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"
    echo

    # Check logs for errors
    echo -e "${BLUE}Recent Errors (last 50 lines):${NC}"
    if docker compose -f "$DEV_COMPOSE_FILE" logs --tail=50 | grep -i error || true; then
        echo "No recent errors found ✓"
    fi
}

show_urls() {
    log_step "Development Environment URLs"
    echo
    echo -e "${BLUE}Access URLs:${NC}"
    echo "  🌐 Development Tools:    http://localhost:8081"
    echo "  🔧 Admin Panel (HTTP):   http://localhost:5280/admin"
    echo "  🔒 Admin Panel (HTTPS):  https://localhost:5281/admin"
    echo "  🗄️  Database Admin:       http://localhost:8080"
    echo "  📊 Log Viewer:          http://localhost:8082"
    echo "  📈 Metrics:             http://localhost:5280/metrics"
    echo "  📁 Static Files:        http://localhost:5280/files/"
    echo "  📤 File Upload:         https://localhost:5281/upload"
    echo
    echo -e "${BLUE}XMPP Endpoints:${NC}"
    echo "  📱 C2S (STARTTLS):      localhost:5222"
    echo "  🔒 C2S (Direct TLS):    localhost:5223"
    echo "  🌐 WebSocket:           ws://localhost:5280/xmpp-websocket"
    echo "  🌐 WebSocket (TLS):     wss://localhost:5281/xmpp-websocket"
    echo "  🌐 BOSH:               http://localhost:5280/http-bind"
    echo "  🌐 BOSH (TLS):         https://localhost:5281/http-bind"
    echo
}

test_connectivity() {
    log_step "Testing XMPP Connectivity"

    check_dev_environment

    echo
    echo -e "${BLUE}Testing XMPP Ports:${NC}"

    # Test C2S port
    if timeout 3 bash -c "</dev/tcp/localhost/5222" 2>/dev/null; then
        echo "  ✅ C2S (5222): Reachable"
    else
        echo "  ❌ C2S (5222): Not reachable"
    fi

    # Test C2S Direct TLS port
    if timeout 3 bash -c "</dev/tcp/localhost/5223" 2>/dev/null; then
        echo "  ✅ C2S Direct TLS (5223): Reachable"
    else
        echo "  ❌ C2S Direct TLS (5223): Not reachable"
    fi

    # Test HTTP port
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:5280/admin | grep -q "200\|401"; then
        echo "  ✅ HTTP (5280): Reachable"
    else
        echo "  ❌ HTTP (5280): Not reachable"
    fi

    # Test HTTPS port (ignore cert errors for dev)
    if curl -k -s -o /dev/null -w "%{http_code}" https://localhost:5281/admin | grep -q "200\|401"; then
        echo "  ✅ HTTPS (5281): Reachable"
    else
        echo "  ❌ HTTPS (5281): Not reachable"
    fi

    echo
    echo -e "${BLUE}Testing Development Tools:${NC}"

    # Test Adminer
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200"; then
        echo "  ✅ Database Admin (8080): Available"
    else
        echo "  ❌ Database Admin (8080): Not available"
    fi

    # Test Web Client
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 | grep -q "200"; then
        echo "  ✅ Web Client (8081): Available"
    else
        echo "  ❌ Web Client (8081): Not available"
    fi

    # Test Log Viewer
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8082 | grep -q "200"; then
        echo "  ✅ Log Viewer (8082): Available"
    else
        echo "  ❌ Log Viewer (8082): Not available"
    fi

    echo
}

test_prosody_config() {
    log_step "Testing Prosody Configuration"

    check_dev_environment

    echo
    echo -e "${BLUE}Configuration Check:${NC}"
    docker compose -f "$DEV_COMPOSE_FILE" exec xmpp-prosody-dev prosodyctl check config

    echo
    echo -e "${BLUE}Connectivity Check:${NC}"
    docker compose -f "$DEV_COMPOSE_FILE" exec xmpp-prosody-dev prosodyctl check connectivity localhost

    echo
    echo -e "${BLUE}Module Check:${NC}"
    docker compose -f "$DEV_COMPOSE_FILE" exec xmpp-prosody-dev prosodyctl check modules
}

list_users() {
    log_step "Listing XMPP Users"

    check_dev_environment

    echo
    echo -e "${BLUE}Users on localhost domain:${NC}"
    docker compose -f "$DEV_COMPOSE_FILE" exec xmpp-prosody-dev prosodyctl list users localhost || echo "No users found"
    echo
}

create_user() {
    local username="$1"
    local password="${2:-}"

    log_step "Creating XMPP User: $username@localhost"

    check_dev_environment

    if [[ -z "$password" ]]; then
        docker compose -f "$DEV_COMPOSE_FILE" exec xmpp-prosody-dev prosodyctl adduser "$username@localhost"
    else
        echo "$password" | docker compose -f "$DEV_COMPOSE_FILE" exec -T xmpp-prosody-dev prosodyctl adduser "$username@localhost"
    fi

    log_info "User $username@localhost created successfully ✓"
}

delete_user() {
    local username="$1"

    log_step "Deleting XMPP User: $username@localhost"

    check_dev_environment

    docker compose -f "$DEV_COMPOSE_FILE" exec xmpp-prosody-dev prosodyctl deluser "$username@localhost"

    log_info "User $username@localhost deleted successfully ✓"
}

change_password() {
    local username="$1"

    log_step "Changing Password for: $username@localhost"

    check_dev_environment

    docker compose -f "$DEV_COMPOSE_FILE" exec xmpp-prosody-dev prosodyctl passwd "$username@localhost"

    log_info "Password changed for $username@localhost ✓"
}

show_logs() {
    local service="${1:-}"
    local lines="${2:-50}"

    log_step "Showing Development Environment Logs"

    check_dev_environment

    if [[ -n "$service" ]]; then
        echo -e "${BLUE}Logs for $service (last $lines lines):${NC}"
        docker compose -f "$DEV_COMPOSE_FILE" logs --tail="$lines" -f "$service"
    else
        echo -e "${BLUE}All logs (last $lines lines):${NC}"
        docker compose -f "$DEV_COMPOSE_FILE" logs --tail="$lines" -f
    fi
}

restart_service() {
    local service="${1:-xmpp-prosody-dev}"

    log_step "Restarting Service: $service"

    check_dev_environment

    docker compose -f "$DEV_COMPOSE_FILE" restart "$service"

    log_info "Service $service restarted ✓"
}

cleanup_dev() {
    log_step "Cleaning Up Development Environment"

    echo -e "${YELLOW}This will stop all development containers and optionally remove data${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Stop containers
        docker compose -f "$DEV_COMPOSE_FILE" down

        # Ask about volumes
        read -p "Remove development data volumes? (y/N): " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker volume rm -f xmpp_prosody_data_dev xmpp_prosody_uploads_dev xmpp_postgres_data_dev xmpp_coturn_data_dev xmpp_certs_dev 2>/dev/null || true
            log_info "Development volumes removed ✓"
        fi

        log_info "Development environment cleaned up ✓"
    else
        log_info "Cleanup cancelled"
    fi
}

backup_dev_data() {
    local backup_dir="$PROJECT_DIR/backups/dev-$(date +%Y%m%d-%H%M%S)"

    log_step "Backing Up Development Data"

    check_dev_environment

    mkdir -p "$backup_dir"

    # Backup database
    log_info "Backing up PostgreSQL database..."
    docker compose -f "$DEV_COMPOSE_FILE" exec -T xmpp-postgres-dev pg_dump -U prosody prosody >"$backup_dir/database.sql"

    # Backup Prosody data
    log_info "Backing up Prosody data..."
    docker cp "$(docker compose -f "$DEV_COMPOSE_FILE" ps -q xmpp-prosody-dev):/var/lib/prosody/data" "$backup_dir/prosody-data"

    # Backup uploads
    log_info "Backing up file uploads..."
    docker cp "$(docker compose -f "$DEV_COMPOSE_FILE" ps -q xmpp-prosody-dev):/var/lib/prosody/uploads" "$backup_dir/uploads"

    log_info "Development data backed up to: $backup_dir ✓"
}

run_performance_test() {
    log_step "Running Performance Test"

    check_dev_environment

    echo -e "${BLUE}Testing connection performance...${NC}"

    # Simple connection test
    for i in {1..10}; do
        start_time=$(date +%s%N)
        timeout 5 bash -c "</dev/tcp/localhost/5222" 2>/dev/null
        end_time=$(date +%s%N)
        duration=$(((end_time - start_time) / 1000000))
        echo "  Connection $i: ${duration}ms"
    done

    echo
    echo -e "${BLUE}Memory usage:${NC}"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" $(docker compose -f "$DEV_COMPOSE_FILE" ps -q)
}

# ============================================================================
# HELP AND USAGE
# ============================================================================

show_help() {
    echo -e "${BLUE}${BOLD}Professional Prosody XMPP Server - Development Tools${NC}"
    echo "Utility functions for development environment testing and management"
    echo
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 <command> [arguments]"
    echo
    echo -e "${BLUE}Commands:${NC}"
    echo "  ${BOLD}status${NC}              Show development environment status"
    echo "  ${BOLD}urls${NC}                Show all access URLs"
    echo "  ${BOLD}test${NC}                Test connectivity to all services"
    echo "  ${BOLD}config${NC}              Test Prosody configuration"
    echo "  ${BOLD}users${NC}               List all XMPP users"
    echo "  ${BOLD}adduser${NC} <username> [password]   Create new XMPP user"
    echo "  ${BOLD}deluser${NC} <username>  Delete XMPP user"
    echo "  ${BOLD}passwd${NC} <username>   Change user password"
    echo "  ${BOLD}logs${NC} [service] [lines]  Show logs (default: all services, 50 lines)"
    echo "  ${BOLD}restart${NC} [service]   Restart service (default: prosody)"
    echo "  ${BOLD}cleanup${NC}             Clean up development environment"
    echo "  ${BOLD}backup${NC}              Backup development data"
    echo "  ${BOLD}perf${NC}                Run performance test"
    echo "  ${BOLD}help${NC}                Show this help message"
    echo
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 status                    # Show environment status"
    echo "  $0 adduser alice alice123    # Create user alice with password alice123"
    echo "  $0 logs xmpp-prosody-dev     # Show Prosody logs"
    echo "  $0 restart                   # Restart Prosody service"
    echo "  $0 test                      # Test all connectivity"
    echo
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    cd "$PROJECT_DIR"

    case "${1:-help}" in
    "status")
        show_status
        ;;
    "urls")
        show_urls
        ;;
    "test")
        test_connectivity
        ;;
    "config")
        test_prosody_config
        ;;
    "users")
        list_users
        ;;
    "adduser")
        if [[ -z "${2:-}" ]]; then
            log_error "Username required"
            echo "Usage: $0 adduser <username> [password]"
            exit 1
        fi
        create_user "$2" "${3:-}"
        ;;
    "deluser")
        if [[ -z "${2:-}" ]]; then
            log_error "Username required"
            echo "Usage: $0 deluser <username>"
            exit 1
        fi
        delete_user "$2"
        ;;
    "passwd")
        if [[ -z "${2:-}" ]]; then
            log_error "Username required"
            echo "Usage: $0 passwd <username>"
            exit 1
        fi
        change_password "$2"
        ;;
    "logs")
        show_logs "${2:-}" "${3:-50}"
        ;;
    "restart")
        restart_service "${2:-xmpp-prosody-dev}"
        ;;
    "cleanup")
        cleanup_dev
        ;;
    "backup")
        backup_dev_data
        ;;
    "perf")
        run_performance_test
        ;;
    "help" | "-h" | "--help")
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
    esac
}

# Run main function with all arguments
main "$@"
