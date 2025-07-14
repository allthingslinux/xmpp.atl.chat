# Module Management Guide

This guide explains the hybrid module management system that supports both official and community Prosody modules.

## Overview

The prosody-manager provides two complementary approaches for installing modules:

### 🔵 Official Modules (via LuaRocks)

- **Source**: Official Prosody modules repository
- **Installation**: `prosody-manager module rocks install <module>`
- **Dependencies**: Automatically handled by LuaRocks
- **Stability**: Production-ready, well-tested
- **Updates**: Version-controlled with proper dependency resolution

### 🟢 Community Modules (via Mercurial)

- **Source**: Community prosody-modules repository (~1000+ modules)
- **Installation**: `prosody-manager module install <module>`
- **Dependencies**: Manual management required
- **Stability**: Varies (alpha, beta, experimental, stable)
- **Updates**: Latest development versions

## When to Use Each Approach

### Use Official Modules For

- ✅ **Production environments**
- ✅ **Modules with complex Lua dependencies**
- ✅ **Stable, well-tested functionality**
- ✅ **Automatic dependency resolution**
- ✅ **Version management and updates**

### Use Community Modules For

- 🔬 **Development and testing**
- 🔬 **Latest experimental features**
- 🔬 **Modules not available in official repository**
- 🔬 **Bleeding-edge functionality**
- 🔬 **Custom or specialized modules**

## Command Reference

### General Commands

```bash
# Search both repositories
prosody-manager module search <query>

# List all installed modules
prosody-manager module list

# Show detailed module information
prosody-manager module info <module>

# Update all modules
prosody-manager module update

# Sync repositories
prosody-manager module sync
```

### Official Modules (LuaRocks)

```bash
# Install with automatic dependency handling
prosody-manager module rocks install mod_cloud_notify

# Remove official module
prosody-manager module rocks remove mod_cloud_notify

# List only official modules
prosody-manager module rocks list

# Check for outdated official modules
prosody-manager module rocks outdated
```

### Community Modules (Mercurial)

```bash
# Install community module
prosody-manager module install mod_pastebin

# Remove community module  
prosody-manager module remove mod_pastebin
```

## Configuration

The system is automatically configured in `prosody.cfg.lua`:

```lua
-- Official Prosody modules repository for prosodyctl install
plugin_server = "https://modules.prosody.im/rocks/"

-- Custom plugin installation path
installer_plugin_path = "/usr/local/lib/prosody/modules"
```

## Dependencies

### Requirements

- **LuaRocks**: Required for official module installation
- **Mercurial (hg)**: Required for community module installation
- **prosodyctl**: Built-in Prosody tool for official modules

### Dependency Handling

#### Official Modules

- ✅ **Automatic**: LuaRocks resolves and installs all Lua dependencies
- ✅ **Version management**: Handles version conflicts
- ✅ **Clean uninstall**: Removes dependencies when no longer needed

#### Community Modules

- ⚠️ **Manual**: You must install Lua dependencies yourself
- ⚠️ **No version management**: Latest development versions only
- ⚠️ **Manual cleanup**: Dependencies remain after module removal

## Module Installation Paths

### Official Modules

- Installed via LuaRocks to standard Lua paths
- Automatically discovered by Prosody
- Managed by `prosodyctl` commands

### Community Modules

- Installed to `/usr/local/lib/prosody/modules/`
- Cached locally in `.prosody-modules/`
- Manually copied from Mercurial repository

## Best Practices

### Production Environments

1. **Prefer official modules** for critical functionality
2. **Test community modules** in development first
3. **Document dependencies** for community modules
4. **Use version control** for your module configuration

### Development Environments

1. **Use community modules** for latest features
2. **Contribute back** improvements to the community
3. **Report issues** to module maintainers
4. **Test compatibility** before production deployment

### Module Selection Workflow

1. **Search first**: `prosody-manager module search <feature>`
2. **Check official**: Look for official modules with dependency handling
3. **Evaluate community**: Consider community modules for additional features
4. **Read documentation**: Always check module-specific setup requirements
5. **Test thoroughly**: Verify functionality in development environment

## Examples

### Installing Push Notifications

```bash
# Official module (recommended for production)
prosody-manager module rocks install mod_cloud_notify

# Community alternative with more features
prosody-manager module install mod_unified_push
```

### Installing File Upload

```bash
# Official HTTP upload module
prosody-manager module rocks install mod_http_upload

# Community module with additional features
prosody-manager module install mod_http_upload_external
```

### Installing MUC (Multi-User Chat) Enhancements

```bash
# Search for MUC modules
prosody-manager module search muc

# Install official MUC modules
prosody-manager module rocks install mod_muc_mam

# Install community MUC modules
prosody-manager module install mod_muc_notifications
```

## Troubleshooting

### Official Module Issues

```bash
# Check LuaRocks status
prosody-manager module rocks list

# Verify prosodyctl functionality
./scripts/prosody-manager prosodyctl status

# Check for outdated modules
prosody-manager module rocks outdated
```

### Community Module Issues

```bash
# Sync repository
prosody-manager module sync

# Check module information
prosody-manager module info mod_example

# Verify installation
prosody-manager module list
```

### Common Issues

#### "Module not found"

- **Official**: Module may not be packaged for LuaRocks yet
- **Community**: Check spelling and use `module search` to find correct name

#### "Dependency errors"

- **Official**: LuaRocks should handle automatically; check container logs
- **Community**: Install Lua dependencies manually using `luarocks install`

#### "Module not loading"

- Verify module is added to `modules_enabled` in configuration
- Check Prosody logs for specific error messages
- Ensure module dependencies are satisfied

## Migration Guide

### From Community to Official

1. Remove community module: `prosody-manager module remove mod_example`
2. Install official module: `prosody-manager module rocks install mod_example`
3. Update configuration if needed
4. Restart Prosody

### From Official to Community

1. Remove official module: `prosody-manager module rocks remove mod_example`
2. Install community module: `prosody-manager module install mod_example`
3. Install any missing dependencies manually
4. Update configuration if needed
5. Restart Prosody

## Contributing

### To Official Repository

- Follow Prosody's contribution guidelines
- Ensure proper packaging for LuaRocks
- Include comprehensive documentation

### To Community Repository

- Fork the prosody-modules repository
- Add your module following existing patterns
- Submit pull request with documentation
- Include README.markdown with setup instructions

---

For more information:

- [Official Prosody Plugin Installer](https://prosody.im/doc/plugin_installer)
- [Community Prosody Modules](https://modules.prosody.im/)
- [Installing Modules Documentation](https://prosody.im/doc/installing_modules)
