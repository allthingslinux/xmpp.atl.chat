# Docker Deployment Guide

Complete guide for deploying the Professional Prosody XMPP Server using Docker.

## Quick Start

### 1. Prerequisites

- Docker and Docker Compose installed
- Domain name configured (e.g., `atl.chat`)
- DNS records set up (see [DNS Setup Guide](dns-setup.md))
- SSL certificate (wildcard recommended)

### 2. Basic Deployment

```bash
# Clone the repository
git clone <repository-url>
cd xmpp.atl.chat

# Copy and configure environment
cp examples/env.example .env
# Edit .env with your domain and credentials

# Start the basic services
docker compose up -d prosody db
```

## Complete Deployment Process

### Step 1: Environment Configuration

1. **Copy the environment template**:

   ```bash
   cp examples/env.example .env
   ```

2. **Configure your domain**:

   ```bash
   # Edit .env file
   PROSODY_DOMAIN=atl.chat
   PROSODY_ADMINS=admin@atl.chat
   LETSENCRYPT_EMAIL=admin@allthingslinux.org
   ```

3. **Set database credentials**:

   ```bash
   PROSODY_DB_PASSWORD=YourSecurePassword123!
   ```

### Step 2: SSL Certificate Setup

Choose one of the following methods:

#### Option A: Wildcard Certificate with Cloudflare DNS-01 (Recommended)

1. **Configure Cloudflare API**:

   ```bash
   # Copy the credentials template
   cp examples/cloudflare-credentials.ini.example cloudflare-credentials.ini
   
   # Edit with your Cloudflare API token
   # Get token from: https://dash.cloudflare.com/profile/api-tokens
   # Permissions needed: Zone:Zone:Read, Zone:DNS:Edit
   ```

2. **Generate wildcard certificate**:

   ```bash
   # Generate wildcard certificate for all subdomains
   docker compose --profile letsencrypt run --rm certbot
   ```

#### Option B: Manual Certificate

1. **Copy existing certificates**:

   ```bash
   # Copy certificates to the certs directory
   cp your-wildcard.crt ./certs/atl.chat.crt
   cp your-wildcard.key ./certs/atl.chat.key
   
   # Set proper permissions
   chmod 644 ./certs/atl.chat.crt
   chmod 600 ./certs/atl.chat.key
   ```

### Step 3: Deploy Services

#### Minimal Deployment (XMPP + Database)

```bash
docker compose up -d prosody db
```

#### Full Deployment (All Services)

```bash
docker compose up -d
```

#### Custom Service Selection

```bash
# XMPP with voice/video support
docker compose up -d prosody db coturn

# Add TURN/STUN server for voice/video calls
docker compose up -d prosody db coturn
```

### Step 4: Verify Deployment

1. **Check service status**:

   ```bash
   docker compose ps
   ```

2. **Check logs**:

   ```bash
   docker logs prosody
   docker logs prosody-db
   ```

3. **Test connectivity**:

   ```bash
   # Test XMPP ports
   telnet xmpp.atl.chat 5222
   telnet xmpp.atl.chat 5269
   
   # Test HTTP services
   curl https://xmpp.atl.chat:5281/admin
   ```

4. **Health check**:

   ```bash
   docker exec prosody /opt/prosody/scripts/health-check.sh
   ```

## Service Architecture

### Core Services

| Service | Purpose | Port | Health Check |
|---------|---------|------|--------------|
| `prosody` | XMPP Server | 5222, 5269, 5280, 5281 | ✅ Built-in |
| `db` | PostgreSQL Database | 5432 | ✅ Built-in |

### Optional Services

| Service | Purpose | Port | Profile |
|---------|---------|------|---------|
| `coturn` | TURN/STUN for voice/video | 3478, 5349 | Default |
| ~~`prometheus`~~ | ~~Metrics collection~~ | ~~9090~~ | ~~External monitoring~~ |
| ~~`node-exporter`~~ | ~~System metrics~~ | ~~9100~~ | ~~External monitoring~~ |

### Certificate Services

| Service | Purpose | Profile | Usage |
|---------|---------|---------|-------|
| `certbot` | Let's Encrypt certificate | `letsencrypt` | One-time |
| `certbot-renew` | Certificate renewal | `renewal` | Scheduled |

## Production Configuration

### Resource Limits

The Docker Compose includes production-ready resource limits:

```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '2.0'
    reservations:
      memory: 256M
      cpus: '0.5'
```

### Security Settings

- **Non-privileged containers**: `no-new-privileges:true`
- **AppArmor profiles**: `apparmor:docker-default`
- **User isolation**: Runs as `prosody` user (UID 999)
- **Read-only mounts**: Configuration mounted read-only

### Performance Optimization

- **Sysctls**: Optimized for high concurrency
- **Ulimits**: Increased file descriptor limits
- **PostgreSQL**: Production-tuned parameters
- **Logging**: Compressed log rotation

## Monitoring and Maintenance

### Service Monitoring

1. **Use external monitoring**: This deployment is designed for centralized monitoring

2. **Prosody metrics available at**:
   - Metrics endpoint: `http://your-domain:5280/metrics`
   - Add to your external Prometheus configuration (see `examples/prometheus-scrape-config.yml`)

### Log Management

1. **View logs**:

   ```bash
   # All services
   docker compose logs -f
   
   # Specific service
   docker logs -f prosody
   ```

2. **Log rotation**: Configured automatically with compression

### Certificate Renewal

#### Automated Renewal (Recommended)

**Option 1: Using the renewal script** (simplest):

```bash
# Set up automated renewal (run once)
(crontab -l 2>/dev/null; echo "0 3 * * * /path/to/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -

# Test the renewal script
./scripts/renew-certificates.sh --help
./scripts/renew-certificates.sh  # Run manually to test
```

**Option 2: Direct Docker commands**:

```bash
# Add to crontab
0 3 * * * cd /path/to/xmpp.atl.chat && docker compose --profile renewal run --rm certbot-renew && docker compose restart prosody
```

#### Manual Renewal

```bash
# Renew certificates manually
docker compose --profile letsencrypt run --rm certbot
docker compose restart prosody

# Check certificate expiration
docker compose exec prosody openssl x509 -in /etc/prosody/certs/live/atl.chat/fullchain.pem -noout -dates
```

### Backup Strategy

1. **Database backup**:

   ```bash
   docker exec prosody-db pg_dump -U prosody prosody > backup.sql
   ```

2. **Volume backup**:

   ```bash
   docker run --rm -v prosody_data:/data -v $(pwd):/backup debian:bookworm-slim \
     tar czf /backup/prosody-data.tar.gz /data
   ```

3. **Certificate backup**:

   ```bash
   docker run --rm -v prosody_certs:/certs -v $(pwd):/backup debian:bookworm-slim \
     tar czf /backup/prosody-certs.tar.gz /certs
   ```

## Troubleshooting

### Common Issues

1. **Certificate errors**:

   ```bash
   # Check certificate status
   docker run --rm -v prosody_certs:/certs debian:bookworm-slim \
     openssl x509 -in /certs/atl.chat.crt -text -noout
   ```

2. **Database connection issues**:

   ```bash
   # Test database connection
   docker exec prosody-db psql -U prosody -d prosody -c "SELECT version();"
   ```

3. **Port conflicts**:

   ```bash
   # Check port usage
   netstat -tulpn | grep -E ":(5222|5269|5280|5281)"
   ```

4. **Permission issues**:

   ```bash
   # Fix volume permissions
   docker run --rm -v prosody_data:/data debian:bookworm-slim \
     chown -R 999:999 /data
   ```

### Health Checks

All services include health checks:

```bash
# Check all service health
docker compose ps

# Manual health check
docker exec prosody /opt/prosody/scripts/health-check.sh
```

### Performance Tuning

1. **Increase file limits** (if needed):

   ```bash
   # Add to docker-compose.yml
   ulimits:
     nofile:
       soft: 65536
       hard: 65536
   ```

2. **Database optimization**:

   ```bash
   # Increase shared_buffers for more memory
   command: postgres -c shared_buffers=512MB
   ```

## Scaling and High Availability

### Horizontal Scaling

1. **Multiple Prosody instances**:

   ```bash
   docker compose up -d --scale prosody=3
   ```

2. **Load balancer configuration** (Nginx):

   ```nginx
   upstream prosody_backend {
       server prosody_1:5280;
       server prosody_2:5280;
       server prosody_3:5280;
   }
   ```

### Database High Availability

1. **PostgreSQL clustering**: Use external PostgreSQL cluster
2. **Backup database**: Configure automated backups
3. **Read replicas**: For improved performance

### Certificate Management at Scale

1. **Centralized certificate storage**: Use external volume or NFS
2. **Automated renewal**: Set up proper renewal workflows
3. **Certificate monitoring**: Monitor expiration dates

## Integration Examples

### Reverse Proxy (Nginx)

```nginx
server {
    listen 443 ssl http2;
    server_name xmpp.atl.chat;
    
    ssl_certificate /etc/nginx/certs/atl.chat.crt;
    ssl_certificate_key /etc/nginx/certs/atl.chat.key;
    
    location / {
        proxy_pass http://prosody:5280;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /xmpp-websocket {
        proxy_pass http://prosody:5280;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### CI/CD Integration

```yaml
# .github/workflows/deploy.yml
name: Deploy XMPP Server
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to production
        run: |
          docker compose pull
          docker compose up -d --remove-orphans
          docker system prune -f
```

This guide provides a complete foundation for deploying and managing your Prosody XMPP server with Docker, including proper certificate management, monitoring, and production best practices.
