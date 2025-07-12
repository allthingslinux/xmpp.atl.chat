# Prosody XMPP Server

> **XMPP server with modular configuration, XEP compliance, and security features**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](./docker/docker-compose.yml)
[![Security](https://img.shields.io/badge/Security-Enabled-green)](#security)
[![XEP Compliance](https://img.shields.io/badge/XEP-Compliant-purple)](#xmpp-features)

## Overview

This is a Prosody XMPP server setup built from analyzing 42+ XMPP implementations. It uses a **modular configuration system** that separates concerns into focused, maintainable components.

### Modular Architecture

The configuration is split into 7 focused components instead of a single monolithic file:

```text
config/
├── prosody.cfg.lua      # Main entry point (80 lines)
├── global.cfg.lua       # Global settings & performance
├── security.cfg.lua     # TLS, encryption & security policies  
├── database.cfg.lua     # Storage backends & connections
├── modules.cfg.lua      # Module management & loading
├── vhosts.cfg.lua       # Virtual host definitions
└── components.cfg.lua   # XMPP components (MUC, Upload, etc.)
```

**Before**: Single 442-line file  
**After**: 7 focused modules

## Key Features

### Modular Configuration

- **Focused Components** - Each file handles one responsibility
- **Environment-Driven** - No rebuilds needed for changes
- **Clear Structure** - Well-organized and documented
- **Validation** - Configuration validation and error checking
- **Conditional Loading** - Modules loaded based on environment

### Module Organization

Module categorization based on **source and distribution** rather than stability:

```text
modules.d/
├── distributed/           # Shipped with Prosody
│   └── distributed.cfg.lua # MAM, carbons, smacks, websocket, etc.
└── community/             # Third-party modules
    ├── stable/            # Well-tested (firewall, spam_reporting)
    │   ├── anti-spam.cfg.lua
    │   ├── firewall.cfg.lua
    │   ├── push-notifications.cfg.lua
    │   ├── web-features.cfg.lua
    │   └── monitoring.cfg.lua
    ├── beta/              # Mostly stable (password_reset, sasl2)
    └── alpha/             # Experimental (audit, json_logs)
```

### XMPP Features (25+ XEPs Implemented)

#### Core Communication

- **Message Archive Management (XEP-0313)** - Message history
- **Carbon Copies (XEP-0280)** - Multi-device sync
- **Stream Management (XEP-0198)** - Connection resilience
- **Push Notifications (XEP-0357)** - Mobile support

#### Security & Privacy

- **OMEMO Support (XEP-0384)** - End-to-end encryption
- **SASL2 (XEP-0388)** - Updated authentication
- **Channel Binding (XEP-0440)** - Security enhancement
- **FAST (XEP-0484)** - Fast authentication

#### Extensions

- **HTTP File Upload (XEP-0363)** - File sharing
- **WebSocket (RFC 7395)** - Web client support
- **Server Info (XEP-0157)** - Service discovery
- **vCard4 (XEP-0292)** - User profiles

### Security Features

- **TLS 1.3** - Current encryption standards
- **Anti-Spam** - DNS blocklists, rate limiting, quarantine
- **Firewall Protection** - Connection monitoring, abuse prevention
- **Compliance** - XMPP Safeguarding 2025 compliant
- **Audit Logging** - Security monitoring

### Operations

- **Multi-Architecture Docker** - AMD64, ARM64, ARM support
- **Database Options** - SQLite, PostgreSQL, MySQL
- **Monitoring** - Prometheus, Grafana support
- **Backups** - Automated backup scripts
- **Health Checks** - Monitoring and validation

## Quick Start

### 1. Basic Setup

```bash
# Clone the repository
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat

# Configure environment
cp examples/env.example .env
# Edit .env with your domain and settings

# Deploy
docker-compose up -d

# Verify deployment
docker-compose ps
docker-compose logs prosody
```

### 2. Create Your First User

```bash
# Create admin user
docker-compose exec prosody prosodyctl adduser admin@yourdomain.com

# Create regular user
docker-compose exec prosody prosodyctl adduser user@yourdomain.com
```

### 3. Connect & Test

Connect with any XMPP client:

- **Server**: `yourdomain.com`
- **Port**: `5222` (STARTTLS) or `5223` (Direct TLS)
- **Username**: `admin@yourdomain.com`

## Configuration Profiles

### Personal Server (1-50 users)

```bash
# Minimal resource usage
PROSODY_ENABLE_BETA=false
PROSODY_ENABLE_ALPHA=false
PROSODY_DB_DRIVER=SQLite3
```

- **Resources**: 64-128MB RAM, 1 CPU core
- **Features**: Core + Distributed modules
- **Database**: SQLite

### Community Server (50-500 users)

```bash
# Balanced features and performance
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=false
PROSODY_DB_DRIVER=PostgreSQL
```

- **Resources**: 256-512MB RAM, 2-4 CPU cores
- **Features**: All stable modules + monitoring
- **Database**: PostgreSQL

### Production Server (500+ users)

```bash
# Full feature set with monitoring
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=true
PROSODY_MONITORING=true
```

- **Resources**: 512MB-2GB RAM, 4+ CPU cores
- **Features**: All modules + compliance + monitoring
- **Database**: PostgreSQL cluster

## Environment Configuration

Key environment variables for customization:

```bash
# Domain Configuration
PROSODY_DOMAIN=yourdomain.com
PROSODY_ADMINS=admin@yourdomain.com

# Module Control
PROSODY_DISABLE_AUTOLOADED=false  # Disable autoloaded modules (not recommended)
PROSODY_ENABLE_DISTRIBUTED=true   # Distributed Prosody modules
PROSODY_ENABLE_SECURITY=true      # Security & anti-spam
PROSODY_ENABLE_BETA=false         # Beta community modules
PROSODY_ENABLE_ALPHA=false        # Alpha experimental modules

# Database
PROSODY_DB_DRIVER=SQLite3         # SQLite3, PostgreSQL, MySQL
PROSODY_DB_HOST=localhost
PROSODY_DB_NAME=prosody

# Security
PROSODY_TLS_CERT_PATH=/etc/prosody/certs/
PROSODY_REQUIRE_ENCRYPTION=true
PROSODY_ENABLE_FIREWALL=true

# Performance
PROSODY_MAX_CLIENTS=1000
PROSODY_RATE_LIMIT=10
```

## Project Structure

```
xmpp.atl.chat/
├── README.md                    # This comprehensive guide
├── docker/
│   ├── Dockerfile               # Multi-stage optimized build
│   └── docker-compose.yml       # Production-ready deployment
├── config/                      # Modular configuration system
│   ├── prosody.cfg.lua          # Main entry point (80 lines)
│   ├── global.cfg.lua           # Global settings & admins
│   ├── security.cfg.lua         # TLS & security policies
│   ├── database.cfg.lua         # Storage configuration
│   ├── modules.cfg.lua          # Module management
│   ├── vhosts.cfg.lua           # Virtual hosts
│   ├── components.cfg.lua       # XMPP components
│   ├── README.md                # Configuration documentation
│   ├── modules.d/               # Module configurations
│   │   ├── official/            # Official Prosody modules
│   │   └── community/           # Community modules by stability
│   └── firewall/                # Firewall rules
├── scripts/
│   ├── entrypoint.sh            # Docker entrypoint
│   ├── backup.sh                # Automated backups
│   ├── deploy.sh                # Deployment automation
│   └── health-check.sh          # Health monitoring
├── docs/
│   ├── QUICK_START.md           # Getting started guide
│   ├── PROSODY_MODULES_ALIGNMENT.md      # Module organization
│   └── PROSODY_MODULES_XEP_ANALYSIS.md   # XEP compliance analysis
├── examples/
│   └── env.example              # Environment template
└── research/                    # Implementation research
    ├── review/                  # 42+ implementation reviews
    └── summary/                 # Analysis summaries
```

## Security Features

### Encryption & TLS

- **TLS 1.3 Preferred** with fallback to TLS 1.2
- **Perfect Forward Secrecy** with ECDHE key exchange
- **Modern Cipher Suites** (ChaCha20-Poly1305, AES-GCM)
- **Certificate Validation** with DANE/TLSA support

### Anti-Spam Protection

- **DNS Blocklists** (Spamhaus, xmppbl.org integration)
- **Real-time JID Blocklists** with server reputation
- **Rate Limiting** per IP and per user
- **Registration Controls** with CAPTCHA support
- **User Quarantine** for suspicious activity

### Firewall & Access Control

- **Connection Rate Limiting** - Prevent DoS attacks
- **Stanza Size Limits** - Prevent resource exhaustion
- **IP-based Filtering** - Geographic and reputation-based blocking
- **Abuse Reporting** - XEP-0157 compliant reporting

### Monitoring & Compliance

- **XMPP Safeguarding 2025** compliance ready
- **Audit Logging** for security events
- **Failed Authentication Tracking**
- **Real-time Security Alerts**

## Monitoring & Observability

### Built-in Metrics

- Connection counts and rates
- Message throughput and latency
- Error rates and types
- Resource utilization (CPU, memory, disk)

### Prometheus Integration

```bash
# Enable monitoring
PROSODY_MONITORING=true
PROSODY_PROMETHEUS_PORT=9090
```

### Grafana Dashboards

- Real-time server status
- User activity patterns
- Performance metrics
- Security event tracking

## Backup & Recovery

### Automated Backups

```bash
# Run backup
./scripts/backup.sh

# Scheduled backups (add to crontab)
0 2 * * * /path/to/xmpp.atl.chat/scripts/backup.sh
```

### What's Backed Up

- **Database** - All user data and messages
- **Configuration** - All config files
- **Certificates** - TLS certificates and keys
- **Logs** - Security and audit logs

## Advanced Deployment

### Production with PostgreSQL

```bash
# Production deployment with external database
PROSODY_DB_DRIVER=PostgreSQL
PROSODY_DB_HOST=your-postgres-server
docker-compose up -d
```

### Load Balancer Configuration

```nginx
upstream prosody_cluster {
    server prosody1:5222;
    server prosody2:5222;
    server prosody3:5222;
}
```

## Testing & Validation

### Health Checks

```bash
# Check server health
./scripts/health-check.sh

# Validate configuration
docker-compose exec prosody prosodyctl check config
```

### XEP Compliance Testing

```bash
# Test modern XMPP features
prosodyctl check connectivity yourdomain.com
```

## Contributing

We welcome contributions! This setup incorporates best practices from 42+ XMPP implementations.

### Development Setup

```bash
# Fork and clone
git clone https://github.com/yourusername/xmpp.atl.chat
cd xmpp.atl.chat

# Development environment
cp examples/env.example .env.dev
docker-compose up -d
```

### Contribution Guidelines

1. **Fork** the repository
2. **Create** a feature branch
3. **Test** thoroughly with different configurations
4. **Document** changes in relevant files
5. **Submit** a pull request with clear description

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

This professional setup incorporates best practices from the XMPP community:

- **[Prosody IM](https://prosody.im/)** - The amazing XMPP server
- **[prosody-modules](https://modules.prosody.im/)** - Community module ecosystem
- **42+ XMPP Implementations** - Research and analysis in `/research/`
- **XMPP Standards Foundation** - XEP specifications and compliance

---

**Ready to deploy professional XMPP infrastructure?**

[Get Started](#quick-start) • [Configuration Guide](config/README.md) • [XEP Analysis](docs/PROSODY_MODULES_XEP_ANALYSIS.md)
