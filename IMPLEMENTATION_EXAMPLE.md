# Implementation Example: Profile-Feature-Environment (PFE) Architecture

This document provides concrete examples of how the new PFE architecture would work in practice, including actual configuration files and migration steps.

## Example 1: Standard Profile Implementation

### Profile Definition

```lua
-- config/profiles/standard/profile.cfg.lua
profile_info = {
    name = "Standard",
    description = "Full-featured XMPP server for small to medium teams (10-100 users)",
    target_users = "10-100",
    stability = "production-ready",
    resource_requirements = {
        memory = "256MB",
        cpu = "1 core",
        storage = "5GB"
    },
    features = {
        -- Core messaging
        "messaging/core",
        "messaging/archive",
        "messaging/carbons",
        
        -- Authentication
        "authentication/basic",
        "authentication/modern",
        
        -- Collaboration
        "collaboration/muc",
        "collaboration/bookmarks",
        
        -- Web services
        "web/http",
        "web/websocket",
        "web/upload",
        
        -- Mobile support
        "mobile/push",
        "mobile/csi",
        
        -- Security
        "security/firewall",
        "security/antispam",
        
        -- Administration
        "admin/shell"
    },
    optional_features = {
        "web/admin",
        "admin/api",
        "security/monitoring"
    }
}

-- Profile-specific defaults
default_archive_policy = "roster"
archive_expires_after = "1y"
muc_room_default_public = false
http_upload_file_size_limit = 50 * 1024 * 1024  -- 50MB
max_history_messages = 50
```

### Feature Configuration Example

```lua
-- config/features/authentication/modern.cfg.lua
-- Modern Authentication Features
-- Implements: XEP-0388 (SASL2), XEP-0386 (Bind2), XEP-0484 (FAST)

local feature_info = {
    name = "Modern Authentication",
    description = "Next-generation SASL authentication with Bind2 and FAST tokens",
    xeps = {"XEP-0388", "XEP-0386", "XEP-0484", "XEP-0474"},
    stability = "beta",
    dependencies = {"authentication/basic"},
    conflicts = {},
    modules = {"sasl2", "sasl2_bind2", "sasl2_fast", "sasl_ssdp"}
}

-- Initialize modules table if not exists
modules_enabled = modules_enabled or {}

-- SASL2 support (XEP-0388: Extensible SASL Profile)
if os.getenv("PROSODY_FEATURES_AUTH_SASL2") ~= "false" then
    table.insert(modules_enabled, "sasl2")
    
    -- SASL2 configuration
    sasl2_require_encryption = true
    sasl2_timeout = tonumber(os.getenv("PROSODY_SASL2_TIMEOUT")) or 300
    
    -- Bind2 support (XEP-0386: Bind 2)
    if os.getenv("PROSODY_FEATURES_AUTH_BIND2") ~= "false" then
        table.insert(modules_enabled, "sasl2_bind2")
        
        -- Bind2 configuration
        sasl2_bind2_enable_carbons = true
        sasl2_bind2_enable_sm = true
    end
    
    -- FAST token support (XEP-0484: Fast Authentication Streamlining Tokens)
    if os.getenv("PROSODY_FEATURES_AUTH_FAST") == "true" then
        table.insert(modules_enabled, "sasl2_fast")
        
        -- FAST configuration
        sasl2_fast_token_ttl = tonumber(os.getenv("PROSODY_FAST_TOKEN_TTL")) or 86400 -- 24 hours
        sasl2_fast_max_tokens_per_user = tonumber(os.getenv("PROSODY_FAST_MAX_TOKENS")) or 10
    end
end

-- SASL downgrade protection (XEP-0474: SASL SCRAM Downgrade Protection)
if os.getenv("PROSODY_FEATURES_AUTH_DOWNGRADE_PROTECTION") ~= "false" then
    table.insert(modules_enabled, "sasl_ssdp")
end

-- Modern SASL mechanisms (prioritized order)
sasl_enabled_mechanisms = {
    "SCRAM-SHA-256-PLUS",  -- Channel binding
    "SCRAM-SHA-256",
    "SCRAM-SHA-1-PLUS",    -- Channel binding
    "SCRAM-SHA-1",
    "PLAIN"                -- Only over TLS
}

-- Authentication policy
authentication_policy = {
    require_encryption = true,
    allow_unencrypted_plain = false,
    require_channel_binding = os.getenv("PROSODY_REQUIRE_CHANNEL_BINDING") == "true"
}

log("info", "Modern authentication features loaded: %s", table.concat(feature_info.modules, ", "))
```

### Environment-Specific Override

```lua
-- config/environments/production.cfg.lua
-- Production environment hardening

-- Enhanced security settings
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true

-- Stricter rate limiting for production
limits = {
    c2s = {
        rate = "5kb/s",
        burst = "10kb"
    },
    s2sin = {
        rate = "10kb/s", 
        burst = "20kb"
    }
}

-- Production logging
log = {
    { levels = { "error" }, to = "file", filename = "/var/log/prosody/error.log" },
    { levels = { "warn" }, to = "file", filename = "/var/log/prosody/prosody.log" },
    { levels = { "info" }, to = "syslog" }
}

-- Disable debug features
admin_shell_enabled = false
debug_mode = false

-- Enhanced firewall rules for production
firewall_scripts = {
    "/etc/prosody/firewall/production-rules.pfw"
}

log("info", "Production environment configuration loaded")
```

## Example 2: Enhanced Docker Configuration

### Modular Docker Compose

```yaml
# docker/compose/base.yml
version: '3.8'

x-prosody-common: &prosody-common
  image: prosody:${PROSODY_VERSION:-latest}
  restart: unless-stopped
  networks:
    - prosody_network
  environment: &prosody-env
    - PROSODY_PROFILE=${PROSODY_PROFILE:-standard}
    - PROSODY_ENVIRONMENT=${PROSODY_ENVIRONMENT:-production}
    - PROSODY_DOMAIN=${PROSODY_DOMAIN}
    - PROSODY_ADMINS=${PROSODY_ADMINS}
    
    # Feature toggles
    - PROSODY_FEATURES_AUTH_MODERN=${PROSODY_FEATURES_AUTH_MODERN:-true}
    - PROSODY_FEATURES_WEB_ENABLED=${PROSODY_FEATURES_WEB_ENABLED:-true}
    - PROSODY_FEATURES_MOBILE_PUSH=${PROSODY_FEATURES_MOBILE_PUSH:-true}
    - PROSODY_FEATURES_SECURITY_ENHANCED=${PROSODY_FEATURES_SECURITY_ENHANCED:-true}
    
    # Database configuration
    - PROSODY_STORAGE=${PROSODY_STORAGE:-sqlite}
    - PROSODY_DB_HOST=${PROSODY_DB_HOST:-db}
    - PROSODY_DB_NAME=${PROSODY_DB_NAME:-prosody}
    - PROSODY_DB_USER=${PROSODY_DB_USER:-prosody}
    - PROSODY_DB_PASSWORD=${PROSODY_DB_PASSWORD}
    
  volumes:
    - ./config:/etc/prosody/config:ro
    - prosody_data:/var/lib/prosody/data
    - prosody_logs:/var/log/prosody
    - prosody_certs:/etc/prosody/certs
    
  healthcheck:
    test: ["/opt/prosody/scripts/health-check.sh", "--profile", "${PROSODY_PROFILE:-standard}"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 60s

services:
  prosody:
    <<: *prosody-common
    container_name: prosody-${PROSODY_ENVIRONMENT:-prod}
    hostname: ${PROSODY_DOMAIN}
    
    ports:
      - '${PROSODY_C2S_PORT:-5222}:5222'   # Client connections
      - '${PROSODY_S2S_PORT:-5269}:5269'   # Server connections
      - '${PROSODY_HTTP_PORT:-5280}:5280'  # HTTP services
      - '${PROSODY_HTTPS_PORT:-5281}:5281' # HTTPS services
      
    deploy:
      resources:
        limits:
          memory: ${PROSODY_MEMORY_LIMIT:-256M}
          cpus: ${PROSODY_CPU_LIMIT:-1.0}
        reservations:
          memory: ${PROSODY_MEMORY_RESERVE:-64M}
          cpus: ${PROSODY_CPU_RESERVE:-0.5}

volumes:
  prosody_data:
    driver: local
  prosody_logs:
    driver: local
  prosody_certs:
    driver: local

networks:
  prosody_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Profile-Aware Dockerfile

```dockerfile
# docker/images/prosody/Dockerfile
FROM debian:bookworm-slim AS base

# Install base dependencies
RUN apt-get update && apt-get install -y \
    prosody \
    lua5.4 \
    lua-dbi-postgresql \
    lua-dbi-sqlite3 \
    lua-sec \
    lua-socket \
    lua-filesystem \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Profile-specific stage
FROM base AS profile-builder
ARG PROSODY_PROFILE=standard
ARG PROSODY_FEATURES=standard

# Copy profile configurations
COPY config/profiles/${PROSODY_PROFILE}/ /etc/prosody/profiles/active/
COPY config/features/ /etc/prosody/features/
COPY config/core/ /etc/prosody/core/

# Install profile-specific modules
RUN /opt/prosody/scripts/install-profile-modules.sh ${PROSODY_PROFILE}

# Runtime stage
FROM base AS runtime

# Copy from profile builder
COPY --from=profile-builder /etc/prosody/ /etc/prosody/
COPY --from=profile-builder /usr/lib/prosody/modules/ /usr/lib/prosody/modules/

# Copy scripts
COPY docker/images/prosody/entrypoint.sh /opt/prosody/scripts/
COPY docker/images/prosody/healthcheck.sh /opt/prosody/scripts/
COPY scripts/ /opt/prosody/scripts/

# Create prosody user and directories
RUN groupadd -r prosody && useradd -r -g prosody -d /var/lib/prosody prosody
RUN mkdir -p /var/lib/prosody/data /var/log/prosody /etc/prosody/certs
RUN chown -R prosody:prosody /var/lib/prosody /var/log/prosody /etc/prosody

# Expose ports
EXPOSE 5222 5269 5280 5281

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /opt/prosody/scripts/healthcheck.sh

USER prosody
ENTRYPOINT ["/opt/prosody/scripts/entrypoint.sh"]
CMD ["prosody", "--foreground"]
```

## Example 3: Configuration Management Tools

### Profile Manager Script

```bash
#!/bin/bash
# scripts/profile-manager.sh - Enhanced profile management

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROFILES_DIR="$PROJECT_DIR/config/profiles"
readonly FEATURES_DIR="$PROJECT_DIR/config/features"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# List available profiles
list_profiles() {
    echo "Available profiles:"
    for profile in "$PROFILES_DIR"/*; do
        if [[ -d "$profile" && -f "$profile/profile.cfg.lua" ]]; then
            local name=$(basename "$profile")
            local desc=$(grep -o 'description = "[^"]*"' "$profile/profile.cfg.lua" | cut -d'"' -f2 || echo "No description")
            printf "  %-15s %s\n" "$name" "$desc"
        fi
    done
}

# List available features
list_features() {
    echo "Available features:"
    find "$FEATURES_DIR" -name "*.cfg.lua" | while read -r feature; do
        local path=${feature#$FEATURES_DIR/}
        local name=${path%.cfg.lua}
        local desc=$(grep -o 'description = "[^"]*"' "$feature" | cut -d'"' -f2 || echo "No description")
        printf "  %-25s %s\n" "$name" "$desc"
    done
}

# Validate profile configuration
validate_profile() {
    local profile="${1:-${PROSODY_PROFILE:-standard}}"
    local profile_dir="$PROFILES_DIR/$profile"
    
    if [[ ! -d "$profile_dir" ]]; then
        log_error "Profile '$profile' not found"
        return 1
    fi
    
    log_info "Validating profile: $profile"
    
    # Check required files
    local required_files=("profile.cfg.lua")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$profile_dir/$file" ]]; then
            log_error "Required file missing: $file"
            return 1
        fi
    done
    
    # Validate Lua syntax
    if ! lua -l "$profile_dir/profile.cfg.lua" -e "" 2>/dev/null; then
        log_error "Syntax error in profile.cfg.lua"
        return 1
    fi
    
    # Check feature dependencies
    local features=$(grep -o '"[^"]*"' "$profile_dir/profile.cfg.lua" | grep -E '^"[a-z]+/' | tr -d '"')
    for feature in $features; do
        if [[ ! -f "$FEATURES_DIR/$feature.cfg.lua" ]]; then
            log_warn "Feature not found: $feature"
        fi
    done
    
    log_info "Profile validation completed"
}

# Create new profile from template
create_profile() {
    local name="$1"
    local template="${2:-standard}"
    
    if [[ -z "$name" ]]; then
        log_error "Profile name required"
        echo "Usage: $0 create <profile-name> [template]"
        return 1
    fi
    
    local target_dir="$PROFILES_DIR/$name"
    local template_dir="$PROFILES_DIR/$template"
    
    if [[ -d "$target_dir" ]]; then
        log_error "Profile '$name' already exists"
        return 1
    fi
    
    if [[ ! -d "$template_dir" ]]; then
        log_error "Template '$template' not found"
        return 1
    fi
    
    cp -r "$template_dir" "$target_dir"
    
    # Update profile info
    sed -i "s/name = \"[^\"]*\"/name = \"$name\"/" "$target_dir/profile.cfg.lua"
    sed -i "s/description = \"[^\"]*\"/description = \"Custom profile: $name\"/" "$target_dir/profile.cfg.lua"
    
    log_info "Created profile: $name (based on $template)"
}

# Generate deployment configuration
generate_config() {
    local profile="${1:-${PROSODY_PROFILE:-standard}}"
    local environment="${2:-${PROSODY_ENVIRONMENT:-production}}"
    local output="${3:-prosody-generated.cfg.lua}"
    
    log_info "Generating configuration for profile '$profile' in '$environment' environment"
    
    cat > "$output" <<EOF
-- Generated Prosody configuration
-- Profile: $profile
-- Environment: $environment
-- Generated: $(date)

-- Load core configuration
Include("/etc/prosody/core/global.cfg.lua")
Include("/etc/prosody/core/security.cfg.lua")
Include("/etc/prosody/core/database.cfg.lua")

-- Load profile
Include("/etc/prosody/profiles/$profile/profile.cfg.lua")

-- Load environment overrides
Include("/etc/prosody/environments/$environment.cfg.lua")
EOF
    
    log_info "Configuration generated: $output"
}

# Main command dispatcher
main() {
    case "${1:-help}" in
        list|ls)
            list_profiles
            ;;
        features)
            list_features
            ;;
        validate|check)
            validate_profile "${2:-}"
            ;;
        create|new)
            create_profile "${2:-}" "${3:-}"
            ;;
        generate|gen)
            generate_config "${2:-}" "${3:-}" "${4:-}"
            ;;
        help|--help|-h)
            cat <<EOF
Profile Manager - Prosody Configuration Management

Usage: $0 <command> [options]

Commands:
  list                          List available profiles
  features                      List available features
  validate [profile]            Validate profile configuration
  create <name> [template]      Create new profile from template
  generate [profile] [env] [output]  Generate deployment configuration

Examples:
  $0 list
  $0 create mycompany enterprise
  $0 validate mycompany
  $0 generate mycompany production
EOF
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            return 1
            ;;
    esac
}

main "$@"
```

### Environment Configuration Generator

```bash
#!/bin/bash
# scripts/env-generator.sh - Generate environment files for different profiles

generate_env_for_profile() {
    local profile="$1"
    local environment="${2:-production}"
    
    cat > ".env.${profile}.${environment}" <<EOF
# Generated environment for profile: $profile (environment: $environment)
# Generated: $(date)

# Basic Configuration
PROSODY_PROFILE=$profile
PROSODY_ENVIRONMENT=$environment
PROSODY_DOMAIN=example.com
PROSODY_ADMINS=admin@example.com

# Profile-specific features
EOF

    # Add profile-specific features
    case "$profile" in
        minimal)
            cat >> ".env.${profile}.${environment}" <<EOF
PROSODY_FEATURES_AUTH_MODERN=false
PROSODY_FEATURES_WEB_ENABLED=false
PROSODY_FEATURES_MOBILE_PUSH=false
PROSODY_FEATURES_SECURITY_ENHANCED=true
PROSODY_FEATURES_ADMIN_WEB=false
EOF
            ;;
        standard)
            cat >> ".env.${profile}.${environment}" <<EOF
PROSODY_FEATURES_AUTH_MODERN=true
PROSODY_FEATURES_WEB_ENABLED=true
PROSODY_FEATURES_MOBILE_PUSH=true
PROSODY_FEATURES_SECURITY_ENHANCED=true
PROSODY_FEATURES_ADMIN_WEB=false
EOF
            ;;
        enterprise)
            cat >> ".env.${profile}.${environment}" <<EOF
PROSODY_FEATURES_AUTH_MODERN=true
PROSODY_FEATURES_AUTH_EXTERNAL=true
PROSODY_FEATURES_WEB_ENABLED=true
PROSODY_FEATURES_MOBILE_PUSH=true
PROSODY_FEATURES_SECURITY_ENHANCED=true
PROSODY_FEATURES_SECURITY_MONITORING=true
PROSODY_FEATURES_SECURITY_COMPLIANCE=true
PROSODY_FEATURES_ADMIN_WEB=true
PROSODY_FEATURES_ADMIN_API=true
PROSODY_FEATURES_PERFORMANCE_CACHING=true
EOF
            ;;
    esac
    
    # Add environment-specific settings
    case "$environment" in
        development)
            cat >> ".env.${profile}.${environment}" <<EOF

# Development settings
PROSODY_LOG_LEVEL=debug
PROSODY_ALLOW_REGISTRATION=true
PROSODY_FEATURES_DEBUG=true
EOF
            ;;
        production)
            cat >> ".env.${profile}.${environment}" <<EOF

# Production settings
PROSODY_LOG_LEVEL=info
PROSODY_ALLOW_REGISTRATION=false
PROSODY_RESOURCE_LIMITS=true
EOF
            ;;
    esac
    
    echo "Generated: .env.${profile}.${environment}"
}

# Generate for common combinations
generate_env_for_profile minimal production
generate_env_for_profile standard production
generate_env_for_profile enterprise production
generate_env_for_profile development development
```

## Migration Path from Current Structure

### Step 1: Parallel Implementation

```bash
# Create new structure alongside current
mkdir -p config/profiles/{minimal,standard,enterprise,development}
mkdir -p config/features/{authentication,messaging,collaboration,web,mobile,security,admin}
mkdir -p config/environments
mkdir -p config/templates

# Symlink current structure for compatibility
ln -s ../modules.d config/legacy/modules.d
```

### Step 2: Gradual Migration

```bash
# Migrate current modules to features
./scripts/migrate-to-features.sh

# Test new structure
PROSODY_PROFILE=standard PROSODY_LEGACY_MODE=false docker-compose up -d

# Validate configuration
./scripts/profile-manager.sh validate standard
```

### Step 3: Full Deployment

```bash
# Switch to new structure
export PROSODY_LEGACY_MODE=false
export PROSODY_PROFILE=standard

# Deploy with new configuration
./scripts/deploy.sh --profile=standard --environment=production
```

This implementation demonstrates how the new PFE architecture provides better modularity, easier deployment management, and clearer separation of concerns while maintaining full backward compatibility with your existing excellent foundation.
