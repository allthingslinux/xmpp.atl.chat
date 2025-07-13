# Docker Deployment Guide

## Overview

This guide covers deploying the Professional Prosody XMPP Server using Docker and Docker Compose with all available components and features.

## Components Available

### Core Services

- **Prosody XMPP Server** - Main XMPP server with comprehensive features
- **PostgreSQL Database** - Primary data storage with optimization
- **Redis Cache** - Session and data caching for performance

### Optional Services

- **Monitoring Stack** - Prometheus, Grafana, Node Exporter
- **TURN/STUN Server** - Coturn for WebRTC support
- **Prosody Exporter** - XMPP-specific metrics for Prometheus

## Deployment Profiles

### 1. Basic Deployment (Development)

```bash
# Basic XMPP server with SQLite
docker-compose up -d
```

### 2. SQL Database Deployment

```bash
# With PostgreSQL database
docker-compose --profile sql up -d
```

### 3. Performance Deployment

```bash
# With PostgreSQL and Redis cache
docker-compose --profile sql --profile cache up -d
```

### 4. Monitoring Deployment

```bash
# With full monitoring stack
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.monitoring.yml \
  --profile sql --profile cache --profile monitoring up -d
```

### 5. Complete Deployment

```bash
# Everything including WebRTC support
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.monitoring.yml \
  -f docker-compose.turn.yml \
  --profile sql --profile cache --profile monitoring --profile turn up -d
```

### 6. Production Deployment

```bash
# Production-optimized configuration
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  -f docker-compose.monitoring.yml \
  -f docker-compose.turn.yml \
  --profile sql --profile cache --profile monitoring --profile turn up -d
```

## Environment Configuration

### Required Environment Variables

```bash
# Domain configuration (REQUIRED)
PROSODY_DOMAIN=yourdomain.com
PROSODY_ADMINS=admin@yourdomain.com

# Database configuration (for SQL profile)
PROSODY_DB_PASSWORD=secure_password_here
PROSODY_DB_NAME=prosody
PROSODY_DB_USER=prosody

# TURN server configuration (for WebRTC)
TURN_USERNAME=prosody
TURN_PASSWORD=secure_turn_password
TURN_SECRET=secure_turn_secret

# Monitoring configuration
GRAFANA_ADMIN_PASSWORD=secure_grafana_password
```

### Feature Control Environment Variables

```bash
# Module control
PROSODY_ENABLE_SECURITY=true      # Security modules
PROSODY_ENABLE_MODERN=true        # Modern XMPP features
PROSODY_ENABLE_BETA=true          # Beta/testing modules
PROSODY_ENABLE_ALPHA=false        # Experimental modules

# Service features
PROSODY_ENABLE_HTTP=true          # HTTP file upload
PROSODY_ENABLE_ADMIN=true         # Web admin interface
PROSODY_ALLOW_REGISTRATION=false  # User self-registration

# Performance tuning
PROSODY_C2S_RATE=10kb/s          # Client connection rate limit
PROSODY_S2S_RATE=30kb/s          # Server connection rate limit
```

## Port Configuration

### Core XMPP Ports

- `5222` - Client-to-Server (C2S) STARTTLS
- `5269` - Server-to-Server (S2S)
- `5280` - HTTP (BOSH, WebSocket, file upload)
- `5281` - HTTPS (secure HTTP services)

### Optional Service Ports

- `5432` - PostgreSQL database (internal)
- `6379` - Redis cache (internal)
- `3000` - Grafana dashboard
- `9090` - Prometheus metrics
- `9100` - Node Exporter metrics
- `9269` - Prosody Exporter metrics
- `3478` - TURN/STUN server
- `5349` - TURNS (secure TURN)

## SSL/TLS Certificates

### Automatic Certificate Generation

The server will automatically generate self-signed certificates for development. For production, use proper certificates:

### Let's Encrypt Integration

```bash
# Place Let's Encrypt certificates in:
./certs/${PROSODY_DOMAIN}/fullchain.pem
./certs/${PROSODY_DOMAIN}/privkey.pem

# Or use traditional format:
./certs/${PROSODY_DOMAIN}.crt
./certs/${PROSODY_DOMAIN}.key
```

### Certificate Installation Script

```bash
# Use the included certificate installation script
./scripts/install-certificates.sh yourdomain.com --letsencrypt /etc/letsencrypt/live/yourdomain.com/
```

## Storage Configuration

### SQLite (Default)

- File-based storage in Docker volume
- Suitable for development and small deployments
- No additional setup required

### PostgreSQL (Recommended)

- Full SQL database with indexing and optimization
- Automatic schema creation and optimization
- Performance monitoring included
- Backup and maintenance scripts provided

### Data Volumes

- `prosody_data` - User data and message archives
- `prosody_uploads` - HTTP file uploads
- `prosody_certs` - SSL certificates
- `prosody_logs` - Server logs
- `postgres_data` - Database files (if using PostgreSQL)
- `redis_data` - Cache data (if using Redis)

## Security Features

### Network Security

- Isolated Docker networks for service separation
- No-new-privileges security option
- AppArmor and seccomp profiles
- Rate limiting and connection management

### XMPP Security

- Mandatory TLS encryption
- SASL authentication with SCRAM-SHA-256
- Anti-spam and firewall modules
- Security policy enforcement

### Monitoring and Auditing

- Security event logging
- Authentication monitoring
- Connection tracking
- Performance metrics

## Monitoring and Observability

### Grafana Dashboards

- XMPP server metrics and health
- Database performance monitoring
- System resource utilization
- User activity and connection statistics

### Prometheus Metrics

- Custom XMPP metrics via prosody-exporter
- Standard system metrics via node-exporter
- Database metrics and query performance
- Alert rules for critical events

### Log Management

- Structured JSON logging available
- Log rotation and compression
- Security event logging
- Performance monitoring logs

## Backup and Maintenance

### Automated Backup

```bash
# Run the backup script
./scripts/backup.sh

# Backup with custom retention
./scripts/backup.sh --retention 14
```

### Database Maintenance

```bash
# Optimize PostgreSQL tables (run after initial setup)
docker-compose exec db psql -U prosody -d prosody -c "SELECT optimize_prosody_tables();"

# Run general maintenance
docker-compose exec db psql -U prosody -d prosody -c "SELECT prosody_maintenance();"
```

### Health Checks

```bash
# Manual health check
docker-compose exec prosody /opt/prosody/scripts/health-check.sh

# Continuous monitoring via Docker health checks (automatic)
docker-compose ps  # Shows health status
```

## Deployment Automation

### Using the Deploy Script

```bash
# Automated deployment with validation
./scripts/deploy.sh

# Debug mode
./scripts/deploy.sh --debug
```

### CI/CD Integration

The deployment is designed for easy CI/CD integration:

- Environment-based configuration
- Health checks for deployment validation
- Backup scripts for data protection
- Monitoring for operational visibility

## Troubleshooting

### Common Issues

#### Container Won't Start

```bash
# Check logs
docker-compose logs prosody

# Validate configuration
docker-compose exec prosody prosodyctl check config
```

#### Database Connection Issues

```bash
# Check database connectivity
docker-compose exec prosody nc -z db 5432

# Check database logs
docker-compose logs db
```

#### Certificate Issues

```bash
# Check certificate status
docker-compose exec prosody prosodyctl check certs

# Regenerate certificates
docker-compose exec prosody prosodyctl cert generate ${PROSODY_DOMAIN}
```

### Health Check Endpoints

- Prosody health: `curl -f http://localhost:5280/health` (if HTTP enabled)
- Database health: Docker health check built-in
- Monitoring health: `curl -f http://localhost:9090/-/healthy`

## Performance Tuning

### Resource Limits

Adjust resource limits in docker-compose files based on your needs:

- Development: 128MB RAM, 1 CPU
- Production: 2GB RAM, 4 CPU (see production.yml)

### Database Optimization

The production configuration includes optimized PostgreSQL settings for XMPP workloads.

### Network Performance

Production configuration includes network optimizations via sysctls.

## Security Hardening

### Production Security

- Use strong passwords for all services
- Enable security modules and policies
- Configure firewall rules at the host level
- Use proper SSL certificates
- Enable audit logging
- Monitor security events

### Network Security

- Use Docker networks for service isolation
- Configure firewall rules for XMPP ports
- Enable fail2ban for brute force protection
- Use VPN for administrative access

## Next Steps

1. **Initial Setup**: Configure environment variables and deploy basic stack
2. **Certificate Installation**: Install proper SSL certificates
3. **User Management**: Create admin users and configure policies
4. **Monitoring Setup**: Deploy monitoring stack and configure alerts
5. **Backup Configuration**: Set up automated backups
6. **Performance Monitoring**: Monitor and tune performance
7. **Security Hardening**: Implement security policies and monitoring

For additional help, see the other documentation files in the `docs/` directory.
