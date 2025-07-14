# MUC Message Archiving Configuration Guide

This guide covers the configuration and management of Message Archive Management (MAM) for Multi-User Chat (MUC) rooms using XEP-0313.

## Overview

MUC Message Archiving automatically stores group chat messages on the server, allowing users to:

- Access chat history when joining rooms
- Synchronize messages across multiple devices
- Retrieve missed messages from when they were offline
- Maintain compliance with organizational record-keeping requirements

## Quick Start

### Basic Configuration

The server comes with sensible defaults for MUC archiving. To customize settings, add these to your `.env` file:

```bash
# Enable archiving by default for all new rooms
PROSODY_MUC_LOG_BY_DEFAULT=true

# Store room messages for 1 year
PROSODY_MUC_LOG_EXPIRES_AFTER=1y

# Return up to 100 messages per query
PROSODY_MUC_MAX_ARCHIVE_QUERY_RESULTS=100
```

### Room-Level Control

Room administrators can control archiving per room through their XMPP client's room configuration interface.

## Configuration Options

### Core Settings

#### `PROSODY_MUC_LOG_BY_DEFAULT`

- **Default**: `true`
- **Values**: `true`, `false`
- **Description**: Whether new rooms have archiving enabled by default

```bash
# New rooms start with archiving enabled
PROSODY_MUC_LOG_BY_DEFAULT=true

# New rooms start with archiving disabled (must be manually enabled)
PROSODY_MUC_LOG_BY_DEFAULT=false
```

#### `PROSODY_MUC_LOG_EXPIRES_AFTER`

- **Default**: `1y`
- **Values**: `1d`, `1w`, `1m`, `1y`, `never`, or seconds as number
- **Description**: How long room messages are stored

```bash
# Common retention periods
PROSODY_MUC_LOG_EXPIRES_AFTER=1w      # 1 week
PROSODY_MUC_LOG_EXPIRES_AFTER=1m      # 1 month
PROSODY_MUC_LOG_EXPIRES_AFTER=1y      # 1 year (default)
PROSODY_MUC_LOG_EXPIRES_AFTER=never   # Keep forever
PROSODY_MUC_LOG_EXPIRES_AFTER=2592000 # 30 days in seconds
```

#### `PROSODY_MUC_MAX_ARCHIVE_QUERY_RESULTS`

- **Default**: `100`
- **Range**: `50-250`
- **Description**: Maximum messages returned per query

```bash
# Balance between performance and user experience
PROSODY_MUC_MAX_ARCHIVE_QUERY_RESULTS=100  # Default
PROSODY_MUC_MAX_ARCHIVE_QUERY_RESULTS=50   # Conservative
PROSODY_MUC_MAX_ARCHIVE_QUERY_RESULTS=250  # High-volume rooms
```

### Advanced Settings

#### `PROSODY_MUC_LOG_PRESENCES`

- **Default**: `false`
- **Values**: `true`, `false`
- **Description**: Archive join/part/status messages

```bash
# Archive presence changes (increases storage usage)
PROSODY_MUC_LOG_PRESENCES=true

# Only archive actual messages (recommended)
PROSODY_MUC_LOG_PRESENCES=false
```

#### `PROSODY_MUC_LOG_ALL_ROOMS`

- **Default**: `false`
- **Values**: `true`, `false`
- **Description**: Force archiving for all rooms (disables room-level control)

```bash
# Allow rooms to control their own archiving
PROSODY_MUC_LOG_ALL_ROOMS=false

# Force all rooms to be archived (compliance mode)
PROSODY_MUC_LOG_ALL_ROOMS=true
```

#### `PROSODY_MUC_MAM_SMART_ENABLE`

- **Default**: `false`
- **Values**: `true`, `false`
- **Description**: Only start archiving after first MAM query

```bash
# Archive all configured rooms immediately
PROSODY_MUC_MAM_SMART_ENABLE=false

# Only archive rooms that actually use MAM (saves storage)
PROSODY_MUC_MAM_SMART_ENABLE=true
```

### Storage Optimization

#### `PROSODY_MUC_LOG_COMPRESSION`

- **Default**: `true`
- **Values**: `true`, `false`
- **Description**: Compress archived messages

```bash
# Enable compression (recommended)
PROSODY_MUC_LOG_COMPRESSION=true

# Disable compression (faster but uses more storage)
PROSODY_MUC_LOG_COMPRESSION=false
```

#### `PROSODY_MUC_ARCHIVE_EXCLUDE_NAMESPACES`

- **Default**: Excludes typing indicators and call messages
- **Format**: Comma-separated list
- **Description**: Namespaces to exclude from archiving

```bash
# Exclude custom namespaces to reduce storage
PROSODY_MUC_ARCHIVE_EXCLUDE_NAMESPACES="http://example.com/custom,urn:example:custom"
```

### Maintenance Settings

#### `PROSODY_MUC_LOG_CLEANUP_INTERVAL`

- **Default**: `86400` (daily)
- **Values**: Seconds between cleanup runs
- **Description**: How often to remove expired messages

```bash
# Daily cleanup (recommended)
PROSODY_MUC_LOG_CLEANUP_INTERVAL=86400

# Hourly cleanup (high-volume servers)
PROSODY_MUC_LOG_CLEANUP_INTERVAL=3600

# Weekly cleanup (low-volume servers)
PROSODY_MUC_LOG_CLEANUP_INTERVAL=604800
```

## Client Usage

### Retrieving Room History

Most modern XMPP clients automatically request room history when joining. Users can also manually request history:

#### Conversations (Android)

1. Join the room
2. Scroll up to load more history
3. Use "Load earlier messages" if available

#### Gajim (Desktop)

1. Join the room
2. Right-click in the chat area
3. Select "Request chat history"
4. Choose date range

#### Siskin IM (iOS)

1. Join the room
2. Pull down to refresh and load history
3. Use "Load more messages" button

### Room Configuration

Room administrators can configure archiving through their client:

#### Enabling/Disabling Archiving

1. Join the room as admin/owner
2. Access room configuration (usually right-click → "Configure room")
3. Look for "Message Archiving" or "Store messages" option
4. Enable or disable as needed

## Monitoring and Maintenance

### Storage Usage

Monitor MUC archive storage usage:

```bash
# Check database size for MUC logs
docker compose exec db psql -U prosody -d prosody -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE tablename LIKE '%muc%archive%' OR tablename LIKE '%muc%log%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"

# Check archive record counts
docker compose exec db psql -U prosody -d prosody -c "
SELECT COUNT(*) as total_muc_messages FROM prosodyarchive WHERE store LIKE '%muc%';
"
```

### Performance Monitoring

Key metrics to monitor:

```bash
# Archive query performance
curl -s http://localhost:5280/metrics | grep muc_archive

# Storage cleanup metrics
curl -s http://localhost:5280/metrics | grep archive_cleanup
```

### Manual Cleanup

Force cleanup of expired messages:

```bash
# Trigger immediate cleanup
docker compose exec xmpp-prosody prosodyctl mod_mam cleanup
```

## Compliance and Privacy

### GDPR Compliance

When archiving is enabled, inform users about:

- What data is stored (messages, timestamps, participants)
- How long data is retained
- How to request data deletion
- Who has access to archived data

#### Privacy Notice Example

```
This room has message archiving enabled. Messages are stored for 
[retention period] and may be accessed by room administrators. 
For data deletion requests, contact [admin contact].
```

### Data Retention Policies

Configure appropriate retention based on your requirements:

```bash
# Personal/informal rooms - shorter retention
PROSODY_MUC_LOG_EXPIRES_AFTER=1w

# Business/compliance rooms - longer retention
PROSODY_MUC_LOG_EXPIRES_AFTER=7y

# Legal/regulatory rooms - permanent retention
PROSODY_MUC_LOG_EXPIRES_AFTER=never
```

### User Notifications

Enable notifications about archiving:

```bash
# Notify users when joining archived rooms
PROSODY_MUC_LOG_NOTIFICATION=true
```

## Troubleshooting

### Common Issues

#### Messages Not Being Archived

1. **Check room configuration**:

   ```bash
   # Verify archiving is enabled for the room
   docker compose logs prosody | grep -i "muc.*archive"
   ```

2. **Verify module is loaded**:

   ```bash
   docker compose exec xmpp-prosody prosodyctl about | grep muc_mam
   ```

3. **Check storage configuration**:

   ```bash
   # Ensure muc_log is using SQL storage
   docker compose exec xmpp-prosody prosodyctl check config
   ```

#### History Not Loading in Clients

1. **Check MAM support**:
   - Ensure client supports XEP-0313 (MAM)
   - Update client to latest version

2. **Verify query limits**:

   ```bash
   # Increase query results if needed
   PROSODY_MUC_MAX_ARCHIVE_QUERY_RESULTS=250
   ```

3. **Test with different client**:
   - Try Conversations (Android) or Gajim (desktop)
   - These have excellent MAM support

#### High Storage Usage

1. **Enable compression**:

   ```bash
   PROSODY_MUC_LOG_COMPRESSION=true
   ```

2. **Reduce retention period**:

   ```bash
   PROSODY_MUC_LOG_EXPIRES_AFTER=3m
   ```

3. **Exclude unnecessary namespaces**:

   ```bash
   PROSODY_MUC_ARCHIVE_EXCLUDE_NAMESPACES="http://jabber.org/protocol/chatstates"
   ```

4. **Enable smart archiving**:

   ```bash
   PROSODY_MUC_MAM_SMART_ENABLE=true
   ```

#### Performance Issues

1. **Optimize cleanup interval**:

   ```bash
   # Less frequent cleanup for better performance
   PROSODY_MUC_LOG_CLEANUP_INTERVAL=604800  # Weekly
   ```

2. **Check database performance**:

   ```bash
   # Monitor database queries
   docker compose logs db | grep -i slow
   ```

3. **Consider database tuning**:
   - Increase `shared_buffers` in PostgreSQL
   - Add indexes for large archive tables

### Debug Commands

```bash
# Check MUC MAM module status
docker compose exec xmpp-prosody prosodyctl about | grep -A5 -B5 muc_mam

# View recent MUC archive activity
docker compose logs prosody | grep -i "muc.*archive" | tail -20

# Test MAM query manually (advanced)
docker compose exec xmpp-prosody prosodyctl shell
> muc_mam = require "core.moduleapi".get_module("muc", "muc_mam")
```

## Security Considerations

### Access Control

- Only room participants can access archived messages
- Room administrators have full access to archives
- Server administrators have database-level access

### Encryption

- Messages are stored as received (plaintext if not E2E encrypted)
- Consider enabling E2E encryption in sensitive rooms
- Database encryption at rest is recommended

### Backup Security

- Ensure archive backups are properly secured
- Consider encrypted backup storage
- Implement proper backup retention policies

## Migration and Upgrades

### Upgrading Archive Format

When upgrading Prosody versions:

```bash
# Backup current archives
docker compose exec db pg_dump -U prosody prosody > muc_archive_backup.sql

# Test configuration after upgrade
docker compose exec xmpp-prosody prosodyctl check config

# Verify archive accessibility
docker compose exec xmpp-prosody prosodyctl mod_mam info
```

### Migrating from Legacy Systems

If migrating from older archive systems:

1. Export existing archives
2. Convert to Prosody format if needed
3. Import using appropriate tools
4. Verify data integrity
5. Update client configurations

## Performance Tuning

### Database Optimization

For high-volume MUC servers:

```sql
-- Add indexes for better query performance
CREATE INDEX CONCURRENTLY idx_prosodyarchive_muc_when 
ON prosodyarchive (store, "when") 
WHERE store LIKE '%muc%';

CREATE INDEX CONCURRENTLY idx_prosodyarchive_muc_with 
ON prosodyarchive (store, "with") 
WHERE store LIKE '%muc%';
```

### Memory Usage

```bash
# Monitor memory usage
docker compose exec xmpp-prosody prosodyctl about | grep memory

# Tune garbage collection if needed
# Add to prosody.cfg.lua:
# gc = { speed = 200, threshold = 120 }
```

## Related Documentation

- [Message Archiving Guide](message-archiving.md) - Personal MAM configuration
- [Monitoring Guide](monitoring.md) - Server monitoring and metrics
- [Security Guide](../admin/security.md) - Security best practices
- [XEP-0313: Message Archive Management](https://xmpp.org/extensions/xep-0313.html)
- [XEP-0045: Multi-User Chat](https://xmpp.org/extensions/xep-0045.html)
