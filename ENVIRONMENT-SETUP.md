# Environment Management Strategy

This document outlines the comprehensive approach to managing development, testing, and production environments for the XMPP server deployment.

## 🏗️ Environment Strategy Overview

### Environment Separation

- **Development**: Local development with relaxed security
- **Production**: Secure, optimized production deployment
- **Testing**: Automated testing with minimal resource usage

### Configuration Management

- Environment-specific `.env` files
- Docker Compose overrides for environment-specific services
- Container naming to prevent conflicts

## 📁 Environment File Structure

```
.env.development    # Local development settings
.env.production     # Production deployment settings
.env.testing       # Automated testing settings
```

### Creating Environment Files

1. **Copy the master template:**

   ```bash
   # For development
   cp .env.example .env.development

   # For production
   cp .env.example .env.production

   # For testing
   cp .env.example .env.testing
   ```

2. **Customize for each environment** (see sections below)

## 🏠 Development Environment

### Usage

```bash
cp env.testing.template .env.development
# Edit .env.development with development settings
docker compose -f docker-compose.dev.yml --env-file .env.development up -d
```

### Key Development Settings

#### Database Configuration

```bash
# Use Docker service name
PROSODY_DB_HOST=xmpp-postgres-dev
PROSODY_DB_PASSWORD=devpassword
```

#### Security (Relaxed)

```bash
PROSODY_ALLOW_REGISTRATION=true
PROSODY_C2S_REQUIRE_ENCRYPTION=false
PROSODY_LOG_LEVEL=debug
```

#### Domain & Networking

```bash
PROSODY_DOMAIN=localhost
PROSODY_HTTP_SCHEME=http
```

#### MUC Settings (Permissive)

```bash
PROSODY_RESTRICT_ROOM_CREATION=false
PROSODY_MUC_DEFAULT_PUBLIC=true
```

## 🚀 Production Environment

### Usage

```bash
cp env.testing.template .env.production
# Edit .env.production with production settings
docker compose --env-file .env.production up -d
```

### Key Production Settings

#### Database Configuration

```bash
# Use production database host
PROSODY_DB_HOST=your-production-db.com
PROSODY_DB_PASSWORD=SECURE_PRODUCTION_PASSWORD
```

#### Security (Strict)

```bash
PROSODY_ALLOW_REGISTRATION=false
PROSODY_C2S_REQUIRE_ENCRYPTION=true
PROSODY_LOG_LEVEL=info
```

#### Domain & SSL

```bash
PROSODY_DOMAIN=your-domain.com
PROSODY_HTTP_SCHEME=https
PROSODY_SSL_KEY=/etc/prosody/certs/live/your-domain.com/privkey.pem
PROSODY_SSL_CERT=/etc/prosody/certs/live/your-domain.com/fullchain.pem
```

#### MUC Settings (Controlled)

```bash
PROSODY_RESTRICT_ROOM_CREATION=true
PROSODY_MUC_DEFAULT_PUBLIC=false
```

## 🧪 Testing Environment

### Usage

```bash
cp env.testing.template .env.testing
# Edit .env.testing with test settings
docker compose -f docker-compose.test.yml --env-file .env.testing up -d
```

### Key Testing Settings

#### Database Configuration

```bash
PROSODY_DB_HOST=localhost
PROSODY_DB_NAME=prosody_test
PROSODY_DB_PASSWORD=testpassword
```

#### Performance (Optimized for Speed)

```bash
PROSODY_LOG_LEVEL=error
PROSODY_ARCHIVE_POLICY=false
```

## 🐳 Docker Concerns Addressed

### Service Naming

- **Development**: `xmpp-prosody-dev`, `xmpp-postgres-dev`
- **Production**: `xmpp-prosody`, `xmpp-postgres`
- **Prevents conflicts** when running multiple environments

### Volume Management

```yaml
# Development: Shared volumes for easy access
volumes:
  - ./app/config:/etc/prosody/config:rw
  - xmpp_prosody_data:/var/lib/prosody/data

# Production: Restricted access, persistent volumes
volumes:
  - ./app/config:/etc/prosody/config:ro
  - xmpp_prosody_data:/var/lib/prosody/data
```

### Resource Limits

```yaml
# Production: Resource constraints
deploy:
  resources:
    limits:
      memory: 512M
      cpus: '1.0'
```

## 🌐 DNS Configuration Strategy

### Development Environment

```bash
# /etc/hosts entries for development
127.0.0.1 localhost
127.0.0.1 muc.localhost
127.0.0.1 upload.localhost
127.0.0.1 proxy.localhost
```

### Production Environment

```bash
# DNS A records
your-domain.com      -> SERVER_IP
muc.your-domain.com  -> SERVER_IP
upload.your-domain.com -> SERVER_IP
proxy.your-domain.com  -> SERVER_IP
turn.your-domain.com   -> SERVER_IP
```

### SSL Certificate Strategy

#### Development

- Self-signed certificates
- Generated automatically by container
- Stored in `xmpp_certs` volume

#### Production

- Let's Encrypt certificates
- Mounted from host: `/etc/letsencrypt/live/your-domain.com/`
- Automatic renewal via certbot

## 🔧 Configuration Override Strategy

### Docker Compose Override Files

```yaml
# docker-compose.dev.yml - Development overrides
services:
  xmpp-prosody:
    image: allthingslinux/prosody:dev
    container_name: xmpp-prosody-dev
    volumes:
      - ./app/config:/etc/prosody/config:rw  # Read-write for dev

# docker-compose.yml - Production (base configuration)
services:
  xmpp-prosody:
    image: allthingslinux/prosody:latest
    container_name: xmpp-prosody
    volumes:
      - ./app/config:/etc/prosody/config:ro  # Read-only for prod
```

## 📊 Environment-Specific Features

| Feature | Development | Production | Testing |
|---------|-------------|------------|---------|
| Registration | Open | Closed | Closed |
| Encryption | Optional | Required | Required |
| Logging | Debug | Info | Error |
| Database | Docker | External | Local |
| SSL | Self-signed | Let's Encrypt | Self-signed |
| Resources | Unlimited | Limited | Minimal |
| Volumes | Read-write | Read-only | Read-write |

## 🚦 Environment Detection

The application can detect its environment:

```lua
-- In Prosody configuration files
local environment = Lua.os.getenv("PROSODY_ENV") or "development"

if environment == "production" then
    -- Production-specific settings
    c2s_require_encryption = true
    allow_registration = false
else
    -- Development/test settings
    c2s_require_encryption = false
    allow_registration = true
end
```

## 🔒 Security Considerations

### Environment Variable Security

- Never commit `.env` files to version control
- Use different secrets for each environment
- Store production secrets securely (e.g., Docker secrets, Vault)

### Network Security

- Development: Open ports locally
- Production: Firewall protection, VPN access
- Testing: Isolated networks

## 📝 Best Practices

1. **Always use environment-specific files**
2. **Never hardcode sensitive values**
3. **Test configuration changes in development first**
4. **Use the same Docker images across environments**
5. **Document environment-specific requirements**
6. **Monitor resource usage in production**
7. **Regularly update and patch containers**

## 🆘 Troubleshooting

### Common Issues

**Database Connection Failed**

- Check `PROSODY_DB_HOST` matches your environment
- Verify database is running and accessible
- Ensure database credentials are correct

**SSL Certificate Issues**

- Development: Regenerate self-signed certificates
- Production: Check Let's Encrypt renewal status
- Verify certificate paths in environment file

**Port Conflicts**

- Development: Uses standard ports (5222, 5280, etc.)
- Production: May need to change if conflicts exist
- Check `netstat -tlnp` for port usage

This strategy ensures clean separation between environments while maintaining consistency and security across deployments.
