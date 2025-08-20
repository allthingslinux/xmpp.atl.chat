#!/bin/bash

# Test-Driven Development Script for XMPP Admin Interface
# This script systematically tests each component to identify issues

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
PASSED=0
FAILED=0
TOTAL=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

test_service() {
    local service="$1"
    local timeout="${2:-30}"

    ((TOTAL++))
    if docker compose -f docker-compose.dev.yml ps --services --filter "status=running" | grep -q "^${service}$"; then
        log_success "Service $service is running"
        return 0
    else
        log_error "Service $service is NOT running"
        return 1
    fi
}

test_http_endpoint() {
    local url="$1"
    local expected_code="${2:-200}"
    local description="$3"

    ((TOTAL++))
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "^$expected_code$"; then
        log_success "$description ($url returned $expected_code)"
        return 0
    else
        local actual_code
        actual_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2> /dev/null || echo "000")
        log_error "$description ($url returned $actual_code, expected $expected_code)"
        return 1
    fi
}

test_port() {
    local host="$1"
    local port="$2"
    local description="$3"

    ((TOTAL++))
    if timeout 3 bash -c "</dev/tcp/$host/$port" 2> /dev/null; then
        log_success "$description (port $port is open)"
        return 0
    else
        log_error "$description (port $port is closed)"
        return 1
    fi
}

test_module_installation() {
    local module="$1"
    local description="$2"

    ((TOTAL++))
    if docker compose -f docker-compose.dev.yml exec -T xmpp-prosody-dev prosodyctl install --server=https://modules.prosody.im/rocks/ "$module" 2> /dev/null | grep -q "successfully installed"; then
        log_success "$description"
        return 0
    else
        log_error "$description (installation failed)"
        return 1
    fi
}

test_module_loading() {
    local module="$1"
    local description="$2"

    ((TOTAL++))
    if docker compose -f docker-compose.dev.yml exec -T xmpp-prosody-dev prosodyctl shell <<< "module:load('$module')" 2>&1 | grep -q "true"; then
        log_success "$description"
        return 0
    else
        log_error "$description (module failed to load)"
        return 1
    fi
}

main() {
    # Create log file
    LOG_FILE="tests/test-results-$(date +%Y%m%d_%H%M%S).log"
    mkdir -p tests
    exec > >(tee -i "$LOG_FILE")
    exec 2>&1

    echo "🧪 XMPP Admin Interface Test Suite"
    echo "=================================="
    echo "Log file: $LOG_FILE"
    echo

    # Test 1: Basic services running
    echo "📋 Test 1: Basic Service Status"
    echo "-------------------------------"
    test_service "xmpp-postgres-dev"
    test_service "xmpp-prosody-dev"
    test_service "xmpp-nginx-dev"

    echo
    echo "🔌 Test 2: Network Connectivity"
    echo "-------------------------------"
    test_port "localhost" "5222" "XMPP client port"
    test_port "localhost" "5280" "Prosody HTTP port"
    test_port "localhost" "8080" "Nginx HTTP port"

    echo
    echo "🌐 Test 3: Basic HTTP Endpoints"
    echo "-------------------------------"
    test_http_endpoint "http://localhost:5280/status" "200" "Prosody status endpoint"
    test_http_endpoint "http://localhost:8080/status" "200" "Nginx status proxy"
    test_http_endpoint "http://localhost:8080/http-bind" "200" "BOSH endpoint"
    test_http_endpoint "http://localhost:8080/dev-test" "200" "Nginx dev endpoint"

    echo
    echo "📦 Test 4: Module Installation"
    echo "------------------------------"
    test_module_installation "mod_admin_web" "Admin web module installation"

    echo
    echo "🔄 Test 5: Configuration Reload"
    echo "-------------------------------"
    ((TOTAL++))
    if docker compose -f docker-compose.dev.yml exec -T xmpp-prosody-dev prosodyctl reload 2> /dev/null; then
        log_success "Prosody configuration reload"
    else
        log_error "Prosody configuration reload"
    fi

    echo
    echo "🎯 Test 6: Admin Interface Access"
    echo "---------------------------------"
    test_http_endpoint "http://localhost:5280/admin/" "200" "Direct Prosody admin access"
    test_http_endpoint "http://localhost:8080/admin/" "200" "Nginx admin proxy"

    echo
    echo "📊 Test Results Summary"
    echo "======================="
    echo "Total tests: $TOTAL"
    echo -e "Passed: ${GREEN}${PASSED}${NC}"
    echo -e "Failed: ${RED}${FAILED}${NC}"

    if [ $FAILED -gt 0 ]; then
        echo
        echo -e "${RED}❌ Some tests failed. Admin interface may not be working properly.${NC}"
        echo "   Check the detailed output above to identify the issues."
        exit 1
    else
        echo
        echo -e "${GREEN}✅ All tests passed! Admin interface should be working.${NC}"
        echo "   You can access it at: http://localhost:8080/admin/"
        exit 0
    fi
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
