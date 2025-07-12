# Prosody XMPP Server - Layer-Based Configuration

This directory contains a comprehensive, layer-based configuration system for Prosody XMPP server. The configuration is organized by XMPP protocol stack layers, making it intuitive for XMPP experts and excellent for troubleshooting.

## 🏗️ Architecture Overview

The configuration follows a **unified "everything enabled"** approach organized by XMPP protocol stack layers:

```
XMPP Protocol Stack Layers:
├── 01-transport    → Network, ports, TLS, compression, connections
├── 02-stream       → Authentication, encryption, stream management
├── 03-stanza       → Routing, filtering, validation, processing  
├── 04-protocol     → Core XMPP, extensions, legacy, experimental
├── 05-services     → Messaging, presence, groupchat, pubsub
├── 06-storage      → Backends, archiving, caching, migration
├── 07-interfaces   → HTTP, WebSocket, BOSH, components
└── 08-integration  → LDAP, OAuth, webhooks, APIs
```

## 📁 Directory Structure

```
config/
├── prosody.cfg.lua              # Main orchestration file
├── global.cfg.lua               # Global settings
├── modules.cfg.lua              # Module management
├── security.cfg.lua             # Security policies
├── vhosts.cfg.lua              # Virtual host templates
├── database.cfg.lua             # Database configuration
├── components.cfg.lua           # Component definitions
├── 
├── stack/                       # Layer-based configuration
│   ├── 01-transport/           # Transport Layer
│   │   ├── ports.cfg.lua       # Port bindings (c2s, s2s, HTTP, components)
│   │   ├── tls.cfg.lua         # TLS/SSL configuration
│   │   ├── compression.cfg.lua # Stream compression (XEP-0138)
│   │   └── connections.cfg.lua # Connection management & QoS
│   │
│   ├── 02-stream/              # Stream Layer  
│   │   ├── authentication.cfg.lua # SASL authentication & backends
│   │   ├── encryption.cfg.lua     # OMEMO, OpenPGP encryption
│   │   ├── management.cfg.lua     # Stream management (XEP-0198)
│   │   └── negotiation.cfg.lua    # Service discovery & capabilities
│   │
│   ├── 03-stanza/              # Stanza Layer
│   │   ├── routing.cfg.lua     # Message routing & delivery
│   │   ├── filtering.cfg.lua   # Firewall & anti-spam
│   │   ├── validation.cfg.lua  # XML schema & security validation
│   │   └── processing.cfg.lua  # Advanced message processing
│   │
│   ├── 04-protocol/            # Protocol Layer
│   │   ├── core.cfg.lua        # RFC 6120/6121 core features
│   │   ├── extensions.cfg.lua  # Modern XEPs (MAM, MUC, etc.)
│   │   ├── legacy.cfg.lua      # Backwards compatibility
│   │   └── experimental.cfg.lua # Cutting-edge features
│   │
│   ├── 05-services/            # Services Layer
│   │   ├── messaging.cfg.lua   # Message delivery & archiving
│   │   ├── presence.cfg.lua    # Presence management
│   │   ├── groupchat.cfg.lua   # Multi-User Chat (MUC)
│   │   └── pubsub.cfg.lua      # Publish-Subscribe services
│   │
│   ├── 06-storage/             # Storage Layer
│   │   ├── backends.cfg.lua    # Storage backend configuration
│   │   ├── archiving.cfg.lua   # Message Archive Management
│   │   ├── caching.cfg.lua     # Performance caching
│   │   └── migration.cfg.lua   # Data migration tools
│   │
│   ├── 07-interfaces/          # Interfaces Layer
│   │   ├── http.cfg.lua        # HTTP server & file upload
│   │   ├── websocket.cfg.lua   # WebSocket support (RFC 7395)
│   │   ├── bosh.cfg.lua        # BOSH for web clients
│   │   └── components.cfg.lua  # External component protocol
│   │
│   └── 08-integration/         # Integration Layer
│       ├── ldap.cfg.lua        # LDAP authentication
│       ├── oauth.cfg.lua       # OAuth 2.0 provider
│       ├── webhooks.cfg.lua    # HTTP callbacks & events
│       └── apis.cfg.lua        # REST API endpoints
│
├── domains/                     # Domain-specific configuration
│   └── main.cfg.lua            # Primary domain setup
│
├── environments/               # Environment-specific settings
│   ├── production.cfg.lua      # Production optimizations
│   ├── development.cfg.lua     # Development settings
│   └── docker.cfg.lua          # Docker-specific config
│
├── policies/                   # Policy-based configuration
│   ├── security/               # Security policies
│   ├── performance/            # Performance tuning
│   └── compliance/             # Compliance requirements
│
└── tools/                      # Configuration management tools
    └── loader.cfg.lua          # Configuration loader utilities
```

## 🚀 Quick Start

### 1. Environment Setup

Set environment variables for your deployment:

```bash
# Required
export PROSODY_DOMAIN="your-domain.com"
export PROSODY_ENVIRONMENT="production"  # or development, docker

# Optional
export PROSODY_DATA_PATH="/var/lib/prosody"
export PROSODY_CONFIG_PATH="/etc/prosody"
export PROSODY_ADMINS="admin@your-domain.com"

# Database (for production)
export PROSODY_DB_DRIVER="PostgreSQL"
export PROSODY_DB_NAME="prosody"
export PROSODY_DB_USER="prosody"
export PROSODY_DB_PASSWORD="your-password"
export PROSODY_DB_HOST="localhost"
```

### 2. Certificate Setup

```bash
# Generate TLS certificates
sudo prosodyctl cert generate your-domain.com
sudo prosodyctl cert generate conference.your-domain.com
sudo prosodyctl cert generate upload.your-domain.com
```

### 3. Database Setup (Production)

```sql
-- PostgreSQL setup
CREATE DATABASE prosody;
CREATE USER prosody WITH PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE prosody TO prosody;
```

### 4. Start Prosody

```bash
# Test configuration
sudo prosodyctl check config

# Start server
sudo systemctl start prosody
sudo systemctl enable prosody
```

## 🔧 Configuration System

### Layer Loading Order

The configuration loads in XMPP protocol stack order:

1. **Transport Layer** - Network foundations
2. **Stream Layer** - Authentication & encryption  
3. **Stanza Layer** - Message processing
4. **Protocol Layer** - XMPP features
5. **Services Layer** - User services
6. **Storage Layer** - Data persistence
7. **Interfaces Layer** - Client connections
8. **Integration Layer** - External systems

### Module Collection

Each layer defines modules in variables like:

- `transport_modules` - Transport layer modules
- `stream_modules` - Stream layer modules
- `stanza_modules` - Stanza layer modules
- etc.

The main configuration automatically collects and enables all modules from all layers.

### Environment Override

Environment-specific settings are applied after layer loading:

```lua
-- Production environment applies:
-- - Enhanced security (forced encryption)
-- - SQL storage backends
-- - Performance optimizations
-- - Comprehensive logging
-- - Rate limiting
```

## 🛡️ Security Features

### Transport Security

- **TLS 1.2+** mandatory
- **Perfect Forward Secrecy** (PFS)
- **OCSP stapling**
- **HSTS headers**
- **Strong cipher suites**

### Authentication

- **SASL 2.0** support
- **SCRAM-SHA-256** default
- **Multi-factor authentication**
- **Enterprise LDAP** integration
- **OAuth 2.0** provider

### Message Security

- **OMEMO encryption** (XEP-0384)
- **OpenPGP integration**
- **Message Archive Management** (XEP-0313)
- **Anti-spam filtering**
- **Content validation**

## 📊 Monitoring & Compliance

### Built-in Monitoring

- **Prometheus metrics** (`/metrics`)
- **Health checks** (`/health`)
- **Performance statistics**
- **Security event logging**

### Compliance Features

- **XMPP Compliance Suites 2023**
- **GDPR compliance** tools
- **Contact information** (XEP-0157)
- **Server information** disclosure
- **Audit logging**

## 🔧 Management Tools

### Configuration Loader

The `tools/loader.cfg.lua` provides utilities:

```lua
local loader = require "tools.loader"

-- Validate configuration
local missing = loader.validate_layers("/etc/prosody")

-- Check for conflicts
local conflicts = loader.check_module_conflicts(all_modules)

-- Test configuration
local results = loader.test_config("/etc/prosody")

-- Create backup
local backup = loader.backup_config("/etc/prosody", "/backups")

-- Debug information
loader.debug_info(all_modules, layer_configs)
```

### Command Line Tools

```bash
# Configuration validation
sudo prosodyctl check config

# Module management
sudo prosodyctl module list
sudo prosodyctl module install mod_name

# User management
sudo prosodyctl adduser user@domain.com
sudo prosodyctl passwd user@domain.com

# Certificate management
sudo prosodyctl cert generate domain.com
sudo prosodyctl cert import domain.com /path/to/cert.pem /path/to/key.pem
```

## 🚀 Performance Optimization

### Production Settings

- **SQL storage** backends
- **Connection pooling**
- **Aggressive garbage collection**
- **Caching strategies**
- **Rate limiting**

### Mobile Optimization

- **Stream Management** (XEP-0198)
- **Client State Indication** (XEP-0352)
- **Push notifications** (XEP-0357)
- **Roster versioning** (XEP-0237)
- **Message Carbons** (XEP-0280)

## 🔌 Supported Features

### Core XMPP (RFC 6120/6121)

✅ **Client-to-Server** (c2s)  
✅ **Server-to-Server** (s2s)  
✅ **SASL Authentication**  
✅ **TLS Encryption**  
✅ **Resource Binding**  
✅ **Session Management**  

### Modern Extensions

✅ **Message Archive Management** (XEP-0313)  
✅ **Message Carbons** (XEP-0280)  
✅ **Stream Management** (XEP-0198)  
✅ **Multi-User Chat** (XEP-0045)  
✅ **Publish-Subscribe** (XEP-0060)  
✅ **Service Discovery** (XEP-0030)  
✅ **Entity Capabilities** (XEP-0115)  
✅ **OMEMO Encryption** (XEP-0384)  
✅ **HTTP File Upload** (XEP-0363)  
✅ **Push Notifications** (XEP-0357)  

### Web Technologies

✅ **BOSH** (XEP-0124/0206)  
✅ **WebSocket** (RFC 7395)  
✅ **HTTP API** endpoints  
✅ **Web administration**  
✅ **File sharing** service  

### Enterprise Features

✅ **LDAP integration**  
✅ **OAuth 2.0** provider  
✅ **Webhook** support  
✅ **Audit logging**  
✅ **Compliance** reporting  
✅ **High availability**  

## 🐛 Troubleshooting

### Layer-by-Layer Debugging

1. **Transport Issues**: Check `01-transport/` configs
   - Port bindings
   - TLS certificates
   - Network connectivity

2. **Authentication Problems**: Check `02-stream/` configs
   - SASL mechanisms
   - User backends
   - Password policies

3. **Message Delivery**: Check `03-stanza/` configs
   - Routing rules
   - Firewall settings
   - Validation errors

4. **Feature Problems**: Check `04-protocol/` configs
   - Module conflicts
   - XEP compatibility
   - Legacy support

### Common Issues

**Module Conflicts**: Use configuration loader to detect:

```lua
local conflicts = loader.check_module_conflicts(all_modules)
```

**Missing Dependencies**: Check layer validation:

```lua
local missing = loader.validate_layers("/etc/prosody")
```

**Performance Issues**: Review production environment settings and enable metrics.

## 📚 Additional Resources

- [Prosody Documentation](https://prosody.im/doc/)
- [XMPP RFCs](https://xmpp.org/rfcs/)
- [XEP Extensions](https://xmpp.org/extensions/)
- [XMPP Compliance Suites](https://xmpp.org/extensions/xep-0423.html)
- [Prosody Modules](https://modules.prosody.im/)

## 🤝 Contributing

When modifying the configuration:

1. **Follow the layer organization** - place configs in appropriate layers
2. **Document XEP references** - include XEP numbers and URLs
3. **Test thoroughly** - use the configuration loader tools
4. **Update this README** - document new features or changes
5. **Validate against compliance** - ensure XMPP standards compliance

---

**🎯 This configuration provides a production-ready, feature-complete XMPP server with modern security, mobile optimization, and enterprise integration capabilities.**
