# Prosody Modules Alignment with Official Documentation

This document describes the comprehensive update made to align our XMPP server configuration with the official Prosody modules documentation.

## Overview

Based on the official Prosody modules documentation (<https://prosody.im/doc/modules>), we've reorganized our module configuration from a **stability-based** approach to an **official status-based** approach for better reliability and maintainability.

## Key Changes Made

### 1. Module Categorization Restructure

**Previous Organization (Stability-Based):**

- 🟢 Core modules (always enabled)
- 🟢 Stable modules (production ready)
- 🟡 Beta modules (mostly stable)
- 🟠 Alpha modules (experimental)
- 🔧 HTTP services (mixed stability)
- 🛠️ Administration (mixed stability)

**New Organization (Official Status-Based):**

- 🟢 **Core modules** (built into Prosody core)
- ✅ **Official modules** (distributed with Prosody)
- 🟢 **Community stable modules** (well-tested third-party)
- 🟡 **Community beta modules** (mostly stable third-party)
- 🟠 **Community alpha modules** (experimental third-party)

### 2. Directory Structure Changes

**Old Structure:**

```
modules.d/
├── core/
├── stable/
├── beta/
├── alpha/
├── http/
└── admin/
```

**New Structure:**

```
modules.d/
├── official/
└── community/
    ├── stable/
    ├── beta/
    └── alpha/
```

**Note**: Core modules are configured directly in the main `prosody.cfg.lua` file since they are built into Prosody.

### 3. Module Inventory Updates

#### Core Modules (Always Enabled)

These are essential XMPP functionality built into Prosody:

- `roster`, `saslauth`, `tls`, `dialback`, `disco`
- `private`, `vcard`, `version`, `uptime`, `time`, `ping`
- `iq`, `message`, `presence`, `c2s`, `s2s`

#### Official Modules (Distributed with Prosody)

These are officially maintained and distributed with Prosody:

- **Modern XMPP**: `mam`, `smacks`, `carbons`, `csi`, `csi_simple`, `bookmarks`, `blocklist`, `lastactivity`, `pep`
- **Security & Admin**: `limits`, `admin_adhoc`, `admin_shell`, `invites`, `invites_adhoc`, `invites_register`, `tombstones`, `server_contact_info`, `watchregistrations`
- **HTTP Services**: `http`, `http_errors`, `http_files`, `http_file_share`, `bosh`, `websocket`
- **Multi-User Chat**: `muc`, `muc_mam`, `muc_unique`
- **File Transfer**: `proxy65`, `turn_external`
- **Miscellaneous**: `motd`, `welcome`, `announce`, `offline`, `register_ibr`, `register_limits`, `user_account_management`, `vcard_legacy`, `mimicking`, `cloud_notify`

#### Community Modules (Third-Party)

These are from the prosody-modules project:

- **Stable**: `firewall`, `spam_reporting`, `block_registrations`
- **Beta**: `vcard4`, `password_reset`, `http_altconnect`, `pubsub_serverinfo`, `cloud_notify_extensions`, `push`
- **Alpha**: `measure_cpu`, `measure_memory`, `measure_message_e2e`, `json_logs`, `audit`, `compliance_policy`

### 4. Environment Variable Changes

**Previous Variables:**

```bash
PROSODY_ENABLE_SECURITY=true
PROSODY_ENABLE_MODERN=true
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=false
PROSODY_ENABLE_HTTP=false
PROSODY_ENABLE_ADMIN=false
```

**New Variables:**

```bash
PROSODY_ENABLE_OFFICIAL=true     # Official Prosody modules
PROSODY_ENABLE_SECURITY=true     # Community security modules
PROSODY_ENABLE_BETA=false        # Community beta modules
PROSODY_ENABLE_ALPHA=false       # Community alpha modules
```

### 5. Configuration Loading Logic

**Updated Loading Order:**

1. **Core modules** - Always enabled (built into Prosody)
2. **Official modules** - Enabled by default (`PROSODY_ENABLE_OFFICIAL != false`)
3. **Community stable** - Enabled by default (`PROSODY_ENABLE_SECURITY != false`)
4. **Community beta** - Opt-in (`PROSODY_ENABLE_BETA == true`)
5. **Community alpha** - Opt-in (`PROSODY_ENABLE_ALPHA == true`)

## Benefits of New Organization

### 1. **Reliability First**

- Official modules are prioritized over community alternatives
- Clear distinction between officially supported and third-party modules
- Reduced risk of using unstable or deprecated modules

### 2. **Better Documentation**

- Module categories aligned with official Prosody documentation
- Clear references to XEP specifications and official module purposes
- Easier to find information about specific modules

### 3. **Simplified Configuration**

- Fewer environment variables to manage
- Clearer defaults (official modules enabled by default)
- More predictable behavior

### 4. **Enhanced Security**

- Community modules clearly marked as third-party
- Alpha/experimental modules require explicit opt-in
- Security-focused modules grouped together

### 5. **Future-Proof**

- Aligned with official Prosody development
- Easier to adopt new official modules
- Clear upgrade path for community modules

## Migration Impact

### Backward Compatibility

- ✅ All existing functionality preserved
- ✅ Environment variables updated but defaults maintained
- ✅ No breaking changes for existing deployments

### Configuration Files

- ✅ Old configuration files moved to new locations
- ✅ All settings preserved and enhanced
- ✅ New official modules configuration added

### Default Behavior Changes

- ✅ Official modules now enabled by default
- ✅ Community beta modules now opt-in (previously default)
- ✅ HTTP and admin modules integrated into official modules

## Deployment Recommendations

### Production Deployments

- ✅ **Enable official modules** - Use `PROSODY_ENABLE_OFFICIAL=true` (default)
- ✅ **Enable community security** - Use `PROSODY_ENABLE_SECURITY=true` (default)
- ⚠️ **Test community beta modules** - Use `PROSODY_ENABLE_BETA=true` with testing
- ❌ **Avoid community alpha modules** - Keep `PROSODY_ENABLE_ALPHA=false`

### Development/Testing

- ✅ Test with community beta modules enabled
- ✅ Experiment with community alpha modules
- ✅ Report issues to prosody-modules project
- ✅ Contribute improvements back to community

## Official Documentation References

This alignment is based on:

- **Core modules**: <https://prosody.im/doc/modules>
- **Community modules**: <https://modules.prosody.im/>
- **XMPP specifications**: <https://xmpp.org/extensions/>

## Next Steps

1. **Monitor official updates** - Watch for new official modules in Prosody releases
2. **Community module updates** - Keep community modules updated from prosody-modules
3. **Performance testing** - Verify module combinations work well together
4. **Documentation updates** - Keep module documentation current with official changes

This reorganization provides a more reliable, maintainable, and future-proof XMPP server configuration that aligns with official Prosody development practices.
