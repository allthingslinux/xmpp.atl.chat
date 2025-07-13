# 🚀 Professional Prosody XMPP Server

> **Enterprise-grade XMPP server with layer-based configuration, extensive XEP compliance, and production-ready security**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](./docker/docker-compose.yml)
[![Security](https://img.shields.io/badge/Security-Hardened-green)](#security-features)
[![XEP Compliance](https://img.shields.io/badge/XEP-30%2B%20Supported-purple)](#xep-compliance)
[![Prosody](https://img.shields.io/badge/Prosody-13.0.0-orange)](https://prosody.im/)

## 🌟 Overview

This is a **professional-grade Prosody XMPP server** featuring a revolutionary **layer-based configuration architecture** that organizes settings by XMPP protocol stack layers. Built from extensive research and analysis of real-world XMPP deployments, this setup provides enterprise-level features with exceptional maintainability.

### 🏗️ Layer-Based Architecture

Our configuration system is organized by **XMPP protocol stack layers**, making it intuitive for XMPP experts and excellent for troubleshooting:

```
XMPP Protocol Stack (8 Layers × 4 Configuration Files = 32 Total)

01-transport/     → Network & TLS foundations
├── ports.cfg.lua       # Port bindings (c2s:5222, s2s:5269, HTTP:5280/5281)
├── tls.cfg.lua         # Modern TLS 1.3, PFS, OCSP, security hardening
├── compression.cfg.lua # XEP-0138 stream compression with security
└── connections.cfg.lua # Connection management, rate limiting, QoS

02-stream/        → Authentication & session management
├── authentication.cfg.lua # SASL 2.0, SCRAM-SHA-256, MFA, enterprise backends
├── encryption.cfg.lua     # OMEMO, OpenPGP, encryption policies
├── management.cfg.lua     # XEP-0198 Stream Management, mobile optimizations
└── negotiation.cfg.lua    # Service Discovery, Entity Capabilities, roster

03-stanza/        → Message processing & routing
├── routing.cfg.lua     # BOSH, WebSocket, message delivery, XMPP Ping
├── filtering.cfg.lua   # Advanced firewall, anti-spam, content filtering
├── validation.cfg.lua  # XML schema, security validation, compliance
└── processing.cfg.lua  # Message processing, forwarding, pipelines

04-protocol/      → Core XMPP features
├── core.cfg.lua        # RFC 6120/6121 core features, JID validation
├── extensions.cfg.lua  # Modern XEPs (MAM, Carbons, MUC, file transfer)
├── legacy.cfg.lua      # Backwards compatibility with security warnings
└── experimental.cfg.lua # Cutting-edge features, alpha modules

05-services/      → Communication services
├── messaging.cfg.lua   # Message handling, delivery, archiving
├── presence.cfg.lua    # Presence, status, availability management
├── groupchat.cfg.lua   # MUC, group chat, conference features
└── pubsub.cfg.lua      # PubSub, XEP-0060, real-time publishing

06-storage/       → Data persistence
├── backends.cfg.lua    # Database drivers, connection pooling
├── archiving.cfg.lua   # Message archiving, retention policies
├── caching.cfg.lua     # Performance caching, memory optimization
└── migration.cfg.lua   # Database migrations, schema management

07-interfaces/    → External interfaces
├── http.cfg.lua        # HTTP server, file upload, web admin
├── websocket.cfg.lua   # WebSocket, real-time web connections
├── bosh.cfg.lua        # BOSH, HTTP binding for web clients
└── components.cfg.lua  # External components, gateways

08-integration/   → External systems
├── ldap.cfg.lua        # LDAP authentication, directory services
├── oauth.cfg.lua       # OAuth 2.0, modern authentication
├── webhooks.cfg.lua    # HTTP webhooks, external notifications
└── apis.cfg.lua        # REST APIs, external integrations
```

## ✨ Key Features

### 🎯 Layer-Based Configuration

- **Protocol Stack Organization** - Mirrors XMPP architecture
- **32 Focused Files** - Each handles specific functionality
- **Expert-Friendly** - Intuitive for XMPP protocol experts
- **Troubleshooting** - Easy to locate and debug issues
- **Maintainability** - Clean separation of concerns

### 🔒 Enterprise Security

- **TLS 1.3 + Perfect Forward Secrecy** - State-of-the-art encryption
- **Multi-Factor Authentication** - SASL 2.0, SCRAM-SHA-256, token auth
- **Anti-Spam Protection** - DNS blocklists, rate limiting, quarantine
- **Firewall Integration** - Advanced stanza filtering and abuse prevention
- **Compliance Ready** - GDPR, HIPAA, audit logging capabilities

### 🌐 Modern XMPP Features (30+ XEPs)

- **Message Archive Management (XEP-0313)** - Searchable message history
- **Message Carbons (XEP-0280)** - Multi-device synchronization
- **Stream Management (XEP-0198)** - Connection resilience
- **HTTP File Upload (XEP-0363)** - Secure file sharing
- **Push Notifications (XEP-0357)** - Mobile push support
- **OMEMO Support (XEP-0384)** - End-to-end encryption
- **WebSocket (RFC 7395)** - Modern web client support

### 🚀 Production Ready

- **Multi-Architecture Docker** - AMD64, ARM64, ARM support
- **Database Flexibility** - SQLite, PostgreSQL, MySQL support
- **Monitoring & Metrics** - Prometheus, Grafana integration
- **Health Checks** - Comprehensive monitoring and validation
- **Backup & Recovery** - Automated backup systems

## 🚀 Quick Start

### 1. Deploy with Docker

```bash
# Clone the repository
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat

# Configure your environment
cp examples/env.example .env
# Edit .env with your domain and preferences

# Deploy the server
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f prosody
```

### 2. Create Users

```bash
# Create admin user
docker-compose exec prosody prosodyctl adduser admin@yourdomain.com

# Create regular users
docker-compose exec prosody prosodyctl adduser user@yourdomain.com
```

### 3. Connect & Test

Connect with any XMPP client:

- **Server**: `yourdomain.com`
- **Ports**: 5222 (STARTTLS), 5223 (Direct TLS)
- **Web Access**: `https://yourdomain.com:5281/` (admin interface)

## 🔧 Configuration Profiles

### 💻 Development Setup

```bash
# Minimal resources, core features only
PROSODY_ENABLE_BETA=false
PROSODY_ENABLE_ALPHA=false
PROSODY_STORAGE=sqlite
```

- **Resources**: 64-128MB RAM, 1 CPU core
- **Features**: Core XMPP features, essential security
- **Database**: SQLite (file-based)

### 🏢 Production Server

```bash
# Full feature set with monitoring
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=false
PROSODY_STORAGE=postgresql
PROSODY_MONITORING=true
```

- **Resources**: 512MB-2GB RAM, 2-4 CPU cores
- **Features**: All stable modules, comprehensive monitoring
- **Database**: PostgreSQL with connection pooling

### 🌐 Enterprise Deployment

```bash
# Maximum features, compliance, monitoring
PROSODY_ENABLE_BETA=true
PROSODY_ENABLE_ALPHA=true
PROSODY_COMPLIANCE_MODE=enterprise
PROSODY_MONITORING=prometheus
```

- **Resources**: 1GB+ RAM, 4+ CPU cores
- **Features**: All modules, compliance logging, audit trails
- **Database**: PostgreSQL cluster with replication

## 📊 XEP Compliance

### Core Protocol Support

| XEP | Description | Status |
|-----|------------|---------|
| **XEP-0030** | Service Discovery | ✅ Core |
| **XEP-0115** | Entity Capabilities | ✅ Core |
| **XEP-0191** | Blocking Command | ✅ Core |
| **XEP-0198** | Stream Management | ✅ Core |
| **XEP-0280** | Message Carbons | ✅ Core |
| **XEP-0313** | Message Archive Management | ✅ Core |

### Modern Extensions

| XEP | Description | Status |
|-----|------------|---------|
| **XEP-0357** | Push Notifications | ✅ Community |
| **XEP-0363** | HTTP File Upload | ✅ Core |
| **XEP-0384** | OMEMO Encryption | ✅ Community |
| **XEP-0388** | Extensible SASL Profile | ✅ Community |
| **XEP-0440** | SASL Channel-Binding | ✅ Community |
| **XEP-0484** | Fast Authentication | ✅ Community |

### Advanced Features

| XEP | Description | Status |
|-----|------------|---------|
| **XEP-0156** | Discovering Connection Methods | ✅ Core |
| **XEP-0215** | External Service Discovery | ✅ Community |
| **XEP-0292** | vCard4 Over XMPP | ✅ Core |
| **XEP-0352** | Client State Indication | ✅ Community |
| **XEP-0368** | SRV Records for XMPP | ✅ Core |

## 🔒 Security Features

### 🛡️ Transport Security

- **TLS 1.3 Preferred** with TLS 1.2 fallback
- **Perfect Forward Secrecy** (ECDHE key exchange)
- **Modern Cipher Suites** (ChaCha20-Poly1305, AES-GCM)
- **Certificate Validation** with DANE/TLSA support
- **HSTS & Security Headers** for web interfaces

### 🚫 Anti-Spam & Abuse Protection

- **DNS Blocklists** (Spamhaus, SURBL integration)
- **Real-time JID Blocklists** with reputation scoring
- **Rate Limiting** per IP, per user, per stanza type
- **Registration Controls** with CAPTCHA and approval workflows
- **User Quarantine** for suspicious activity detection

### 🔐 Authentication & Authorization

- **Multi-Factor Authentication** support
- **SASL 2.0** with channel binding
- **SCRAM-SHA-256** secure authentication
- **Enterprise Backends** (LDAP, OAuth, custom HTTP)
- **Role-Based Access Control** with granular permissions

### 📊 Monitoring & Compliance

- **Audit Logging** for security events
- **Failed Authentication Tracking**
- **Real-time Security Alerts**
- **Compliance Reports** (GDPR, HIPAA ready)
- **Performance Metrics** with Prometheus integration

## 🏗️ Project Structure

```
xmpp.atl.chat/
├── README.md                    # This comprehensive guide
├── docker/
│   ├── Dockerfile               # Multi-stage production build
│   └── docker-compose.yml       # Production deployment
├── config/
│   ├── prosody.cfg.lua          # Main configuration loader
│   ├── stack/                   # Layer-based configuration (32 files)
│   │   ├── 01-transport/        # Network & TLS layer
│   │   ├── 02-stream/           # Authentication & session layer
│   │   ├── 03-stanza/           # Message processing layer
│   │   ├── 04-protocol/         # Core XMPP features layer
│   │   ├── 05-services/         # Communication services layer
│   │   ├── 06-storage/          # Data persistence layer
│   │   ├── 07-interfaces/       # External interfaces layer
│   │   └── 08-integration/      # External systems layer
│   ├── domains/                 # Domain-specific configurations
│   ├── environments/            # Environment-specific settings
│   ├── policies/                # Security & compliance policies
│   ├── firewall/                # Firewall rules & filters
│   └── tools/                   # Configuration utilities
├── prosody-hg/                  # Prosody source (development)
├── prosody-modules/             # Community modules repository
├── scripts/                     # Deployment & management scripts
├── docs/                        # Comprehensive documentation
└── examples/                    # Configuration examples
```

## 🌍 Environment Configuration

### Core Settings

```bash
# Basic server configuration
PROSODY_DOMAIN=yourdomain.com
PROSODY_ADMINS=admin@yourdomain.com
PROSODY_ENVIRONMENT=production

# Module control (stability-based)
PROSODY_ENABLE_CORE=true         # Core Prosody modules
PROSODY_ENABLE_SECURITY=true     # Security enhancements
PROSODY_ENABLE_BETA=true         # Beta community modules
PROSODY_ENABLE_ALPHA=false       # Alpha experimental modules
```

### Database Configuration

```bash
# Database backend selection
PROSODY_STORAGE=postgresql       # sqlite, postgresql, mysql
PROSODY_DB_HOST=localhost
PROSODY_DB_NAME=prosody
PROSODY_DB_USER=prosody
PROSODY_DB_PASSWORD=secure_password
```

### Security Settings

```bash
# TLS and encryption
PROSODY_TLS_CERT_PATH=/etc/prosody/certs/
PROSODY_REQUIRE_ENCRYPTION=true
PROSODY_TLS_VERSION=1.3

# Access control
PROSODY_FIREWALL_ENABLED=true
PROSODY_RATE_LIMIT_ENABLED=true
PROSODY_SPAM_PROTECTION=true
```

### Performance Tuning

```bash
# Resource limits
PROSODY_MAX_CLIENTS=1000
PROSODY_C2S_RATE_LIMIT=10kb/s
PROSODY_S2S_RATE_LIMIT=30kb/s
PROSODY_MEMORY_LIMIT=512M
```

## 🔍 Monitoring & Observability

### Built-in Metrics

- **Connection Statistics** - Active users, connection rates
- **Message Throughput** - Messages/second, delivery success rates
- **Resource Usage** - CPU, memory, disk utilization
- **Security Events** - Authentication failures, abuse attempts
- **Performance Metrics** - Response times, queue lengths

### Prometheus Integration

```bash
# Enable Prometheus metrics
PROSODY_MONITORING=prometheus
PROSODY_METRICS_PORT=9090

# Access metrics
curl http://localhost:9090/metrics
```

### Grafana Dashboards

- **Server Overview** - Health, performance, resource usage
- **User Activity** - Login patterns, message activity
- **Security Dashboard** - Threats, blocks, authentication events
- **Compliance Reports** - Audit logs, policy violations

## 🔄 Backup & Recovery

### Automated Backup System

```bash
# Configure backup
PROSODY_BACKUP_ENABLED=true
PROSODY_BACKUP_SCHEDULE="0 2 * * *"  # Daily at 2 AM
PROSODY_BACKUP_RETENTION=30          # Keep 30 days

# Manual backup
./scripts/backup.sh
```

### What Gets Backed Up

- **Database** - All user data, messages, configurations
- **Certificates** - TLS certificates and private keys
- **Configuration** - All configuration files and customizations
- **Logs** - Security logs, audit trails, error logs

## 🚀 Advanced Deployment

### Load Balancer Configuration

```nginx
upstream prosody_xmpp {
    server prosody1:5222;
    server prosody2:5222;
    server prosody3:5222;
}

upstream prosody_http {
    server prosody1:5280;
    server prosody2:5280;
    server prosody3:5280;
}

server {
    listen 5222;
    proxy_pass prosody_xmpp;
}
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prosody-xmpp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: prosody-xmpp
  template:
    spec:
      containers:
      - name: prosody
        image: professional-prosody:latest
        ports:
        - containerPort: 5222
        - containerPort: 5269
        - containerPort: 5280
```

## 🧪 Testing & Validation

### Health Checks

```bash
# Server health validation
./scripts/health-check.sh

# Configuration validation
docker-compose exec prosody prosodyctl check config

# Connectivity testing
docker-compose exec prosody prosodyctl check connectivity yourdomain.com
```

### XEP Compliance Testing

```bash
# Test modern XMPP features
prosodyctl check xep yourdomain.com

# Validate security configuration
prosodyctl check security yourdomain.com
```

## 🤝 Contributing

We welcome contributions! This setup incorporates best practices from extensive XMPP implementation research.

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch from `main`
3. **Implement** changes with proper documentation
4. **Test** thoroughly with different configurations
5. **Submit** a pull request with detailed description

### Code Standards

- Follow the layer-based architecture
- Include comprehensive documentation
- Add appropriate XEP references
- Maintain security best practices
- Test across multiple environments

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

This professional setup is built on the shoulders of giants:

- **[Prosody IM](https://prosody.im/)** - The outstanding XMPP server
- **[Prosody Modules](https://modules.prosody.im/)** - Community module ecosystem
- **[XMPP Standards Foundation](https://xmpp.org/)** - Protocol specifications
- **XMPP Community** - Continuous innovation and support

---

## 🚀 Ready to Deploy?

**[Quick Start Guide](#-quick-start)** • **[Configuration Docs](config/README.md)** • **[Security Guide](docs/SECURITY.md)**

*Professional XMPP infrastructure made simple.*
