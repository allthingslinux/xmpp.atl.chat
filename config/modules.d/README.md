# Modules Configuration Directory

This directory contains configuration files organized by **source and distribution** for better reliability and maintainability, aligned with Prosody's internal module structure.

## Directory Structure

```text
modules.d/
├── README.md                    # This file
├── distributed/                 # ✅ Distributed modules (shipped with Prosody)
│   └── distributed.cfg.lua     # Distributed modules configuration
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

### 🟢 **Core Modules**

- **Status**: Autoloaded by Prosody - Essential XMPP functionality
- **Source**: Built into Prosody core (autoload_modules)
- **Risk**: Minimal - Required for basic operation
- **Configuration**: Configured in main `prosody.cfg.lua` file
- **Examples**: `presence`, `message`, `iq`, `offline`, `c2s`, `s2s`

### ✅ **Distributed Modules**

- **Status**: Enabled by default - Shipped with Prosody
- **Source**: Official Prosody distribution (not autoloaded)
- **Risk**: Low - Officially maintained and tested
- **Examples**: `mam`, `smacks`, `carbons`, `bosh`, `websocket`, `muc`

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
# Distributed modules (enabled by default)
PROSODY_ENABLE_DISTRIBUTED=true  # Distributed Prosody modules

# Community modules
PROSODY_ENABLE_SECURITY=true     # Community security modules (stable)
PROSODY_ENABLE_BETA=false        # Community beta modules
PROSODY_ENABLE_ALPHA=false       # Community alpha/experimental modules
```

## Configuration Loading

The main `prosody.cfg.lua` file loads configurations conditionally:

1. **Core modules** - Autoloaded by Prosody (configured in main file)
2. **Distributed modules** - Enabled by default (`PROSODY_ENABLE_DISTRIBUTED != false`)
3. **Community stable** - Enabled by default (`PROSODY_ENABLE_SECURITY != false`)
4. **Community beta** - Opt-in (`PROSODY_ENABLE_BETA == true`)
5. **Community alpha** - Opt-in (`PROSODY_ENABLE_ALPHA == true`)

## Module Inventory

### Core Modules (Autoloaded by Prosody)

Based on Prosody's `autoload_modules`:

- `presence` - Presence stanza handling (autoloaded)
- `message` - Message stanza handling (autoloaded)
- `iq` - IQ stanza handling (autoloaded)
- `offline` - Offline message storage (autoloaded)
- `c2s` - Client-to-server connections (autoloaded)
- `s2s` - Server-to-server connections (autoloaded)
- `s2s_auth_certs` - S2S certificate authentication (autoloaded)

Essential modules (always needed):

- `roster` - Contact list management
- `saslauth` - SASL authentication
- `tls` - Transport Layer Security
- `dialback` - Server-to-server authentication
- `disco` - Service discovery
- `private` - Private XML storage
- `vcard` - User profile information
- `version` - Software version queries
- `uptime` - Server uptime reporting
- `time` - Time synchronization
- `ping` - Connection keep-alive

### Distributed Modules (Shipped with Prosody)

- `mam` - Message Archive Management (XEP-0313)
- `smacks` - Stream Management (XEP-0198)
- `carbons` - Message Carbons (XEP-0280)
- `csi` - Client State Indication (XEP-0352)
- `csi_simple` - Simple CSI implementation
- `bookmarks` - Bookmarks (XEP-0048/0402)
- `blocklist` - Blocking Command (XEP-0191)
- `lastactivity` - Last Activity (XEP-0012)
- `pep` - Personal Eventing Protocol (XEP-0163)
- `limits` - Connection limiting
- `admin_adhoc` - Admin commands (XEP-0050)
- `admin_shell` - Admin shell interface
- `invites` - Invitation system
- `invites_adhoc` - Ad-hoc invitations
- `invites_register` - Registration via invites
- `tombstones` - Prevent account reuse
- `server_contact_info` - Server contact info (XEP-0157)
- `watchregistrations` - Registration monitoring
- `http` - HTTP server
- `http_errors` - HTTP error pages
- `http_files` - Static file serving
- `http_file_share` - File sharing (XEP-0447)
- `bosh` - BOSH (XEP-0124/0206)
- `websocket` - WebSocket (RFC 7395)
- `muc` - Multi-User Chat (XEP-0045)
- `muc_mam` - MUC Message Archive Management
- `muc_unique` - Unique MUC names
- `proxy65` - File transfer proxy (XEP-0065)
- `turn_external` - TURN services (XEP-0215)
- `motd` - Message of the day
- `welcome` - Welcome messages
- `announce` - Server announcements
- `register_ibr` - In-band registration
- `register_limits` - Registration limits
- `user_account_management` - Account management
- `vcard4` - Modern vCard format (XEP-0292)
- `vcard_legacy` - vCard compatibility
- `mimicking` - Username mimicking prevention
- `cloud_notify` - Push notifications (XEP-0357)
- `http_openmetrics` - Expose metrics in OpenMetrics format

### Community Modules (Third-Party)

- **Stable**: `firewall`, `spam_reporting`, `block_registrations`, `pep_vcard_avatar`, `filter_chatstates`, `offline_hints`, `profile`, `watch_spam_reports`, `admin_blocklist`
- **Beta**: `password_reset`, `http_altconnect`, `pubsub_serverinfo`, `cloud_notify_extensions`, `push`, `sasl2`, `sasl2_bind2`, `sasl2_fast`, `sasl_ssdp`, `isr`, `compliance_2023`, `service_outage_status`, `server_info`, `extdisco`
- **Alpha**: `measure_cpu`, `measure_memory`, `measure_message_e2e`, `json_logs`, `audit`, `compliance_policy`

## Best Practices

### Production Deployments

- ✅ Use distributed modules for core functionality
- ✅ Consider community stable modules for security
- ⚠️ Test community beta modules thoroughly
- ❌ Avoid community alpha modules in production

### Development/Testing

- ✅ Test with community beta modules
- ✅ Experiment with community alpha modules
- ✅ Report issues to prosody-modules project
- ✅ Contribute improvements back

### Security Considerations

- ✅ Prefer distributed modules over community alternatives
- ✅ Regularly update community modules
- ✅ Monitor prosody-modules for security advisories
- ✅ Disable unused modules to reduce attack surface

## Prosody Source Alignment

This organization is based on Prosody's internal module structure:

- **Core modules**: Based on `autoload_modules` in Prosody's modulemanager
- **Distributed modules**: Shipped with Prosody but not autoloaded
- **Community modules**: <https://modules.prosody.im/>

For the most up-to-date information, always refer to:

- **Prosody core**: <https://prosody.im/doc/modules>
- **Community modules**: <https://modules.prosody.im/>

This organization aligns with Prosody's internal structure and makes it clear which modules are autoloaded, distributed, or community-provided.
