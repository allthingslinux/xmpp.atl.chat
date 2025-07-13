#!/bin/bash

# ============================================================================
# PROSODY LAYER-BASED CONFIGURATION VALIDATOR
# ============================================================================
# Validates the layer-based configuration system and reports any issues

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_ROOT/config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNING_CHECKS++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_CHECKS++))
}

check() {
    ((TOTAL_CHECKS++))
    local description="$1"
    local command="$2"

    if eval "$command" >/dev/null 2>&1; then
        log_success "$description"
        return 0
    else
        log_error "$description"
        return 1
    fi
}

check_warning() {
    ((TOTAL_CHECKS++))
    local description="$1"
    local command="$2"

    if eval "$command" >/dev/null 2>&1; then
        log_success "$description"
        return 0
    else
        log_warning "$description"
        return 1
    fi
}

# ============================================================================
# CONFIGURATION STRUCTURE VALIDATION
# ============================================================================

validate_directory_structure() {
    log_info "Validating directory structure..."

    # Main configuration files
    check "Main configuration file exists" "test -f '$CONFIG_DIR/prosody.cfg.lua'"
    check "Global configuration exists" "test -f '$CONFIG_DIR/global.cfg.lua'"
    check "Modules configuration exists" "test -f '$CONFIG_DIR/modules.cfg.lua'"

    # Stack directories
    local layers=(
        "01-transport" "02-stream" "03-stanza" "04-protocol"
        "05-services" "06-storage" "07-interfaces" "08-integration"
    )

    for layer in "${layers[@]}"; do
        check "Layer directory exists: $layer" "test -d '$CONFIG_DIR/stack/$layer'"
    done

    # Layer files
    local layer_files=(
        "01-transport/ports.cfg.lua"
        "01-transport/tls.cfg.lua"
        "01-transport/compression.cfg.lua"
        "01-transport/connections.cfg.lua"
        "02-stream/authentication.cfg.lua"
        "02-stream/encryption.cfg.lua"
        "02-stream/management.cfg.lua"
        "02-stream/negotiation.cfg.lua"
        "03-stanza/routing.cfg.lua"
        "03-stanza/filtering.cfg.lua"
        "03-stanza/validation.cfg.lua"
        "03-stanza/processing.cfg.lua"
        "04-protocol/core.cfg.lua"
        "04-protocol/extensions.cfg.lua"
        "04-protocol/legacy.cfg.lua"
        "04-protocol/experimental.cfg.lua"
        "05-services/messaging.cfg.lua"
        "05-services/presence.cfg.lua"
        "05-services/groupchat.cfg.lua"
        "05-services/pubsub.cfg.lua"
        "06-storage/backends.cfg.lua"
        "06-storage/archiving.cfg.lua"
        "06-storage/caching.cfg.lua"
        "06-storage/migration.cfg.lua"
        "07-interfaces/http.cfg.lua"
        "07-interfaces/websocket.cfg.lua"
        "07-interfaces/bosh.cfg.lua"
        "07-interfaces/components.cfg.lua"
        "08-integration/ldap.cfg.lua"
        "08-integration/oauth.cfg.lua"
        "08-integration/webhooks.cfg.lua"
        "08-integration/apis.cfg.lua"
    )

    for file in "${layer_files[@]}"; do
        check "Layer file exists: $file" "test -f '$CONFIG_DIR/stack/$file'"
    done

    # Supporting directories
    check "Domains directory exists" "test -d '$CONFIG_DIR/domains'"
    check "Environments directory exists" "test -d '$CONFIG_DIR/environments'"
    check "Tools directory exists" "test -d '$CONFIG_DIR/tools'"

    # Supporting files
    check "Domain configuration exists" "test -f '$CONFIG_DIR/domains/main.cfg.lua'"
    check "Production environment exists" "test -f '$CONFIG_DIR/environments/production.cfg.lua'"
    check "Configuration loader exists" "test -f '$CONFIG_DIR/tools/loader.cfg.lua'"
}

# ============================================================================
# SYNTAX VALIDATION
# ============================================================================

validate_lua_syntax() {
    log_info "Validating Lua syntax..."

    local lua_files
    mapfile -t lua_files < <(find "$CONFIG_DIR" -name "*.cfg.lua" -type f)

    for file in "${lua_files[@]}"; do
        local relative_path="${file#$CONFIG_DIR/}"
        if lua -l luacheck "$file" >/dev/null 2>&1 || lua -e "loadfile('$file')" >/dev/null 2>&1; then
            log_success "Lua syntax valid: $relative_path"
            ((PASSED_CHECKS++))
        else
            log_error "Lua syntax error: $relative_path"
            ((FAILED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    done
}

# ============================================================================
# CONTENT VALIDATION
# ============================================================================

validate_configuration_content() {
    log_info "Validating configuration content..."

    # Check for layer module variables
    local layer_vars=(
        "transport_modules"
        "stream_modules"
        "stanza_modules"
        "protocol_modules"
        "services_modules"
        "storage_modules"
        "interfaces_modules"
        "integration_modules"
    )

    for var in "${layer_vars[@]}"; do
        if grep -r "$var" "$CONFIG_DIR/stack/" >/dev/null 2>&1; then
            log_success "Layer variable defined: $var"
            ((PASSED_CHECKS++))
        else
            log_warning "Layer variable not found: $var"
            ((WARNING_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    done

    # Check for environment detection
    check "Environment detection in main config" "grep -q 'PROSODY_ENVIRONMENT' '$CONFIG_DIR/prosody.cfg.lua'"
    check "Layer loading in main config" "grep -q 'dofile.*stack.*cfg.lua' '$CONFIG_DIR/prosody.cfg.lua'"
    check "Module collection in main config" "grep -q 'collect_layer_modules' '$CONFIG_DIR/prosody.cfg.lua'"

    # Check for XEP references
    local xep_count=$(grep -r "XEP-" "$CONFIG_DIR/stack/" | wc -l)
    if [ "$xep_count" -gt 50 ]; then
        log_success "Good XEP documentation coverage ($xep_count references)"
        ((PASSED_CHECKS++))
    else
        log_warning "Limited XEP documentation coverage ($xep_count references)"
        ((WARNING_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
}

# ============================================================================
# MODULE VALIDATION
# ============================================================================

validate_modules() {
    log_info "Validating module configuration..."

    # Check for common Prosody modules
    local core_modules=(
        "roster" "saslauth" "tls" "dialback" "disco"
        "c2s" "s2s" "private" "vcard" "carbons" "mam"
    )

    for module in "${core_modules[@]}"; do
        if grep -r "\"$module\"" "$CONFIG_DIR/stack/" >/dev/null 2>&1; then
            log_success "Core module configured: $module"
            ((PASSED_CHECKS++))
        else
            log_warning "Core module not found: $module"
            ((WARNING_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    done

    # Check for module conflicts
    local conflicting_pairs=(
        "carbons:carbon_copy"
        "mam:mod_archive"
        "smacks:stream_management"
    )

    for pair in "${conflicting_pairs[@]}"; do
        local mod1="${pair%:*}"
        local mod2="${pair#*:}"
        local has_mod1=$(grep -r "\"$mod1\"" "$CONFIG_DIR/stack/" | wc -l)
        local has_mod2=$(grep -r "\"$mod2\"" "$CONFIG_DIR/stack/" | wc -l)

        if [ "$has_mod1" -gt 0 ] && [ "$has_mod2" -gt 0 ]; then
            log_error "Module conflict detected: $mod1 and $mod2"
            ((FAILED_CHECKS++))
        else
            log_success "No conflict between: $mod1 and $mod2"
            ((PASSED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    done
}

# ============================================================================
# SECURITY VALIDATION
# ============================================================================

validate_security() {
    log_info "Validating security configuration..."

    # Check for security settings
    check "TLS encryption configured" "grep -r 'c2s_require_encryption.*true' '$CONFIG_DIR/'"
    check "S2S encryption configured" "grep -r 's2s_require_encryption.*true' '$CONFIG_DIR/'"
    check "Modern TLS protocols" "grep -r 'tlsv1_2' '$CONFIG_DIR/'"
    check "Strong ciphers configured" "grep -r 'ciphers.*ECDHE' '$CONFIG_DIR/'"

    # Check for authentication
    check "SASL authentication configured" "grep -r 'SCRAM-SHA' '$CONFIG_DIR/'"
    check "Authentication backends defined" "grep -r 'authentication.*=' '$CONFIG_DIR/'"

    # Check for rate limiting
    check "Rate limiting configured" "grep -r 'limits.*=' '$CONFIG_DIR/'"
    check "Connection throttling" "grep -r 'throttle' '$CONFIG_DIR/'"
}

# ============================================================================
# COMPLIANCE VALIDATION
# ============================================================================

validate_compliance() {
    log_info "Validating XMPP compliance..."

    # Check for compliance features
    check "Contact information configured" "grep -r 'contact_info' '$CONFIG_DIR/'"
    check "Server information available" "grep -r 'server_contact_info' '$CONFIG_DIR/'"
    check "Message archiving (MAM)" "grep -r 'mam' '$CONFIG_DIR/'"
    check "Stream management" "grep -r 'smacks' '$CONFIG_DIR/'"
    check "Message carbons" "grep -r 'carbons' '$CONFIG_DIR/'"

    # Check for modern features
    check_warning "OMEMO support configured" "grep -r 'omemo' '$CONFIG_DIR/'"
    check_warning "Push notifications" "grep -r 'cloud_notify' '$CONFIG_DIR/'"
    check_warning "HTTP file upload" "grep -r 'http_file_share' '$CONFIG_DIR/'"
}

# ============================================================================
# PROSODY VALIDATION
# ============================================================================

validate_prosody_config() {
    log_info "Validating Prosody configuration..."

    # Check if prosodyctl is available
    if command -v prosodyctl >/dev/null 2>&1; then
        # Test configuration syntax
        if prosodyctl check config 2>/dev/null; then
            log_success "Prosody configuration syntax valid"
            ((PASSED_CHECKS++))
        else
            log_error "Prosody configuration has syntax errors"
            ((FAILED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))

        # Check for prosody modules
        if prosodyctl check 2>/dev/null; then
            log_success "Prosody dependency check passed"
            ((PASSED_CHECKS++))
        else
            log_warning "Prosody dependency check failed (modules may be missing)"
            ((WARNING_CHECKS++))
        fi
        ((TOTAL_CHECKS++))

        # Check certificate configuration (Prosody 0.12+)
        if prosodyctl check certs 2>/dev/null; then
            log_success "Prosody certificate check passed"
            ((PASSED_CHECKS++))
        else
            log_warning "Prosody certificate check failed (certificates may be missing or invalid)"
            ((WARNING_CHECKS++))
        fi
        ((TOTAL_CHECKS++))

        # Check connectivity if domain is set
        if [[ -n "${PROSODY_DOMAIN:-}" ]] && prosodyctl check connectivity "${PROSODY_DOMAIN}" 2>/dev/null; then
            log_success "Prosody connectivity check passed for ${PROSODY_DOMAIN}"
            ((PASSED_CHECKS++))
        else
            log_warning "Prosody connectivity check failed (network/DNS issues may exist)"
            ((WARNING_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    else
        log_warning "prosodyctl not available - skipping Prosody validation"
        ((WARNING_CHECKS++))
        ((TOTAL_CHECKS++))
    fi
}

# ============================================================================
# ENVIRONMENT VALIDATION
# ============================================================================

validate_environment() {
    log_info "Validating environment configuration..."

    # Check for environment variables
    check_warning "PROSODY_DOMAIN set" "test -n '${PROSODY_DOMAIN:-}'"
    check_warning "PROSODY_ENVIRONMENT set" "test -n '${PROSODY_ENVIRONMENT:-}'"

    # Check for production-specific settings
    if [ "${PROSODY_ENVIRONMENT:-}" = "production" ]; then
        check_warning "Database password set" "test -n '${PROSODY_DB_PASSWORD:-}'"
        check_warning "TLS certificates path" "test -d '/etc/prosody/certs' || test -d '/var/lib/prosody/certs'"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo "============================================================================"
    echo "PROSODY LAYER-BASED CONFIGURATION VALIDATOR"
    echo "============================================================================"
    echo

    # Run all validation checks
    validate_directory_structure
    echo
    validate_lua_syntax
    echo
    validate_configuration_content
    echo
    validate_modules
    echo
    validate_security
    echo
    validate_compliance
    echo
    validate_prosody_config
    echo
    validate_environment
    echo

    # Summary
    echo "============================================================================"
    echo "VALIDATION SUMMARY"
    echo "============================================================================"
    echo -e "Total checks: ${TOTAL_CHECKS}"
    echo -e "${GREEN}Passed: ${PASSED_CHECKS}${NC}"
    echo -e "${YELLOW}Warnings: ${WARNING_CHECKS}${NC}"
    echo -e "${RED}Failed: ${FAILED_CHECKS}${NC}"
    echo

    # Calculate score
    local success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

    if [ $FAILED_CHECKS -eq 0 ]; then
        if [ $WARNING_CHECKS -eq 0 ]; then
            echo -e "${GREEN}✅ EXCELLENT: Configuration is complete and ready for production!${NC}"
            exit 0
        else
            echo -e "${YELLOW}⚠️  GOOD: Configuration is functional with minor warnings.${NC}"
            exit 0
        fi
    else
        echo -e "${RED}❌ ISSUES FOUND: Configuration has errors that need to be addressed.${NC}"
        exit 1
    fi
}

# Run the validator
main "$@"
