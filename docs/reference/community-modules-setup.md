# Community Modules Setup Guide

This document explains how community modules from the [prosody-modules](https://modules.prosody.im/) repository are automatically integrated into the Professional Prosody XMPP Server.

## Overview

Community modules provide additional functionality beyond what's included in the base Prosody installation. These modules are maintained by the community and offer cutting-edge features, experimental functionality, and specialized use cases.

**The system now provides fully automated community module installation** through multiple methods:

1. **Build-time Installation**: Essential modules are installed during Docker image build
2. **Runtime Installation**: Additional modules via environment variables
3. **Manual Installation**: On-demand installation via prosody-manager

## Automatically Installed Community Modules

The following community modules are **automatically installed during Docker build**:

### Security and Anti-Spam

- **`mod_cloud_notify`** - XEP-0357: Push Notifications for mobile devices
  - URL: <https://modules.prosody.im/mod_cloud_notify.html>
  - Purpose: Enables push notifications for mobile XMPP clients
  - Status: ✅ **Pre-installed and enabled**

- **`mod_firewall`** - Advanced filtering and security rules
  - URL: <https://modules.prosody.im/mod_firewall.html>
  - Purpose: Sophisticated filtering system for blocking spam and enforcing policies
  - Status: ✅ **Pre-installed and enabled**

- **`mod_anti_spam`** - Automatic spam detection and prevention
  - URL: <https://modules.prosody.im/mod_anti_spam.html>
  - Purpose: Automatically detects and blocks spam messages
  - Status: ✅ **Pre-installed and enabled**

- **`mod_spam_reporting`** - XEP-0377: Spam reporting mechanism
  - URL: <https://modules.prosody.im/mod_spam_reporting.html>
  - Purpose: Allows users to report spam messages
  - Status: ✅ **Pre-installed and enabled**

### Administrative Tools

- **`mod_admin_blocklist`** - Enhanced administrative blocklist management
  - URL: <https://modules.prosody.im/mod_admin_blocklist.html>
  - Purpose: Advanced user and domain blocking capabilities
  - Status: ✅ **Pre-installed and enabled**

- **`mod_server_contact_info`** - XEP-0157: Server contact information
  - URL: <https://modules.prosody.im/mod_server_contact_info.html>
  - Purpose: Provides server contact information to clients
  - Status: ✅ **Pre-installed and enabled**

- **`mod_invites`** - User invitation system
  - URL: <https://modules.prosody.im/mod_invites.html>
  - Purpose: Allows administrators to generate invitation links
  - Status: ✅ **Pre-installed and enabled**

### Mobile and Client Optimizations

- **`mod_csi_battery_saver`** - Client State Indication battery optimization
  - URL: <https://modules.prosody.im/mod_csi_battery_saver.html>
  - Purpose: Reduces battery usage on mobile devices
  - Status: ✅ **Pre-installed and enabled**

### MUC (Multi-User Chat) Enhancements

- **`mod_muc_notifications`** - Enhanced MUC notification system
  - URL: <https://modules.prosody.im/mod_muc_notifications.html>
  - Purpose: Improved notifications for group chat activities
  - Status: ✅ **Pre-installed and enabled**

- **`mod_pastebin`** - Automatic pastebin for long messages
  - URL: <https://modules.prosody.im/mod_pastebin.html>
  - Purpose: Automatically converts long messages to pastebin links
  - Status: ✅ **Pre-installed and enabled**

## Installation Methods

### 1. Automatic Build-Time Installation

**Essential community modules are automatically installed during Docker image build.** No manual intervention required.

```dockerfile
# Community modules are installed automatically during build
RUN echo "Installing community modules..." && \
    cd /tmp && \
    hg clone https://hg.prosody.im/prosody-modules/ prosody-modules && \
    # Install essential modules automatically
    cp -r prosody-modules/mod_cloud_notify /usr/local/lib/prosody/modules/ && \
    # ... (10+ modules installed automatically)
```

### 2. Runtime Installation via Environment Variables

**Add additional modules dynamically using environment variables:**

```bash
# In .env or .env.dev file
PROSODY_EXTRA_MODULES=mod_register_web,mod_http_upload_external,mod_unified_push
```

The entrypoint script will automatically:

- Clone the prosody-modules repository
- Install the specified modules
- Set proper ownership and permissions
- Make them available to Prosody

### 3. Manual Installation via prosody-manager

**Install modules on-demand using the management script:**

```bash
# Search for available modules
./prosody-manager module search push

# Install a specific community module
./prosody-manager module install mod_unified_push

# List installed modules
./prosody-manager module list
```

## Module Management

The **`prosody-manager`** script provides comprehensive module management with **automatic container detection**:

```bash
# Search both official and community repositories
./prosody-manager module search <query>

# List all installed modules
./prosody-manager module list

# Install a community module
./prosody-manager module install <module_name>

# Show detailed module information
./prosody-manager module info <module_name>
```

### Key Features

- ✅ **Automatic container detection** (works with dev, production, and custom container names)
- ✅ **Dual repository support** (official LuaRocks + community prosody-modules)
- ✅ **Dependency management** (automatic for official, manual guidance for community)
- ✅ **Real-time installation** (no container rebuild required)

## Configuration Integration

All community modules are **automatically integrated into the Prosody configuration** with:

- ✅ **Detailed descriptions** of what each module does
- ✅ **XEP references** and documentation links
- ✅ **Consistent naming** following user preferences [[memory:3030813]]
- ✅ **Proper categorization** by functionality

Example configuration entry:

```lua
modules_enabled = {
    -- COMMUNITY MODULES (from prosody-modules)
    "cloud_notify", -- XEP-0357: Push Notifications (community module from prosody-modules)
    "firewall", -- Advanced filtering and security rules (https://modules.prosody.im/mod_firewall.html)
    -- ... additional modules
}
```

## Verification and Testing

### Check Installed Modules

```bash
# List all community modules
docker exec -it xmpp-prosody-dev ls -la /usr/local/lib/prosody/modules/ | grep mod_

# Verify module installation
./prosody-manager module list

# Test module functionality
./prosody-manager module info mod_cloud_notify
```

### Container Logs

```bash
# Check for module loading messages
docker logs xmpp-prosody-dev | grep -E "(community|module)"

# Monitor real-time logs
docker logs -f xmpp-prosody-dev
```

## Troubleshooting

### Module Not Loading

1. **Check if module is installed**: `./prosody-manager module list`
2. **Verify configuration**: Ensure module is in `modules_enabled` list
3. **Check dependencies**: Some modules require specific Lua libraries
4. **Restart Prosody**: `docker compose restart xmpp-prosody-dev`

### Installation Issues

1. **Container detection**: The script automatically detects container names
2. **Repository access**: Ensure internet access for cloning prosody-modules
3. **Permissions**: Modules are automatically chowned to `prosody:prosody`

### Environment Variables Not Working

1. **File format**: Ensure proper `.env` or `.env.dev` file format
2. **Docker Compose**: Verify environment file is loaded in docker-compose.yml
3. **Variable syntax**: Use `PROSODY_EXTRA_MODULES=mod1,mod2,mod3` format

## Best Practices

### Production Environments

1. **Use build-time installation** for essential modules (already done)
2. **Test community modules** thoroughly before enabling
3. **Monitor performance** impact of additional modules
4. **Keep modules updated** via regular image rebuilds

### Development Environments

1. **Use environment variables** for experimental modules
2. **Use prosody-manager** for quick testing and iteration
3. **Check module compatibility** before production deployment

### Module Selection

1. **Essential modules** are pre-installed (security, push notifications, etc.)
2. **Experimental modules** can be added via environment variables
3. **Specialized modules** can be installed on-demand via prosody-manager

## Automated Benefits

This automated system provides:

✅ **Zero-configuration setup** - Essential modules work out of the box
✅ **Flexible expansion** - Add modules via environment variables or management script
✅ **Production-ready** - All modules properly installed with correct permissions
✅ **Development-friendly** - Easy testing and iteration without container rebuilds
✅ **Comprehensive management** - Full-featured module management via prosody-manager
✅ **Automatic updates** - Modules updated during image rebuilds

---

**🎉 Result**: You now have a fully automated community module system that requires no manual copying or pasting of modules!
