# Proposed Module/Config Structure for Dynamic, Modular, Long-term Use

## Executive Summary

This proposal outlines a **next-generation configuration architecture** for your Prosody XMPP server that builds upon your current excellent foundation while addressing scalability, maintainability, and deployment flexibility challenges.

## Current Structure Analysis

### ✅ Strengths of Current System

- **Stability-based organization** provides clear risk assessment
- **Environment-driven configuration** via comprehensive `.env` files
- **Modular Lua includes** keep configuration files focused
- **Docker-ready** with professional compose setup
- **Excellent documentation** with detailed module descriptions
- **Security-first approach** aligns with XMPP Safeguarding Manifesto
- **Professional deployment scripts** with comprehensive validation

### ❌ Areas for Improvement

1. **Rigid stability categories** don't reflect real-world deployment needs
2. **Deep directory nesting** creates maintenance overhead
3. **Mixed concerns** in single configuration files
4. **Limited deployment profiles** for different use cases
5. **Manual module dependency management**
6. **Docker configuration** could be more modular and scalable
7. **Configuration duplication** across similar deployments

## Proposed Architecture: **Profile-Feature-Environment (PFE) Model**

### Core Principles

1. **Profile-Based Deployment** - Match real-world usage patterns
2. **Feature-Driven Configuration** - Granular control over functionality
3. **Environment-Aware** - Automatic adaptation to deployment context
4. **Container-Native** - Designed for modern deployment patterns
5. **Backward Compatible** - Smooth migration from current system

## New Directory Structure

```
config/
├── core/                           # Core Prosody configuration (unchanged)
│   ├── prosody.cfg.lua            # Main entry point
│   ├── global.cfg.lua             # Global settings
│   ├── security.cfg.lua           # Security policies
│   └── database.cfg.lua           # Storage configuration
├── profiles/                       # Deployment profiles (NEW)
│   ├── minimal/                   # Personal/hobby use (1-10 users)
│   │   ├── profile.cfg.lua        # Profile definition
│   │   ├── modules.cfg.lua        # Core modules only
│   │   └── defaults.env           # Default environment
│   ├── standard/                  # Small teams (10-100 users)
│   │   ├── profile.cfg.lua
│   │   ├── modules.cfg.lua        # Core + essential community
│   │   ├── components.cfg.lua     # MUC, file sharing
│   │   └── defaults.env
│   ├── enterprise/                # Large organizations (100+ users)
│   │   ├── profile.cfg.lua
│   │   ├── modules.cfg.lua        # Full feature set
│   │   ├── components.cfg.lua     # All components
│   │   ├── monitoring.cfg.lua     # Performance monitoring
│   │   ├── compliance.cfg.lua     # Compliance features
│   │   └── defaults.env
│   ├── development/               # Development/testing
│   │   ├── profile.cfg.lua
│   │   ├── modules.cfg.lua        # All modules for testing
│   │   ├── debug.cfg.lua          # Debug configuration
│   │   └── defaults.env
│   └── custom/                    # User-defined profiles
│       └── README.md
├── features/                       # Feature-specific configurations (NEW)
│   ├── authentication/
│   │   ├── basic.cfg.lua         # Standard SASL mechanisms
│   │   ├── modern.cfg.lua        # SASL2, Bind2, FAST tokens
│   │   ├── external.cfg.lua      # LDAP, OAuth integration
│   │   └── mfa.cfg.lua           # Multi-factor authentication
│   ├── messaging/
│   │   ├── core.cfg.lua          # Basic messaging (presence, message)
│   │   ├── archive.cfg.lua       # MAM configuration
│   │   ├── carbons.cfg.lua       # Message carbons
│   │   └── encryption.cfg.lua    # E2EE support modules
│   ├── collaboration/
│   │   ├── muc.cfg.lua           # Multi-user chat
│   │   ├── pubsub.cfg.lua        # Publish-subscribe
│   │   ├── sharing.cfg.lua       # File sharing
│   │   └── bookmarks.cfg.lua     # Bookmark synchronization
│   ├── web/
│   │   ├── http.cfg.lua          # HTTP services base
│   │   ├── websocket.cfg.lua     # WebSocket support
│   │   ├── upload.cfg.lua        # File upload services
│   │   └── admin.cfg.lua         # Web admin interface
│   ├── mobile/
│   │   ├── push.cfg.lua          # Push notifications
│   │   ├── csi.cfg.lua           # Client State Indication
│   │   ├── battery.cfg.lua       # Battery optimization
│   │   └── offline.cfg.lua       # Offline message handling
│   ├── security/
│   │   ├── firewall.cfg.lua      # Firewall rules and policies
│   │   ├── antispam.cfg.lua      # Anti-spam measures
│   │   ├── monitoring.cfg.lua    # Security monitoring
│   │   └── compliance.cfg.lua    # Regulatory compliance
│   ├── performance/
│   │   ├── caching.cfg.lua       # Caching strategies
│   │   ├── clustering.cfg.lua    # Multi-node setup
│   │   └── optimization.cfg.lua  # Performance tuning
│   └── admin/
│       ├── shell.cfg.lua         # Admin shell
│       ├── api.cfg.lua           # Admin API
│       ├── monitoring.cfg.lua    # Admin monitoring
│       └── backup.cfg.lua        # Backup configuration
├── environments/                   # Environment-specific overrides (NEW)
│   ├── development.cfg.lua        # Development settings
│   ├── staging.cfg.lua           # Staging environment
│   ├── production.cfg.lua        # Production hardening
│   └── testing.cfg.lua           # Testing configuration
├── templates/                      # Configuration templates (NEW)
│   ├── vhost.template.lua        # Virtual host template
│   ├── component.template.lua    # Component template
│   ├── module.template.lua       # Module configuration template
│   └── profile.template.lua      # Profile template
└── legacy/                        # Backward compatibility (NEW)
    └── modules.d/                 # Current structure (symlinked)
```

## Enhanced Docker Structure

```
docker/
├── compose/                        # Modular compose files
│   ├── base.yml                   # Core Prosody service
│   ├── database.yml               # PostgreSQL, SQLite options
│   ├── monitoring.yml             # Prometheus, Grafana
│   ├── cache.yml                  # Redis caching
│   ├── proxy.yml                  # Nginx reverse proxy
│   ├── backup.yml                 # Automated backup services
│   ├── development.yml            # Development overrides
│   └── production.yml             # Production hardening
├── images/                         # Custom Docker images
│   ├── prosody/
│   │   ├── Dockerfile             # Multi-stage optimized build
│   │   ├── Dockerfile.alpine      # Lightweight Alpine version
│   │   ├── entrypoint.sh          # Enhanced entrypoint
│   │   └── healthcheck.sh         # Comprehensive health checks
│   ├── prosody-modules/
│   │   ├── Dockerfile             # Community modules builder
│   │   └── update.sh              # Module update automation
│   └── tools/
│       ├── backup/
│       │   └── Dockerfile         # Backup utility image
│       └── monitoring/
│           └── Dockerfile         # Custom monitoring tools
├── configs/                        # External service configs
│   ├── nginx/
│   │   ├── nginx.conf
│   │   ├── prosody.conf
│   │   └── ssl.conf
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   └── rules/
│   ├── grafana/
│   │   ├── datasources/
│   │   └── dashboards/
│   └── logrotate/
│       └── prosody.conf
├── scripts/                        # Enhanced container scripts
│   ├── init/
│   │   ├── 00-validate-env.sh
│   │   ├── 10-setup-ssl.sh
│   │   ├── 20-configure-profile.sh
│   │   └── 30-start-services.sh
│   ├── maintenance/
│   │   ├── backup.sh
│   │   ├── restore.sh
│   │   ├── update-modules.sh
│   │   └── health-check.sh
│   └── deployment/
│       ├── deploy.sh              # Enhanced deployment
│       ├── rollback.sh            # Rollback capability
│       └── scale.sh               # Scaling operations
└── k8s/                           # Kubernetes manifests (NEW)
    ├── namespace.yaml
    ├── configmap.yaml
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── hpa.yaml                   # Horizontal Pod Autoscaler
```

## New Configuration Loading Logic

### Profile-Based Loading

```lua
-- Enhanced prosody.cfg.lua
local profile = os.getenv("PROSODY_PROFILE") or "standard"
local environment = os.getenv("PROSODY_ENVIRONMENT") or "production"

-- Load core configuration (always)
Include("/etc/prosody/core/global.cfg.lua")
Include("/etc/prosody/core/security.cfg.lua")
Include("/etc/prosody/core/database.cfg.lua")

-- Load profile configuration
Include("/etc/prosody/profiles/" .. profile .. "/profile.cfg.lua")

-- Load enabled features based on environment variables
local features = {
    "authentication/basic",
    "messaging/core",
    "security/firewall"
}

-- Add conditional features based on environment
if os.getenv("PROSODY_FEATURES_AUTH_MODERN") == "true" then
    table.insert(features, "authentication/modern")
end

if os.getenv("PROSODY_FEATURES_WEB_ENABLED") == "true" then
    table.insert(features, "web/http")
    table.insert(features, "web/websocket")
end

-- Load feature configurations
for _, feature in ipairs(features) do
    Include("/etc/prosody/features/" .. feature .. ".cfg.lua")
end

-- Load environment-specific overrides
Include("/etc/prosody/environments/" .. environment .. ".cfg.lua")
```

## Enhanced Environment Configuration

### Hierarchical Environment Variables

```bash
# Profile Selection
PROSODY_PROFILE=standard                    # minimal|standard|enterprise|development|custom

# Environment Context
PROSODY_ENVIRONMENT=production              # development|staging|production|testing

# Feature Toggles (granular control)
PROSODY_FEATURES_AUTH_MODERN=true          # SASL2, Bind2, FAST
PROSODY_FEATURES_AUTH_EXTERNAL=false       # LDAP, OAuth
PROSODY_FEATURES_AUTH_MFA=false            # Multi-factor authentication

PROSODY_FEATURES_WEB_ENABLED=true          # HTTP services
PROSODY_FEATURES_WEB_UPLOAD=true           # File upload
PROSODY_FEATURES_WEB_ADMIN=false           # Web admin interface

PROSODY_FEATURES_MOBILE_PUSH=true          # Push notifications
PROSODY_FEATURES_MOBILE_CSI=true           # Client State Indication
PROSODY_FEATURES_MOBILE_BATTERY=true       # Battery optimization

PROSODY_FEATURES_SECURITY_ENHANCED=true    # Enhanced security features
PROSODY_FEATURES_SECURITY_MONITORING=true  # Security monitoring
PROSODY_FEATURES_SECURITY_COMPLIANCE=false # Regulatory compliance

PROSODY_FEATURES_PERFORMANCE_CACHING=false # Redis caching
PROSODY_FEATURES_PERFORMANCE_CLUSTERING=false # Multi-node

PROSODY_FEATURES_ADMIN_SHELL=true          # Admin shell
PROSODY_FEATURES_ADMIN_API=false           # Admin API
PROSODY_FEATURES_ADMIN_MONITORING=true     # Admin monitoring

# Deployment Configuration
PROSODY_DEPLOYMENT_TYPE=docker             # docker|kubernetes|systemd|manual
PROSODY_SCALE_PROFILE=small                # small|medium|large|enterprise
PROSODY_RESOURCE_LIMITS=true               # Apply resource limits

# Legacy Compatibility
PROSODY_LEGACY_MODE=false                  # Enable legacy module structure
PROSODY_MIGRATION_MODE=false               # Migration assistance
```

## Migration Strategy

### Phase 1: Parallel Structure (Weeks 1-2)

1. Create new directory structure alongside current
2. Implement profile loading logic
3. Create minimal and standard profiles
4. Test backward compatibility

### Phase 2: Feature Migration (Weeks 3-4)

1. Migrate current modules to feature-based structure
2. Create feature toggle system
3. Update Docker configuration
4. Test all profiles

### Phase 3: Environment Enhancement (Weeks 5-6)

1. Implement environment-specific configurations
2. Add Kubernetes support
3. Enhanced monitoring and backup
4. Documentation updates

### Phase 4: Production Rollout (Weeks 7-8)

1. Gradual migration of existing deployments
2. Performance testing and optimization
3. Training and documentation
4. Legacy structure deprecation

## Benefits of New Structure

### 1. **Deployment Flexibility**

- **Profile-based deployment** matches real-world usage patterns
- **Easy scaling** from personal to enterprise use
- **Environment-aware** configuration reduces errors
- **Container-native** design for modern infrastructure

### 2. **Maintainability**

- **Feature-based organization** reduces configuration complexity
- **Template system** ensures consistency
- **Modular loading** enables easier testing
- **Clear separation of concerns**

### 3. **Operational Excellence**

- **Automated deployment** with validation
- **Comprehensive monitoring** integration
- **Backup and disaster recovery** built-in
- **Kubernetes support** for cloud-native deployments

### 4. **Developer Experience**

- **Hot-reloading** of feature configurations
- **Development profiles** with debugging enabled
- **Template-based** new feature creation
- **Comprehensive documentation** and examples

## Implementation Examples

### Example Profile Configuration

```lua
-- profiles/standard/profile.cfg.lua
profile_info = {
    name = "Standard",
    description = "Full-featured XMPP server for small to medium teams",
    target_users = "10-100",
    stability = "production-ready",
    features = {
        "authentication/basic",
        "authentication/modern",
        "messaging/core",
        "messaging/archive",
        "collaboration/muc",
        "web/http",
        "mobile/push",
        "security/firewall"
    }
}

-- Profile-specific defaults
default_archive_policy = "roster"
muc_room_default_public = false
http_upload_file_size_limit = 50 * 1024 * 1024  -- 50MB
```

### Example Feature Configuration

```lua
-- features/authentication/modern.cfg.lua
-- Modern Authentication Features
-- XEP-0388: Extensible SASL Profile (SASL2)
-- XEP-0386: Bind 2
-- XEP-0484: Fast Authentication Streamlining Tokens

modules_enabled = modules_enabled or {}

-- SASL2 support
if os.getenv("PROSODY_FEATURES_AUTH_SASL2") ~= "false" then
    table.insert(modules_enabled, "sasl2")
    table.insert(modules_enabled, "sasl2_bind2")
    
    -- SASL2 configuration
    sasl2_require_encryption = true
    sasl2_fast_enabled = os.getenv("PROSODY_AUTH_FAST_TOKENS") == "true"
end

-- Modern authentication mechanisms
sasl_enabled_mechanisms = {
    "SCRAM-SHA-256",
    "SCRAM-SHA-1",
    "PLAIN"  -- Only over TLS
}

-- Downgrade protection
if os.getenv("PROSODY_AUTH_DOWNGRADE_PROTECTION") ~= "false" then
    table.insert(modules_enabled, "sasl_ssdp")
end
```

### Example Docker Compose Enhancement

```yaml
# docker/compose/base.yml
version: '3.8'

services:
  prosody:
    build:
      context: ../images/prosody
      args:
        PROFILE: ${PROSODY_PROFILE:-standard}
        FEATURES: ${PROSODY_FEATURES:-standard}
    image: prosody:${PROSODY_VERSION:-latest}
    container_name: prosody-${PROSODY_ENVIRONMENT:-prod}
    
    environment:
      - PROSODY_PROFILE=${PROSODY_PROFILE:-standard}
      - PROSODY_ENVIRONMENT=${PROSODY_ENVIRONMENT:-production}
      - PROSODY_DOMAIN=${PROSODY_DOMAIN}
      - PROSODY_ADMINS=${PROSODY_ADMINS}
      
    volumes:
      - ./config:/etc/prosody/config:ro
      - prosody_data:/var/lib/prosody/data
      - prosody_logs:/var/log/prosody
      
    networks:
      - prosody_network
      
    healthcheck:
      test: ["/opt/prosody/scripts/health-check.sh"]
      interval: 30s
      timeout: 10s
      retries: 3
      
    deploy:
      resources:
        limits:
          memory: ${PROSODY_MEMORY_LIMIT:-256M}
          cpus: ${PROSODY_CPU_LIMIT:-1.0}
```

## Configuration Management Tools

### Profile Manager Script

```bash
#!/bin/bash
# scripts/profile-manager.sh

PROFILES_DIR="config/profiles"
FEATURES_DIR="config/features"

case "$1" in
    list)
        echo "Available profiles:"
        ls -1 "$PROFILES_DIR" | grep -v template
        ;;
    create)
        if [ -z "$2" ]; then
            echo "Usage: $0 create <profile-name>"
            exit 1
        fi
        cp -r "$PROFILES_DIR/template" "$PROFILES_DIR/$2"
        echo "Created profile: $2"
        ;;
    validate)
        profile="${2:-${PROSODY_PROFILE:-standard}}"
        echo "Validating profile: $profile"
        prosodyctl check config --profile="$profile"
        ;;
    features)
        echo "Available features:"
        find "$FEATURES_DIR" -name "*.cfg.lua" | sed "s|$FEATURES_DIR/||g" | sed 's|\.cfg\.lua||g'
        ;;
esac
```

## Next Steps

1. **Review and approve** this architectural proposal
2. **Create prototype** implementation of the new structure
3. **Test migration** process with current configuration
4. **Implement Phase 1** parallel structure
5. **Gradual rollout** with comprehensive testing
6. **Documentation updates** and training materials

This proposed structure provides a **future-proof foundation** that scales from personal use to enterprise deployments while maintaining the security-first approach and professional quality of your current system.
