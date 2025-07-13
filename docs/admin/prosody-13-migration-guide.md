# Prosody 13.0 Migration Guide

This guide covers the migration from earlier Prosody versions to 13.0, specifically tailored for our layer-based XMPP server configuration.

## Overview

Prosody 13.0.0 was released on March 17, 2025, with significant new features and some breaking changes. Our configuration has been enhanced to take advantage of these improvements while maintaining backward compatibility.

## ⚠️ Critical Breaking Changes

### 1. Lua 5.1 Support Removed

**Issue**: Prosody 13.0 no longer supports Lua 5.1 or LuaJIT.

**Solution**:

- Ensure Lua 5.2+ is installed (Lua 5.4 recommended)
- On Debian/Ubuntu: `update-alternatives --config lua-interpreter`

**Check**: `lua -v` should show Lua 5.2 or higher

### 2. Component Permissions Changed

**Issue**: The new roles and permissions framework affects component access.

**Affected Components**:

- `mod_http_file_share` (file uploads)
- `mod_muc` (chat rooms)

**Solutions Applied**:

```lua
-- For direct subdomains (automatically handled)
Component "upload.example.com" "http_file_share"
-- parent_host is automatically detected

-- For non-direct subdomains
Component "upload.xmpp.example.com" "http_file_share"
parent_host = "example.com"

-- For multi-domain setups
Component "shared-upload.example.com" "http_file_share"
server_user_role = "prosody:registered"
```

### 3. SQL Schema Migration Required

**Issue**: Database schema changes require manual upgrade.

**Solution**:

```bash
# Check and upgrade schema
prosodyctl mod_storage_sql upgrade

# Restart after upgrade
systemctl restart prosody
```

**Error Messages to Watch For**:

```
error    Old database format detected. Please run: prosodyctl mod_storage_sql upgrade
```

### 4. Manual SSL Configuration Ignored (13.0.0 Bug)

**Issue**: Manual SSL configuration ignored in 13.0.0 (fixed in 13.0.1).

**Affected Settings**:

- `https_ssl`
- `c2s_direct_tls_ssl`
- `s2s_direct_tls_ssl`

**Solution**:

- Upgrade to 13.0.1+ immediately
- Or use automatic certificate configuration

## 🆕 New Features Integrated

### 1. Account Activity Tracking

**Module**: `mod_account_activity`

**Configuration**: `config/stack/05-services/account-management.cfg.lua`

**Features**:

- Last login/logout tracking
- User activity history
- Admin activity reporting

**Usage**:

```bash
prosodyctl user:activity user@example.com
prosodyctl user:last_seen user@example.com
prosodyctl user:login_history user@example.com
```

### 2. Enhanced Security Features

**File**: `config/stack/02-stream/security-enhancements.cfg.lua`

**New Capabilities**:

- **DANE Support**: `mod_s2s_auth_dane_in` for DNS-based authentication
- **SASL Channel Binding**: RFC 9266 TLS 1.3 exporter channel binding
- **Modern TLS**: RFC 9525 compliance (no Common Name checking)
- **Flags System**: `mod_flags` for enhanced metadata tracking

### 3. Credential Management (Prosody 13.0+)

**File**: `config/tools/security/credentials.cfg.lua`

**Features**:

- `Credential()` directive for secure password storage
- `FileLines()`, `FileLine()`, `FileContents()` for dynamic configuration
- systemd `LoadCredential=` integration
- Podman/Docker secrets support

**Example**:

```lua
-- Secure database password
sql = {
    driver = "PostgreSQL",
    database = "prosody",
    username = "prosody",
    password = Credential("db_password"), -- From CREDENTIALS_DIRECTORY
    host = "localhost"
}

-- Dynamic admin list
admins = FileLines("config/security/admin-list.txt")
```

### 4. Enhanced Module Loading

**File**: `config/tools/core/module-loader.cfg.lua`

**Features**:

- Automatic dependency resolution
- XEP compliance tracking
- Error handling for missing modules
- Consistent module naming enforcement

### 5. Advanced Logging

**Enhanced logging configuration** with multiple targets:

- Console output for development
- File logging with rotation
- Security event logging
- Audit trail logging
- Syslog integration

## 📦 New Modules Available

| Module | Description | Auto-Enabled |
|--------|-------------|--------------|
| `account_activity` | Login/logout tracking | Yes |
| `flags` | Enhanced metadata tracking | Yes |
| `s2s_auth_dane_in` | DANE authentication | Production only |
| `cloud_notify` | Push notifications | Available |
| `http_altconnect` | Connection method discovery | Available |

## 🔧 Configuration Changes Made

### Layer Structure Enhanced

Our 8-layer architecture remains intact with additions:

```
config/stack/
├── 01-transport/           # Enhanced with modern TLS
├── 02-stream/              # + security-enhancements.cfg.lua  
├── 03-stanza/              # Updated filtering and validation
├── 04-protocol/            # Enhanced with new core features
├── 05-services/            # + account-management.cfg.lua
├── 06-storage/             # Updated for SQLCipher support
├── 07-interfaces/          # Enhanced HTTP configuration
└── 08-integration/         # Updated OAuth and external services
```

### Domains Updated

**Upload Component** (`config/domains/upload/domain.cfg.lua`):

- Enhanced for 13.0 permission model
- Role-based access control
- Improved security restrictions
- Better monitoring and cleanup

### Tools Enhanced

**New Tools**:

- `config/tools/security/credentials.cfg.lua` - Credential management
- `config/tools/core/module-loader.cfg.lua` - Enhanced module loading
- `config/tools/migration/prosody-13-upgrade.cfg.lua` - Upgrade assistance

## 🚀 Migration Steps

### Pre-Migration Checklist

- [ ] **Backup Everything**: Configuration files and databases
- [ ] **Check Lua Version**: Must be 5.2+ (5.4 recommended)
- [ ] **Review Components**: Note any custom component configurations
- [ ] **List Community Modules**: Identify which might be deprecated
- [ ] **Check SSL Config**: Note any manual SSL configurations

### Migration Process

1. **Upgrade System**:

   ```bash
   # Update package repositories
   apt update && apt upgrade
   
   # Ensure Lua 5.2+
   update-alternatives --config lua-interpreter
   ```

2. **Install Prosody 13.0**:

   ```bash
   apt install prosody
   ```

3. **Keep Existing Configuration**:
   - When prompted, keep your existing `prosody.cfg.lua`
   - Our layer-based config is fully compatible

4. **Run Compatibility Checks**:

   ```bash
   # Check configuration
   prosodyctl check config
   
   # Check for improvements  
   prosodyctl check features
   ```

5. **SQL Migration** (if applicable):

   ```bash
   prosodyctl mod_storage_sql upgrade
   ```

6. **Clean Up Deprecated Modules**:

   ```lua
   -- Remove these from modules_enabled if present:
   -- "vcard_muc" (now built-in)
   -- "legacyauth" (deprecated)
   -- "compression" (security risk)
   ```

7. **Restart and Verify**:

   ```bash
   systemctl restart prosody
   systemctl status prosody
   journalctl -u prosody -f
   ```

### Post-Migration Tasks

- [ ] **Enable New Features**: Review and enable desired 13.0 modules
- [ ] **Update Monitoring**: Adjust for new log formats and metrics
- [ ] **Test Components**: Verify file upload and MUC functionality
- [ ] **Review Permissions**: Check component access permissions
- [ ] **Update Documentation**: Document any custom configurations

## 🔍 Troubleshooting

### Common Issues

**Issue**: "Old database format detected"

```bash
# Solution
prosodyctl mod_storage_sql upgrade
systemctl restart prosody
```

**Issue**: "Unable to load module 'vcard_muc'"

```lua
-- Solution: Remove from modules_enabled
-- The functionality is now built-in
```

**Issue**: File upload not working after upgrade

```lua
-- Check component configuration
Component "upload.example.com" "http_file_share"
parent_host = "main.example.com"  -- Add if needed
```

**Issue**: Lua version errors

```bash
# Check version
lua -v

# Update default (Debian/Ubuntu)
update-alternatives --config lua-interpreter
```

### Verification Commands

```bash
# Check Prosody status
prosodyctl status

# Check configuration
prosodyctl check config

# Check for new features
prosodyctl check features

# Monitor logs
journalctl -u prosody -f

# Test connectivity
prosodyctl shell --help
```

## 📚 Additional Resources

### Official Documentation

- [Prosody 13.0.0 Release Notes](https://prosody.im/doc/release/13.0.0)
- [Configuration Guide](https://prosody.im/doc/configure)
- [Module Documentation](https://prosody.im/doc/modules)

### Our Documentation

- [Layer-Based Architecture](../dev/architecture.md)
- [Security Configuration](security.md)
- [Module Reference](../reference/modules.md)

### Support

- [Prosody Community Chat](https://chat.prosody.im/)
- [Issue Tracker](https://issues.prosody.im/)
- [Development Discussion](https://groups.google.com/forum/#!forum/prosody-dev)

---

## Migration Summary

✅ **Successfully Integrated**:

- All new Prosody 13.0 features
- Credential management system
- Enhanced security features
- Account activity tracking
- Modern TLS configuration
- Component permission updates

✅ **Maintained Compatibility**:

- Layer-based architecture preserved
- Environment-aware configurations
- Policy-driven security model
- Existing module organization

✅ **Enhanced Administration**:

- New prosodyctl commands
- Improved monitoring capabilities
- Better error handling and reporting
- Comprehensive upgrade assistance

Your XMPP server is now ready for Prosody 13.0 with enterprise-grade features and modern security standards! 🎉
