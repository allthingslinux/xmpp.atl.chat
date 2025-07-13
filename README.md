# 🚀 Professional Prosody XMPP Server

> **Production-ready XMPP server with comprehensive feature set, extensive XEP compliance, and enterprise security**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](./docker-compose.yml)
[![Security](https://img.shields.io/badge/Security-Hardened-green)](#-security-features)
[![XEP Compliance](https://img.shields.io/badge/XEP-50%2B%20Supported-purple)](./docs/reference/xep-compliance.md)
[![Prosody](https://img.shields.io/badge/Prosody-13.0%2B-orange)](https://prosody.im/)

## ✨ What is This?

A **single, opinionated Prosody XMPP server configuration** designed for professional deployment. Built from extensive research of real-world XMPP deployments, this setup provides enterprise-level features with all modern XMPP capabilities enabled by default.

**No complex layers or environments** - just one comprehensive, production-ready configuration that works out of the box.

## 🚀 Quick Start

### 1. Deploy with Docker

```bash
# Clone the repository
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat

# Configure your environment
cp examples/env.example .env
# Edit .env with your domain and database password

# Generate SSL certificate (choose one method)
docker compose --profile letsencrypt run --rm certbot  # Let's Encrypt
# OR copy your existing certificate to the volume

# Set up automatic certificate renewal (recommended)
(crontab -l 2>/dev/null; echo "0 3 * * * /path/to/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -

# Deploy the server
docker compose up -d prosody db

# Check status
docker compose logs -f prosody
```

📖 **Complete Setup Guide**: [Docker Deployment Guide](docs/admin/docker-deployment.md)

### 2. Create Users

```bash
# Using the unified CLI tool
./scripts/prosody-manager prosodyctl adduser admin@atl.chat
./scripts/prosody-manager prosodyctl adduser user@atl.chat

# Or directly with Docker
docker compose exec prosody prosodyctl adduser admin@atl.chat
```

### 3. Connect

Your XMPP server is now ready! Connect with any XMPP client:

- **Server**: `atl.chat`
- **Ports**: 5222 (STARTTLS), 5223 (Direct TLS)
- **Web Admin**: `https://xmpp.atl.chat:5281/admin`
- **WebSocket**: `wss://xmpp.atl.chat:5281/xmpp-websocket`

## 🌟 Key Features

### 🔒 **Enterprise Security** (Default Enabled)

- **TLS 1.3** with perfect forward secrecy
- **SCRAM-SHA-256** authentication (XEP-0474)
- **Anti-spam & abuse protection** with DNS blocklists
- **Certificate validation** with DANE/TLSA support

### 📱 **Modern XMPP Features** (Default Enabled)

- **Message Archive Management** (MAM) - XEP-0313
- **Message Carbons** - XEP-0280  
- **Stream Management** (SMACKS) - XEP-0198
- **Client State Indication** (CSI) - XEP-0352
- **HTTP File Upload** - XEP-0363
- **Push Notifications** - XEP-0357

### 🚀 **Mobile Optimizations** (Default Enabled)

- **Battery-saving CSI configuration**
- **Mobile presence deduplication**
- **Optimized offline message handling**
- **WebSocket and BOSH support**

### 💼 **Professional Features** (Default Enabled)

- **Multi-User Chat** (MUC) - XEP-0045
- **Publish-Subscribe** (PubSub) - XEP-0060
- **External Service Discovery** - XEP-0215
- **TURN/STUN integration** for voice/video calls
- **Web admin interface** and monitoring

## 🐳 Service Architecture

This deployment includes multiple services for a complete XMPP solution:

| Service | Purpose | Port(s) | Status |
|---------|---------|---------|--------|
| **Prosody** | XMPP server with PostgreSQL | 5222, 5223, 5269, 5280, 5281 | Core |
| **PostgreSQL** | Database backend | 5432 (internal) | Core |
| **Coturn** | TURN/STUN server for voice/video | 3478, 5349, 49152-65535 | Optional |
| ~~**Prometheus**~~ | ~~Metrics collection~~ | ~~9090~~ | ~~External~~ |
| ~~**Grafana**~~ | ~~Monitoring dashboards~~ | ~~3000~~ | ~~External~~ |
| ~~**Node Exporter**~~ | ~~System metrics~~ | ~~9100~~ | ~~External~~ |

### Deployment Options

```bash
# Minimal deployment (XMPP + Database only)
docker compose up -d prosody db

# Full deployment (all services)
docker compose up -d

# Custom service selection
docker compose up -d prosody db prometheus grafana
```

## 📊 XEP Compliance

This server supports **50+ XMPP Extension Protocols (XEPs)** for maximum client compatibility:

| Category | Key XEPs | Status |
|----------|----------|---------|
| **Core Protocol** | XEP-0030 (Service Discovery), XEP-0115 (Entity Capabilities) | ✅ |
| **Modern Messaging** | XEP-0313 (MAM), XEP-0280 (Carbons), XEP-0198 (Stream Management) | ✅ |
| **File Sharing** | XEP-0363 (HTTP Upload), XEP-0447 (Stateless File Sharing) | ✅ |
| **Security** | XEP-0384 (OMEMO), XEP-0474 (SASL SCRAM Downgrade Protection) | ✅ |
| **Mobile** | XEP-0352 (CSI), XEP-0357 (Push), XEP-0198 (Stream Management) | ✅ |
| **Real-time** | XEP-0215 (External Services), XEP-0167/0176 (Jingle A/V) | ✅ |

**[→ View complete XEP compliance list](./docs/reference/xep-compliance.md)**

## 🔒 Security Features

- **🛡️ Transport Security**: TLS 1.3, perfect forward secrecy, modern cipher suites
- **🚫 Anti-Spam**: DNS blocklists, rate limiting, JID reputation scoring  
- **🔐 Authentication**: Multi-factor auth support, SASL 2.0, SCRAM-SHA-256
- **📊 Monitoring**: Audit logging, security alerts, compliance reports
- **🌐 Network**: IPv6 support, DNSSEC validation, SRV record discovery

**[→ View detailed security documentation](./docs/admin/security.md)**

## 📚 Documentation

This project includes comprehensive documentation organized by audience:

### 👥 **For Users**

- **[Getting Started Guide](./docs/user/getting-started.md)** - Detailed deployment walkthrough
- **[Configuration Guide](./docs/user/configuration.md)** - Environment variables and settings

### 🛠️ **For Administrators**

- **[Administrator Guide](./docs/admin/README.md)** - Essential admin documentation and CLI tool
- **[DNS Setup](./docs/admin/dns-setup.md)** - Required DNS records and security
- **[Certificate Management](./docs/admin/certificate-management.md)** - SSL/TLS certificates and Let's Encrypt
- **[Security Hardening](./docs/admin/security.md)** - Production security configuration

### 💻 **For Developers**

- **[Architecture Overview](./docs/dev/architecture.md)** - System design and structure
- **[Prosody Modern Features](./docs/dev/prosody-modern-features.md)** - Advanced XMPP features

### 📖 **Reference**

- **[Module Reference](./docs/reference/modules.md)** - Complete module documentation
- **[XEP Compliance](./docs/reference/xep-compliance.md)** - Supported XMPP extensions

**[→ Browse all documentation](./docs/README.md)**

## 🛠️ Management Tools

### Unified CLI Tool

The **`prosody-manager`** script provides comprehensive server management:

```bash
# Show all available commands
./scripts/prosody-manager help

# User management
./scripts/prosody-manager prosodyctl adduser alice@atl.chat
./scripts/prosody-manager prosodyctl passwd alice@atl.chat

# Health monitoring
./scripts/prosody-manager health all

# Certificate management
./scripts/prosody-manager cert check atl.chat
./scripts/prosody-manager cert install atl.chat

# Backup operations
./scripts/prosody-manager backup create
./scripts/prosody-manager backup restore backup.tar.gz

# Deployment management
./scripts/prosody-manager deploy up full
./scripts/prosody-manager deploy logs prosody
```

### Docker-Specific Scripts

- **`scripts/entrypoint.sh`** - Docker container initialization
- **`scripts/generate-dhparam.sh`** - DH parameter generation for TLS
- **`scripts/renew-certificates.sh`** - Automated certificate renewal with Prosody reload
- **`scripts/init-db.sql`** - PostgreSQL database initialization

## 🤝 Contributing

We welcome contributions! Please:

- **Open issues** for bugs or feature requests
- **Submit pull requests** with clear descriptions
- **Follow conventional commit** style for commit messages
- **Update documentation** when making changes

## 📋 Requirements

- **Docker** 20.10+ and **Docker Compose** 2.0+
- **2GB RAM** minimum (4GB+ recommended for full deployment)
- **Valid domain name** with DNS control
- **SSL certificate** (Let's Encrypt recommended)

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

Built with:

- **[Prosody IM](https://prosody.im/)** - Lightweight XMPP server
- **[PostgreSQL](https://postgresql.org/)** - Reliable database backend
- **[Docker](https://docker.com/)** - Containerization platform
- **Community modules** from the [Prosody Community Modules](https://modules.prosody.im/) project

---

**⭐ Star this repository if you find it useful!**

For questions or support, please [open an issue](https://github.com/allthingslinux/xmpp.atl.chat/issues) or check our [documentation](./docs/README.md).
