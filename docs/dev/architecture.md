# 🏗️ Architecture Overview

This document provides a technical overview of the Professional Prosody XMPP Server's layer-based configuration architecture for developers and contributors.

## 🌟 Design Philosophy

### Layer-Based Architecture Principles

Our configuration system is built on these core principles:

1. **Protocol Stack Alignment** - Configuration layers mirror XMPP protocol stack
2. **Separation of Concerns** - Each layer handles specific functionality
3. **Intuitive Organization** - Easy for XMPP experts to navigate
4. **Maintainability** - Clear boundaries between components
5. **Scalability** - Easy to extend with new features

### Why Layer-Based?

**Traditional approach:**

- Monolithic configuration files
- Unclear boundaries between features
- Difficult to troubleshoot
- Hard to maintain and extend

**Our approach:**

- Clear separation by protocol layer
- Intuitive for XMPP protocol experts
- Easy to locate and debug issues
- Modular and extensible

## 🏗️ System Architecture

### Overview Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    XMPP Client Applications                  │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Layer 08: Integration                   │
│          OAuth, LDAP, Webhooks, REST APIs                   │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Layer 07: Interfaces                    │
│         HTTP, WebSocket, BOSH, Components                   │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Layer 06: Storage                       │
│      Database, Archiving, Caching, Migration               │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Layer 05: Services                      │
│      Messaging, Presence, Group Chat, PubSub               │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Layer 04: Protocol                      │
│        Core XMPP, Extensions, Legacy, Experimental         │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Layer 03: Stanza                        │
│       Routing, Filtering, Validation, Processing           │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Layer 02: Stream                        │
│     Authentication, Encryption, Management, Negotiation    │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Layer 01: Transport                     │
│          Ports, TLS, Compression, Connections              │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    Network Infrastructure                   │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Configuration Structure

### Directory Layout

```
config/
├── prosody.cfg.lua              # Main configuration loader
├── stack/                       # Layer-based configuration (32 files)
│   ├── 01-transport/            # Network & TLS foundations
│   │   ├── ports.cfg.lua        # Port bindings and listeners
│   │   ├── tls.cfg.lua          # TLS/SSL configuration
│   │   ├── compression.cfg.lua  # Stream compression settings
│   │   └── connections.cfg.lua  # Connection management
│   ├── 02-stream/               # Authentication & session layer
│   │   ├── authentication.cfg.lua # Authentication methods
│   │   ├── encryption.cfg.lua    # Encryption policies
│   │   ├── management.cfg.lua    # Session management
│   │   └── negotiation.cfg.lua   # Feature negotiation
│   ├── 03-stanza/               # Message processing layer
│   │   ├── routing.cfg.lua      # Message routing
│   │   ├── filtering.cfg.lua    # Content filtering
│   │   ├── validation.cfg.lua   # Input validation
│   │   └── processing.cfg.lua   # Message processing
│   ├── 04-protocol/             # Core XMPP features
│   │   ├── core.cfg.lua         # RFC 6120/6121 features
│   │   ├── extensions.cfg.lua   # Modern XEP implementations
│   │   ├── legacy.cfg.lua       # Backwards compatibility
│   │   └── experimental.cfg.lua # Experimental features
│   ├── 05-services/             # Communication services
│   │   ├── messaging.cfg.lua    # Message handling
│   │   ├── presence.cfg.lua     # Presence management
│   │   ├── groupchat.cfg.lua    # Multi-user chat
│   │   └── pubsub.cfg.lua       # Publish-subscribe
│   ├── 06-storage/              # Data persistence
│   │   ├── backends.cfg.lua     # Database backends
│   │   ├── archiving.cfg.lua    # Message archiving
│   │   ├── caching.cfg.lua      # Performance caching
│   │   └── migration.cfg.lua    # Data migration
│   ├── 07-interfaces/           # External interfaces
│   │   ├── http.cfg.lua         # HTTP server
│   │   ├── websocket.cfg.lua    # WebSocket interface
│   │   ├── bosh.cfg.lua         # BOSH interface
│   │   └── components.cfg.lua   # External components
│   └── 08-integration/          # External systems
│       ├── ldap.cfg.lua         # LDAP integration
│       ├── oauth.cfg.lua        # OAuth authentication
│       ├── webhooks.cfg.lua     # HTTP webhooks
│       └── apis.cfg.lua         # REST APIs
├── domains/                     # Domain configurations
├── environments/                # Environment-specific settings
├── policies/                    # Security & compliance policies
├── firewall/                    # Firewall rules
└── tools/                       # Configuration utilities
```

## 🔄 Configuration Loading Process

### Loading Sequence

1. **Main Configuration** (`prosody.cfg.lua`)
   - Loads environment detection
   - Initializes layer-based loader
   - Sets up global configuration

2. **Layer-Based Loading** (Sequential)
   - Loads each layer in order (01-08)
   - Processes 4 files per layer
   - Merges configurations

3. **Domain Loading**
   - Loads domain-specific configurations
   - Applies domain overrides

4. **Environment Loading**
   - Applies environment-specific settings
   - Overrides based on deployment mode

### Configuration Merging

```lua
-- Example of configuration merging
local function merge_config(base, override)
    for key, value in pairs(override) do
        if type(value) == "table" and type(base[key]) == "table" then
            merge_config(base[key], value)
        else
            base[key] = value
        end
    end
    return base
end
```

## 🎯 Layer Details

### Layer 01: Transport

**Purpose**: Network foundations and connectivity
**Key Components**:

- Port bindings (5222, 5269, 5280, 5281)
- TLS configuration and certificate management
- Stream compression (XEP-0138)
- Connection management and rate limiting

### Layer 02: Stream

**Purpose**: Authentication and session management
**Key Components**:

- SASL authentication mechanisms
- Stream Management (XEP-0198)
- Encryption policies (OMEMO, OpenPGP)
- Feature negotiation and capabilities

### Layer 03: Stanza

**Purpose**: Message processing and routing
**Key Components**:

- Message routing and delivery
- Content filtering and firewall
- Input validation and security
- Advanced message processing

### Layer 04: Protocol

**Purpose**: Core XMPP features and extensions
**Key Components**:

- RFC 6120/6121 compliance
- Modern XEP implementations
- Legacy protocol support
- Experimental features

### Layer 05: Services

**Purpose**: Communication services
**Key Components**:

- Message handling and delivery
- Presence and availability
- Multi-user chat (MUC)
- Publish-subscribe (PubSub)

### Layer 06: Storage

**Purpose**: Data persistence and management
**Key Components**:

- Database backends (SQLite, PostgreSQL, MySQL)
- Message archiving (XEP-0313)
- Performance caching
- Data migration tools

### Layer 07: Interfaces

**Purpose**: External interfaces and protocols
**Key Components**:

- HTTP server and file upload
- WebSocket connections
- BOSH (HTTP binding)
- External component protocol

### Layer 08: Integration

**Purpose**: External system integration
**Key Components**:

- LDAP directory services
- OAuth 2.0 authentication
- HTTP webhooks
- REST API endpoints

## 🔧 Development Patterns

### Configuration Module Template

```lua
-- Layer XX: Name - Description
-- Brief description of layer functionality
-- XEP references where applicable

local layer_config = {
    -- Core functionality
    core = {
        -- Core modules and settings
    },
    
    -- Security features
    security = {
        -- Security-related configuration
    },
    
    -- Performance optimizations
    performance = {
        -- Performance tuning settings
    },
    
    -- Monitoring and diagnostics
    monitoring = {
        -- Monitoring configuration
    },
}

-- Configuration utilities
local layer_utilities = {
    -- Helper functions
    configure_feature = function(options)
        -- Configuration logic
    end,
    
    -- Validation functions
    validate_config = function(config)
        -- Validation logic
    end,
}

-- Export configuration
return {
    modules = layer_config,
    utilities = layer_utilities,
    version = "1.0.0",
    dependencies = {"dependency1", "dependency2"},
}
```

### Module Organization

**Naming Convention**:

- `core` - Essential functionality
- `security` - Security-related features
- `performance` - Performance optimizations
- `monitoring` - Monitoring and diagnostics
- `utilities` - Helper functions

### Environment Detection

```lua
local function get_environment()
    local env = os.getenv("PROSODY_ENV") or "production"
    return env
end

local function is_feature_enabled(feature)
    local env_var = "PROSODY_ENABLE_" .. feature:upper()
    return os.getenv(env_var) == "true"
end
```

## 🧪 Testing Strategy

### Unit Testing

```lua
-- Test configuration loading
local function test_config_loading()
    local config = require("config.stack.01-transport.tls")
    assert(config.modules, "Config must have modules")
    assert(config.utilities, "Config must have utilities")
end

-- Test environment detection
local function test_environment_detection()
    os.setenv("PROSODY_ENV", "testing")
    local env = get_environment()
    assert(env == "testing", "Environment detection failed")
end
```

### Integration Testing

```bash
# Test full configuration loading
prosodyctl check config

# Test layer-specific configuration
prosodyctl check config --layer=01-transport

# Test environment-specific loading
PROSODY_ENV=testing prosodyctl check config
```

## 🔄 Extension Points

### Adding New Layers

1. **Create layer directory**
2. **Implement layer modules**
3. **Update main loader**
4. **Add documentation**
5. **Create tests**

### Adding New Modules

1. **Choose appropriate layer**
2. **Follow naming conventions**
3. **Implement configuration structure**
4. **Add utility functions**
5. **Update layer exports**

### Environment Integration

```lua
-- Environment-specific overrides
local function apply_environment_overrides(config)
    local env = get_environment()
    
    if env == "development" then
        -- Development-specific settings
        config.debug = true
        config.logging = "verbose"
    elseif env == "production" then
        -- Production-specific settings
        config.debug = false
        config.logging = "info"
    end
    
    return config
end
```

## 📊 Performance Considerations

### Configuration Loading Performance

- **Lazy Loading**: Load configurations only when needed
- **Caching**: Cache compiled configurations
- **Optimization**: Minimize file I/O operations

### Memory Usage

- **Efficient Data Structures**: Use appropriate data structures
- **Garbage Collection**: Minimize temporary objects
- **Resource Cleanup**: Clean up unused resources

### Startup Time

- **Parallel Loading**: Load independent layers in parallel
- **Precompilation**: Precompile configurations when possible
- **Validation Caching**: Cache validation results

## 🔍 Debugging and Troubleshooting

### Configuration Debugging

```lua
-- Debug configuration loading
local function debug_config_loading()
    print("Loading layer configurations...")
    
    for layer = 1, 8 do
        local layer_name = string.format("%02d-layer", layer)
        print("Loading layer: " .. layer_name)
        
        -- Load and validate layer
        local success, config = pcall(require, "config.stack." .. layer_name)
        if success then
            print("  ✓ Layer loaded successfully")
        else
            print("  ✗ Layer failed to load: " .. config)
        end
    end
end
```

### Common Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Module not found | Error during loading | Check module path and name |
| Configuration conflict | Unexpected behavior | Review layer dependencies |
| Performance issues | Slow startup | Optimize configuration loading |
| Memory leaks | Increasing memory usage | Review resource cleanup |

## 📚 Development Resources

### Key Files

- **[prosody.cfg.lua](../../config/prosody.cfg.lua)** - Main configuration
- **[Layer Templates](../../config/stack/)** - Layer configuration files
- **[Module Reference](../reference/modules.md)** - Module documentation

### Development Tools

- **Configuration Validator** - Validates configuration syntax
- **Layer Tester** - Tests individual layers
- **Performance Profiler** - Analyzes loading performance
- **Dependency Checker** - Validates dependencies

### Contributing Guidelines

1. **Follow layer-based architecture**
2. **Use consistent naming conventions**
3. **Include comprehensive documentation**
4. **Add appropriate tests**
5. **Maintain backward compatibility**

---

*This architecture guide is maintained by the development team and updated with each major release.*
