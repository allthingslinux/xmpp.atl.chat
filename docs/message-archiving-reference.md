# 📚 Message Archive Management Reference (XEP-0313)

Complete technical reference for Message Archive Management (MAM) configuration and administration.

## Configuration Reference

### Environment Variables

**Basic MAM Configuration:**

```bash
# Message retention period (default: 1 year)
PROSODY_ARCHIVE_EXPIRES_AFTER=1y

# Archive policy - who gets messages archived
PROSODY_ARCHIVE_POLICY=roster              # roster, true, false

# Query performance limit (messages per request)
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=250

# Smart archiving - only archive for users who query
PROSODY_MAM_SMART_ENABLE=true

# Archive compression to save storage
PROSODY_ARCHIVE_COMPRESSION=true

# Cleanup frequency in seconds (default: daily)
PROSODY_ARCHIVE_CLEANUP_INTERVAL=86400
```

**Time Period Formats:**

```bash
# Time formats supported:
PROSODY_ARCHIVE_EXPIRES_AFTER=1d     # 1 day
PROSODY_ARCHIVE_EXPIRES_AFTER=1w     # 1 week
PROSODY_ARCHIVE_EXPIRES_AFTER=1m     # 1 month
PROSODY_ARCHIVE_EXPIRES_AFTER=1y     # 1 year
PROSODY_ARCHIVE_EXPIRES_AFTER=never  # Keep forever

# Seconds format:
PROSODY_ARCHIVE_EXPIRES_AFTER=2592000  # 30 days in seconds
```

**Archive Policies:**

```bash
# false - No archiving
PROSODY_ARCHIVE_POLICY=false

# roster - Only archive messages from contacts in user's roster (default)
PROSODY_ARCHIVE_POLICY=roster

# true - Archive all messages
PROSODY_ARCHIVE_POLICY=true
```

### Prosody Module Configuration

MAM is provided by `mod_mam`. Configuration is automatically generated:

```lua
-- Auto-generated in prosody.cfg.lua
modules_enabled = {
    "mam";
}

-- Archive settings
archive_expires_after = "1y"
mam_smart_enable = true
max_archive_query_results = 250

-- Storage backend
storage = {
    archive = "sql";  -- Uses PostgreSQL
}

-- Excluded namespaces (automatically configured)
mam_archive_exclude_namespaces = {
    "http://jabber.org/protocol/chatstates";  -- Typing indicators
    "urn:xmpp:jingle-message:0";             -- Call setup
}
```

## Database Schema

### Archive Storage

**PostgreSQL Schema:**

```sql
-- Message archive table
CREATE TABLE prosodyarchive (
    host TEXT NOT NULL,
    user TEXT NOT NULL,
    store TEXT NOT NULL,
    key TEXT NOT NULL,
    type TEXT,
    value TEXT,
    when_col INTEGER NOT NULL
);

-- Indexes for performance
CREATE INDEX prosodyarchive_index ON prosodyarchive (host, user, store, key);
CREATE INDEX prosodyarchive_when_index ON prosodyarchive (when_col);
CREATE INDEX prosodyarchive_store_when_index ON prosodyarchive (host, user, store, when_col);
```

**Archive Entry Structure:**

```json
{
  "stanza": "<message>...</message>",
  "timestamp": 1640995200,
  "jid_from": "user1@domain.com",
  "jid_to": "user2@domain.com",
  "message_id": "abc123",
  "body": "Hello world"
}
```

## XEP-0313 Protocol

### Service Discovery

**Discover MAM Support:**

```xml
<iq type='get' to='domain.com'>
  <query xmlns='http://jabber.org/protocol/disco#info'/>
</iq>
```

**Response:**

```xml
<iq type='result'>
  <query xmlns='http://jabber.org/protocol/disco#info'>
    <feature var='urn:xmpp:mam:2'/>
    <feature var='urn:xmpp:mam:1'/>
  </query>
</iq>
```

### Query Archive

**Basic Query:**

```xml
<iq type='set' id='query1'>
  <query xmlns='urn:xmpp:mam:2' queryid='q1'/>
</iq>
```

**Query with Filters:**

```xml
<iq type='set' id='query2'>
  <query xmlns='urn:xmpp:mam:2' queryid='q2'>
    <x xmlns='jabber:x:data' type='submit'>
      <field var='FORM_TYPE' type='hidden'>
        <value>urn:xmpp:mam:2</value>
      </field>
      <field var='with'>
        <value>user@domain.com</value>
      </field>
      <field var='start'>
        <value>2024-01-01T00:00:00Z</value>
      </field>
      <field var='end'>
        <value>2024-01-31T23:59:59Z</value>
      </field>
    </x>
    <set xmlns='http://jabber.org/protocol/rsm'>
      <max>50</max>
    </set>
  </query>
</iq>
```

**Archive Response:**

```xml
<message to='user@domain.com'>
  <result xmlns='urn:xmpp:mam:2' queryid='q2' id='msg123'>
    <forwarded xmlns='urn:xmpp:forward:0'>
      <delay xmlns='urn:xmpp:delay' stamp='2024-01-15T10:30:00Z'/>
      <message type='chat' from='friend@domain.com' to='user@domain.com'>
        <body>Hello!</body>
      </message>
    </forwarded>
  </result>
</message>
```

## Administration Commands

### Using prosody-manager

```bash
# Check MAM statistics
./prosody-manager prosodyctl mod_mam info

# View user archive size
./prosody-manager prosodyctl mod_mam user_stats user@domain.com

# Force archive cleanup
./prosody-manager prosodyctl mod_mam cleanup

# Export user archive
./prosody-manager prosodyctl mod_mam export user@domain.com

# Archive maintenance
./prosody-manager prosodyctl mod_mam optimize
```

### Direct Prosody Commands

```bash
# Inside prosody container
prosodyctl mod_mam info
prosodyctl mod_mam user_stats user@domain.com
prosodyctl mod_mam cleanup
```

### Database Maintenance

```bash
# Check archive table size
./prosody-manager deploy logs postgres | grep -i archive

# Manual cleanup of old messages
docker-compose exec postgres psql -U prosody -d prosody -c "
DELETE FROM prosodyarchive 
WHERE when_col < EXTRACT(EPOCH FROM NOW() - INTERVAL '1 year');
"

# Vacuum database after cleanup
docker-compose exec postgres psql -U prosody -d prosody -c "VACUUM ANALYZE prosodyarchive;"
```

## Performance Optimization

### Query Performance

**Indexing Strategy:**

```sql
-- Essential indexes (automatically created)
CREATE INDEX prosodyarchive_user_store ON prosodyarchive (host, user, store);
CREATE INDEX prosodyarchive_when ON prosodyarchive (when_col);

-- Additional indexes for large deployments
CREATE INDEX prosodyarchive_jid_when ON prosodyarchive (host, user, store, key, when_col);
CREATE INDEX prosodyarchive_type_when ON prosodyarchive (host, user, store, type, when_col);
```

**Query Limits:**

```bash
# Conservative (many small queries)
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=50

# Balanced (default)
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=250

# Aggressive (fewer large queries)
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=500
```

### Storage Optimization

**Compression:**

```bash
# Enable compression (recommended)
PROSODY_ARCHIVE_COMPRESSION=true

# Compression saves ~30-50% storage for text messages
# Slight CPU overhead during archive/retrieval
```

**Retention Policies:**

```bash
# Aggressive cleanup for high-volume servers
PROSODY_ARCHIVE_EXPIRES_AFTER=90d
PROSODY_ARCHIVE_CLEANUP_INTERVAL=43200  # 12 hours

# Conservative for compliance
PROSODY_ARCHIVE_EXPIRES_AFTER=7y
PROSODY_ARCHIVE_CLEANUP_INTERVAL=604800  # Weekly
```

## Monitoring & Metrics

### Prometheus Metrics

Available at `http://domain.com:5280/metrics`:

```
# Archive storage metrics
prosody_mod_mam_archive_size_bytes
prosody_mod_mam_messages_total
prosody_mod_mam_users_total

# Query performance
prosody_mod_mam_queries_total
prosody_mod_mam_query_duration_seconds

# Cleanup operations
prosody_mod_mam_cleanup_runs_total
prosody_mod_mam_cleanup_messages_deleted_total
```

### Log Monitoring

```bash
# Monitor MAM activity
docker-compose logs prosody | grep -i "mam\|archive"

# Watch for performance issues
docker-compose logs prosody | grep -i "slow.*query\|timeout"

# Monitor cleanup operations
docker-compose logs prosody | grep -i "cleanup\|expire"
```

### Storage Monitoring

```bash
# Check database size
docker-compose exec postgres psql -U prosody -d prosody -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE tablename = 'prosodyarchive';
"

# Check archive statistics
docker-compose exec postgres psql -U prosody -d prosody -c "
SELECT 
    host,
    COUNT(*) as message_count,
    MIN(when_col) as oldest_message,
    MAX(when_col) as newest_message
FROM prosodyarchive 
WHERE store = 'archive2' 
GROUP BY host;
"
```

## Security & Privacy

### Data Protection

**Encryption:**

- Messages encrypted in transit (TLS)
- Database encryption at rest (PostgreSQL)
- No client-side encryption of archived messages

**Access Control:**

```bash
# User can only access their own archive
# No cross-user archive access
# Admin can access all archives for compliance
```

**GDPR Compliance:**

```bash
# Enable GDPR features
PROSODY_GDPR_ENABLED=true
PROSODY_DATA_EXPORT=enabled
PROSODY_DATA_DELETION=enabled

# User data export
./prosody-manager prosodyctl mod_mam export user@domain.com --format json

# User data deletion
./prosody-manager prosodyctl mod_mam delete_user_data user@domain.com
```

### Privacy Controls

**Smart Archiving:**

```bash
# Only enable archiving after user's first MAM query
PROSODY_MAM_SMART_ENABLE=true

# Benefits:
# - Reduces storage for users with legacy clients
# - Privacy-friendly (no archiving until requested)
# - Automatic activation when user uses modern client
```

**Namespace Exclusions:**

```lua
-- Automatically excluded from archiving:
mam_archive_exclude_namespaces = {
    "http://jabber.org/protocol/chatstates";  -- Typing indicators
    "urn:xmpp:jingle-message:0";             -- Call setup messages
    "urn:xmpp:receipts";                     -- Message receipts
}
```

## Troubleshooting

### Common Issues

**Messages Not Archived:**

1. **Check MAM enabled**: Verify `mod_mam` is loaded
2. **Check policy**: Ensure sender is in roster (if policy=roster)
3. **Check smart archiving**: User may need to query archive first
4. **Check storage**: Verify database connectivity

**Slow Archive Queries:**

1. **Check indexes**: Ensure database indexes exist
2. **Reduce query size**: Lower `PROSODY_ARCHIVE_MAX_QUERY_RESULTS`
3. **Database performance**: Monitor PostgreSQL performance
4. **Network latency**: Check client-server connection

**Missing History in Clients:**

1. **Client support**: Verify client supports MAM
2. **Service discovery**: Check client discovers MAM feature
3. **Query limits**: Client may need multiple queries for full history
4. **Time zones**: Check timestamp handling in client

### Debugging

**Enable Debug Logging:**

```lua
-- In prosody.cfg.lua
log = {
    debug = "/var/log/prosody/prosody.log";
}
mam_debug = true;
```

**Test MAM Manually:**

```bash
# Test service discovery
./prosody-manager prosodyctl check connectivity domain.com

# Check archive directly
docker-compose exec postgres psql -U prosody -d prosody -c "
SELECT COUNT(*) FROM prosodyarchive WHERE store = 'archive2';
"

# Test query performance
docker-compose exec postgres psql -U prosody -d prosody -c "
EXPLAIN ANALYZE SELECT * FROM prosodyarchive 
WHERE host = 'domain.com' AND user = 'testuser' 
ORDER BY when_col DESC LIMIT 50;
"
```

## Configuration Examples

### High-Performance Setup

```bash
# Optimized for large deployments
PROSODY_ARCHIVE_EXPIRES_AFTER=1y
PROSODY_ARCHIVE_POLICY=roster
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=100
PROSODY_MAM_SMART_ENABLE=true
PROSODY_ARCHIVE_COMPRESSION=true
PROSODY_ARCHIVE_CLEANUP_INTERVAL=43200  # 12 hours
```

### Compliance/Legal Hold

```bash
# Long retention for compliance
PROSODY_ARCHIVE_EXPIRES_AFTER=7y
PROSODY_ARCHIVE_POLICY=true             # Archive all messages
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=250
PROSODY_MAM_SMART_ENABLE=false          # Always archive
PROSODY_ARCHIVE_COMPRESSION=false       # Uncompressed for forensics
PROSODY_ARCHIVE_CLEANUP_INTERVAL=604800  # Weekly cleanup
```

### Privacy-Focused

```bash
# Minimal archiving for privacy
PROSODY_ARCHIVE_EXPIRES_AFTER=30d
PROSODY_ARCHIVE_POLICY=roster
PROSODY_ARCHIVE_MAX_QUERY_RESULTS=50
PROSODY_MAM_SMART_ENABLE=true
PROSODY_ARCHIVE_COMPRESSION=true
PROSODY_ARCHIVE_CLEANUP_INTERVAL=86400  # Daily cleanup
```

---

*This reference covers all aspects of MAM configuration and administration. For user-facing documentation, see the [User Guide](../guides/users/user-guide.md).*
