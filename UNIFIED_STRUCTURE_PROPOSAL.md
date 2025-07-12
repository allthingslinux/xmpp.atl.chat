# Unified All-Features Module Structure Proposal

## Executive Summary

This proposal outlines a **unified, feature-complete architecture** that includes ALL XMPP features in a single configuration while maintaining excellent modularity, Docker support, and long-term maintainability.

## Core Philosophy: "Everything Enabled, Intelligently Organized"

Instead of profiles, we organize by **functional domains** with **smart defaults** and **environment-aware toggles**. Every feature is available, but can be fine-tuned per environment.

## Proposed Directory Structure

```
config/
├── prosody.cfg.lua                 # Main entry point
├── environments/
│   ├── development.cfg.lua         # Dev-specific overrides
│   ├── staging.cfg.lua             # Staging-specific overrides  
│   ├── production.cfg.lua          # Production-specific overrides
│   └── testing.cfg.lua             # Testing-specific overrides
├── features/
│   ├── core/
│   │   ├── messaging.cfg.lua       # Core XMPP messaging (RFC 6120/6121)
│   │   ├── presence.cfg.lua        # Presence and roster management
│   │   ├── storage.cfg.lua         # Database and storage backends
│   │   └── networking.cfg.lua      # Network, ports, SSL/TLS
│   ├── authentication/
│   │   ├── methods.cfg.lua         # All auth methods (SASL, OAuth, etc)
│   │   ├── registration.cfg.lua    # User registration and management
│   │   └── security.cfg.lua        # Security policies and restrictions
│   ├── messaging/
│   │   ├── mam.cfg.lua            # Message Archive Management (XEP-0313)
│   │   ├── carbons.cfg.lua        # Message Carbons (XEP-0280)
│   │   ├── delivery.cfg.lua       # Delivery receipts and chat states
│   │   └── offline.cfg.lua        # Offline message handling
│   ├── mobile/
│   │   ├── push.cfg.lua           # Push notifications (XEP-0357)
│   │   ├── csi.cfg.lua            # Client State Indication (XEP-0352)
│   │   └── smacks.cfg.lua         # Stream Management (XEP-0198)
│   ├── web/
│   │   ├── http.cfg.lua           # HTTP server and BOSH/WebSocket
│   │   ├── upload.cfg.lua         # HTTP File Upload (XEP-0363)
│   │   └── websocket.cfg.lua      # WebSocket connections
│   ├── collaboration/
│   │   ├── muc.cfg.lua            # Multi-User Chat (XEP-0045)
│   │   ├── pubsub.cfg.lua         # Publish-Subscribe (XEP-0060)
│   │   ├── mix.cfg.lua            # Mediated Information eXchange (XEP-0369)
│   │   └── conferencing.cfg.lua   # Video/audio conferencing support
│   ├── compliance/
│   │   ├── gdpr.cfg.lua           # GDPR compliance features
│   │   ├── retention.cfg.lua      # Data retention policies
│   │   ├── audit.cfg.lua          # Audit logging and compliance
│   │   └── legal.cfg.lua          # Legal hold and data export
│   ├── security/
│   │   ├── firewall.cfg.lua       # Advanced firewall rules
│   │   ├── antispam.cfg.lua       # Anti-spam and abuse prevention
│   │   ├── encryption.cfg.lua     # E2EE support and requirements
│   │   └── monitoring.cfg.lua     # Security monitoring and alerts
│   ├── administration/
│   │   ├── admin.cfg.lua          # Admin interfaces and tools
│   │   ├── metrics.cfg.lua        # Prometheus metrics and monitoring
│   │   ├── logging.cfg.lua        # Comprehensive logging configuration
│   │   └── backup.cfg.lua         # Backup and recovery features
│   └── integrations/
│       ├── ldap.cfg.lua           # LDAP/Active Directory integration
│       ├── external-auth.cfg.lua  # External authentication systems
│       ├── webhooks.cfg.lua       # Webhook integrations
│       └── apis.cfg.lua           # REST APIs and external interfaces
├── domains/
│   ├── main.cfg.lua               # Primary domain configuration
│   ├── conference.cfg.lua         # Conference subdomain
│   ├── upload.cfg.lua             # File upload subdomain
│   └── proxy.cfg.lua              # Proxy/gateway subdomains
├── policies/
│   ├── default.cfg.lua            # Default policies for all features
│   ├── security-levels.cfg.lua    # Security level definitions
│   └── feature-toggles.cfg.lua    # Environment-specific feature toggles
└── scripts/
    ├── load-features.lua          # Dynamic feature loading logic
    ├── environment-detect.lua     # Environment detection and setup
    └── validation.lua             # Configuration validation
```

## Key Design Principles

### 1. **Everything Enabled by Default**

- All features are included and enabled with sensible defaults
- Environment-specific toggles can disable features if needed
- No feature exclusion - only intelligent configuration

### 2. **Functional Domain Organization**

- Features grouped by what they DO, not stability level
- Clear separation of concerns
- Easy to find and modify specific functionality

### 3. **Environment-Aware Configuration**

```lua
-- Example: features/mobile/push.cfg.lua
local env = prosody.environment or "production"

-- Always enable push notifications, but adjust settings per environment
modules_enabled = {
    "cloud_notify",           -- XEP-0357: Push Notifications
    "cloud_notify_extensions",
    "cloud_notify_priority_tag"
}

-- Environment-specific configuration
if env == "development" then
    cloud_notify_debug = true
    push_notification_important_body = "Debug: {body}"
elseif env == "production" then
    cloud_notify_max_devices = 10
    push_notification_rate_limit = 100
end

-- Feature always available, configuration adapts
cloud_notify_priority_threshold = 1
```

### 4. **Smart Dependency Management**

```lua
-- features/messaging/mam.cfg.lua
-- Message Archive Management - always enabled with intelligent defaults

modules_enabled = {
    "mam",                    -- XEP-0313: Message Archive Management
    "mam_muc",               -- MAM for group chats
}

-- Auto-configure based on storage backend
local storage_backend = prosody.storage_backend or "internal"

if storage_backend == "sql" then
    archive_expires_after = "1y"     -- 1 year retention for SQL
    max_archive_query_results = 1000
elseif storage_backend == "internal" then
    archive_expires_after = "1m"     -- 1 month for internal storage
    max_archive_query_results = 100
end

-- Always enable, but adapt to capabilities
default_archive_policy = "roster"    -- Archive for roster contacts
```

## Implementation Strategy

### Phase 1: Restructure Without Breaking

1. **Create new structure alongside existing**
2. **Migrate configurations incrementally**
3. **Maintain backward compatibility**
4. **Test extensively**

### Phase 2: Enhanced Docker Integration

```yaml
# docker-compose.yml enhancement
services:
  prosody:
    build: .
    environment:
      - PROSODY_ENVIRONMENT=production
      - PROSODY_DOMAIN=${DOMAIN}
      - PROSODY_ADMIN_EMAIL=${ADMIN_EMAIL}
      # All features enabled, environment-specific tuning
      - ENABLE_DEBUG_LOGGING=${DEBUG:-false}
      - STORAGE_BACKEND=${STORAGE:-sql}
      - MAX_UPLOAD_SIZE=${MAX_UPLOAD_SIZE:-100MB}
    volumes:
      - ./config:/etc/prosody:ro
      - prosody_data:/var/lib/prosody
      - prosody_certs:/etc/prosody/certs
```

### Phase 3: Configuration Management

```lua
-- config/prosody.cfg.lua (main entry point)
-- Detect environment
local environment = os.getenv("PROSODY_ENVIRONMENT") or "production"
prosody.environment = environment

-- Load all feature configurations
local feature_loader = require "scripts.load-features"
feature_loader.load_all_features()

-- Apply environment-specific overrides
local env_config = "environments/" .. environment .. ".cfg.lua"
if lfs.attributes(env_config) then
    dofile(env_config)
end

-- Validate final configuration
require "scripts.validation".validate_config()
```

## Benefits of This Approach

### ✅ **Unified Feature Set**

- Single configuration includes ALL XMPP features
- No feature exclusion or complex profile selection
- Everything works out of the box

### ✅ **Intelligent Defaults**

- Smart configuration based on environment detection
- Automatic optimization for different deployment contexts
- Sensible security and performance defaults

### ✅ **Maintainable Modularity**

- Clear functional organization
- Easy to find and modify specific features
- Independent feature development and testing

### ✅ **Docker-Native Design**

- Environment variables control behavior
- Container-friendly configuration management
- Easy scaling and deployment

### ✅ **Future-Proof Architecture**

- New features easily added to appropriate domains
- Environment-specific customization without code duplication
- Clear upgrade and migration paths

## Migration Path

1. **Week 1**: Create new directory structure
2. **Week 2**: Migrate core features to new organization
3. **Week 3**: Migrate advanced features and integrations
4. **Week 4**: Update Docker configuration and scripts
5. **Week 5**: Testing and validation
6. **Week 6**: Documentation and deployment

This approach gives you the "everything enabled" philosophy you want while maintaining the modularity and maintainability benefits of good organization.
