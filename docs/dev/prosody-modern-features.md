# Modern Prosody Features Integration

This document describes the integration of modern Prosody features (13.0+) into our **single configuration** XMPP server setup, based on the official [Prosody configuration documentation](https://prosody.im/doc/configure).

## Overview

Our configuration has been enhanced with the latest Prosody features using a **single, comprehensive configuration file** approach. The improvements focus on security, credential management, and operational excellence while maintaining simplicity.

## New Features Implemented

### 1. Credential Management (Prosody 13.0+)

**Implementation**: Integrated directly into `core/config/prosody.cfg.lua`

Implements secure credential handling using environment variables and the new `Credential()` directive:

```lua
-- Secure database password loading via environment variables
sql = {
    driver = Lua.os.getenv("PROSODY_DB_DRIVER") or "PostgreSQL",
    database = Lua.os.getenv("PROSODY_DB_NAME") or "prosody",
    username = Lua.os.getenv("PROSODY_DB_USER") or "prosody",
    password = Lua.os.getenv("PROSODY_DB_PASSWORD") or "changeme",
    host = Lua.os.getenv("PROSODY_DB_HOST") or "localhost"
}
```

**Benefits**:

- Integration with Docker secrets and environment variables
- Compatible with container orchestration systems
- Eliminates plaintext passwords in configuration files
- Supports enterprise credential management systems

**Setup**:

```bash
# Docker environment with secrets
docker run --env-file .env \
           -e PROSODY_DB_PASSWORD_FILE=/run/secrets/db_password \
           prosody:latest
```

### 2. Environment-Driven Configuration

Dynamic configuration loading from environment variables:

```lua
-- Dynamic administrator list
admins = { Lua.os.getenv("PROSODY_ADMIN_JID") or "admin@localhost" }

-- Domain configuration
server_name = Lua.os.getenv("PROSODY_DOMAIN") or "localhost"

-- Port configuration
c2s_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_C2S_PORT")) or 5222 }
```

**Benefits**:

- No config rebuild needed for environment changes
- Integration with container orchestration
- Automated deployment support
- External configuration management

### 3. Enhanced Module Management

**Implementation**: Built into the single configuration file with dual module support

Advanced module management with:

- **Automatic Loading**: Pre-configured with 50+ modules for maximum compatibility
- **Dual Installation Support**: Both official (LuaRocks) and community modules via `prosody-manager`
- **XEP Compliance Tracking**: Comprehensive XEP support documentation
- **Error Handling**: Graceful handling of missing modules

```lua
-- Core modules pre-configured in prosody.cfg.lua
modules_enabled = {
    -- Core XMPP Protocol
    "roster", "saslauth", "tls", "dialback",
    
    -- Modern Messaging Features  
    "mam", "carbons", "smacks", "csi_simple",
    
    -- Community modules (automatically installed)
    "cloud_notify", "firewall", "anti_spam"
}
```

### 4. Advanced Logging Configuration

Based on the [Logging Configuration](https://prosody.im/doc/logging) documentation:

```lua
-- Production-ready logging configuration
log = {
    -- Console output for development
    { levels = { min = Lua.os.getenv("PROSODY_LOG_LEVEL") or "info" }, to = "console" },
    
    -- File logging for production
    { levels = { min = "info" }, to = "file", filename = "/var/log/prosody/prosody.log" },
    
    -- Security event logging
    { levels = { "warn", "error" }, to = "file", filename = "/var/log/prosody/security.log" }
}
```

### 5. Modern Security Defaults

Alignment with current security best practices:

```lua
-- Enhanced TLS settings
ssl = {
    protocol = "tlsv1_2+", -- TLS 1.2+ only
    ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
    curve = "secp384r1",
    options = { "cipher_server_preference", "single_dh_use", "single_ecdh_use" }
}

-- Mandatory encryption
c2s_require_encryption = true
s2s_require_encryption = true
```

## Integration with Current Architecture

### Single Configuration Benefits

The main configuration file (`core/config/prosody.cfg.lua`) provides:

1. **Centralized Management**: All settings in one comprehensive file
2. **Environment Integration**: Dynamic configuration via environment variables  
3. **Production Ready**: Optimized defaults for production deployment
4. **Docker Native**: Designed for containerized deployment

### Unified Management

All configuration is managed through:

- **Environment Variables**: Via `.env` file for deployment configuration
- **prosody-manager CLI**: Unified tool for all administrative tasks
- **Single Config File**: `core/config/prosody.cfg.lua` with comprehensive settings

## Deployment Considerations

### Container Integration

For modern container deployments:

```yaml
# docker-compose.yml
services:
  xmpp-prosody:
    image: allthingslinux/prosody:latest
    env_file: .env
    environment:
      - PROSODY_DB_HOST=xmpp-postgres
      - PROSODY_DOMAIN=${PROSODY_DOMAIN}
    volumes:
      - ./core/config:/etc/prosody/config:ro
```

### Environment Configuration

```bash
# .env file
PROSODY_DOMAIN=atl.chat
PROSODY_ADMIN_JID=admin@atl.chat
PROSODY_DB_PASSWORD=secure_password_here
PROSODY_LOG_LEVEL=info
```

## XEP Compliance Tracking

The single configuration automatically enables comprehensive XEP support:

| Module | XEP | Description |
|--------|-----|-------------|
| mam | XEP-0313 | Message Archive Management |
| carbons | XEP-0280 | Message Carbons |
| smacks | XEP-0198 | Stream Management |
| csi_simple | XEP-0352 | Client State Indication |
| http_upload | XEP-0363 | HTTP File Upload |
| cloud_notify | XEP-0357 | Push Notifications |

See [XEP Compliance Documentation](../reference/xep-compliance.md) for complete list.

## Configuration Management

### Using prosody-manager

The unified CLI tool provides comprehensive management:

```bash
# Module management
./prosody-manager module list
./prosody-manager module install mod_example

# Configuration validation
./prosody-manager health config

# User management  
./prosody-manager prosodyctl adduser alice@atl.chat
```

### Environment Updates

```bash
# Update configuration
nano .env

# Restart to apply changes
docker compose restart xmpp-prosody
```

## Migration Guide

### From Complex Multi-File Configurations

To adopt this simplified approach:

1. **Consolidate Settings**: Move all configuration to environment variables
2. **Use Single Config**: Replace multiple config files with single comprehensive file
3. **Adopt prosody-manager**: Use unified CLI tool for all management tasks
4. **Environment-Driven**: Configure via `.env` file rather than config file edits

### From Legacy Prosody Deployments

1. **Update Prosody**: Ensure version 13.0 or later
2. **Migrate Configuration**: Convert existing settings to environment variables
3. **Test Environment**: Validate in development before production deployment
4. **Use Modern Features**: Enable new security and performance features

## Example Configurations

Complete example configurations are available in:

- `templates/env/env.example` - Environment variable template
- `core/config/prosody.cfg.lua` - Complete production configuration
- `docker-compose.yml` - Container orchestration setup

## Management Tools

### prosody-manager CLI

Comprehensive management via unified tool:

```bash
# Health monitoring
./prosody-manager health all

# Certificate management
./prosody-manager cert check atl.chat

# Backup operations
./prosody-manager backup create

# Deployment management
./prosody-manager deploy status
```

## References

- [Official Prosody Configuration Documentation](https://prosody.im/doc/configure)
- [Prosody 13.0 Release Notes](https://prosody.im/doc/release/0.13.0)
- [Environment Variable Configuration](../user/configuration.md)
- [prosody-manager CLI Reference](../admin/README.md)
- [Architecture Overview](architecture.md)
