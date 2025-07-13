# Modern Prosody Features Integration

This document describes the integration of modern Prosody features (13.0+) into our layer-based XMPP server configuration, based on the official [Prosody configuration documentation](https://prosody.im/doc/configure).

## Overview

Our configuration has been enhanced with the latest Prosody features while maintaining the existing layer-based architecture. The improvements focus on security, credential management, and operational excellence.

## New Features Implemented

### 1. Credential Management (Prosody 13.0+)

**File**: `config/tools/security/credentials.cfg.lua`

Implements secure credential handling using the new `Credential()` directive:

```lua
-- Secure database password loading
sql = {
    driver = "PostgreSQL",
    database = "prosody", 
    username = "prosody",
    password = Credential("db_password"), -- Secure from CREDENTIALS_DIRECTORY
    host = "localhost"
}
```

**Benefits**:

- Integration with systemd `LoadCredential=`
- Compatible with podman/docker secrets
- Eliminates plaintext passwords in configuration files
- Supports enterprise credential management systems

**Setup**:

```bash
# Systemd service example
[Service]
DynamicUser=true
LoadCredential=db_password:/etc/prosody/secrets/db_password
Environment=CREDENTIALS_DIRECTORY=%d/credentials
```

### 2. File Content Directives (Prosody 13.0+)

Dynamic configuration loading from external files:

```lua
-- Dynamic administrator list
admins = FileLines("config/security/admin-list.txt")

-- System MOTD integration
motd_text = FileContents("/etc/motd")

-- Certificate path management
ssl_certificate = FileLine("config/tls/cert-path.txt")
```

**Benefits**:

- No config reload needed for admin changes
- Integration with system announcements
- Automated certificate rotation support
- External security policy management

### 3. Enhanced Module Loading

**File**: `config/tools/core/module-loader.cfg.lua`

Advanced module management with:

- **Dependency Resolution**: Automatic loading order based on module dependencies
- **XEP Compliance Tracking**: Documentation of which XEPs each module implements
- **Error Handling**: Graceful handling of missing modules
- **Consistent Naming**: Enforces consistent module naming patterns

```lua
-- Example usage
local loader = require("config.tools.core.module-loader")
loader.load_module_set({"mam", "carbons", "smacks"}, "example.com")
loader.generate_compliance_report()
```

### 4. Advanced Logging Configuration

Based on the [Logging Configuration](https://prosody.im/doc/logging) documentation:

```lua
log = {
    -- Development console output
    { levels = { min = "debug" }, to = "console", timestamps = true },
    
    -- Production file logging
    { levels = { min = "info" }, to = "file", filename = "/var/log/prosody/prosody.log" },
    
    -- Security event logging
    { levels = { "warn", "error" }, to = "file", filename = "/var/log/prosody/security.log" },
    
    -- Audit trail
    { events = { "authentication-success", "authentication-failure" }, 
      to = "file", filename = "/var/log/prosody/audit.log" },
      
    -- Syslog integration
    { levels = { min = "warn" }, to = "*syslog", syslog_name = "prosody" }
}
```

### 5. Modern Security Defaults

Alignment with current security best practices:

```lua
-- Mozilla TLS recommendations
tls_profile = "intermediate"

-- Mandatory encryption
c2s_require_encryption = true
s2s_require_encryption = true

-- Secure POSIX settings (no mod_posix required in 13.0+)
pidfile = "/run/prosody/prosody.pid"
umask = "027"
```

## Integration with Existing Architecture

### Layer-Based Loading Enhancement

The main configuration file (`config/prosody.cfg.lua`) now includes:

1. **Credential Loading**: Called before other configurations
2. **Enhanced Error Handling**: Better detection of missing files
3. **Feature Detection**: Automatic detection of Prosody version capabilities

### Backward Compatibility

All enhancements are backward compatible:

- Environment variable fallbacks for older Prosody versions
- Graceful degradation when new features aren't available
- Existing layer structure preserved

## Deployment Considerations

### Systemd Integration

For modern systemd deployments:

```ini
[Unit]
Description=Prosody XMPP Server
After=network.target

[Service]
Type=simple
User=prosody
Group=prosody
DynamicUser=true
LoadCredential=db_password:/etc/prosody/secrets/db_password
LoadCredential=ldap_password:/etc/prosody/secrets/ldap_password
Environment=CREDENTIALS_DIRECTORY=%d/credentials
Environment=PROSODY_ENV=production
ExecStart=/usr/bin/prosody
Restart=always

[Install]
WantedBy=multi-user.target
```

### Container Deployment

For containerized environments:

```bash
# Podman with secrets
podman secret create prosody_db_password /path/to/password/file
podman run --secret prosody_db_password \
           -e CREDENTIALS_DIRECTORY=/run/secrets \
           prosody:latest
```

## XEP Compliance Tracking

The enhanced module loader automatically tracks XEP compliance:

| Module | XEP | Description |
|--------|-----|-------------|
| mam | XEP-0313 | Message Archive Management |
| carbons | XEP-0280 | Message Carbons |
| smacks | XEP-0198 | Stream Management |
| csi_simple | XEP-0352 | Client State Indication |
| http_upload | XEP-0363 | HTTP File Upload |
| websocket | RFC 7395 | WebSocket Subprotocol for XMPP |
| bosh | XEP-0124/0206 | BOSH |

## Configuration Validation

Enhanced configuration validation includes:

- Module dependency checking
- Credential availability verification
- File existence validation
- XEP compliance reporting

## Migration Guide

### From Basic Configuration

To adopt these features in an existing Prosody setup:

1. **Update Prosody**: Ensure version 13.0 or later
2. **Add Credential Support**: Set up `CREDENTIALS_DIRECTORY`
3. **Update Logging**: Migrate to advanced logging configuration
4. **Enable Module Loader**: Integrate enhanced module management

### From Legacy Configuration

1. **Preserve Existing Settings**: All current configurations remain valid
2. **Gradual Migration**: Adopt new features incrementally
3. **Test Environment**: Validate in development before production deployment

## Example Configurations

See `examples/prosody-13-features.cfg.lua` for a complete demonstration of all modern features integrated together.

## References

- [Official Prosody Configuration Documentation](https://prosody.im/doc/configure)
- [Prosody 13.0 Release Notes](https://prosody.im/doc/release/0.13.0)
- [Logging Configuration](https://prosody.im/doc/logging)
- [Security Best Practices](https://prosody.im/doc/security)
- [Certificate Management](https://prosody.im/doc/certificates)
