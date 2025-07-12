# Telepath XMPP Server Analysis

## Overview

The Telepath XMPP server (<https://forge.fsky.io/telepath/xmpp-server>) reportedly scores 100% on the XMPP compliance tester. This analysis compares their configuration with our current setup to identify best practices and potential improvements.

## Key Findings

### 1. Module Configuration Excellence

**Telepath's Strengths:**

- **Comprehensive module set**: They enable 40+ carefully selected modules
- **User-focused modules**: Strong emphasis on user experience with modules like:
  - `invites` + `invites_adhoc` + `invites_register` + `invites_register_web` (complete invitation system)
  - `cloud_notify` + `cloud_notify_extensions` (push notifications)
  - `password_reset` (user-friendly password recovery)
  - `http_altconnect` (alternative connection methods)
  - `lastactivity` (presence information)
  - `privilege` (component privileges)
  - `pubsub_serverinfo` (server information publishing)

**Our Current Gap:**

- We have a modular approach but miss several key user experience modules
- Our invitation system is not as comprehensive
- We lack cloud notification extensions
- No password reset functionality

### 2. Advanced Component Architecture

**Telepath's Component Setup:**

```lua
-- MUC with advanced features
Component "room.telepath.im" "muc"
modules_enabled = { "muc_mam", "vcard_muc", "muc_moderation", "muc_offline_delivery", "muc_hats_adhoc" }

-- HTTP File Share (separate from upload)
Component "hypertext.telepath.im" "http_file_share"
http_file_share_size_limit = 300*1024*1024 -- 300 MiB
http_file_share_global_quota = 200*1024*1024*1024 -- 200 GiB

-- PubSub component
Component "beacon.telepath.im" "pubsub"
pubsub_max_items = 10000

-- SOCKS5 proxy
Component "relayer.telepath.im" "proxy65"

-- Matrix gateway
Component "parsee.telepath.im" (external component)
```

**Our Current Gap:**

- We use basic MUC without advanced moderation features
- No dedicated HTTP file share component (only basic upload)
- No PubSub component
- No Matrix gateway integration
- Missing MUC offline delivery and hats (roles/badges)

### 3. Performance and Scalability Configuration

**Telepath's Performance Settings:**

```lua
-- High-performance limits
limits = {
    c2s = { rate = "10mb/s" };
    s2sin = { rate = "5mb/s" };
}

-- Extended hibernation for mobile devices
smacks_hibernation_time = 86400 -- 24 hours

-- Large PEP storage
pep_max_items = 10000

-- Efficient archiving
archive_expires_after = "1m" -- 1 month (shorter than our 1 year)
```

**Our Current Gap:**

- Our rate limits are much lower (10kb/s vs 10mb/s)
- We don't configure smacks hibernation time
- Lower PEP storage limits
- Longer archive retention (may impact performance)

### 4. Security and Anti-Spam

**Telepath's Security Features:**

```lua
-- Comprehensive blocked usernames
block_registrations_users = { 
    "ethereal", "telepath", "telepath.im", "fsky", "fsky.io", 
    "admin", "administrator", "root", "xmpp", "postmaster", 
    "webmaster", "hostmaster" 
}

-- Tombstone management
user_tombstone_expire = 60*86400 -- 2 months
muc_tombstones = true
muc_tombstone_expiry = 60*86400

-- Advanced modules
modules_enabled = {
    "mimicking", -- Prevent address spoofing
    "tombstones", -- Prevent registration of deleted accounts
    "watchregistrations", -- Alert admins of registrations
}
```

**Our Current Advantage:**

- We have more comprehensive firewall rules
- Better environment-driven security configuration
- More granular security module management

### 5. HTTP Integration and Web Services

**Telepath's Web Integration:**

```lua
-- Multiple HTTP services
http_host = "xmpp.telepath.im"
http_external_url = "https://xmpp.telepath.im/"
trusted_proxies = { "127.0.0.1", "::1" }

-- Custom HTTP paths
http_paths = {
    invites_page = "/join/$host/invite";
    invites_register_web = "/join/$host/register";
}

-- CORS headers for host-meta
header /.well-known/host-meta Access-Control-Allow-Origin "*"
```

**Our Current Gap:**

- No web-based invitation system
- No custom HTTP paths configuration
- Missing CORS headers for discovery
- No host-meta configuration

### 6. Database and Storage

**Telepath's Database Config:**

```lua
storage = "sql"
sql = {
    driver = "PostgreSQL";
    database = "prosody";
    username = "prosody";
    password = "dolphins"; -- Simple password (not best practice)
    host = "localhost";
}
```

**Our Current Advantage:**

- Environment-driven database configuration
- Connection pooling configuration
- Multiple storage backend support
- Better security practices for credentials

### 7. Contact Information and Compliance

**Telepath's Contact Setup:**

```lua
contact_info = {
    admin = { "xmpp:admin@telepath.im", "mailto:telepath@riseup.net", "https://toot.community/@telepath" };
    support = { "xmpp:admin@telepath.im", "mailto:telepath@riseup.net", "https://toot.community/@telepath" };
    abuse = { "xmpp:admin@telepath.im", "mailto:telepath@riseup.net", "https://toot.community/@telepath" };
}
```

**Our Current Gap:**

- No contact information configuration
- Missing server contact info module

## Recommendations for Improvement

### Immediate Improvements (High Impact)

1. **Add Missing Core Modules:**

```lua
-- Add to our modules_enabled
"invites", "invites_adhoc", "invites_register", "invites_register_web",
"cloud_notify_extensions", "password_reset", "http_altconnect",
"lastactivity", "mimicking", "tombstones", "pubsub_serverinfo"
```

2. **Enhance MUC Configuration:**

```lua
-- Add to MUC component
"muc_moderation", "muc_offline_delivery", "muc_hats_adhoc"
```

3. **Add Contact Information:**

```lua
contact_info = {
    admin = { "xmpp:admin@" .. main_domain, "mailto:admin@" .. main_domain };
    support = { "xmpp:admin@" .. main_domain, "mailto:support@" .. main_domain };
    abuse = { "xmpp:admin@" .. main_domain, "mailto:abuse@" .. main_domain };
}
```

4. **Improve Performance Settings:**

```lua
-- Increase rate limits for better performance
limits = {
    c2s = { rate = "1mb/s", burst = "2mb" };
    s2sin = { rate = "500kb/s", burst = "1mb" };
}

-- Configure smacks hibernation
smacks_hibernation_time = 86400 -- 24 hours
```

### Medium-term Improvements

1. **Add HTTP File Share Component:**

```lua
Component ("files." .. main_domain) "http_file_share"
    http_file_share_size_limit = 100*1024*1024 -- 100 MiB
    http_file_share_expires_after = 30*86400 -- 1 month
```

2. **Add PubSub Component:**

```lua
Component ("pubsub." .. main_domain) "pubsub"
    pubsub_max_items = 1000
```

3. **Web-based Invitation System:**

```lua
http_paths = {
    invites_page = "/join/$host/invite";
    invites_register_web = "/join/$host/register";
}
```

### Long-term Improvements

1. **Matrix Gateway Integration** (if needed)
2. **Advanced Monitoring** with pubsub_serverinfo
3. **Web Interface** for user management

## Configuration Comparison Summary

| Feature | Telepath | Our Setup | Recommendation |
|---------|----------|-----------|----------------|
| Module Count | 40+ modules | 20+ modules | Add 15+ missing modules |
| Rate Limits | 10mb/s | 10kb/s | Increase to 1mb/s |
| MUC Features | Advanced | Basic | Add moderation, offline delivery |
| File Sharing | Dedicated component | Basic upload | Add http_file_share |
| Invitations | Full web system | None | Implement web invitations |
| Contact Info | Complete | Missing | Add contact_info |
| Performance | Optimized | Conservative | Increase limits |
| Security | Good | Excellent | Keep our approach |

## Conclusion

The Telepath XMPP server achieves 100% compliance through:

1. **Comprehensive module coverage** - they enable almost every useful module
2. **User-focused features** - strong emphasis on user experience
3. **Performance optimization** - high rate limits and efficient settings
4. **Complete component architecture** - dedicated components for different services
5. **Web integration** - seamless web-based user management

Our current setup is more security-focused and enterprise-ready, but we can significantly improve compliance and user experience by adopting many of Telepath's module choices and configuration patterns.
