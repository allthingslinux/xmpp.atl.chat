# 🚀 Production Deployment Guide

Complete guide for deploying the Professional Prosody XMPP Server in production using Docker.

## 📋 Prerequisites

- **Server**: 2GB+ RAM, 20GB+ storage, Linux distribution
- **Domain**: Domain name with DNS control (e.g., `atl.chat`)
- **Docker**: Docker 20.10+ and Docker Compose 2.0+
- **Cloudflare**: Account with API access (for SSL certificates)

## ⚡ Quick Production Setup

### 1. Clone and Run Setup

```bash
# Clone to production directory
git clone https://github.com/allthingslinux/xmpp.atl.chat /opt/xmpp.atl.chat
cd /opt/xmpp.atl.chat

# Run automated setup
./prosody-manager setup
```

The setup script will guide you through:

- Environment configuration (.env file)
- Cloudflare API credentials setup
- SSL certificate generation
- Service startup
- Administrator user creation

### 2. Configure DNS Records

Add these DNS records for your domain:

```dns
# SRV records for client discovery
_xmpp-client._tcp.atl.chat.  3600  IN  SRV  5 0 5222 xmpp.atl.chat.
_xmpps-client._tcp.atl.chat. 3600  IN  SRV  5 0 5223 xmpp.atl.chat.

# SRV records for server-to-server
_xmpp-server._tcp.atl.chat.  3600  IN  SRV  5 0 5269 xmpp.atl.chat.
_xmpps-server._tcp.atl.chat. 3600  IN  SRV  5 0 5270 xmpp.atl.chat.

# A record pointing to your server
xmpp.atl.chat.  3600  IN  A  YOUR_SERVER_IP
```

### 3. Verify Deployment

```bash
# Check service status
./prosody-manager deploy status

# Run health check
./prosody-manager health

# Test connectivity
./prosody-manager health --ports
```

## 🔧 Manual Setup (Step by Step)

### Step 1: Environment Configuration

```bash
# Copy environment template
cp templates/env/env.example .env

# Edit with your settings
nano .env
```

**Required settings in .env:**

```bash
# Your XMPP domain (REQUIRED)
PROSODY_DOMAIN=atl.chat

# Administrator JIDs
PROSODY_ADMINS=admin@atl.chat

# Database credentials
PROSODY_DB_PASSWORD=YourSecurePassword123!
POSTGRES_PASSWORD=YourSecurePassword123!

# Let's Encrypt email
LETSENCRYPT_EMAIL=admin@allthingslinux.org
```

### Step 2: SSL Certificate Setup

**Configure Cloudflare API:**

```bash
# Copy credentials template
cp templates/configs/cloudflare-credentials.ini.example cloudflare-credentials.ini

# Edit with your Cloudflare API token
nano cloudflare-credentials.ini
```

Get your API token from: <https://dash.cloudflare.com/profile/api-tokens>
Required permissions: `Zone:Zone:Read, Zone:DNS:Edit`

**Generate wildcard certificate:**

```bash
# Generate certificate for *.atl.chat
docker compose --profile letsencrypt run --rm xmpp-certbot
```

### Step 3: Deploy Services

**Minimal deployment (recommended for start):**

```bash
# Start XMPP server and database only
docker compose up -d xmpp-prosody xmpp-postgres
```

**Full deployment:**

```bash
# Start all services including TURN server
docker compose up -d
```

**Verify deployment:**

```bash
# Check running services
docker compose ps

# View logs
docker compose logs xmpp-prosody

# Check service health
docker compose exec xmpp-prosody prosodyctl check config
```

### Step 4: Create Administrator

```bash
# Create admin user
docker compose exec xmpp-prosody prosodyctl adduser admin@atl.chat

# Or use prosody-manager
./prosody-manager user create admin@atl.chat --admin
```

## 🏗️ Service Architecture

### Core Services

| Service | Purpose | Ports | Required |
|---------|---------|-------|----------|
| `xmpp-prosody` | XMPP Server | 5222, 5223, 5269, 5270, 5280, 5281 | ✅ |
| `xmpp-postgres` | Database | 5432 (internal) | ✅ |

### Optional Services

| Service | Purpose | Ports | When to Use |
|---------|---------|-------|-------------|
| `xmpp-coturn` | TURN/STUN for voice/video | 3478, 5349, 49152-65535 | Voice/video calls |
| `xmpp-adminer` | Database web interface | 8080 | Database management |

### Certificate Services

| Service | Purpose | Usage |
|---------|---------|-------|
| `xmpp-certbot` | Let's Encrypt certificate generation | One-time setup |
| `xmpp-certbot-renew` | Certificate renewal | Automated via cron |

## 🛠️ Management with prosody-manager

### Daily Operations

```bash
# Check system health
./prosody-manager health

# View service status
./prosody-manager deploy status

# View logs
./prosody-manager deploy logs

# Restart services
./prosody-manager deploy restart
```

### User Management

```bash
# Create user
./prosody-manager user create username@atl.chat

# List users
./prosody-manager user list

# Delete user
./prosody-manager user delete username@atl.chat
```

### Certificate Management

```bash
# Check certificate status
./prosody-manager cert check

# Renew certificates
./prosody-manager cert renew

# View certificate info
./prosody-manager cert info
```

### Backup Operations

```bash
# Create backup
./prosody-manager backup create

# List backups
./prosody-manager backup list

# Restore backup
./prosody-manager backup restore backup-file.tar.gz
```

## 📊 Monitoring & Maintenance

### Health Monitoring

```bash
# Comprehensive health check
./prosody-manager health --all

# Check specific components
./prosody-manager health --config
./prosody-manager health --database
./prosody-manager health --certificates
./prosody-manager health --ports
```

### Log Management

```bash
# View real-time logs
./prosody-manager deploy logs --follow

# View specific service logs
./prosody-manager deploy logs xmpp-prosody

# Export logs
docker compose logs xmpp-prosody > prosody.log
```

### Performance Monitoring

**Metrics endpoint:**

- Available at: `http://your-domain:5280/metrics`
- Format: Prometheus metrics
- Use with external monitoring (Prometheus/Grafana)

### Automated Maintenance

**Certificate renewal (automatically set up by setup.sh):**

```bash
# Cron job runs daily at 3 AM
0 3 * * * cd /opt/xmpp.atl.chat && ./prosody-manager cert renew
```

**Manual renewal:**

```bash
# Run renewal script manually
./scripts/maintenance/renew-certificates.sh

# Or use prosody-manager
./prosody-manager cert renew
```

## 🔒 Security Configuration

### Firewall Setup

**Required ports:**

```bash
# XMPP ports
ufw allow 5222/tcp  # Client connections (STARTTLS)
ufw allow 5223/tcp  # Client connections (Direct TLS)
ufw allow 5269/tcp  # Server-to-server
ufw allow 5270/tcp  # Server-to-server (Direct TLS)

# Web services (optional, for admin panel)
ufw allow 5280/tcp  # HTTP
ufw allow 5281/tcp  # HTTPS

# TURN/STUN (if using voice/video)
ufw allow 3478/tcp
ufw allow 3478/udp
ufw allow 5349/tcp
ufw allow 49152:65535/udp
```

### SSL/TLS Security

The setup automatically configures:

- **TLS 1.2+ only** - No legacy protocols
- **Strong cipher suites** - ChaCha20-Poly1305, AES-GCM
- **Perfect Forward Secrecy** - ECDHE key exchange
- **Certificate validation** - Full chain verification

### Database Security

```bash
# Database runs in isolated container
# No external ports exposed
# Strong password required in .env
# Regular backups recommended
```

## 🚀 Scaling & High Availability

### Horizontal Scaling

**Load balancer setup:**

```bash
# Multiple Prosody instances
docker compose up -d --scale xmpp-prosody=3

# Configure external load balancer (nginx/haproxy)
# Point to multiple Prosody containers
```

### Database High Availability

**External PostgreSQL cluster:**

```bash
# Update .env to point to external database
PROSODY_DB_HOST=postgres-cluster.example.com
PROSODY_DB_PORT=5432
```

### Backup Strategy

```bash
# Daily automated backups
./prosody-manager backup create --daily

# Weekly full backups
./prosody-manager backup create --full --weekly

# Remote backup storage
./prosody-manager backup upload --s3 bucket-name
```

## 🔧 Troubleshooting

### Common Issues

**Services won't start:**

```bash
# Check logs
docker compose logs

# Verify configuration
./prosody-manager health --config

# Check ports
./prosody-manager health --ports
```

**Certificate issues:**

```bash
# Check certificate status
./prosody-manager cert check

# Regenerate certificate
docker compose --profile letsencrypt run --rm xmpp-certbot

# Verify Cloudflare API
./prosody-manager cert test-api
```

**Database connection issues:**

```bash
# Check database status
./prosody-manager health --database

# Restart database
docker compose restart xmpp-postgres

# Check database logs
docker compose logs xmpp-postgres
```

### Performance Issues

**High memory usage:**

```bash
# Check resource usage
./prosody-manager deploy status

# Restart services
./prosody-manager deploy restart

# Optimize database
./prosody-manager database optimize
```

**Connection problems:**

```bash
# Test external connectivity
./prosody-manager health --external

# Check firewall
ufw status

# Verify DNS records
dig SRV _xmpp-client._tcp.atl.chat
```

## 📚 Additional Resources

- **[prosody-manager Guide](../administration/prosody-manager-guide.md)** - Complete CLI tool reference
- **[Administration Guide](../administration/administration.md)** - Comprehensive administration
- **[DNS Setup](../../admin/dns-setup.md)** - DNS configuration details
- **[Certificate Management](../../admin/certificate-management.md)** - SSL/TLS details
- **[Security Guide](../../admin/security.md)** - Security hardening

## 🆘 Support

**Getting Help:**

- Check logs: `./prosody-manager deploy logs`
- Run diagnostics: `./prosody-manager health --all`
- Review documentation in `docs/` directory
- Join community: `#support@atl.chat`

---

*This guide covers production deployment using the actual project structure and tools. For development setup, see the [Quick Start Guide](../../quick-start.md).*
