# 📁 Static File Serving

Your Prosody XMPP server includes support for serving static files via `mod_http_files`. This is useful for hosting web content, landing pages, or documentation alongside your XMPP server.

## 🚀 Quick Setup

### 1. Enable Static File Serving

Add to your `.env` file:

```bash
# Enable static file serving
PROSODY_HTTP_FILES_DIR=/var/www/html

# Optional: Enable directory listing (default: false)
PROSODY_HTTP_DIR_LISTING=false
```

### 2. Create Content Directory

```bash
# Create directory for static files
mkdir -p static-files

# Create a simple index page
cat > static-files/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My XMPP Server</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 40px; }
        .feature { margin: 20px 0; padding: 20px; border-left: 4px solid #007acc; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Welcome to My XMPP Server</h1>
            <p>Professional XMPP communication server</p>
        </div>
        
        <div class="feature">
            <h3>📱 Connect with XMPP Clients</h3>
            <p>Use any modern XMPP client to connect:</p>
            <ul>
                <li><strong>Android:</strong> Conversations</li>
                <li><strong>iOS:</strong> Monal</li>
                <li><strong>Desktop:</strong> Gajim, Pidgin</li>
                <li><strong>Web:</strong> Converse.js</li>
            </ul>
        </div>
        
        <div class="feature">
            <h3>🔒 Security Features</h3>
            <ul>
                <li>TLS 1.3 encryption</li>
                <li>OMEMO end-to-end encryption support</li>
                <li>Modern authentication mechanisms</li>
                <li>Anti-spam protection</li>
            </ul>
        </div>
        
        <div class="feature">
            <h3>🌐 Server Information</h3>
            <p><strong>Domain:</strong> your-domain.com</p>
            <p><strong>Ports:</strong> 5222 (STARTTLS), 5223 (Direct TLS)</p>
            <p><strong>Admin Panel:</strong> <a href="/admin">Admin Interface</a></p>
        </div>
    </div>
</body>
</html>
EOF
```

### 3. Mount in Docker Compose

Update your `docker-compose.yml` to mount the static files:

```yaml
services:
  prosody:
    # ... existing configuration ...
    environment:
      - PROSODY_HTTP_FILES_DIR=/var/www/html
    volumes:
      # ... existing volumes ...
      - ./static-files:/var/www/html:ro  # Mount static files read-only
```

### 4. Restart and Access

```bash
# Restart to apply changes
docker compose restart prosody

# Access your static files
curl https://your-domain.com:5281/files/
```

## 📁 File Structure

Your static files will be served from the configured directory:

```
static-files/
├── index.html          # Served at /files/
├── about.html          # Served at /files/about.html
├── css/
│   └── style.css       # Served at /files/css/style.css
├── js/
│   └── app.js          # Served at /files/js/app.js
└── images/
    └── logo.png        # Served at /files/images/logo.png
```

## 🔧 Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PROSODY_HTTP_FILES_DIR` | *disabled* | Directory to serve static files from |
| `PROSODY_HTTP_DIR_LISTING` | `false` | Enable directory listing for folders without index files |

### URL Paths

Static files are served at: `https://your-domain.com:5281/files/`

- **Index files:** `index.html`, `index.htm` are served for directory requests
- **MIME types:** Automatically detected from file extensions
- **Cache:** Small files (< 4KB) are cached in memory for performance

## 🌐 Use Cases

### Landing Page

Create a landing page for your XMPP server with connection instructions and client downloads.

### Documentation

Host documentation, guides, or help pages for your users.

### Web Client

Host a web-based XMPP client like Converse.js for browser access.

### API Documentation

Serve OpenAPI/Swagger documentation for any custom APIs.

## 🔒 Security Considerations

### File Permissions

Ensure files are readable by the `prosody` user:

```bash
# Set proper ownership
sudo chown -R 999:999 static-files/

# Set proper permissions
find static-files/ -type f -exec chmod 644 {} \;
find static-files/ -type d -exec chmod 755 {} \;
```

### Directory Listing

Keep `PROSODY_HTTP_DIR_LISTING=false` unless you specifically need directory browsing.

### Sensitive Files

Never place sensitive files in the static directory:

- Configuration files
- Database files
- Private keys
- User data

## 🚀 Advanced Configuration

### Custom MIME Types

For custom file types, you can mount a custom MIME types file:

```yaml
volumes:
  - ./mime.types:/etc/mime.types:ro
```

### Reverse Proxy

When using a reverse proxy, static files can be served directly by nginx/Apache for better performance:

```nginx
# nginx configuration
location /files/ {
    alias /path/to/static-files/;
    expires 1d;
    add_header Cache-Control "public, immutable";
}
```

## 🛟 Troubleshooting

### Files Not Loading

1. **Check permissions:**

   ```bash
   docker compose exec xmpp-prosody ls -la /var/www/html/
   ```

2. **Check logs:**

   ```bash
   docker compose logs prosody | grep -i "http"
   ```

3. **Verify mount:**

   ```bash
   docker compose exec xmpp-prosody cat /var/www/html/index.html
   ```

### 404 Errors

- Ensure files exist in the mounted directory
- Check that `PROSODY_HTTP_FILES_DIR` is set correctly
- Verify the container can read the files

### Performance Issues

- Enable nginx/Apache for serving static files in production
- Use a CDN for large static assets
- Optimize images and compress CSS/JS files

## 📚 Related Documentation

- **[Configuration Guide](configuration.md)** - Environment variables and settings
- **[Docker Deployment](../admin/docker-deployment.md)** - Container setup and volumes
- **[Security Guide](../admin/security.md)** - Security best practices
