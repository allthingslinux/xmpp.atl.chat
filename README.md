# 🚀 Professional Prosody XMPP Server

> **Production-ready XMPP server with comprehensive feature set, extensive XEP compliance, and enterprise security**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](./docker/docker-compose.yml)
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

# Deploy the server
docker-compose up -d

# Check status
docker-compose logs -f prosody
```

### 2. Create Users

```bash
# Create admin user
docker-compose exec prosody prosodyctl adduser admin@yourdomain.com

# Create regular users  
docker-compose exec prosody prosodyctl adduser user@yourdomain.com
```

### 3. Connect

Your XMPP server is now ready! Connect with any XMPP client:

- **Server**: `yourdomain.com`
- **Ports**: 5222 (STARTTLS), 5223 (Direct TLS)
- **Web Admin**: `https://yourdomain.com:5281/admin`
- **WebSocket**: `wss://yourdomain.com:5281/xmpp-websocket`

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
| **Prometheus** | Metrics collection | 9090 | Optional |
| **Grafana** | Monitoring dashboards | 3000 | Optional |
| **Node Exporter** | System metrics | 9100 | Optional |

### Deployment Options

```bash
# Minimal deployment (XMPP + Database only)
docker-compose up -d prosody db

# Full deployment (all services)
docker-compose up -d

# Custom service selection
docker-compose up -d prosody db prometheus grafana
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
- **[Client Setup](./docs/user/client-setup.md)** - Connecting XMPP clients

### 🛠️ **For Administrators**

- **[Docker Deployment Guide](./docs/admin/docker-deployment-guide.md)** - Production deployment strategies
- **[Certificate Management](./docs/admin/certificate-management.md)** - SSL/TLS certificate handling
- **[WebSocket Configuration](./docs/admin/websocket-configuration.md)** - WebSocket setup and reverse proxy
- **[Security Hardening](./docs/admin/security.md)** - Security best practices
- **[Prosodyctl Management](./docs/admin/prosodyctl-management.md)** - Server management tools

### 💻 **For Developers**

- **[Architecture Overview](./docs/dev/architecture.md)** - System design and structure
- **[Prosody Modern Features](./docs/dev/prosody-modern-features.md)** - Advanced XMPP features

### 📖 **Reference**

- **[Module Reference](./docs/reference/modules.md)** - Complete module documentation
- **[XEP Compliance](./docs/reference/xep-compliance.md)** - Supported XMPP extensions

**[→ Browse all documentation](./docs/README.md)**

## 🛠️ Management Tools

Included scripts for server management:

- **`scripts/deploy.sh`** - Automated deployment and updates
- **`scripts/prosodyctl-manager.sh`** - Enhanced prosodyctl wrapper with additional features
- **`scripts/backup.sh`** - Database and data backup automation
- **`scripts/health-check.sh`** - Server health monitoring
- **`scripts/install-certificates.sh`** - SSL certificate installation and renewal
- **`scripts/validate-config.sh`** - Configuration validation and testing

## 🤝 Contributing

We welcome contributions! Please see our [contributing guidelines](./docs/dev/contributing.md) for:

- **Development workflow**
- **Testing procedures**
- **Code style guidelines**
- **Documentation standards**

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
