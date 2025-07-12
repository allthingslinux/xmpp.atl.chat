# Module Stability Guide

This guide explains our stability-based module organization system and provides detailed information about each module's purpose and stability level.

## Stability Levels

### 🟢 **Core Modules**

- **Status**: Always enabled
- **Risk**: Minimal - part of Prosody core
- **Description**: Essential XMPP functionality required for basic operation

### 🟢 **Stable Modules**

- **Status**: Enabled by default
- **Risk**: Low - production-ready community modules
- **Description**: Well-tested modules with active maintenance and broad deployment

### 🟡 **Beta Modules**

- **Status**: Enabled by default (can be disabled)
- **Risk**: Medium - mostly stable with some edge cases
- **Description**: Mature modules that may have minor issues in specific scenarios

### 🟠 **Alpha/Experimental Modules**

- **Status**: Disabled by default (explicit opt-in required)
- **Risk**: High - experimental features
- **Description**: Cutting-edge features that may have bugs or breaking changes

## Module Inventory

### 🟢 Core Modules (Always Enabled)

| Module | Purpose | Notes |
|--------|---------|-------|
| `roster` | Contact list management | Essential for XMPP |
| `saslauth` | Authentication mechanism | Required for login |
| `tls` | Transport Layer Security | Encryption support |
| `dialback` | Server-to-server authentication | S2S communication |
| `disco` | Service discovery | Feature advertisement |
| `private` | Private XML storage | Client settings storage |
| `vcard` | User profile information | Contact cards |
| `version` | Software version queries | Diagnostic information |
| `uptime` | Server uptime reporting | Monitoring |
| `time` | Time synchronization | Timestamp services |
| `ping` | Connection keep-alive | Network health |

### 🟢 Stable Modules (Production Ready)

#### Security (Stable)

| Module | Purpose | XMPP Safeguarding Compliance |
|--------|---------|------------------------------|
| `firewall` | Rule-based packet filtering | ✅ Required for spam/abuse control |
| `limits` | Rate limiting and DoS protection | ✅ Required for connection limits |
| `blocklist` | IP/domain blocking | ✅ Required for malicious server blocking |
| `spam_reporting` | Spam report handling | ✅ Required for abuse reporting |
| `watchregistrations` | Registration monitoring | ✅ Required for registration oversight |
| `block_registrations` | Registration restrictions | ✅ Required for registration control |
| `tombstones` | Deleted user handling | ✅ Required for privacy compliance |

#### Modern XMPP (Stable)

| Module | Purpose | XEP Reference |
|--------|---------|---------------|
| `carbons` | Message synchronization | XEP-0280 |
| `mam` | Message Archive Management | XEP-0313 |
| `smacks` | Stream Management | XEP-0198 |
| `csi_simple` | Client State Indication | XEP-0352 |
| `bookmarks` | Bookmark synchronization | XEP-0048/0402 |
| `invites` | Invitation system | XEP-0401 |
| `invites_adhoc` | Ad-hoc invitations | XEP-0401 |
| `lastactivity` | Last activity tracking | XEP-0012 |

### 🟡 Beta Modules (Mostly Stable)

#### Security (Beta)

| Module | Purpose | Notes |
|--------|---------|-------|
| `mimicking` | Username similarity detection | Prevents impersonation attacks |

#### Modern XMPP (Beta)

| Module | Purpose | XEP Reference |
|--------|---------|---------------|
| `cloud_notify` | Push notifications | XEP-0357 |
| `cloud_notify_extensions` | Enhanced push notifications | XEP-0357 extensions |
| `push` | Push notification core | XEP-0357 |
| `vcard4` | Modern vCard support | XEP-0292 |
| `invites_register` | Registration via invites | XEP-0401 |
| `invites_register_web` | Web-based invite registration | XEP-0401 |
| `password_reset` | Password reset functionality | Custom |
| `http_altconnect` | Alternative connection methods | XEP-0156 |
| `pubsub_serverinfo` | Server information publishing | XEP-0157 |

### 🟠 Alpha/Experimental Modules (Use with Caution)

#### Enterprise Features (Alpha/Experimental)

| Module | Purpose | Stability Concerns |
|--------|---------|-------------------|
| `measure_cpu` | CPU usage monitoring | May impact performance |
| `measure_memory` | Memory usage monitoring | May impact performance |
| `measure_message_e2e` | End-to-end message metrics | Privacy implications |
| `json_logs` | JSON-formatted logging | Format may change |
| `audit` | Security audit logging | Implementation evolving |
| `compliance_policy` | Compliance enforcement | Policy format may change |

### 🔧 HTTP Services (Mixed Stability)

| Module | Purpose | Stability | Notes |
|--------|---------|-----------|-------|
| `bosh` | BOSH connections | 🟢 Stable | XEP-0124/0206 |
| `websocket` | WebSocket connections | 🟢 Stable | RFC 7395 |
| `http_upload` | File upload service | 🟡 Beta | XEP-0363 |
| `http_file_share` | Modern file sharing | 🟡 Beta | XEP-0447 |

### 🛠️ Administration Modules (Mixed Stability)

| Module | Purpose | Stability | Notes |
|--------|---------|-----------|-------|
| `admin_adhoc` | Ad-hoc admin commands | 🟢 Stable | XEP-0050 |
| `admin_shell` | Admin shell interface | 🟢 Stable | Built-in |
| `statistics` | Server statistics | 🟡 Beta | Metrics collection |
| `prometheus` | Prometheus metrics | 🟡 Beta | Monitoring integration |
| `server_contact_info` | Contact information | 🟢 Stable | XEP-0157 |

## Configuration Control

### Environment Variables

```bash
# Stability-based controls
PROSODY_ENABLE_SECURITY=true      # Stable security modules
PROSODY_ENABLE_MODERN=true        # Stable modern XMPP modules
PROSODY_ENABLE_BETA=true          # Beta modules (mostly stable)
PROSODY_ENABLE_ALPHA=false        # Alpha/experimental modules

# Feature-based controls
PROSODY_ENABLE_HTTP=false         # HTTP services
PROSODY_ENABLE_ADMIN=false        # Administration modules
```

### Recommended Configurations

#### 🏠 **Personal Server (1-50 users)**

```bash
PROSODY_ENABLE_SECURITY=true
PROSODY_ENABLE_MODERN=true
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=false
PROSODY_ENABLE_HTTP=false
PROSODY_ENABLE_ADMIN=false
```

#### 🏢 **Community Server (50-500 users)**

```bash
PROSODY_ENABLE_SECURITY=true
PROSODY_ENABLE_MODERN=true
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=false
PROSODY_ENABLE_HTTP=true
PROSODY_ENABLE_ADMIN=true
```

#### 🏭 **Enterprise Server (500+ users)**

```bash
PROSODY_ENABLE_SECURITY=true
PROSODY_ENABLE_MODERN=true
PROSODY_ENABLE_BETA=false         # Conservative approach
PROSODY_ENABLE_ALPHA=false
PROSODY_ENABLE_HTTP=true
PROSODY_ENABLE_ADMIN=true
```

#### 🧪 **Development/Testing**

```bash
PROSODY_ENABLE_SECURITY=true
PROSODY_ENABLE_MODERN=true
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=true         # Test cutting-edge features
PROSODY_ENABLE_HTTP=true
PROSODY_ENABLE_ADMIN=true
```

## Risk Assessment

### Low Risk (Safe for Production)

- **Core modules**: Essential functionality
- **Stable modules**: Battle-tested in production
- **Most HTTP services**: Standard protocols

### Medium Risk (Monitor Carefully)

- **Beta modules**: Generally stable but may have edge cases
- **Some admin modules**: May expose additional attack surface

### High Risk (Development/Testing Only)

- **Alpha modules**: Experimental features
- **Monitoring modules**: May impact performance
- **Compliance modules**: Evolving implementations

## Monitoring and Maintenance

### Startup Logging

The system logs module stability information on startup:

```
Module stability profile: Core=11, Stable=15, Beta=9, Alpha=6, HTTP=4, Admin=5
```

### Regular Review Schedule

- **Monthly**: Review enabled modules and their stability status
- **Quarterly**: Check for module updates and stability changes
- **Before upgrades**: Verify module compatibility
- **After incidents**: Assess if module-related issues occurred

### Module Update Strategy

1. **Core modules**: Updated with Prosody releases
2. **Stable modules**: Update regularly with testing
3. **Beta modules**: Update with caution, test thoroughly
4. **Alpha modules**: Update only when necessary, extensive testing required

## Troubleshooting

### Common Issues by Stability Level

#### Stable Module Issues

- Usually configuration-related
- Check module documentation
- Verify environment variables
- Review log files for errors

#### Beta Module Issues

- May have compatibility issues
- Check community forums
- Consider disabling problematic modules
- Report bugs to module maintainers

#### Alpha Module Issues

- Expect occasional problems
- Use only in development/testing
- Keep detailed logs
- Be prepared to disable quickly

### Debugging Commands

```bash
# Check enabled modules
prosodyctl about

# Test configuration
prosodyctl check config

# Monitor module loading
tail -f /var/log/prosody/prosody.log | grep -i module

# Check module status
prosodyctl shell
> module:list_loaded()
```

## Migration Guide

### From Feature-Based to Stability-Based

If migrating from the old feature-based system:

1. **Backup your configuration**
2. **Update environment variables**:
   - `PROSODY_ENABLE_ENTERPRISE=true` → `PROSODY_ENABLE_ALPHA=true`
   - Other variables remain the same
3. **Review enabled modules** in logs after restart
4. **Test functionality** to ensure nothing is broken

### Gradual Rollout Strategy

1. **Start conservative**: Disable beta and alpha modules
2. **Enable beta modules**: One category at a time
3. **Monitor for issues**: Check logs and user reports
4. **Enable alpha modules**: Only if needed and in testing first

## Best Practices

### Production Deployments

- ✅ Always enable security modules
- ✅ Use stable and beta modules for core functionality
- ❌ Avoid alpha modules in production
- ✅ Monitor module performance impact
- ✅ Have rollback plan for module changes

### Development/Testing

- ✅ Test with alpha modules to prepare for future
- ✅ Report bugs and issues to community
- ✅ Document module behavior and compatibility
- ✅ Maintain separate configs for dev/prod

### Security Considerations

- ✅ Regularly review enabled modules
- ✅ Disable unused modules to reduce attack surface
- ✅ Keep modules updated
- ✅ Monitor security advisories
- ✅ Follow principle of least privilege

This stability-based approach provides clear risk assessment and makes it easier to maintain a secure, reliable XMPP server while still having access to cutting-edge features when needed.
