# 📤 File Upload (XEP-0363: HTTP File Upload)

Your Prosody XMPP server includes full support for file sharing via XEP-0363: HTTP File Upload. This allows users to share images, videos, documents, and other files in both private chats and group conversations.

## 🚀 Quick Overview

File upload is **already enabled** and working out of the box with these defaults:

- **Upload URL:** `https://upload.your-domain.com`
- **Size limit:** 100MB per file
- **Daily quota:** 1GB per user per day
- **Retention:** 30 days
- **Storage:** SQL database + file system

## 🔧 Configuration Options

All file upload settings can be configured via environment variables in your `.env` file:

### Basic Settings

```bash
# File size limit per upload (default: 100MB)
PROSODY_UPLOAD_SIZE_LIMIT=104857600

# Daily upload quota per user (default: 1GB)
PROSODY_UPLOAD_DAILY_QUOTA=1073741824

# File expiration time in seconds (default: 30 days)
PROSODY_UPLOAD_EXPIRE_AFTER=2592000
```

### Advanced Settings

```bash
# Global storage quota for ALL users (default: unlimited)
PROSODY_UPLOAD_GLOBAL_QUOTA=10737418240  # 10GB total

# Restrict allowed file types (default: all types allowed)
PROSODY_UPLOAD_ALLOWED_TYPES="image/*,video/*,audio/*"

# Custom storage path (default: /var/lib/prosody/http_file_share)
PROSODY_UPLOAD_PATH=/var/lib/prosody/uploads
```

## 📊 Configuration Examples

### Media Server (Images/Videos Only)

```bash
# Allow only media files
PROSODY_UPLOAD_ALLOWED_TYPES="image/*,video/*,audio/*"
PROSODY_UPLOAD_SIZE_LIMIT=52428800    # 50MB per file
PROSODY_UPLOAD_DAILY_QUOTA=524288000  # 500MB per day
PROSODY_UPLOAD_EXPIRE_AFTER=604800    # 7 days retention
```

### Document Sharing

```bash
# Allow documents and images
PROSODY_UPLOAD_ALLOWED_TYPES="image/*,application/pdf,text/plain,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
PROSODY_UPLOAD_SIZE_LIMIT=20971520    # 20MB per file
PROSODY_UPLOAD_DAILY_QUOTA=209715200  # 200MB per day
PROSODY_UPLOAD_EXPIRE_AFTER=2592000   # 30 days retention
```

### High-Volume Server

```bash
# Large files, high quotas, global limit
PROSODY_UPLOAD_SIZE_LIMIT=524288000      # 500MB per file
PROSODY_UPLOAD_DAILY_QUOTA=5368709120    # 5GB per user per day
PROSODY_UPLOAD_GLOBAL_QUOTA=107374182400 # 100GB total server limit
PROSODY_UPLOAD_EXPIRE_AFTER=7776000      # 90 days retention
```

### Minimal/Testing Setup

```bash
# Small limits for testing
PROSODY_UPLOAD_SIZE_LIMIT=1048576      # 1MB per file
PROSODY_UPLOAD_DAILY_QUOTA=10485760    # 10MB per day
PROSODY_UPLOAD_EXPIRE_AFTER=86400      # 1 day retention
```

## 🌐 How It Works

### Upload Process

1. **Client requests upload slot** from `upload.your-domain.com`
2. **Server provides upload URL** with authentication token
3. **Client uploads file** via HTTP PUT to the provided URL
4. **Server stores file** and returns download URL
5. **Client shares download URL** in XMPP message

### URL Structure

- **Upload component:** `upload.your-domain.com`
- **Upload endpoint:** `https://your-domain.com:5281/upload/`
- **Download URLs:** `https://your-domain.com:5281/upload/[slot]/[filename]`

### Storage

Files are stored in two places:

- **Metadata:** SQL database (upload slots, quotas, expiration)
- **File data:** File system (`/var/lib/prosody/http_file_share/`)

## 📱 Client Support

### Modern XMPP Clients

All modern XMPP clients support XEP-0363 file upload:

| Client | Platform | File Upload Support |
|--------|----------|-------------------|
| **Conversations** | Android | ✅ Full support |
| **Monal** | iOS | ✅ Full support |
| **Gajim** | Desktop | ✅ Full support |
| **Dino** | Desktop | ✅ Full support |
| **Converse.js** | Web | ✅ Full support |
| **Pidgin** | Desktop | ✅ With plugins |

### Usage Examples

**In Conversations (Android):**

1. Open chat
2. Tap attachment icon (📎)
3. Select file/photo/video
4. File uploads automatically

**In Gajim (Desktop):**

1. Open chat window
2. Drag & drop file into chat
3. Or use Ctrl+U to select file

## 🔒 Security & Privacy

### File Type Restrictions

Restrict uploads to specific MIME types for security:

```bash
# Only allow safe media files
PROSODY_UPLOAD_ALLOWED_TYPES="image/jpeg,image/png,image/gif,video/mp4,audio/mpeg"

# Block potentially dangerous files
# (executable files are blocked by most clients anyway)
```

### Access Control

File upload is available to:

- ✅ **Local users** on your XMPP server
- ✅ **Authenticated users** only
- ❌ **Anonymous users** (blocked)
- ❌ **External users** (by default)

### Privacy Considerations

- **Files are public** once uploaded (anyone with URL can download)
- **URLs are hard to guess** (cryptographically secure random IDs)
- **Files expire automatically** based on `PROSODY_UPLOAD_EXPIRE_AFTER`
- **No file scanning** is performed (upload what users provide)

## 📊 Monitoring & Management

### Storage Usage

Check current storage usage:

```bash
# Check total storage used
docker compose exec xmpp-prosody du -sh /var/lib/prosody/http_file_share/

# Check database records
docker compose exec xmpp-prosody prosodyctl mod_http_file_share info
```

### Cleanup

Manual cleanup of expired files:

```bash
# Force cleanup of expired files
docker compose exec xmpp-prosody prosodyctl mod_http_file_share cleanup
```

### Logs

Monitor file upload activity:

```bash
# View upload logs
docker compose logs prosody | grep -i "http_file_share\|upload"

# Real-time monitoring
docker compose logs -f prosody | grep -i upload
```

## 🛠️ Troubleshooting

### Upload Failures

**"Upload failed" in client:**

1. **Check quotas:**

   ```bash
   # View current quotas and usage
   docker compose exec xmpp-prosody prosodyctl mod_http_file_share quota user@domain.com
   ```

2. **Check file size:**
   - Ensure file is under `PROSODY_UPLOAD_SIZE_LIMIT`
   - Check client-side size limits

3. **Check file type:**
   - Verify file type is allowed by `PROSODY_UPLOAD_ALLOWED_TYPES`
   - Check MIME type detection

### Storage Issues

**"Quota exceeded" errors:**

```bash
# Check global quota usage
docker compose exec xmpp-prosody prosodyctl mod_http_file_share info

# Increase quotas in .env file
PROSODY_UPLOAD_DAILY_QUOTA=2147483648  # 2GB
PROSODY_UPLOAD_GLOBAL_QUOTA=21474836480  # 20GB
```

### Permission Problems

**"Cannot write to storage" errors:**

```bash
# Check storage directory permissions
docker compose exec xmpp-prosody ls -la /var/lib/prosody/

# Fix permissions if needed
docker compose exec xmpp-prosody chown -R prosody:prosody /var/lib/prosody/http_file_share/
```

## 🚀 Advanced Configuration

### External Storage

For high-volume deployments, consider external storage:

```bash
# Mount external storage
# In docker-compose.yml:
volumes:
  - /mnt/nfs/uploads:/var/lib/prosody/http_file_share
```

### Reverse Proxy Optimization

Serve files directly through nginx for better performance:

```nginx
# nginx configuration
location /upload/ {
    alias /var/lib/prosody/http_file_share/;
    expires 1d;
    add_header Cache-Control "public";
    
    # Security headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
}
```

### CDN Integration

For global deployment, integrate with CDN:

1. **Upload to local storage** (as normal)
2. **Sync to CDN** (external script)
3. **Rewrite URLs** to point to CDN

## 📚 Related Documentation

- **[Configuration Guide](configuration.md)** - Environment variables and settings
- **[Security Guide](../admin/security.md)** - Security best practices
- **[Docker Deployment](../admin/docker-deployment.md)** - Container setup and volumes
- **[XEP-0363 Specification](https://xmpp.org/extensions/xep-0363.html)** - Technical details
