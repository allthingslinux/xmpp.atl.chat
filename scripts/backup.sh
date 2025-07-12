#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server Backup Script
# Comprehensive backup of configuration, data, and certificates

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly BACKUP_DIR="${BACKUP_DIR:-$PROJECT_DIR/backups}"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly BACKUP_NAME="prosody_backup_${TIMESTAMP}"

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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check for required commands
    local required_commands=(
        "docker"
        "docker-compose"
        "tar"
        "gzip"
    )
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Load environment configuration
load_environment() {
    log_info "Loading environment configuration..."
    
    local env_file="$PROJECT_DIR/.env"
    
    if [[ -f "$env_file" ]]; then
        set -a
        source "$env_file"
        set +a
        log_info "Environment configuration loaded"
    else
        log_warn "Environment file not found: $env_file"
        log_warn "Using default values"
    fi
}

# Create backup directory
create_backup_directory() {
    log_info "Creating backup directory..."
    
    local backup_path="$BACKUP_DIR/$BACKUP_NAME"
    mkdir -p "$backup_path"
    
    echo "$backup_path"
}

# Backup configuration files
backup_configuration() {
    local backup_path="$1"
    
    log_info "Backing up configuration files..."
    
    local config_backup_dir="$backup_path/config"
    mkdir -p "$config_backup_dir"
    
    # Backup main configuration
    if [[ -d "$PROJECT_DIR/config" ]]; then
        cp -r "$PROJECT_DIR/config"/* "$config_backup_dir/"
        log_info "Configuration files backed up"
    else
        log_warn "Configuration directory not found"
    fi
    
    # Backup environment file
    if [[ -f "$PROJECT_DIR/.env" ]]; then
        cp "$PROJECT_DIR/.env" "$backup_path/"
        log_info "Environment file backed up"
    fi
    
    # Backup docker-compose files
    if [[ -d "$PROJECT_DIR/docker" ]]; then
        cp -r "$PROJECT_DIR/docker" "$backup_path/"
        log_info "Docker configuration backed up"
    fi
}

# Backup SSL certificates
backup_certificates() {
    local backup_path="$1"
    
    log_info "Backing up SSL certificates..."
    
    local cert_backup_dir="$backup_path/certificates"
    mkdir -p "$cert_backup_dir"
    
    # Check if certificates exist in Docker volume
    if docker volume inspect prosody_certs >/dev/null 2>&1; then
        # Create temporary container to access volume
        docker run --rm -v prosody_certs:/certs -v "$cert_backup_dir":/backup \
            alpine:latest cp -r /certs/. /backup/
        log_info "SSL certificates backed up"
    else
        log_warn "SSL certificates volume not found"
    fi
}

# Backup database
backup_database() {
    local backup_path="$1"
    
    log_info "Backing up database..."
    
    local db_backup_dir="$backup_path/database"
    mkdir -p "$db_backup_dir"
    
    case "${PROSODY_STORAGE:-sqlite}" in
        sqlite)
            backup_sqlite_database "$db_backup_dir"
            ;;
        sql)
            backup_sql_database "$db_backup_dir"
            ;;
    esac
}

# Backup SQLite database
backup_sqlite_database() {
    local backup_dir="$1"
    
    log_info "Backing up SQLite database..."
    
    # Check if data volume exists
    if docker volume inspect prosody_data >/dev/null 2>&1; then
        # Create temporary container to access volume
        docker run --rm -v prosody_data:/data -v "$backup_dir":/backup \
            alpine:latest cp -r /data/. /backup/
        log_info "SQLite database backed up"
    else
        log_warn "Data volume not found"
    fi
}

# Backup SQL database
backup_sql_database() {
    local backup_dir="$1"
    
    log_info "Backing up SQL database..."
    
    # Check if database container is running
    if docker-compose ps db | grep -q "Up"; then
        local db_name="${PROSODY_DB_NAME:-prosody}"
        local db_user="${PROSODY_DB_USER:-prosody}"
        local backup_file="$backup_dir/${db_name}_${TIMESTAMP}.sql"
        
        # Create database dump
        docker-compose exec -T db pg_dump -U "$db_user" "$db_name" > "$backup_file"
        
        # Compress the dump
        gzip "$backup_file"
        
        log_info "SQL database backed up to ${backup_file}.gz"
    else
        log_warn "Database container not running"
    fi
}

# Backup user data
backup_user_data() {
    local backup_path="$1"
    
    log_info "Backing up user data..."
    
    local data_backup_dir="$backup_path/data"
    mkdir -p "$data_backup_dir"
    
    # Backup uploads if HTTP is enabled
    if [[ "${PROSODY_ENABLE_HTTP:-false}" == "true" ]]; then
        if docker volume inspect prosody_uploads >/dev/null 2>&1; then
            local uploads_backup_dir="$data_backup_dir/uploads"
            mkdir -p "$uploads_backup_dir"
            
            docker run --rm -v prosody_uploads:/uploads -v "$uploads_backup_dir":/backup \
                alpine:latest cp -r /uploads/. /backup/
            log_info "User uploads backed up"
        fi
    fi
}

# Backup logs
backup_logs() {
    local backup_path="$1"
    
    log_info "Backing up logs..."
    
    local logs_backup_dir="$backup_path/logs"
    mkdir -p "$logs_backup_dir"
    
    # Check if logs volume exists
    if docker volume inspect prosody_logs >/dev/null 2>&1; then
        docker run --rm -v prosody_logs:/logs -v "$logs_backup_dir":/backup \
            alpine:latest cp -r /logs/. /backup/
        log_info "Logs backed up"
    else
        log_warn "Logs volume not found"
    fi
}

# Create backup metadata
create_backup_metadata() {
    local backup_path="$1"
    
    log_info "Creating backup metadata..."
    
    local metadata_file="$backup_path/backup_metadata.txt"
    
    cat > "$metadata_file" << EOF
# Prosody XMPP Server Backup Metadata
# Generated: $(date)

Backup Name: $BACKUP_NAME
Backup Date: $(date -Iseconds)
Backup Path: $backup_path

# Environment Information
Domain: ${PROSODY_DOMAIN:-unknown}
Admins: ${PROSODY_ADMINS:-unknown}
Storage: ${PROSODY_STORAGE:-sqlite}
Security Enabled: ${PROSODY_ENABLE_SECURITY:-true}
Modern Features: ${PROSODY_ENABLE_MODERN:-true}
HTTP Services: ${PROSODY_ENABLE_HTTP:-false}

# Docker Information
Docker Version: $(docker --version)
Docker Compose Version: $(docker-compose --version)

# Container Status
$(docker-compose ps 2>/dev/null || echo "Docker Compose not available")

# Volume Information
$(docker volume ls | grep prosody || echo "No Prosody volumes found")

# Backup Contents
$(find "$backup_path" -type f -name "*.tar.gz" -o -name "*.sql.gz" -o -name "*.env" | sort)
EOF
    
    log_info "Backup metadata created"
}

# Compress backup
compress_backup() {
    local backup_path="$1"
    
    log_info "Compressing backup..."
    
    cd "$BACKUP_DIR"
    tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
    
    # Remove uncompressed backup
    rm -rf "$BACKUP_NAME"
    
    local compressed_size=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
    log_info "Backup compressed to ${BACKUP_NAME}.tar.gz ($compressed_size)"
}

# Cleanup old backups
cleanup_old_backups() {
    local retention_days="${BACKUP_RETENTION_DAYS:-30}"
    
    log_info "Cleaning up backups older than $retention_days days..."
    
    if [[ -d "$BACKUP_DIR" ]]; then
        find "$BACKUP_DIR" -name "prosody_backup_*.tar.gz" -mtime +$retention_days -delete
        log_info "Old backups cleaned up"
    fi
}

# Verify backup integrity
verify_backup() {
    local backup_file="$BACKUP_DIR/${BACKUP_NAME}.tar.gz"
    
    log_info "Verifying backup integrity..."
    
    if tar -tzf "$backup_file" >/dev/null 2>&1; then
        log_info "Backup integrity verified"
        return 0
    else
        log_error "Backup integrity check failed"
        return 1
    fi
}

# Display backup summary
display_summary() {
    local backup_file="$BACKUP_DIR/${BACKUP_NAME}.tar.gz"
    
    log_info "Backup Summary"
    echo "==============="
    echo "Backup Name: $BACKUP_NAME"
    echo "Backup File: $backup_file"
    echo "Backup Size: $(du -h "$backup_file" | cut -f1)"
    echo "Backup Date: $(date)"
    echo ""
    echo "Backup Contents:"
    tar -tzf "$backup_file" | head -20
    if [[ $(tar -tzf "$backup_file" | wc -l) -gt 20 ]]; then
        echo "... and $(($(tar -tzf "$backup_file" | wc -l) - 20)) more files"
    fi
    echo ""
    echo "To restore this backup:"
    echo "  ./scripts/restore.sh $backup_file"
}

# ============================================================================
# MAIN BACKUP FUNCTION
# ============================================================================

main() {
    log_info "Starting Prosody XMPP Server backup..."
    
    # Check prerequisites
    check_prerequisites
    load_environment
    
    # Create backup directory
    local backup_path
    backup_path=$(create_backup_directory)
    
    # Perform backup operations
    backup_configuration "$backup_path"
    backup_certificates "$backup_path"
    backup_database "$backup_path"
    backup_user_data "$backup_path"
    backup_logs "$backup_path"
    
    # Create metadata
    create_backup_metadata "$backup_path"
    
    # Compress backup
    compress_backup "$backup_path"
    
    # Verify backup
    if verify_backup; then
        log_info "Backup completed successfully"
    else
        log_error "Backup verification failed"
        exit 1
    fi
    
    # Cleanup old backups
    cleanup_old_backups
    
    # Display summary
    display_summary
    
    log_info "Backup process completed"
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
        --retention)
            BACKUP_RETENTION_DAYS="$2"
            shift 2
            ;;
        --backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--debug] [--retention DAYS] [--backup-dir DIR] [--help]"
            echo ""
            echo "Options:"
            echo "  --debug         Enable debug output"
            echo "  --retention     Number of days to keep backups (default: 30)"
            echo "  --backup-dir    Directory to store backups (default: ./backups)"
            echo "  --help          Show this help message"
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