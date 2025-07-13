# Quick Start Guide

## Overview

This guide will help you deploy a professional Prosody XMPP server in minutes using Docker Compose. The setup includes security-first configuration, modern XMPP features, and enterprise-grade monitoring.

## Prerequisites

### System Requirements

**Minimum (Personal Server - 1-50 users):**

- 1 CPU core
- 128MB RAM
- 1GB disk space
- Linux/macOS/Windows with Docker support

**Recommended (Community Server - 50-500 users):**

- 2 CPU cores
- 512MB RAM
- 5GB disk space
- Linux server with Docker support

**Enterprise (500+ users):**

- 4+ CPU cores
- 1GB+ RAM
- 20GB+ disk space
- Linux server with Docker support

### Software Requirements

- Docker 20.10+
- Docker Compose 2.0+
- Domain name with DNS access
- SSL certificates (Let's Encrypt recommended)

### Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose-plugin

# CentOS/RHEL
sudo yum install docker docker-compose

# macOS (using Homebrew)
brew install docker docker-compose

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker
```

## Quick Deployment

### 1. Download and Setup

```bash
# Clone or download the setup
git clone <repository-url>
cd final

# Or download and extract
wget <download-url>
tar -xzf professional-prosody.tar.gz
cd professional-prosody
```

### 2. Configure Environment

```bash
# Copy environment template
cp examples/env.example .env

# Edit configuration (minimum required)
nano .env
```

**Essential Configuration:**

```bash
# Your domain (REQUIRED)
PROSODY_DOMAIN=your-domain.com

# Admin accounts (REQUIRED)
PROSODY_ADMINS=admin@your-domain.com

# Enable features as needed
PROSODY_ENABLE_HTTP=true
PROSODY_ENABLE_ADMIN=true
```

### 3. Deploy Server

```bash
# Run automated deployment
./scripts/deploy.sh

# Or manual deployment
docker-compose up -d
```

### 4. Verify Deployment

```bash
# Check service status
docker-compose ps

# Check logs
docker-compose logs prosody

# Test connectivity
telnet your-domain.com 5222
```

## Configuration Profiles

### Personal Server (SQLite)

```bash
# .env configuration
PROSODY_DOMAIN=your-domain.com
PROSODY_ADMINS=admin@your-domain.com
PROSODY_STORAGE=sqlite
PROSODY_ENABLE_SECURITY=true
PROSODY_ENABLE_MODERN=true
PROSODY_ENABLE_HTTP=false
```

### Community Server (PostgreSQL)

```bash
# .env configuration
PROSODY_DOMAIN=your-domain.com
PROSODY_ADMINS=admin@your-domain.com
PROSODY_STORAGE=sql
PROSODY_ENABLE_SECURITY=true
PROSODY_ENABLE_MODERN=true
PROSODY_ENABLE_HTTP=true
PROSODY_ENABLE_ADMIN=true
COMPOSE_PROFILES=sql
```

### Enterprise Server (Full Features)

```bash
# .env configuration
PROSODY_DOMAIN=your-domain.com
PROSODY_ADMINS=admin@your-domain.com
PROSODY_STORAGE=sql
PROSODY_ENABLE_SECURITY=true
PROSODY_ENABLE_MODERN=true
PROSODY_ENABLE_HTTP=true
PROSODY_ENABLE_ADMIN=true
PROSODY_ENABLE_ENTERPRISE=true
PROSODY_LOG_FORMAT=json
COMPOSE_PROFILES=sql,monitoring
```

## SSL Certificates

### Option 1: Let's Encrypt (Recommended)

```bash
# Install certbot
sudo apt install certbot

# Get certificate
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ./certs/your-domain.com.crt
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ./certs/your-domain.com.key
sudo chown $USER:$USER ./certs/*
```

### Option 2: Self-Signed (Development)

```bash
# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout ./certs/your-domain.com.key -out ./certs/your-domain.com.crt -days 365 -nodes -subj "/CN=your-domain.com"
```

## DNS Configuration

### Required DNS Records

```dns
# A record for main domain
your-domain.com.     IN A     YOUR_SERVER_IP

# SRV records for XMPP services
_xmpp-client._tcp.your-domain.com.  IN SRV 5 0 5222 your-domain.com.
_xmpp-server._tcp.your-domain.com.  IN SRV 5 0 5269 your-domain.com.

# Optional: Subdomains for services
conference.your-domain.com.         IN A     YOUR_SERVER_IP
upload.your-domain.com.             IN A     YOUR_SERVER_IP
```

## Firewall Configuration

### UFW (Ubuntu)

```bash
# Allow XMPP ports
sudo ufw allow 5222/tcp  # Client connections
sudo ufw allow 5269/tcp  # Server connections
sudo ufw allow 5280/tcp  # HTTP (optional)
sudo ufw allow 5281/tcp  # HTTPS (optional)

# Enable firewall
sudo ufw enable
```

### iptables

```bash
# Allow XMPP ports
sudo iptables -A INPUT -p tcp --dport 5222 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5269 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5280 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5281 -j ACCEPT

# Save rules
sudo iptables-save > /etc/iptables/rules.v4
```

## User Management

### Create Admin User

```bash
# Create admin user
docker-compose exec prosody prosodyctl adduser admin@your-domain.com

# Set password
docker-compose exec prosody prosodyctl passwd admin@your-domain.com
```

### Create Regular Users

```bash
# Create user
docker-compose exec prosody prosodyctl adduser user@your-domain.com

# Set password
docker-compose exec prosody prosodyctl passwd user@your-domain.com
```

### Enable User Registration

```bash
# Enable in .env
PROSODY_ALLOW_REGISTRATION=true

# Restart services
docker-compose restart prosody
```

## Testing Connectivity

### Command Line Testing

```bash
# Test C2S port
telnet your-domain.com 5222

# Test S2S port
telnet your-domain.com 5269

# Test HTTP services (if enabled)
curl http://your-domain.com:5280/
```

### XMPP Client Testing

**Recommended Clients:**

- **Desktop:** Gajim, Dino, Conversations
- **Mobile:** Conversations (Android), Siskin IM (iOS)
- **Web:** Converse.js, JSXC

**Connection Settings:**

- **Server:** your-domain.com
- **Port:** 5222
- **Security:** Require encryption
- **Username:** <user@your-domain.com>
- **Password:** (as set above)

## Monitoring and Maintenance

### View Logs

```bash
# View all logs
docker-compose logs

# Follow logs
docker-compose logs -f prosody

# View specific service logs
docker-compose logs db
```

### Health Check

```bash
# Manual health check
docker-compose exec prosody /opt/prosody/scripts/health-check.sh

# Check service status
docker-compose ps
```

### Backup Data

```bash
# Create backup
./scripts/backup.sh

# List backups
ls -la backups/

# Restore backup
./scripts/restore.sh backups/prosody_backup_YYYYMMDD_HHMMSS.tar.gz
```

## Common Issues

### Services Won't Start

```bash
# Check logs
docker-compose logs prosody

# Check configuration
docker-compose exec prosody prosodyctl check config

# Restart services
docker-compose restart
```

### Connection Refused

1. Check firewall rules
2. Verify DNS records
3. Check SSL certificates
4. Verify port bindings

```bash
# Check port bindings
docker-compose ps
netstat -tlnp | grep :5222
```

### Certificate Issues

```bash
# Check certificate validity
openssl x509 -in certs/your-domain.com.crt -text -noout

# Verify certificate chain
openssl verify -CApath /etc/ssl/certs certs/your-domain.com.crt
```

## Next Steps

1. **Security Hardening:** Review [SECURITY.md](SECURITY.md)
2. **Performance Tuning:** Review [PERFORMANCE.md](PERFORMANCE.md)
3. **Monitoring Setup:** Review [MONITORING.md](MONITORING.md)
4. **Backup Strategy:** Review [BACKUP.md](BACKUP.md)
5. **Client Configuration:** Review [CLIENTS.md](CLIENTS.md)

## Support

- **Documentation:** [docs/](docs/)
- **Configuration Reference:** [CONFIGURATION.md](CONFIGURATION.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Community:** XMPP MUC rooms
- **Issues:** GitHub Issues

## Security Notice

🔒 **Important:** This setup includes security-first configuration, but additional hardening may be required for production environments. Review the security documentation before deploying to production.
