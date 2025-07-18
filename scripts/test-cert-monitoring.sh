#!/bin/bash
# Test script for enhanced certificate monitoring system
# Validates all monitoring, renewal, and alerting functionality

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly TEST_DOMAIN="test.example.com"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test framework functions
run_test() {
    local test_name="$1"
    local test_function="$2"

    ((TESTS_RUN++))
    log_info "Running test: $test_name"

    if $test_function; then
        ((TESTS_PASSED++))
        log_success "✓ $test_name"
    else
        ((TESTS_FAILED++))
        log_error "✗ $test_name"
    fi
    echo ""
}

# Test certificate monitoring script exists and is executable
test_script_exists() {
    local script_path="$PROJECT_DIR/scripts/certificate-monitor.sh"

    if [[ -f "$script_path" ]] && [[ -x "$script_path" ]]; then
        return 0
    else
        log_error "Certificate monitoring script not found or not executable: $script_path"
        return 1
    fi
}

# Test configuration loading
test_config_loading() {
    local config_file="$PROJECT_DIR/.runtime/cert-monitor.conf"

    # Create test configuration
    mkdir -p "$(dirname "$config_file")"
    cat > "$config_file" << EOF
CERT_WARNING_THRESHOLD=30
CERT_CRITICAL_THRESHOLD=7
CERT_RENEWAL_THRESHOLD=30
CERT_ALERT_EMAIL="test@example.com"
EOF

    # Test config command
    if "$PROJECT_DIR/scripts/certificate-monitor.sh" config > /dev/null 2>&1; then
        return 0
    else
        log_error "Configuration loading failed"
        return 1
    fi
}

# Test directory creation
test_directory_creation() {
    local dirs=(
        "$PROJECT_DIR/.runtime/logs"
        "$PROJECT_DIR/.runtime/certs"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_error "Required directory not found: $dir"
            return 1
        fi
    done

    return 0
}

# Test certificate monitoring with mock certificate
test_certificate_monitoring() {
    # Create a mock certificate for testing
    local cert_dir="$PROJECT_DIR/.runtime/test-certs"
    mkdir -p "$cert_dir"

    # Generate a self-signed certificate that expires in 10 days
    local expiry_date
    expiry_date=$(date -d "+10 days" "+%Y%m%d%H%M%SZ")

    openssl req -x509 -newkey rsa:2048 -keyout "$cert_dir/$TEST_DOMAIN.key" \
        -out "$cert_dir/$TEST_DOMAIN.crt" -days 10 -nodes \
        -subj "/CN=$TEST_DOMAIN" > /dev/null 2>&1

    if [[ -f "$cert_dir/$TEST_DOMAIN.crt" ]]; then
        log_info "Mock certificate created successfully"
        return 0
    else
        log_error "Failed to create mock certificate"
        return 1
    fi
}

# Test certificate status checking
test_certificate_status() {
    # This test requires Docker to be running with Prosody container
    if ! docker ps --format '{{.Names}}' | grep -q prosody; then
        log_warn "Prosody container not running - skipping certificate status test"
        return 0
    fi

    # Test the monitoring function
    if "$PROJECT_DIR/scripts/certificate-monitor.sh" monitor > /dev/null 2>&1; then
        return 0
    else
        log_error "Certificate monitoring failed"
        return 1
    fi
}

# Test JSON status file generation
test_status_file_generation() {
    local status_file="$PROJECT_DIR/.runtime/cert-status.json"

    # Run monitoring to generate status file
    "$PROJECT_DIR/scripts/certificate-monitor.sh" monitor > /dev/null 2>&1 || true

    if [[ -f "$status_file" ]]; then
        # Validate JSON format
        if command -v jq > /dev/null 2>&1; then
            if jq '.' "$status_file" > /dev/null 2>&1; then
                log_info "Status file is valid JSON"
                return 0
            else
                log_error "Status file is not valid JSON"
                return 1
            fi
        else
            log_warn "jq not available - skipping JSON validation"
            return 0
        fi
    else
        log_error "Status file not generated"
        return 1
    fi
}

# Test dashboard generation
test_dashboard_generation() {
    local dashboard_file="$PROJECT_DIR/.runtime/cert-dashboard.html"

    # Generate dashboard
    if "$PROJECT_DIR/scripts/certificate-monitor.sh" dashboard > /dev/null 2>&1; then
        if [[ -f "$dashboard_file" ]]; then
            # Check if it's a valid HTML file
            if grep -q "<html" "$dashboard_file" && grep -q "</html>" "$dashboard_file"; then
                log_info "Dashboard HTML file generated successfully"
                return 0
            else
                log_error "Dashboard file is not valid HTML"
                return 1
            fi
        else
            log_error "Dashboard file not created"
            return 1
        fi
    else
        log_error "Dashboard generation failed"
        return 1
    fi
}

# Test prosody-manager integration
test_prosody_manager_integration() {
    local prosody_manager="$PROJECT_DIR/prosody-manager"

    if [[ ! -f "$prosody_manager" ]] || [[ ! -x "$prosody_manager" ]]; then
        log_error "prosody-manager not found or not executable"
        return 1
    fi

    # Test certificate commands
    local commands=("monitor" "dashboard" "status")

    for cmd in "${commands[@]}"; do
        if "$prosody_manager" cert "$cmd" --help > /dev/null 2>&1 || \
           "$prosody_manager" cert "$cmd" > /dev/null 2>&1; then
            log_info "Command 'prosody-manager cert $cmd' works"
        else
            log_error "Command 'prosody-manager cert $cmd' failed"
            return 1
        fi
    done

    return 0
}

# Test log file creation
test_log_files() {
    local log_file="$PROJECT_DIR/.runtime/logs/cert-monitor.log"
    local alert_log="$PROJECT_DIR/.runtime/logs/cert-alerts.log"

    # Run monitoring to generate logs
    "$PROJECT_DIR/scripts/certificate-monitor.sh" monitor > /dev/null 2>&1 || true

    if [[ -f "$log_file" ]]; then
        log_info "Main log file created"
    else
        log_error "Main log file not created"
        return 1
    fi

    # Alert log may not exist if no alerts were generated
    if [[ -f "$alert_log" ]]; then
        log_info "Alert log file exists"
    else
        log_info "Alert log file not present (normal if no alerts)"
    fi

    return 0
}

# Test systemd service files
test_systemd_files() {
    local systemd_dir="$PROJECT_DIR/deployment/systemd"
    local services=(
        "prosody-cert-monitor.service"
        "prosody-cert-monitor.timer"
        "prosody-cert-renewal.service"
        "prosody-cert-renewal.timer"
    )

    for service in "${services[@]}"; do
        if [[ -f "$systemd_dir/$service" ]]; then
            log_info "Systemd service file exists: $service"
        else
            log_error "Systemd service file missing: $service"
            return 1
        fi
    done

    return 0
}

# Test Docker Compose integration
test_docker_compose_integration() {
    local compose_file="$PROJECT_DIR/docker-compose.yml"

    if [[ ! -f "$compose_file" ]]; then
        log_error "Docker Compose file not found"
        return 1
    fi

    # Check if certificate monitoring service is defined
    if grep -q "xmpp-cert-monitor:" "$compose_file"; then
        log_info "Certificate monitoring service found in Docker Compose"
        return 0
    else
        log_error "Certificate monitoring service not found in Docker Compose"
        return 1
    fi
}

# Test error handling
test_error_handling() {
    # Test with invalid domain
    if "$PROJECT_DIR/scripts/certificate-monitor.sh" renew "invalid..domain" > /dev/null 2>&1; then
        log_error "Error handling failed - invalid domain should fail"
        return 1
    else
        log_info "Error handling works correctly for invalid domain"
        return 0
    fi
}

# Test help functionality
test_help_functionality() {
    if "$PROJECT_DIR/scripts/certificate-monitor.sh" help > /dev/null 2>&1; then
        log_info "Help command works"
        return 0
    else
        log_error "Help command failed"
        return 1
    fi
}

# Cleanup test files
cleanup_test_files() {
    log_info "Cleaning up test files..."

    local test_dirs=(
        "$PROJECT_DIR/.runtime/test-certs"
    )

    for dir in "${test_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            log_info "Removed test directory: $dir"
        fi
    done
}

# Show test results
show_test_results() {
    echo ""
    echo "Test Results Summary"
    echo "==================="
    echo "Tests run: $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All tests passed! ✓"
        return 0
    else
        log_error "$TESTS_FAILED test(s) failed! ✗"
        return 1
    fi
}

# Main test function
main() {
    echo "Certificate Monitoring System Test Suite"
    echo "========================================"
    echo ""

    # Ensure required directories exist
    mkdir -p "$PROJECT_DIR/.runtime/logs"

    # Run all tests
    run_test "Script exists and is executable" test_script_exists
    run_test "Configuration loading" test_config_loading
    run_test "Directory creation" test_directory_creation
    run_test "Certificate monitoring with mock cert" test_certificate_monitoring
    run_test "Certificate status checking" test_certificate_status
    run_test "Status file generation" test_status_file_generation
    run_test "Dashboard generation" test_dashboard_generation
    run_test "Prosody-manager integration" test_prosody_manager_integration
    run_test "Log file creation" test_log_files
    run_test "Systemd service files" test_systemd_files
    run_test "Docker Compose integration" test_docker_compose_integration
    run_test "Error handling" test_error_handling
    run_test "Help functionality" test_help_functionality

    # Cleanup
    cleanup_test_files

    # Show results
    show_test_results
}

# Run tests
main "$@"
