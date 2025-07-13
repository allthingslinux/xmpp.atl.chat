# ⚙️ Configuration Guide

This guide covers all configuration options for your Prosody XMPP server using the `.env` file approach. All settings are controlled through environment variables for maximum simplicity.

## 📋 Configuration File

All configuration is done through the `.env` file in your project root. Copy from the example:

```bash
cp examples/env.example .env
nano .env  # Edit with your preferred editor
```

## 🔧 Essential Settings

### Domain Configuration (Required)

```bash
# Your XMPP domain (REQUIRED - change this!)
PROSODY_DOMAIN=chat.example.com

# Administrator JIDs (comma-separated)
PROSODY_ADMINS=admin@chat.example.com
```

### Database Configuration (Required)

```bash
# Database credentials (REQUIRED for production)
PROSODY_DB_NAME=prosody
PROSODY_DB_USER=prosody
PROSODY_DB_PASSWORD=ChangeMe123!
```

## 🌐 Network Settings

### Port Configuration

```bash
# XMPP ports (defaults shown)
PROSODY_C2S_PORT=5222              # Client connections (STARTTLS)
PROSODY_S2S_PORT=5269              # Server-to-server
PROSODY_C2S_DIRECT_TLS_PORT=5223   # Client connections (Direct TLS)
PROSODY_S2S_DIRECT_TLS_PORT=5270   # Server-to-server (Direct TLS)

# Web services ports
PROSODY_HTTP_PORT=5280             # HTTP (BOSH/WebSocket/Admin)
PROSODY_HTTPS_PORT=5281            # HTTPS (BOSH/WebSocket/Admin)
```

### Standard Ports (80/443)

To run on standard web ports:

```bash
# Set to standard ports
PROSODY_HTTP_PORT=80
PROSODY_HTTPS_PORT=443

# Note: Requires running as root or using authbind/capabilities
```

## 🔒 Security Settings

### User Registration

```bash
# Registration control (default: false for security)
PROSODY_ALLOW_REGISTRATION=false
```

### Authentication Backends

```bash
# LDAP integration (optional)
PROSODY_LDAP_PASSWORD=your_ldap_password

# OAuth integration (optional)
PROSODY_OAUTH_CLIENT_SECRET=your_oauth_secret
```

### File Upload Limits

```bash
# File upload size limit in bytes (default: ~50MB)
PROSODY_UPLOAD_SIZE_LIMIT=50485760
```

## 🎥 Voice/Video Support

### TURN/STUN Server

```bash
# TURN server ports
TURN_PORT=3478                     # STUN/TURN port
TURNS_PORT=5349                    # TURN over TLS port
TURN_MIN_PORT=49152                # RTP relay port range start
TURN_MAX_PORT=65535                # RTP relay port range end

# TURN server authentication
TURN_USERNAME=prosody
TURN_PASSWORD=ChangeMe123!
TURN_SECRET=ChangeMe123!
```

## 📊 Monitoring & Logging

### Log Level

```bash
# Logging level (debug, info, warn, error)
PROSODY_LOG_LEVEL=info
```

### Monitoring Ports

```bash
# Monitoring service ports
PROMETHEUS_PORT=9090               # Prometheus metrics
GRAFANA_PORT=3000                  # Grafana dashboards
NODE_EXPORTER_PORT=9100            # System metrics

# Grafana admin password
GRAFANA_ADMIN_PASSWORD=ChangeMe123!
```

## 🚀 Deployment Modes

### Minimal Deployment (Recommended for Start)

```bash
# Deploy only XMPP server and database
docker-compose up -d prosody db
```

### Full Deployment

```bash
# Deploy all services (XMPP, Database, Monitoring, TURN)
docker-compose up -d
```

### Custom Service Selection

```bash
# XMPP + Database + Monitoring
docker-compose up -d prosody db prometheus grafana

# XMPP + Database + TURN server
docker-compose up -d prosody db coturn
```

## 🌐 Service URLs

After deployment, access your services at:

### XMPP Services

```bash
# Admin Panel
https://${PROSODY_DOMAIN}:${PROSODY_HTTPS_PORT}/admin

# File Upload
https://${PROSODY_DOMAIN}:${PROSODY_HTTPS_PORT}/upload

# WebSocket (for web clients)
wss://${PROSODY_DOMAIN}:${PROSODY_HTTPS_PORT}/xmpp-websocket

# BOSH (legacy web clients)
https://${PROSODY_DOMAIN}:${PROSODY_HTTPS_PORT}/http-bind
```

### Monitoring Services

```bash
# Prometheus metrics
http://localhost:${PROMETHEUS_PORT}

# Grafana dashboards
http://localhost:${GRAFANA_PORT}

# Node Exporter metrics
http://localhost:${NODE_EXPORTER_PORT}
```

### TURN/STUN Services

```bash
# STUN server
${PROSODY_DOMAIN}:${TURN_PORT}

# TURN server
${PROSODY_DOMAIN}:${TURN_PORT}

# TURNS (TLS)
${PROSODY_DOMAIN}:${TURNS_PORT}
```

## 📝 Complete Example Configuration

Here's a complete `.env` file example for a production deployment:

```bash
# ============================================================================
# DOMAIN CONFIGURATION (REQUIRED)
# ============================================================================
PROSODY_DOMAIN=chat.example.com
PROSODY_ADMINS=admin@chat.example.com

# ============================================================================
# DATABASE CONFIGURATION (REQUIRED)
# ============================================================================
PROSODY_DB_NAME=prosody
PROSODY_DB_USER=prosody
PROSODY_DB_PASSWORD=SuperSecurePassword123!

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================
# Standard XMPP ports (usually no need to change)
PROSODY_C2S_PORT=5222
PROSODY_S2S_PORT=5269
PROSODY_C2S_DIRECT_TLS_PORT=5223
PROSODY_S2S_DIRECT_TLS_PORT=5270

# Web services (change if using reverse proxy)
PROSODY_HTTP_PORT=5280
PROSODY_HTTPS_PORT=5281

# ============================================================================
# SECURITY SETTINGS
# ============================================================================
PROSODY_ALLOW_REGISTRATION=false
PROSODY_LOG_LEVEL=info
PROSODY_UPLOAD_SIZE_LIMIT=50485760

# ============================================================================
# TURN/STUN FOR VOICE/VIDEO
# ============================================================================
TURN_PORT=3478
TURNS_PORT=5349
TURN_MIN_PORT=49152
TURN_MAX_PORT=65535
TURN_USERNAME=prosody
TURN_PASSWORD=TurnPassword123!
TURN_SECRET=TurnSecret123!

# ============================================================================
# MONITORING
# ============================================================================
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000
NODE_EXPORTER_PORT=9100
GRAFANA_ADMIN_PASSWORD=GrafanaAdmin123!
```

## 🔄 Apply Configuration Changes

After editing your `.env` file:

```bash
# Restart services to apply changes
docker-compose down
docker-compose up -d

# Or restart specific service
docker-compose restart prosody
```

## ✅ Validate Configuration

### Check Configuration

```bash
# Test prosody configuration
docker-compose exec prosody prosodyctl check config

# Test connectivity
docker-compose exec prosody prosodyctl check connectivity chat.example.com
```

### Verify Service Access

```bash
# Check if admin panel is accessible
curl -k https://chat.example.com:5281/admin

# Check if file upload is working
curl -k https://chat.example.com:5281/upload

# Check metrics endpoint
curl http://localhost:9090/metrics
```

## 🛠️ Advanced Configuration

### Custom Prosody Configuration

While the default configuration covers most use cases, you can customize Prosody settings by:

1. **Environment variables** (recommended) - Add to `.env` file
2. **Configuration overrides** - Mount custom config files (advanced)

### Reverse Proxy Configuration

For production deployments behind a reverse proxy:

```bash
# Use standard ports internally
PROSODY_HTTP_PORT=5280
PROSODY_HTTPS_PORT=5281

# Configure your reverse proxy to forward to these ports
# See admin/websocket-configuration.md for details
```

### Resource Limits

Docker Compose automatically sets production resource limits:

- **Memory**: 1GB limit, 256MB reservation
- **CPU**: 2.0 cores limit, 0.5 cores reservation
- **File descriptors**: 65536 limit

## 🛟 Troubleshooting

### Common Configuration Issues

**Service won't start:**

```bash
# Check logs for configuration errors
docker-compose logs prosody
```

**Can't access web services:**

```bash
# Check port bindings
docker-compose ps
# Verify firewall allows the ports
```

**Database connection errors:**

```bash
# Check database is running
docker-compose exec db psql -U prosody -d prosody -c "SELECT 1;"
```

### Configuration Validation

```bash
# Check all environment variables are loaded
docker-compose exec prosody env | grep PROSODY

# Test configuration syntax
docker-compose exec prosody prosodyctl check config

# Test all connectivity
docker-compose exec prosody prosodyctl check connectivity
```

## 🎯 Next Steps

- **[Getting Started](getting-started.md)** - Basic deployment guide
- **[Security Guide](../admin/security.md)** - Security hardening
- **[Certificate Management](../admin/certificate-management.md)** - SSL/TLS setup
- **[WebSocket Configuration](../admin/websocket-configuration.md)** - Reverse proxy setup

---

**💡 Pro Tip:** Start with minimal configuration and add services as needed. The default settings are production-ready and secure!
