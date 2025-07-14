# XMPP Server (Prosody)

Production-ready XMPP server with comprehensive features, extensive XEP compliance, and enterprise security.

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](./docker-compose.yml)
[![Security](https://img.shields.io/badge/Security-Hardened-green)](#security-features)
[![XEP Compliance](https://img.shields.io/badge/XEP-50%2B%20Supported-purple)](./docs/reference/xep-compliance.md)

## Overview

Comprehensive Prosody XMPP server setup with both production and development configurations. Built from research of real-world XMPP deployments, this setup provides enterprise-level features with modern XMPP capabilities enabled by default.

## Quick Start

### Production Setup

```bash
# Clone repository
git clone https://github.com/allthingslinux/xmpp.atl.chat /opt/xmpp.atl.chat
cd /opt/xmpp.atl.chat

# Run setup script
./scripts/setup.sh
```

The setup script will:

- Check dependencies (Docker, Docker Compose, OpenSSL)
- Configure environment variables (.env file)
- Set up Cloudflare API credentials
- Generate wildcard SSL certificates
- Set up automatic certificate renewal
- Start all services
- Create administrator user

### Development Setup

```bash
# Clone and setup development environment
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat
./scripts/setup-dev.sh
```

Development environment includes:

- Full XMPP server with all modern features
- PostgreSQL database with web admin interface
- TURN/STUN server for voice/video calls
- Development tools (log viewer, metrics, admin panel)
- Test users automatically created
- Self-signed certificates for localhost testing

### Manual Setup

```bash
# Configure environment
cp examples/env.example .env
# Edit .env with your domain and database password

# Generate SSL certificate (Cloudflare DNS-01)
cp examples/cloudflare-credentials.ini.example cloudflare-credentials.ini
# Edit with your Cloudflare API token
docker compose --profile letsencrypt run --rm xmpp-certbot

# Set up certificate renewal
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -

# Deploy server
docker compose up -d xmpp-prosody xmpp-postgres

# Check status
docker compose logs -f xmpp-prosody
```

## User Management

```bash
# Using unified CLI tool
./prosody-manager prosodyctl adduser admin@atl.chat
./prosody-manager prosodyctl adduser user@atl.chat

# Or directly with Docker
docker compose exec xmpp-prosody prosodyctl adduser admin@atl.chat
```

## Connection Information

### Production

- **Server**: `atl.chat`
- **Ports**: 5222 (STARTTLS), 5223 (Direct TLS)
- **Web Admin**: `https://xmpp.atl.chat:5281/admin`
- **WebSocket**: `wss://xmpp.atl.chat:5281/xmpp-websocket`

### Development

- **Server**: `localhost`
- **Domain**: `localhost`
- **Ports**: 5222 (STARTTLS), 5223 (Direct TLS)
- **Web Admin**: `http://localhost:5280/admin`
- **Test Users**: `admin@localhost` (admin123), `alice@localhost` (alice123), `bob@localhost` (bob123)

## Features

### Security (Default Enabled)

- TLS 1.3 with perfect forward secrecy
- SCRAM-SHA-256 authentication (XEP-0474)
- Anti-spam and abuse protection with DNS blocklists
- Certificate validation with DANE/TLSA support

### Modern XMPP Features (Default Enabled)

- Message Archive Management (MAM) - XEP-0313
- Message Carbons - XEP-0280
- Stream Management (SMACKS) - XEP-0198
- Client State Indication (CSI) - XEP-0352
- HTTP File Upload - XEP-0363
- Push Notifications - XEP-0357

### Mobile Optimizations (Default Enabled)

- Battery-saving CSI configuration
- Mobile presence deduplication
- Optimized offline message handling
- WebSocket and BOSH support

### Professional Features (Default Enabled)

- Multi-User Chat (MUC) - XEP-0045
- Publish-Subscribe (PubSub) - XEP-0060
- External Service Discovery - XEP-0215
- TURN/STUN integration for voice/video calls
- Web admin interface and monitoring

## Service Architecture

| Service | Purpose | Port(s) | Status |
|---------|---------|---------|--------|
| **Prosody** | XMPP server with PostgreSQL | 5222, 5223, 5269, 5280, 5281 | Core |
| **PostgreSQL** | Database backend | 5432 (internal) | Core |
| **Adminer** | Database management interface | 8080 | Optional |
| **Coturn** | TURN/STUN server for voice/video | 3478, 5349, 49152-65535 | Optional |

### Deployment Options

```bash
# Minimal deployment (XMPP + Database only)
docker compose up -d xmpp-prosody xmpp-postgres

# With database management
docker compose up -d xmpp-prosody xmpp-postgres xmpp-adminer

# Full deployment (all services)
docker compose up -d

# Development environment
docker compose -f docker-compose.dev.yml up -d
```

## Development Environment

### Access URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **Development Dashboard** | <http://localhost:8081> | Central hub with all links |
| **Admin Panel** | <http://localhost:5280/admin> | XMPP server management |
| **Database Admin** | <http://localhost:8080> | PostgreSQL web interface |
| **Log Viewer** | <http://localhost:8082> | Real-time log monitoring |
| **Metrics** | <http://localhost:5280/metrics> | Prometheus metrics |

### Development Tools

```bash
# Show environment status
./scripts/dev-tools.sh status

# Test all connectivity
./scripts/dev-tools.sh test

# Create more users
./scripts/dev-tools.sh adduser newuser password123

# View logs
./scripts/dev-tools.sh logs

# Show all URLs
./scripts/dev-tools.sh urls

# Complete cleanup (removes all data)
./scripts/dev-tools.sh cleanup
```

## XEP Compliance

This server supports 50+ XMPP Extension Protocols (XEPs) for maximum client compatibility:

| Category | Key XEPs | Status |
|----------|----------|---------|
| **Core Protocol** | XEP-0030 (Service Discovery), XEP-0115 (Entity Capabilities) | ✅ |
| **Modern Messaging** | XEP-0313 (MAM), XEP-0280 (Carbons), XEP-0198 (Stream Management) | ✅ |
| **File Sharing** | XEP-0363 (HTTP Upload), XEP-0447 (Stateless File Sharing) | ✅ |
| **Security** | XEP-0384 (OMEMO), XEP-0474 (SASL SCRAM Downgrade Protection) | ✅ |
| **Mobile** | XEP-0352 (CSI), XEP-0357 (Push), XEP-0198 (Stream Management) | ✅ |
| **Real-time** | XEP-0215 (External Services), XEP-0167/0176 (Jingle A/V) | ✅ |

[View complete XEP compliance list](./docs/reference/xep-compliance.md)

## Security Features

- **Transport Security**: TLS 1.3, perfect forward secrecy, modern cipher suites
- **Anti-Spam**: DNS blocklists, rate limiting, JID reputation scoring
- **Authentication**: Multi-factor auth support, SASL 2.0, SCRAM-SHA-256
- **Monitoring**: Audit logging, security alerts, compliance reports
- **Network**: IPv6 support, DNSSEC validation, SRV record discovery

[View detailed security documentation](./docs/admin/security.md)

## Management Tools

### Database Management

Adminer provides a web-based database management interface:

```bash
# Start with database management
docker compose up -d xmpp-prosody xmpp-postgres xmpp-adminer

# Access Adminer at http://localhost:8080
# Login credentials are automatically configured from your .env file
```

### Unified CLI Tool

The `prosody-manager` script provides comprehensive server management:

```bash
# Show all available commands
./prosody-manager help

# User management
./prosody-manager prosodyctl adduser alice@atl.chat
./prosody-manager prosodyctl passwd alice@atl.chat

# Health monitoring
./prosody-manager health all

# Certificate management
./prosody-manager cert check atl.chat
./prosody-manager cert install atl.chat

# Backup operations
./prosody-manager backup create
./prosody-manager backup restore backup.tar.gz

# Deployment management
./prosody-manager deploy up full
```

## Documentation

### For Users

- [Getting Started Guide](./docs/user/getting-started.md) - Detailed deployment walkthrough
- [Configuration Guide](./docs/user/configuration.md) - Environment variables and settings

### For Administrators

- [Administrator Guide](./docs/admin/README.md) - Essential admin documentation and CLI tool
- [DNS Setup](./docs/admin/dns-setup.md) - Required DNS records and security
- [Certificate Management](./docs/admin/certificate-management.md) - SSL/TLS certificates and Let's Encrypt
- [Security Hardening](./docs/admin/security.md) - Production security configuration

### For Developers

- [Architecture Overview](./docs/dev/architecture.md) - System design and structure
- [Localhost Testing](./docs/dev/localhost-testing.md) - Development environment guide
- [Prosody Modern Features](./docs/dev/prosody-modern-features.md) - Advanced XMPP features

### Reference

- [Module Reference](./docs/reference/modules.md) - Complete module documentation
- [XEP Compliance](./docs/reference/xep-compliance.md) - Supported XMPP extensions

[Browse all documentation](./docs/README.md)

## Security Notice

**Development environment is NOT secure:**

- Open registration enabled
- Debug logging active
- Self-signed certificates
- Relaxed security settings

**Never expose development environment to the internet!** Use only for localhost testing.

## Project Structure

```
xmpp.atl.chat/
├── prosody-manager          # Unified CLI management tool
├── core/                   # Configuration and database files
├── web/                    # Registration, admin, assets, themes, webclient
├── scripts/                # Setup, admin, dev, maintenance scripts
├── deployment/             # Reverse-proxy, systemd, monitoring configs
├── templates/              # Environment and configuration examples
├── docs/                   # Comprehensive documentation
├── tests/                  # Testing framework
├── .runtime/               # Runtime data (gitignored)
└── research/               # Research and notes
```

## Contributing

See [docs/dev/architecture.md](./docs/dev/architecture.md) for development guidelines and project structure.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
