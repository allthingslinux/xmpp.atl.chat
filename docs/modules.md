# 📦 Module Reference

This document provides a comprehensive reference of all modules enabled in the Professional Prosody XMPP Server. Our single configuration includes **50+ modules** for maximum XMPP compatibility and modern features.

## 🔧 Core Prosody Modules

These are the essential modules included with Prosody that provide basic XMPP functionality:

### Connection & Authentication

- **`roster`** - Contact list management (RFC 6121)
- **`saslauth`** - SASL authentication mechanisms
- **`tls`** - TLS encryption for secure connections
- **`dialback`** - Server-to-server authentication (XEP-0220)
- **`disco`** - Service Discovery (XEP-0030)

### Core Messaging

- **`carbons`** - Message Carbons for multi-device sync (XEP-0280)
- **`pep`** - Personal Eventing Protocol (XEP-0163)
- **`private`** - Private XML Storage (XEP-0049)
- **`blocklist`** - Block communication (XEP-0191)
- **`vcard4`** - User profiles and avatars (XEP-0292)
- **`vcard_legacy`** - Legacy vCard support (XEP-0054)

### Advanced Features

- **`mam`** - Message Archive Management (XEP-0313)
- **`smacks`** - Stream Management for reliability (XEP-0198)
- **`csi_simple`** - Client State Indication for mobile (XEP-0352)
- **`cloud_notify`** - Push notifications (XEP-0357)

## 🌐 Community Modules

These modules from the [Prosody Community Modules](https://modules.prosody.im/) project provide additional functionality:

### Security & Anti-Spam

- **`mod_firewall`** - Advanced firewall and filtering
- **`mod_spam_reporting`** - Report spam messages (XEP-0377)
- **`mod_block_registrations`** - Block unwanted registrations
- **`mod_watchregistrations`** - Monitor new user registrations
- **`mod_welcome`** - Welcome messages for new users

### Mobile & Modern Clients

- **`mod_smacks`** - Enhanced stream management
- **`mod_csi_battery_saver`** - Optimize for mobile battery life
- **`mod_cloud_notify_encrypted`** - Encrypted push notifications
- **`mod_unified_push`** - UnifiedPush notification support

### File Sharing & Media

- **`mod_http_upload`** - HTTP File Upload (XEP-0363)
- **`mod_http_upload_external`** - External file upload services
- **`mod_file_management`** - File management and cleanup

### Multi-User Chat (MUC) Enhancements

- **`mod_muc_mam`** - Message archiving for group chats
- **`mod_muc_limits`** - Room size and message limits
- **`mod_muc_moderation`** - Message moderation (XEP-0425)
- **`mod_muc_rtbl`** - Real-time blocklist for MUC

### Authentication & Integration

- **`mod_auth_ldap`** - LDAP directory integration
- **`mod_auth_external`** - External authentication scripts
- **`mod_sasl2`** - SASL 2.0 support (XEP-0388)
- **`mod_fast`** - Fast authentication (XEP-0484)

### WebSocket & Web Support

- **`mod_websocket`** - WebSocket connections (RFC 7395)
- **`mod_bosh`** - BOSH HTTP binding (XEP-0206)
- **`mod_http_files`** - Static file serving
- **`mod_admin_web`** - Web-based administration
- **`mod_conversejs`** - Serves the Converse.js web client at `/conversejs` with auto-generated config matching the local `VirtualHost`. Uses BOSH/WebSocket automatically and supports templating and CDN overrides. See [module docs](https://modules.prosody.im/mod_conversejs.html) and [Converse.js](https://conversejs.org/).

### Voice/Video & Real-time

- **`mod_external_services`** - External service discovery (XEP-0215)
- **`mod_turn_external`** - TURN/STUN server integration
- **`mod_jingle_stats`** - Voice/video call statistics

### Monitoring & Diagnostics

- **`mod_prometheus`** - Prometheus metrics export
- **`mod_measure_memory`** - Memory usage monitoring
- **`mod_http_status`** - HTTP health check endpoint
- **`mod_watchdog`** - Service health monitoring

## 🔐 Security Modules

### Transport Layer Security

```lua
-- TLS Configuration
modules_enabled = {
    "tls";                    -- TLS encryption
}

ssl = {
    protocol = "tlsv1_3+";    -- TLS 1.3 preferred
    ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM";
    curve = "P-256:P-384";
    honor_cipher_order = true;
}
```

### Authentication Security

```lua
-- SASL Configuration
authentication = "internal_hashed";  -- Secure password storage
sasl_mechanisms = {
    "SCRAM-SHA-256";                 -- Secure authentication
    "SCRAM-SHA-1";                   -- Fallback support
}
```

### Anti-Spam & Firewall

```lua
-- Firewall Rules
modules_enabled = {
    "firewall";              -- Advanced filtering
    "spam_reporting";        -- Report spam
    "block_registrations";   -- Block unwanted signups
}
```

## 📱 Mobile Optimization Modules

### Battery Saving

```lua
-- Client State Indication
modules_enabled = {
    "csi_simple";            -- Basic CSI support
    "csi_battery_saver";     -- Advanced battery optimization
}

-- Push Notifications
modules_enabled = {
    "cloud_notify";          -- XEP-0357 support
    "cloud_notify_encrypted"; -- Encrypted notifications
    "unified_push";          -- UnifiedPush support
}
```

### Connection Reliability

```lua
-- Stream Management
modules_enabled = {
    "smacks";                -- XEP-0198 support
}

smacks_hibernation_time = 600;    -- 10 minutes
smacks_max_hibernated_sessions = 10;
smacks_max_old_sessions = 10;
```

## 🌐 HTTP & Web Modules

### HTTP Services

```lua
-- HTTP Server Configuration
modules_enabled = {
    "http";                  -- HTTP server
    "http_files";           -- Static file serving
    "http_upload";          -- File upload (XEP-0363)
    "websocket";            -- WebSocket support
    "bosh";                 -- BOSH support
    "admin_web";            -- Web admin interface
}

http_ports = { 5280 };
https_ports = { 5281 };
```

### File Upload Configuration

```lua
-- HTTP Upload Settings
http_upload_file_size_limit = 50 * 1024 * 1024;  -- 50MB
http_upload_expire_after = 60 * 60 * 24 * 7;     -- 7 days
http_upload_quota = 1024 * 1024 * 1024;          -- 1GB per user
```

## 💬 Multi-User Chat (MUC) Modules

### MUC Configuration

```lua
-- MUC Component
Component "conference." .. (ENV_DOMAIN or "localhost") "muc"
    modules = {
        "muc_mam";           -- Message archiving
        "muc_limits";        -- Room limits
        "muc_moderation";    -- Message moderation
        "vcard_muc";         -- Room avatars
    }

muc_room_default_public = false;
muc_room_default_members_only = false;
muc_room_default_moderated = false;
```

## 📊 Monitoring & Metrics Modules

### Prometheus Integration

```lua
-- Monitoring Configuration
modules_enabled = {
    "prometheus";            -- Metrics export
    "measure_memory";        -- Memory monitoring
    "http_status";          -- Health checks
    "watchdog";             -- Service monitoring
}

-- Prosody metrics available at /metrics endpoint on HTTP port
-- Configure external Prometheus to scrape: http://your-domain:5280/metrics
```

### Health Monitoring

```lua
-- Health Check Configuration
http_paths = {
    health = "/health";      -- Health check endpoint
    metrics = "/metrics";    -- Prometheus metrics
}
```

## 🗄️ Storage & Archive Modules

### Message Archiving

```lua
-- MAM Configuration  
modules_enabled = {
    "mam";                   -- Message Archive Management
    "muc_mam";              -- MUC archiving
}

archive_expires_after = "1y";     -- Keep messages for 1 year
muc_log_expires_after = "1y";     -- MUC logs retention
```

### Database Configuration

```lua
-- PostgreSQL Storage
storage = "sql";
sql = {
    driver = "PostgreSQL";
    database = ENV_DB_NAME or "prosody";
    username = ENV_DB_USER or "prosody";
    password = ENV_DB_PASSWORD;
    host = ENV_DB_HOST or "localhost";
    port = ENV_DB_PORT or 5432;
}
```

## 🔧 Module Configuration Examples

### Enabling Custom Modules

To add additional modules to your deployment:

1. **Add to environment variables**:

```bash
# Add to .env file
PROSODY_EXTRA_MODULES=mod_example,mod_another
```

2. **Mount custom modules**:

```yaml
# In docker-compose.yml
volumes:
  - ./custom-modules:/usr/local/lib/prosody/modules
```

### Module Dependencies

Some modules have dependencies on others:

| Module | Dependencies |
|--------|-------------|
| `mod_mam` | `mod_disco`, storage backend |
| `mod_cloud_notify` | `mod_smacks`, `mod_csi_simple` |
| `mod_http_upload` | `mod_http`, storage backend |
| `mod_admin_web` | `mod_http`, `mod_admin_adhoc` |

### Troubleshooting Modules

```bash
# Check module status
docker compose exec xmpp-prosody prosodyctl check modules

# List enabled modules
docker compose exec xmpp-prosody prosodyctl list modules

# Test specific module
docker compose exec xmpp-prosody prosodyctl test mod_example
```

## 📚 Module Resources

### Documentation Links

- **[Prosody Modules](https://prosody.im/doc/modules)** - Official module documentation
- **[Community Modules](https://modules.prosody.im/)** - Community module repository
- **[XEP Documentation](https://xmpp.org/extensions/)** - XMPP protocol specifications

### Security Considerations

When adding new modules:

1. **Verify source** - Only use trusted module sources
2. **Review code** - Check module code for security issues
3. **Test thoroughly** - Test in development before production
4. **Monitor impact** - Watch for performance/security impacts
5. **Keep updated** - Regularly update to latest versions

---

**💡 Pro Tip**: This configuration includes all essential modules for a modern XMPP server. The defaults are production-ready and secure. Only add additional modules if you have specific requirements not covered by the included set.
