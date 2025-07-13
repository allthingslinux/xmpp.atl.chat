# ⚙️ User Configuration Guide

This guide covers the essential configuration options for end users who want to customize their Professional Prosody XMPP Server.

## 🎯 Quick Configuration

### Environment Variables

The server is configured primarily through environment variables in your `.env` file:

```bash
# Copy the example environment file
cp examples/env.example .env

# Edit with your settings
nano .env
```

### Essential Settings

```bash
# === DOMAIN CONFIGURATION ===
PROSODY_DOMAIN=your-domain.com
PROSODY_ADMINS=admin@your-domain.com,admin2@your-domain.com

# === FEATURE CONTROL ===
PROSODY_ENABLE_SECURITY=true      # Security features
PROSODY_ENABLE_BETA=true          # Beta features
PROSODY_ENABLE_ALPHA=false        # Experimental features

# === REGISTRATION ===
PROSODY_ALLOW_REGISTRATION=false  # Public registration
PROSODY_INVITE_ONLY=true          # Invite-only registration

# === STORAGE ===
PROSODY_STORAGE=sqlite            # sqlite, postgresql, mysql
PROSODY_ARCHIVE_RETENTION=1y      # Message archive retention
```

## 🔧 Common Configurations

### 1. Personal Server (Friends & Family)

```bash
# Small server for personal use
PROSODY_DOMAIN=chat.yourfamily.com
PROSODY_ADMINS=admin@chat.yourfamily.com
PROSODY_ALLOW_REGISTRATION=false
PROSODY_INVITE_ONLY=true
PROSODY_STORAGE=sqlite
PROSODY_ENABLE_BETA=false
PROSODY_MAX_CLIENTS=50
```

### 2. Community Server (Organization)

```bash
# Medium server for community/organization
PROSODY_DOMAIN=chat.yourorg.com
PROSODY_ADMINS=admin@chat.yourorg.com
PROSODY_ALLOW_REGISTRATION=true
PROSODY_INVITE_ONLY=false
PROSODY_STORAGE=postgresql
PROSODY_ENABLE_BETA=true
PROSODY_MAX_CLIENTS=500
```

### 3. Public Server (Open Community)

```bash
# Large server for public use
PROSODY_DOMAIN=chat.example.com
PROSODY_ADMINS=admin@chat.example.com
PROSODY_ALLOW_REGISTRATION=true
PROSODY_INVITE_ONLY=false
PROSODY_STORAGE=postgresql
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=false
PROSODY_MAX_CLIENTS=5000
```

## 🛡️ Security Settings

### TLS Configuration

```bash
# TLS settings
PROSODY_TLS_CERT_PATH=/etc/prosody/certs/
PROSODY_REQUIRE_ENCRYPTION=true
PROSODY_TLS_VERSION=1.3

# Certificate settings
PROSODY_AUTO_CERT=true           # Automatic certificate generation
PROSODY_CERT_EMAIL=admin@your-domain.com
```

### Access Control

```bash
# Firewall settings
PROSODY_FIREWALL_ENABLED=true
PROSODY_RATE_LIMIT_ENABLED=true
PROSODY_SPAM_PROTECTION=true

# IP restrictions
PROSODY_ALLOWED_IPS=            # Empty = all IPs allowed
PROSODY_BLOCKED_IPS=            # Comma-separated blocked IPs
```

## 💾 Storage Configuration

### SQLite (Default)

```bash
# Simple file-based storage
PROSODY_STORAGE=sqlite
PROSODY_DB_PATH=/var/lib/prosody/prosody.sqlite
```

### PostgreSQL

```bash
# PostgreSQL database
PROSODY_STORAGE=postgresql
PROSODY_DB_HOST=localhost
PROSODY_DB_PORT=5432
PROSODY_DB_NAME=prosody
PROSODY_DB_USER=prosody
PROSODY_DB_PASSWORD=your-secure-password
```

### MySQL

```bash
# MySQL database
PROSODY_STORAGE=mysql
PROSODY_DB_HOST=localhost
PROSODY_DB_PORT=3306
PROSODY_DB_NAME=prosody
PROSODY_DB_USER=prosody
PROSODY_DB_PASSWORD=your-secure-password
```

## 📊 Performance Settings

### Resource Limits

```bash
# Connection limits
PROSODY_MAX_CLIENTS=1000
PROSODY_MAX_CLIENTS_PER_IP=10

# Rate limiting
PROSODY_C2S_RATE_LIMIT=10kb/s
PROSODY_S2S_RATE_LIMIT=30kb/s

# Memory limits
PROSODY_MEMORY_LIMIT=512M
```

### Archive Settings

```bash
# Message archiving
PROSODY_ARCHIVE_ENABLED=true
PROSODY_ARCHIVE_RETENTION=1y     # 1 year retention
PROSODY_ARCHIVE_POLICY=roster    # roster, always, never

# MUC archiving
PROSODY_MUC_ARCHIVE_ENABLED=true
PROSODY_MUC_ARCHIVE_RETENTION=6m # 6 months retention
```

## 🌐 Network Configuration

### Port Settings

```bash
# Standard XMPP ports
PROSODY_C2S_PORT=5222           # Client connections
PROSODY_S2S_PORT=5269           # Server connections
PROSODY_HTTP_PORT=5280          # HTTP services
PROSODY_HTTPS_PORT=5281         # HTTPS services
```

### External Access

```bash
# External hostname
PROSODY_EXTERNAL_HOST=your-domain.com

# Proxy settings (if behind reverse proxy)
PROSODY_PROXY_ENABLED=true
PROSODY_PROXY_PROTOCOL=https
PROSODY_TRUSTED_PROXIES=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
```

## 📱 Mobile & Web Support

### Push Notifications

```bash
# Enable push notifications
PROSODY_PUSH_ENABLED=true
PROSODY_PUSH_BACKEND=fcm         # fcm, apns, webpush

# FCM settings
PROSODY_FCM_SERVER_KEY=your-fcm-server-key
PROSODY_FCM_SENDER_ID=your-sender-id
```

### Web Client Support

```bash
# Web client features
PROSODY_WEB_ENABLED=true
PROSODY_BOSH_ENABLED=true
PROSODY_WEBSOCKET_ENABLED=true

# CORS settings
PROSODY_CORS_ENABLED=true
PROSODY_CORS_ORIGINS=https://webclient.example.com
```

## 🔐 Authentication Options

### Internal Authentication (Default)

```bash
# Built-in authentication
PROSODY_AUTH_METHOD=internal_hashed
```

### LDAP Authentication

```bash
# LDAP integration
PROSODY_AUTH_METHOD=ldap
PROSODY_LDAP_SERVER=ldap.example.com
PROSODY_LDAP_PORT=389
PROSODY_LDAP_BASE_DN=ou=users,dc=example,dc=com
PROSODY_LDAP_BIND_DN=cn=prosody,ou=services,dc=example,dc=com
PROSODY_LDAP_BIND_PASSWORD=ldap-password
```

### External Authentication

```bash
# HTTP authentication
PROSODY_AUTH_METHOD=http
PROSODY_AUTH_URL=https://auth.example.com/xmpp/auth
PROSODY_AUTH_TOKEN=your-auth-token
```

## 🚀 Deployment Modes

### Docker Compose

```bash
# Deploy with Docker
docker-compose up -d

# View logs
docker-compose logs -f prosody

# Restart service
docker-compose restart prosody
```

### Kubernetes

```bash
# Deploy to Kubernetes
kubectl apply -f k8s/

# Check status
kubectl get pods -l app=prosody

# View logs
kubectl logs -f deployment/prosody
```

## 🔧 Advanced Configuration

### Custom Modules

```bash
# Enable custom modules
PROSODY_CUSTOM_MODULES=mod_example,mod_another

# Custom module path
PROSODY_CUSTOM_MODULE_PATH=/etc/prosody/custom-modules/
```

### Logging

```bash
# Log levels
PROSODY_LOG_LEVEL=info          # debug, info, warn, error

# Log format
PROSODY_LOG_FORMAT=json         # json, plain

# Log destinations
PROSODY_LOG_FILE=/var/log/prosody/prosody.log
PROSODY_LOG_SYSLOG=false
```

## 📋 Configuration Validation

### Check Configuration

```bash
# Validate configuration
docker-compose exec prosody prosodyctl check config

# Check connectivity
docker-compose exec prosody prosodyctl check connectivity example.com

# Test DNS
docker-compose exec prosody prosodyctl check dns example.com
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Port conflicts | Change port numbers in environment |
| Certificate errors | Check certificate paths and permissions |
| Database connection | Verify database settings and connectivity |
| Module loading | Check module names and availability |

## 📚 Next Steps

- **[Client Setup Guide](client-setup.md)** - Configure XMPP clients
- **[Troubleshooting Guide](troubleshooting.md)** - Fix common issues
- **[Admin Guide](../admin/deployment.md)** - Advanced deployment
- **[Security Guide](../admin/security.md)** - Security hardening

---

*Need help? Check the [troubleshooting guide](troubleshooting.md) or ask in our community discussions.*
