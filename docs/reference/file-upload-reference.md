# 📤 File Upload Reference (XEP-0363)

Complete technical reference for HTTP File Upload configuration and management.

## Configuration Reference

### Environment Variables

**Basic Configuration:**

```bash
# File size limit per upload in bytes (default: 100MB)
PROSODY_UPLOAD_SIZE_LIMIT=104857600

# Daily upload quota per user in bytes (default: 1GB)
PROSODY_UPLOAD_DAILY_QUOTA=1073741824

# File expiration time in seconds (default: 30 days)
PROSODY_UPLOAD_EXPIRE_AFTER=2592000

# Global storage quota for ALL users in bytes (default: unlimited)
PROSODY_UPLOAD_GLOBAL_QUOTA=10737418240

# Custom storage path (default: /var/lib/prosody/http_file_share)
PROSODY_UPLOAD_PATH=/var/lib/prosody/uploads
```

**File Type Restrictions:**

```bash
# Allow only specific file types (MIME types)
PROSODY_UPLOAD_ALLOWED_TYPES="image/*,video/*,audio/*,application/pdf"

# Example configurations:
# Media only: "image/*,video/*,audio/*"
# Documents: "image/*,application/pdf,text/plain,application/msword"
# All types: "" (empty string, default)
```

### Prosody Module Configuration

The file upload functionality is provided by `mod_http_file_share`. Configuration is automatically generated from environment variables.

**Generated Configuration:**

```lua
-- Auto-generated in prosody.cfg.lua
Component "upload.domain.com" "http_file_share"
    http_file_share_size_limit = 104857600
    http_file_share_daily_quota = 1073741824
    http_file_share_global_quota = 10737418240
    http_file_share_expire_after = 2592000
    http_file_share_allowed_file_types = { "image/*", "video/*", "audio/*" }
```

## URL Structure

### Service Discovery

Clients discover the upload service via service discovery:

```xml
<iq type='get' to='domain.com'>
  <query xmlns='http://jabber.org/protocol/disco#info'/>
</iq>
```

Response includes:

```xml
<feature var='urn:xmpp:http:upload:0'/>
<x xmlns='jabber:x:data' type='result'>
  <field var='max-file-size'><value>104857600</value></field>
</x>
```

### Upload Process

**1. Request Upload Slot:**

```xml
<iq type='get' to='upload.domain.com'>
  <request xmlns='urn:xmpp:http:upload:0' filename='image.jpg' size='123456' content-type='image/jpeg'/>
</iq>
```

**2. Receive Upload URLs:**

```xml
<iq type='result'>
  <slot xmlns='urn:xmpp:http:upload:0'>
    <put url='https://domain.com:5281/upload/abc123/image.jpg'>
      <header name='Authorization'>Bearer token123</header>
    </put>
    <get url='https://domain.com:5281/upload/abc123/image.jpg'/>
  </slot>
</iq>
```

**3. HTTP Upload:**

```bash
curl -X PUT \
  -H "Authorization: Bearer token123" \
  -H "Content-Type: image/jpeg" \
  --data-binary @image.jpg \
  "https://domain.com:5281/upload/abc123/image.jpg"
```

## Storage Architecture

### Directory Structure

```
/var/lib/prosody/http_file_share/
├── 2024/
│   ├── 01/
│   │   ├── 15/
│   │   │   ├── abc123_image.jpg
│   │   │   └── def456_document.pdf
│   │   └── 16/
│   └── 02/
└── metadata.db
```

### Database Schema

**Upload Slots Table:**

```sql
CREATE TABLE http_file_share_slots (
    id TEXT PRIMARY KEY,
    filename TEXT NOT NULL,
    filesize INTEGER NOT NULL,
    content_type TEXT,
    uploader TEXT NOT NULL,
    upload_time INTEGER NOT NULL,
    expires INTEGER NOT NULL
);
```

**Quota Tracking:**

```sql
CREATE TABLE http_file_share_quotas (
    user TEXT PRIMARY KEY,
    daily_bytes INTEGER DEFAULT 0,
    last_reset INTEGER DEFAULT 0
);
```

## Administration Commands

### Using prosody-manager

```bash
# Check upload statistics
./prosody-manager prosodyctl mod_http_file_share info

# View user quota usage
./prosody-manager prosodyctl mod_http_file_share quota user@domain.com

# Force cleanup of expired files
./prosody-manager prosodyctl mod_http_file_share cleanup

# List recent uploads
./prosody-manager prosodyctl mod_http_file_share list --recent

# Remove specific file
./prosody-manager prosodyctl mod_http_file_share remove abc123
```

### Direct Prosody Commands

```bash
# Inside prosody container
prosodyctl mod_http_file_share info
prosodyctl mod_http_file_share quota user@domain.com
prosodyctl mod_http_file_share cleanup
```

## Monitoring & Metrics

### Prometheus Metrics

Available at `http://domain.com:5280/metrics`:

```
# Total uploads
prosody_mod_http_file_share_uploads_total

# Storage usage
prosody_mod_http_file_share_storage_bytes

# Active slots
prosody_mod_http_file_share_slots_active

# Quota violations
prosody_mod_http_file_share_quota_violations_total
```

### Log Monitoring

```bash
# Monitor upload activity
docker-compose logs prosody | grep -i "http_file_share\|upload"

# Watch for quota violations
docker-compose logs prosody | grep -i "quota.*exceeded"

# Monitor cleanup operations
docker-compose logs prosody | grep -i "cleanup\|expire"
```

## Security Considerations

### Access Control

- **Authentication required**: Only authenticated users can upload
- **Roster-based**: Optional restriction to roster contacts only
- **Rate limiting**: Configurable per-user and global limits

### File Type Security

```bash
# Secure configuration - media only
PROSODY_UPLOAD_ALLOWED_TYPES="image/jpeg,image/png,image/gif,video/mp4,audio/mpeg"

# Block dangerous types (automatic in most clients)
# - Executable files (.exe, .sh, .bat)
# - Scripts (.js, .vbs, .ps1)
# - Archives with executables
```

### URL Security

- **Cryptographically secure IDs**: Upload URLs use secure random identifiers
- **Time-limited**: URLs expire after configured retention period
- **No directory traversal**: File paths are sanitized
- **Content-Type validation**: MIME type checking

## Troubleshooting

### Common Issues

**Upload Fails:**

1. **Check quota**: `prosodyctl mod_http_file_share quota user@domain.com`
2. **Verify file size**: Must be under `PROSODY_UPLOAD_SIZE_LIMIT`
3. **Check file type**: Verify MIME type is allowed
4. **Storage space**: Ensure server has available disk space

**Downloads Fail:**

1. **File expired**: Check if file is older than retention period
2. **URL format**: Verify URL structure is correct
3. **Permissions**: Check file system permissions
4. **Network**: Test direct HTTP access to upload URL

**Performance Issues:**

1. **Storage location**: Use fast storage for upload directory
2. **Cleanup frequency**: Adjust cleanup interval for busy servers
3. **Database optimization**: Regular database maintenance
4. **Monitoring**: Track storage usage and quota violations

### Debugging

**Enable Debug Logging:**

```lua
-- In prosody.cfg.lua
log = {
    debug = "/var/log/prosody/prosody.log";
}
modules_enabled = {
    "http_file_share";
}
http_file_share_debug = true;
```

**Test Upload Manually:**

```bash
# Test service discovery
curl -X GET "https://domain.com:5281/upload/" \
  -H "Authorization: Bearer $(echo -n 'user@domain.com:password' | base64)"

# Test file upload
curl -X PUT "https://domain.com:5281/upload/test123/test.txt" \
  -H "Content-Type: text/plain" \
  --data "test content"
```

## Configuration Examples

### High-Security Environment

```bash
# Restrictive file upload for corporate use
PROSODY_UPLOAD_SIZE_LIMIT=10485760          # 10MB
PROSODY_UPLOAD_DAILY_QUOTA=104857600        # 100MB
PROSODY_UPLOAD_EXPIRE_AFTER=604800          # 7 days
PROSODY_UPLOAD_ALLOWED_TYPES="image/jpeg,image/png,application/pdf,text/plain"
PROSODY_UPLOAD_GLOBAL_QUOTA=10737418240     # 10GB total
```

### Media Server

```bash
# Optimized for media sharing
PROSODY_UPLOAD_SIZE_LIMIT=524288000         # 500MB
PROSODY_UPLOAD_DAILY_QUOTA=5368709120       # 5GB
PROSODY_UPLOAD_EXPIRE_AFTER=2592000         # 30 days
PROSODY_UPLOAD_ALLOWED_TYPES="image/*,video/*,audio/*"
PROSODY_UPLOAD_GLOBAL_QUOTA=107374182400    # 100GB total
```

### Development/Testing

```bash
# Minimal limits for testing
PROSODY_UPLOAD_SIZE_LIMIT=1048576           # 1MB
PROSODY_UPLOAD_DAILY_QUOTA=10485760         # 10MB
PROSODY_UPLOAD_EXPIRE_AFTER=86400           # 1 day
PROSODY_UPLOAD_ALLOWED_TYPES=""             # All types
PROSODY_UPLOAD_GLOBAL_QUOTA=1073741824      # 1GB total
```

---

*This reference covers all aspects of file upload configuration and management. For user-facing documentation, see the [User Guide](../guides/users/user-guide.md).*
