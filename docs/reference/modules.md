# 📦 Module Reference Guide

This comprehensive guide documents all modules used in the Professional Prosody XMPP Server, their stability levels, purposes, and configuration details.

## 📋 Module Categories

### 🟢 **Core Modules**

- **Status**: Always enabled
- **Risk**: Minimal - part of Prosody core
- **Source**: Built into Prosody core
- **Description**: Essential XMPP functionality required for basic operation

### ✅ **Official Modules**

- **Status**: Enabled by default
- **Risk**: Low - official Prosody modules
- **Source**: Distributed with Prosody
- **Description**: Official modules maintained by Prosody team

### 🟢 **Community Stable Modules**

- **Status**: Enabled by default
- **Risk**: Low - production-ready community modules
- **Source**: prosody-modules repository
- **Description**: Well-tested modules with active maintenance and broad deployment

### 🟡 **Community Beta Modules**

- **Status**: Enabled by default (can be disabled)
- **Risk**: Medium - mostly stable with some edge cases
- **Source**: prosody-modules repository
- **Description**: Mature modules that may have minor issues in specific scenarios

### 🟠 **Community Alpha Modules**

- **Status**: Disabled by default (explicit opt-in required)
- **Risk**: High - experimental features
- **Source**: prosody-modules repository
- **Description**: Cutting-edge features that may have bugs or breaking changes

## 🏗️ Layer-Based Module Organization

Our modules are organized by XMPP protocol stack layers:

### 📡 **01-Transport Layer**

Network foundations and connectivity

- **Core**: Network listeners, port management
- **Security**: TLS, certificate validation
- **Performance**: Compression, connection pooling

### 🔐 **02-Stream Layer**

Authentication and session management

- **Authentication**: SASL, SCRAM, enterprise backends
- **Encryption**: OMEMO, OpenPGP policies
- **Session Management**: Stream Management (XEP-0198)

### 📨 **03-Stanza Layer**

Message processing and routing

- **Routing**: BOSH, WebSocket, message delivery
- **Filtering**: Firewall, anti-spam, content filtering
- **Validation**: XML schema, security validation

### 🎯 **04-Protocol Layer**

Core XMPP features

- **Core**: RFC 6120/6121 compliance
- **Extensions**: Modern XEPs (MAM, Carbons, MUC)
- **Legacy**: Backwards compatibility

### 🌐 **05-Services Layer**

Communication services

- **Messaging**: Message handling, delivery
- **Presence**: Status, availability management
- **Group Chat**: MUC, conference features

### 💾 **06-Storage Layer**

Data persistence

- **Backends**: Database drivers, connection pooling
- **Archiving**: Message archiving, retention
- **Caching**: Performance optimization

### 🔌 **07-Interfaces Layer**

External interfaces

- **HTTP**: Web server, file upload
- **WebSocket**: Real-time web connections
- **BOSH**: HTTP binding for web clients

### 🔗 **08-Integration Layer**

External systems

- **Authentication**: LDAP, OAuth
- **Webhooks**: External notifications
- **APIs**: REST APIs, integrations

## 📊 Module Stability Matrix

### 🟢 Core Modules (Always Enabled)

| Module | Layer | Purpose | XEP |
|--------|--------|---------|-----|
| `roster` | 04-Protocol | Contact list management | RFC 6121 |
| `saslauth` | 02-Stream | Authentication framework | RFC 6120 |
| `tls` | 01-Transport | TLS encryption | RFC 6120 |
| `dialback` | 01-Transport | Server-to-server auth | XEP-0220 |
| `disco` | 04-Protocol | Service discovery | XEP-0030 |
| `carbons` | 05-Services | Multi-device sync | XEP-0280 |
| `pep` | 05-Services | Personal eventing | XEP-0163 |
| `private` | 06-Storage | Private XML storage | XEP-0049 |
| `blocklist` | 03-Stanza | Blocking users | XEP-0191 |
| `vcard4` | 04-Protocol | User profiles | XEP-0292 |
| `vcard_legacy` | 04-Protocol | Legacy vCard support | XEP-0054 |
| `mam` | 06-Storage | Message archiving | XEP-0313 |
| `smacks` | 02-Stream | Stream management | XEP-0198 |

### ✅ Official Modules (Enabled by Default)

| Module | Layer | Purpose | XEP |
|--------|--------|---------|-----|
| `version` | 04-Protocol | Server version info | XEP-0092 |
| `uptime` | 04-Protocol | Server uptime | XEP-0012 |
| `time` | 04-Protocol | Server time | XEP-0202 |
| `ping` | 03-Stanza | XMPP ping | XEP-0199 |
| `register` | 02-Stream | User registration | XEP-0077 |
| `admin_adhoc` | 08-Integration | Admin commands | XEP-0050 |
| `admin_telnet` | 08-Integration | Telnet admin | - |
| `bosh` | 07-Interfaces | HTTP binding | XEP-0124 |
| `websocket` | 07-Interfaces | WebSocket support | RFC 7395 |
| `http_files` | 07-Interfaces | Static file serving | - |
| `http_file_share` | 07-Interfaces | File upload | XEP-0363 |

### 🟢 Community Stable Modules

| Module | Layer | Purpose | Stability |
|--------|--------|---------|-----------|
| `firewall` | 03-Stanza | Advanced filtering | Stable |
| `spam_reporting` | 03-Stanza | Spam reporting | Stable |
| `limits` | 01-Transport | Rate limiting | Stable |
| `log_auth` | 08-Integration | Auth logging | Stable |
| `stanza_counter` | 08-Integration | Stanza metrics | Stable |
| `admin_web` | 07-Interfaces | Web admin | Stable |
| `storage_xmlarchive` | 06-Storage | XML archive backend | Stable |
| `turncredentials` | 04-Protocol | TURN credentials | Stable |
| `external_services` | 04-Protocol | External services | Stable |

### 🟡 Community Beta Modules

| Module | Layer | Purpose | Stability |
|--------|--------|---------|-----------|
| `cloud_notify` | 05-Services | Push notifications | Beta |
| `client_management` | 02-Stream | Client management | Beta |
| `password_reset` | 02-Stream | Password reset | Beta |
| `sasl2` | 02-Stream | SASL 2.0 | Beta |
| `fast` | 02-Stream | Fast auth | Beta |
| `compliance_2023` | 04-Protocol | Compliance suite | Beta |
| `bookmarks` | 05-Services | Bookmarks | Beta |
| `addressing` | 03-Stanza | Message addressing | Beta |
| `extdisco` | 04-Protocol | External discovery | Beta |

### 🟠 Community Alpha Modules

| Module | Layer | Purpose | Stability |
|--------|--------|---------|-----------|
| `omemo_all_access` | 02-Stream | OMEMO management | Alpha |
| `e2e_policy` | 02-Stream | E2E encryption policy | Alpha |
| `filter_chatstates` | 03-Stanza | Filter chat states | Alpha |
| `measure_stanza_counts` | 08-Integration | Stanza measurements | Alpha |
| `anti_spam` | 03-Stanza | Anti-spam features | Alpha |
| `audit` | 08-Integration | Audit logging | Alpha |
| `json_logs` | 08-Integration | JSON log format | Alpha |

## 🎛️ Module Control

### Environment Variables

Control module categories via environment variables:

```bash
# Core modules (always enabled)
PROSODY_ENABLE_CORE=true

# Official modules (enabled by default)
PROSODY_ENABLE_OFFICIAL=true

# Community stable modules (enabled by default)
PROSODY_ENABLE_STABLE=true

# Community beta modules (enabled by default, can disable)
PROSODY_ENABLE_BETA=true

# Community alpha modules (disabled by default)
PROSODY_ENABLE_ALPHA=false
```

### Configuration Files

Modules are configured in layer-specific files:

```
config/stack/
├── 01-transport/
│   ├── ports.cfg.lua       # Network listeners
│   ├── tls.cfg.lua         # TLS configuration
│   └── connections.cfg.lua # Connection management
├── 02-stream/
│   ├── authentication.cfg.lua # Auth modules
│   ├── encryption.cfg.lua     # Encryption modules
│   └── management.cfg.lua     # Session management
└── ... (other layers)
```

## 🔧 Module Development

### Creating Custom Modules

1. **Choose appropriate layer** based on functionality
2. **Follow module naming conventions**
3. **Implement proper error handling**
4. **Add configuration documentation**
5. **Include XEP references where applicable**

### Module Template

```lua
-- mod_example.lua
-- Brief description of module functionality
-- XEP-XXXX: Reference if applicable

module:set_global();

local log = module._log;

-- Module configuration
local config = module:get_option("example_config", {});

-- Module initialization
function module.load()
    log("info", "Example module loaded");
end

-- Module cleanup
function module.unload()
    log("info", "Example module unloaded");
end

-- Export module API
return {
    version = "1.0.0",
    dependencies = {"core_module"},
    status = "stable"
};
```

### Testing Modules

```bash
# Test module syntax
prosodyctl check config

# Test module loading
prosodyctl about

# Monitor module behavior
tail -f /var/log/prosody/prosody.log
```

## 🔄 Module Updates

### Update Process

1. **Backup current configuration**
2. **Update module files**
3. **Test in development environment**
4. **Deploy to production**
5. **Monitor for issues**

### Version Compatibility

| Prosody Version | Module Compatibility |
|----------------|---------------------|
| 0.11.x | Legacy modules only |
| 0.12.x | Core + Official + Stable |
| 0.13.x | All modules supported |

## 📚 Additional Resources

- **[Prosody Module Documentation](https://prosody.im/doc/modules)**
- **[Community Modules](https://modules.prosody.im/)**
- **[XEP Specifications](https://xmpp.org/extensions/)**
- **[Module Development Guide](https://prosody.im/doc/developers/modules)**

---

*This module reference is maintained as part of the Professional Prosody XMPP Server documentation.*
