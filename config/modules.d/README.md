# Modules Configuration Directory

This directory contains configuration files organized by **official status** for better reliability and maintainability, aligned with the official Prosody documentation.

## Directory Structure

```text
modules.d/
├── README.md                    # This file
├── core/                        # 🟢 Core modules (always enabled)
│   └── README.md               # Core modules documentation
├── official/                    # ✅ Official modules (distributed with Prosody)
│   └── core.cfg.lua            # Official modules configuration
└── community/                   # 🏗️ Community modules (third-party)
    ├── stable/                 # 🟢 Stable community modules
    │   └── security.cfg.lua    # Security modules configuration
    ├── beta/                   # 🟡 Beta community modules
    │   └── advanced-xmpp.cfg.lua # Advanced XMPP features
    └── alpha/                  # 🟠 Alpha community modules
        └── experimental.cfg.lua # Experimental features
```

## Module Categories

### 🟢 **Core Modules**

- **Status**: Always enabled - Essential XMPP functionality
- **Source**: Built into Prosody core
- **Risk**: Minimal - Required for basic operation
- **Examples**: `roster`, `saslauth`, `tls`, `dialback`, `disco`

### ✅ **Official Modules**

- **Status**: Enabled by default - Distributed with Prosody
- **Source**: Official Prosody distribution
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
- **Examples**: `vcard4`, `password_reset`, `http_altconnect`

### 🟠 **Community Alpha Modules**

- **Status**: Opt-in - Experimental features
- **Source**: prosody-modules project (alpha/experimental)
- **Risk**: High - May have bugs or breaking changes
- **Examples**: `measure_cpu`, `json_logs`, `audit`, `compliance_policy`

## Environment Variables

Control which module categories are loaded:

```bash
# Official modules (enabled by default)
PROSODY_ENABLE_OFFICIAL=true     # Official Prosody modules

# Community modules
PROSODY_ENABLE_SECURITY=true     # Community security modules (stable)
PROSODY_ENABLE_BETA=false        # Community beta modules
PROSODY_ENABLE_ALPHA=false       # Community alpha/experimental modules
```

## Configuration Loading

The main `prosody.cfg.lua` file loads configurations conditionally:

1. **Core modules** - Always enabled (built into Prosody)
2. **Official modules** - Enabled by default (`PROSODY_ENABLE_OFFICIAL != false`)
3. **Community stable** - Enabled by default (`PROSODY_ENABLE_SECURITY != false`)
4. **Community beta** - Opt-in (`PROSODY_ENABLE_BETA == true`)
5. **Community alpha** - Opt-in (`PROSODY_ENABLE_ALPHA == true`)

## Module Inventory

### Core Modules (Always Enabled)

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
- `iq` - IQ stanza handling
- `message` - Message stanza handling
- `presence` - Presence stanza handling
- `c2s` - Client-to-server connections
- `s2s` - Server-to-server connections

### Official Modules (Distributed with Prosody)

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
- `offline` - Offline message storage
- `register_ibr` - In-band registration
- `register_limits` - Registration limits
- `user_account_management` - Account management
- `vcard_legacy` - vCard compatibility
- `mimicking` - Username mimicking prevention
- `cloud_notify` - Push notifications (XEP-0357)

### Community Modules (Third-Party)

- **Stable**: `firewall`, `spam_reporting`, `block_registrations`
- **Beta**: `vcard4`, `password_reset`, `http_altconnect`, `pubsub_serverinfo`, `cloud_notify_extensions`, `push`
- **Alpha**: `measure_cpu`, `measure_memory`, `measure_message_e2e`, `json_logs`, `audit`, `compliance_policy`

## Best Practices

### Production Deployments

- ✅ Use official modules for core functionality
- ✅ Consider community stable modules for security
- ⚠️ Test community beta modules thoroughly
- ❌ Avoid community alpha modules in production

### Development/Testing

- ✅ Test with community beta modules
- ✅ Experiment with community alpha modules
- ✅ Report issues to prosody-modules project
- ✅ Contribute improvements back

### Security Considerations

- ✅ Prefer official modules over community alternatives
- ✅ Regularly update community modules
- ✅ Monitor prosody-modules for security advisories
- ✅ Disable unused modules to reduce attack surface

## Official Documentation

This organization is based on the official Prosody modules documentation:

- **Core modules**: <https://prosody.im/doc/modules>
- **Community modules**: <https://modules.prosody.im/>

For the most up-to-date information, always refer to the official documentation.

This organization makes it clear which modules are officially supported and helps you make informed decisions about reliability and security.
