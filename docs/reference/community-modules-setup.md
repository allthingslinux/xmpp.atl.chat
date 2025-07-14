# Community Modules Setup Guide

This document explains how community modules from the [prosody-modules](https://modules.prosody.im/) repository have been integrated into the Professional Prosody XMPP Server.

## Overview

Community modules provide additional functionality beyond what's included in the base Prosody installation. These modules are maintained by the community and offer cutting-edge features, experimental functionality, and specialized use cases.

## Installed Community Modules

The following community modules have been installed and configured:

### Security and Anti-Spam

- **`mod_cloud_notify`** - XEP-0357: Push Notifications for mobile devices
  - URL: <https://modules.prosody.im/mod_cloud_notify.html>
  - Purpose: Enables push notifications for mobile XMPP clients
  - Status: ✅ Installed and enabled

- **`mod_firewall`** - Advanced firewall rules and filtering
  - URL: <https://modules.prosody.im/mod_firewall.html>
  - Purpose: Provides advanced filtering and security rules
  - Status: ✅ Installed and enabled

- **`mod_anti_spam`** - Anti-spam filtering for messages
  - URL: <https://modules.prosody.im/mod_anti_spam.html>
  - Purpose: Automatic spam detection and filtering
  - Status: ✅ Installed and enabled

- **`mod_spam_reporting`** - XEP-0377: Spam Reporting
  - URL: <https://modules.prosody.im/mod_spam_reporting.html>
  - Purpose: Allows users to report spam messages
  - Status: ✅ Installed and enabled

### Administrative Tools

- **`mod_admin_blocklist`** - Administrative blocklist management
  - URL: <https://modules.prosody.im/mod_admin_blocklist.html>
  - Purpose: Enhanced blocklist management for administrators
  - Status: ✅ Installed and enabled

- **`mod_server_contact_info`** - XEP-0157: Contact Addresses for XMPP Services
  - URL: <https://modules.prosody.im/mod_server_contact_info.html>
  - Purpose: Provides server contact information for compliance
  - Status: ✅ Installed and enabled

- **`mod_invites`** - User invitation system
  - URL: <https://modules.prosody.im/mod_invites.html>
  - Purpose: Allows administrators to create user invitation links
  - Status: ✅ Installed and enabled

### Mobile and Client Optimizations

- **`mod_csi_battery_saver`** - Enhanced CSI for mobile battery saving
  - URL: <https://modules.prosody.im/mod_csi_battery_saver.html>
  - Purpose: Advanced battery optimization for mobile clients
  - Status: ✅ Installed and enabled

### MUC Enhancements

- **`mod_muc_notifications`** - Enhanced MUC notifications
  - URL: <https://modules.prosody.im/mod_muc_notifications.html>
  - Purpose: Improved notification system for group chats
  - Status: ✅ Installed and enabled

- **`mod_pastebin`** - Automatic pastebin for long messages
  - URL: <https://modules.prosody.im/mod_pastebin.html>
  - Purpose: Automatically converts long messages to pastebin links
  - Status: ✅ Installed and enabled (MUC component)

## Installation Process

Community modules were installed using the following process:

1. **Repository Cloning**: The prosody-modules repository was cloned locally
2. **Module Selection**: Essential modules were selected based on functionality needs
3. **Manual Installation**: Modules were copied to `/usr/local/lib/prosody/modules/`
4. **Configuration Update**: Modules were added to the `modules_enabled` list
5. **Service Restart**: Prosody was restarted to load the new modules

## Module Management

### Using prosody-manager

The `prosody-manager` script provides comprehensive module management:

```bash
# List all installed modules
./scripts/prosody-manager module list

# Search for available modules
./scripts/prosody-manager module search <query>

# Install a community module
./scripts/prosody-manager module install <module_name>

# Get module information
./scripts/prosody-manager module info <module_name>
```

### Manual Installation

For development or custom installations:

```bash
# Copy module from repository
docker cp .prosody-modules/mod_example xmpp-prosody-dev:/usr/local/lib/prosody/modules/

# Fix ownership
docker exec -it xmpp-prosody-dev chown -R prosody:prosody /usr/local/lib/prosody/modules/mod_example

# Add to configuration and restart
```

## Configuration Details

### Module Loading

Community modules are loaded in the main configuration file (`config/prosody.cfg.lua`) in the dedicated community modules section:

```lua
-- ===============================================
-- COMMUNITY MODULES (from prosody-modules)
-- ===============================================

-- Security and Anti-Spam
"firewall", -- Advanced firewall rules and filtering
"anti_spam", -- Anti-spam filtering for messages
"spam_reporting", -- XEP-0377: Spam Reporting

-- Administrative Tools
"admin_blocklist", -- Administrative blocklist management
"server_contact_info", -- XEP-0157: Contact Addresses for XMPP Services
"invites", -- User invitation system

-- Mobile and Client Optimizations
"csi_battery_saver", -- Enhanced CSI for mobile battery saving

-- MUC Enhancements
"muc_notifications", -- Enhanced MUC notifications
```

### Module-Specific Configuration

Some modules have specific configuration options that can be customized via environment variables or direct configuration.

## Verification

### Feature Check

Use Prosody's built-in feature checker to verify functionality:

```bash
docker exec -it xmpp-prosody-dev prosodyctl check features
```

### Module Status

Check if modules are loading without errors:

```bash
docker logs xmpp-prosody-dev | grep -E "(error|warn)" | tail -10
```

### Configuration Validation

Verify the configuration is valid:

```bash
docker exec -it xmpp-prosody-dev prosodyctl check config
```

## Benefits

### Enhanced Security

- Advanced spam filtering and reporting
- Sophisticated firewall rules
- Improved administrative controls

### Better Mobile Experience

- Push notifications for mobile clients
- Battery optimization features
- Enhanced client state indication

### Improved Group Chat

- Better notification systems
- Automatic pastebin for long messages
- Enhanced administrative features

### Compliance and Administration

- Server contact information for legal compliance
- User invitation systems
- Enhanced administrative tools

## Troubleshooting

### Common Issues

1. **Module Not Loading**
   - Check module is in `/usr/local/lib/prosody/modules/`
   - Verify correct ownership (prosody:prosody)
   - Check module is listed in `modules_enabled`

2. **Configuration Errors**
   - Run `prosodyctl check config` to validate
   - Check logs for specific error messages
   - Verify module dependencies are met

3. **Feature Not Working**
   - Use `prosodyctl check features` to verify
   - Check module-specific configuration
   - Verify client support for the feature

### Log Analysis

Check Prosody logs for module-specific messages:

```bash
docker logs xmpp-prosody-dev | grep -i "module_name"
```

## Future Enhancements

Additional community modules that could be considered:

- **`mod_http_upload_external`** - External file upload service
- **`mod_register_web`** - Web-based user registration
- **`mod_conversejs`** - Integrated web chat client
- **`mod_measure_*`** - Additional metrics and monitoring
- **`mod_unified_push`** - Alternative push notification system

## References

- [Prosody Community Modules](https://modules.prosody.im/)
- [Module Installation Guide](https://prosody.im/doc/installing_modules)
- [XEP Standards](https://xmpp.org/extensions/)
- [Prosody Configuration Guide](https://prosody.im/doc/configure)

---

**Note**: Community modules are maintained by volunteers and may have varying levels of stability and support. Always test thoroughly in development before deploying to production.
