# Modules Configuration Directory

This directory contains configuration files organized by **source and distribution** for better reliability and maintainability, aligned with Prosody's internal module structure.

## Directory Structure

```text
modules.d/
├── README.md                    # This file
├── core/                        # ✅ Core modules (shipped with Prosody)
│   └── core.cfg.lua            # Core modules configuration
└── community/                   # 🏗️ Community modules (third-party)
    ├── stable/                 # 🟢 Stable community modules
    │   ├── anti-spam.cfg.lua   # Anti-spam and abuse prevention
    │   ├── firewall.cfg.lua    # Firewall and rate limiting
    │   └── user-experience.cfg.lua # User experience enhancements
    ├── beta/                   # 🟡 Beta community modules
    │   ├── push-notifications.cfg.lua # Push notifications and mobile
    │   ├── web-features.cfg.lua # Web registration and HTTP features
    │   ├── modern-auth.cfg.lua # Modern authentication (SASL2, Bind2, etc.)
    │   └── compliance.cfg.lua  # Compliance testing and standards
    └── alpha/                  # 🟠 Alpha community modules
        └── monitoring.cfg.lua  # Performance monitoring and auditing
```

## Module Categories

### ✅ **Core Modules**

- **Status**: Enabled by default - Shipped with Prosody
- **Source**: Official Prosody distribution (includes required, autoloaded, and distributed)
- **Risk**: Low - Officially maintained and tested
- **Examples**: `mam`, `smacks`, `carbons`, `bosh`, `websocket`, `muc`, `presence`, `message`

### 🟢 **Community Stable Modules**

- **Status**: Enabled by default - Production-ready third-party
- **Source**: prosody-modules project (stable)
- **Risk**: Low - Well-tested community modules
- **Examples**: `firewall`, `spam_reporting`, `block_registrations`

### 🟡 **Community Beta Modules**

- **Status**: Opt-in - Mostly stable with some edge cases
- **Source**: prosody-modules project (beta)
- **Risk**: Medium - Mature but may have minor issues
- **Examples**: `password_reset`, `http_altconnect`, `pubsub_serverinfo`

### 🟠 **Community Alpha Modules**

- **Status**: Opt-in - Experimental features
- **Source**: prosody-modules project (alpha/experimental)
- **Risk**: High - May have bugs or breaking changes
- **Examples**: `measure_cpu`, `json_logs`, `audit`, `compliance_policy`

## Environment Variables

Control which module categories are loaded:

```bash
# Core modules (enabled by default)
PROSODY_ENABLE_CORE=true         # All Prosody-shipped modules

# Community modules
PROSODY_ENABLE_SECURITY=true     # Community security modules (stable)
PROSODY_ENABLE_BETA=false        # Community beta modules
PROSODY_ENABLE_ALPHA=false       # Community alpha/experimental modules
```

## Configuration Loading

The main `prosody.cfg.lua` file loads configurations conditionally:

1. **Core modules** - Enabled by default (`PROSODY_ENABLE_CORE != false`)
2. **Community stable** - Enabled by default (`PROSODY_ENABLE_SECURITY != false`)
3. **Community beta** - Opt-in (`PROSODY_ENABLE_BETA == true`)
4. **Community alpha** - Opt-in (`PROSODY_ENABLE_ALPHA == true`)

## Module Inventory

All modules shipped with Prosody (configured in `core/core.cfg.lua`):

**Essential modules** (required - cannot be disabled):

- `roster`, `saslauth`, `tls`, `dialback`, `disco`, `c2s`, `s2s`, `private`, `vcard`, `version`, `uptime`, `time`, `ping`

**Autoloaded modules** (loaded by default but can be disabled):

- `presence`, `message`, `iq`, `offline`, `s2s_auth_certs`

**Modern XMPP features** (shipped with Prosody):

- `carbons` - Message Carbons (XEP-0280)
- `mam` - Message Archive Management (XEP-0313)
- `smacks` - Stream Management (XEP-0198)
- `csi`, `csi_simple` - Client State Indication (XEP-0352)
- `bookmarks` - Bookmarks (XEP-0048/0402)
- `blocklist` - Blocking Command (XEP-0191)
- `lastactivity` - Last Activity (XEP-0012)
- `pep` - Personal Eventing Protocol (XEP-0163)

**Security and administration**:

- `limits`, `admin_adhoc`, `admin_shell`, `invites`, `invites_adhoc`, `invites_register`, `tombstones`, `server_contact_info`, `watchregistrations`

**HTTP services**:

- `http`, `http_errors`, `http_files`, `http_file_share`, `bosh`, `websocket`, `http_openmetrics`

**Multi-user chat**:

- `muc`, `muc_mam`, `muc_unique`

**File transfer and media**:

- `proxy65`, `turn_external`

**User profiles and vCard**:

- `vcard4`, `vcard_legacy`

**Miscellaneous modules**:

- `motd`, `welcome`, `announce`, `register_ibr`, `register_limits`, `user_account_management`, `mimicking`, `cloud_notify`

### Community Modules (Third-Party)

- **Stable**: `firewall`, `spam_reporting`, `block_registrations`, `pep_vcard_avatar`, `filter_chatstates`, `offline_hints`, `profile`, `watch_spam_reports`, `admin_blocklist`
- **Beta**: `password_reset`, `http_altconnect`, `pubsub_serverinfo`, `cloud_notify_extensions`, `push`, `sasl2`, `sasl2_bind2`, `sasl2_fast`, `sasl_ssdp`, `isr`, `compliance_2023`, `service_outage_status`, `server_info`, `extdisco`
- **Alpha**: `measure_cpu`, `measure_memory`, `measure_message_e2e`, `json_logs`, `audit`, `compliance_policy`

## Best Practices

### Production Deployments

- ✅ Use core modules for main functionality
- ✅ Consider community stable modules for security
- ⚠️ Test community beta modules thoroughly
- ❌ Avoid community alpha modules in production

### Development/Testing

- ✅ Test with community beta modules
- ✅ Experiment with community alpha modules
- ✅ Report issues to prosody-modules project
- ✅ Contribute improvements back

### Security Considerations

- ✅ Prefer core modules over community alternatives
- ✅ Regularly update community modules
- ✅ Monitor prosody-modules for security advisories
- ✅ Disable unused modules to reduce attack surface

## Prosody Source Alignment

This organization is based on Prosody's internal module structure:

- **Core modules**: All modules shipped with Prosody (required, autoloaded, and distributed)
- **Community modules**: <https://modules.prosody.im/>

For the most up-to-date information, always refer to:

- **Prosody core**: <https://prosody.im/doc/modules>
- **Community modules**: <https://modules.prosody.im/>

This organization aligns with Prosody's internal structure and makes it clear which modules are autoloaded, distributed, or community-provided.
