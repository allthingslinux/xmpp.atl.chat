# 📚 Message Archive Management (MAM) - XEP-0313

Message Archive Management (MAM) enables conversation history synchronization across multiple devices, even when clients are offline. This guide covers the configuration and usage of `mod_mam` in your Prosody XMPP server.

## 📋 Overview

MAM provides:

- **Cross-device synchronization** - Access message history from any device
- **Offline message access** - View conversations that happened while offline
- **Conversation history browser** - Browse past conversations in clients
- **Compliance support** - Message retention for legal/business requirements

## ⚙️ Configuration

All MAM settings are configured via environment variables in your `.env` file.

### Basic Setup

MAM is enabled by default with production-ready settings:

```bash
# Message retention (default: 1 year for compliance)
PROSODY_ARCHIVE_EXPIRES_AFTER=1y

# Archive policy (default: contacts only for privacy)
PROSODY_ARCHIVE_POLICY=roster

# Query performance (default: 250 messages per request)
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=250
```

### Archive Retention Policy

**Message Expiry:**

```bash
# Common retention periods
PROSODY_ARCHIVE_EXPIRES_AFTER=1d    # 1 day
PROSODY_ARCHIVE_EXPIRES_AFTER=1w    # 1 week (Prosody default)
PROSODY_ARCHIVE_EXPIRES_AFTER=1m    # 1 month
PROSODY_ARCHIVE_EXPIRES_AFTER=1y    # 1 year (recommended)
PROSODY_ARCHIVE_EXPIRES_AFTER=never # Keep forever (use with caution)

# Custom periods in seconds
PROSODY_ARCHIVE_EXPIRES_AFTER=2592000  # 30 days
```

### Archive Policy

**Who gets messages archived:**

```bash
# No archiving (not recommended for modern XMPP)
PROSODY_ARCHIVE_POLICY=false

# Only contacts in roster (privacy-friendly, default)
PROSODY_ARCHIVE_POLICY=roster

# All messages (maximum compatibility)
PROSODY_ARCHIVE_POLICY=true
```

### Performance Tuning

**Query Size Limits:**

```bash
# Conservative (many queries, lower server load)
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=50

# Balanced (default, good UX)
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=250

# Aggressive (fewer queries, higher server load)
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=500
```

**Cleanup Frequency:**

```bash
# More frequent cleanup (default: daily)
PROSODY_ARCHIVE_CLEANUP_INTERVAL=86400     # 24 hours

# Less frequent cleanup (weekly)
PROSODY_ARCHIVE_CLEANUP_INTERVAL=604800    # 7 days

# Conservative cleanup (monthly)
PROSODY_ARCHIVE_CLEANUP_INTERVAL=2592000   # 30 days
```

## 🎯 Advanced Configuration

### Smart Archiving

Save storage by only archiving for users who actually use MAM:

```bash
# Enable smart archiving (default: false)
PROSODY_MAM_SMART_ENABLE=true
```

**How it works:**

- Archiving disabled until user first queries their archive
- Once enabled, uses `PROSODY_ARCHIVE_POLICY` setting
- Reduces storage for users with legacy clients

### Storage Optimization

**Archive Compression:**

```bash
# Enable compression (default: true, recommended)
PROSODY_ARCHIVE_COMPRESSION=true

# Disable compression (faster, more storage)
PROSODY_ARCHIVE_COMPRESSION=false
```

**Namespace Exclusions:**

```bash
# Exclude custom namespaces from archiving
PROSODY_ARCHIVE_EXCLUDE_NAMESPACES="custom:namespace:1,custom:namespace:2"
```

**Default exclusions:**

- `http://jabber.org/protocol/chatstates` - Typing indicators
- `urn:xmpp:jingle-message:0` - Call setup messages

### Legacy Migration

**For older MAM installations:**

```bash
# Use legacy store name (only if migrating)
PROSODY_ARCHIVE_STORE=archive2
```

## 💾 Storage Backends

### SQL Storage (Recommended)

Default configuration uses PostgreSQL for reliability:

```lua
# Automatically configured
storage = {
    archive = "sql"  # MAM uses SQL storage
}
```

### Memory Storage (Development)

For testing or privacy-focused deployments:

```bash
# In prosody.cfg.lua (advanced users only)
storage = {
    archive = "memory"  # Lost on restart
}
```

**Use cases:**

- Development and testing
- Privacy-focused deployments
- Small servers with limited storage

**Limitations:**

- Messages lost on server restart
- No persistence across deployments
- Limited to available RAM

## 📱 Client Support

### Desktop Clients

**Gajim:**

- Full MAM support with conversation history
- Automatic synchronization across devices
- Message search and browsing

**Dino:**

- Native MAM integration
- Seamless message synchronization
- History browsing and search

**Conversations (Android):**

- Excellent MAM support
- Multi-device synchronization
- Offline message access

### Web Clients

**Converse.js:**

```javascript
// MAM automatically enabled
// History loaded on conversation open
// Search and pagination supported
```

**Movim:**

- Full MAM integration
- Web-based message history
- Cross-platform synchronization

## 🔧 Client Configuration

### Automatic Discovery

Modern clients automatically discover MAM support:

1. **Service Discovery** - Clients query server capabilities
2. **MAM Negotiation** - Client and server agree on settings
3. **History Sync** - Messages synchronized automatically

### Manual Configuration

Some clients allow MAM customization:

**Message Sync Preferences:**

- Always sync (all messages)
- Roster only (contacts only)
- Never sync (disable MAM)

**History Retrieval:**

- Sync all history
- Sync recent messages only
- On-demand history loading

## 📊 Monitoring & Metrics

### Archive Statistics

Monitor MAM usage with Prometheus metrics:

```promql
# Archive storage usage
prosody_archive_size_bytes

# Archive query rate
rate(prosody_archive_query_total[5m])

# Archive storage operations
rate(prosody_storage_operations_total{store="archive"}[5m])
```

### Database Monitoring

Track archive table growth:

```sql
-- PostgreSQL archive table size
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE tablename LIKE '%archive%';
```

## 🛠️ Maintenance

### Archive Cleanup

**Manual Cleanup:**

```bash
# Force cleanup of expired messages
docker compose exec prosody prosodyctl mod_mam expire
```

**Automatic Cleanup:**

- Runs every `PROSODY_ARCHIVE_CLEANUP_INTERVAL` seconds
- Removes messages older than `PROSODY_ARCHIVE_EXPIRES_AFTER`
- Logged in Prosody logs

### Storage Management

**Monitor Archive Growth:**

```bash
# Check archive table size
docker compose exec db psql -U prosody -d prosody -c "
SELECT pg_size_pretty(pg_total_relation_size('prosodyarchive'));
"
```

**Archive Compression:**

```bash
# PostgreSQL table compression (if needed)
docker compose exec db psql -U prosody -d prosody -c "
VACUUM FULL prosodyarchive;
"
```

## 🔒 Privacy & Compliance

### Data Protection

**GDPR Compliance:**

- Set appropriate retention periods
- Implement user data deletion
- Document data processing purposes

**Privacy Controls:**

```bash
# Privacy-friendly defaults
PROSODY_ARCHIVE_POLICY=roster        # Only contacts
PROSODY_ARCHIVE_EXPIRES_AFTER=90d    # 90-day retention
PROSODY_MAM_SMART_ENABLE=true        # Opt-in archiving
```

### User Rights

**Data Access:**

- Users can query their own archives
- Admin tools for data export
- Compliance with data portability

**Data Deletion:**

```bash
# Delete user's archive (manual process)
docker compose exec prosody prosodyctl mod_mam delete user@domain.com
```

## 🛠️ Troubleshooting

### Common Issues

**Messages not synchronizing:**

1. **Check MAM support:**

   ```bash
   # Verify MAM is enabled
   docker compose logs prosody | grep -i mam
   ```

2. **Test client support:**
   - Use MAM-compatible client (Conversations, Gajim)
   - Check client MAM settings
   - Verify service discovery

3. **Check archive policy:**

   ```bash
   # Ensure messages are being archived
   docker compose exec db psql -U prosody -d prosody -c "
   SELECT COUNT(*) FROM prosodyarchive;
   "
   ```

**Storage errors:**

1. **Check database connectivity:**

   ```bash
   docker compose exec prosody prosodyctl check config
   ```

2. **Verify archive table:**

   ```bash
   docker compose exec db psql -U prosody -d prosody -c "\dt"
   ```

3. **Check storage permissions:**

   ```bash
   docker compose logs prosody | grep -i storage
   ```

**Performance issues:**

1. **Optimize query size:**

   ```bash
   # Reduce query results
   PROSODY_ARCHIVE_MAX_QUERY_RESULTS=100
   ```

2. **Database optimization:**

   ```bash
   # Add database indexes (if needed)
   docker compose exec db psql -U prosody -d prosody -c "
   CREATE INDEX IF NOT EXISTS i_prosodyarchive_when ON prosodyarchive(when);
   "
   ```

### Debug Commands

**Check MAM configuration:**

```bash
# Verify MAM module is loaded
docker compose exec prosody prosodyctl check modules | grep mam

# Check archive settings
docker compose exec prosody prosodyctl config get archive_expires_after
```

**Test archive queries:**

```bash
# Query archive directly (advanced)
docker compose exec db psql -U prosody -d prosody -c "
SELECT user, store, when, with_user 
FROM prosodyarchive 
WHERE user = 'testuser' 
ORDER BY when DESC 
LIMIT 10;
"
```

## 📖 Standards Compliance

This implementation supports:

- **XEP-0313**: Message Archive Management (core)
- **XEP-0059**: Result Set Management (pagination)
- **XEP-0297**: Stanza Forwarding (message format)
- **XEP-0359**: Unique and Stable Stanza IDs

## 🎯 Best Practices

### Configuration

- **Use "roster" policy** for privacy by default
- **Set reasonable retention periods** based on compliance needs
- **Enable compression** to save storage space
- **Monitor storage growth** regularly

### Performance

- **Tune query limits** based on client usage patterns
- **Use appropriate cleanup intervals** (daily for production)
- **Monitor database performance** with archive queries
- **Consider storage backend** based on scale

### Security

- **Implement data retention policies** for compliance
- **Secure database access** with proper authentication
- **Monitor archive access** for unusual patterns
- **Regular backup** of archive data

## 🔗 Related Documentation

- [Message Carbons Configuration](message-carbons.md)
- [Stream Management](stream-management.md)
- [Database Configuration](database-configuration.md)
- [Client Configuration Guide](client-configuration.md)

## 🆘 Support

If you encounter MAM issues:

1. **Check client MAM support** and configuration
2. **Verify server logs** for archive-related errors
3. **Test with known-good clients** (Conversations, Gajim)
4. **Monitor database performance** and storage usage
5. **Contact support** with specific error messages and client details
