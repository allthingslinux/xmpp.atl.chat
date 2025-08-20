# 📚 Documentation

Complete documentation for the Professional Prosody XMPP Server - a production-ready XMPP deployment with enterprise features and modern XMPP capabilities.

## 🚀 Quick Start

New to XMPP or need to deploy quickly? Start here:

- **[Quick Start Guide](quick-start.md)** - Get running in minutes with prosody-manager
- **[User Guide](guides/users/user-guide.md)** - Complete user documentation
- **[Administration Guide](guides/administration/administration.md)** - Server administration
- **[Deployment Guide](guides/deployment/deployment.md)** - Production deployment

## 📖 Documentation Structure

### 🚀 **Quick Start**

*Get up and running quickly*

| Guide | Description | Audience |
|-------|-------------|----------|
| **[Quick Start](quick-start.md)** | Get your server running in minutes | Everyone |

### 📚 **Comprehensive Guides**

*Task-oriented documentation*

| Guide | Description | Audience |
|-------|-------------|----------|
| **[User Guide](guides/users/user-guide.md)** | Complete user documentation | End users |
| **[Administration Guide](guides/administration/administration.md)** | Server administration with prosody-manager | Administrators |
| **[Deployment Guide](guides/deployment/deployment.md)** | Production deployment | DevOps teams |
| **[TURN/STUN Setup](guides/deployment/turn-stun-setup.md)** | Voice/video calling setup | DevOps teams |
| **[prosody-manager Guide](guides/administration/prosody-manager-guide.md)** | Complete CLI tool reference | Administrators |
| **[Migration Guide](guides/administration/migration-guide.md)** | Migrate from legacy scripts to CLI | Administrators |

### 📋 **Reference Documentation**

*Technical specifications and detailed configuration*

| Reference | Description | Audience |
|-----------|-------------|----------|
| **[File Upload Reference](reference/file-upload-reference.md)** | Complete XEP-0363 configuration and management | Administrators |
| **[Message Archiving Reference](reference/message-archiving-reference.md)** | Complete MAM (XEP-0313) reference | Administrators |
| **[XEP Compliance](reference/xep-compliance.md)** | Supported XMPP Extension Protocols (50+ XEPs) | Technical users |
| **[Module Reference](reference/modules.md)** | Complete module documentation and configuration | Administrators |
| **[Community Modules](reference/community-modules-setup.md)** | Third-party module installation | Administrators |
| **[Module Management](reference/module-management.md)** | Prosody module system | Administrators |
| **[Certificate Monitoring](reference/certificate-monitoring-implementation.md)** | SSL certificate monitoring and renewal | Administrators |

### 💻 **Developer Documentation**

*Technical documentation and architecture*

| Guide | Description | Audience |
|-------|-------------|----------|
| **[Architecture Overview](dev/architecture.md)** | System design, components, and data flow | Developers |
| **[Modern XMPP Features](dev/prosody-modern-features.md)** | Advanced XMPP capabilities and implementation | XMPP developers |

## 🎯 Documentation Philosophy

This documentation follows an **opinionated approach** for the server configuration:

- **🎯 Production-focused** - All guides assume production deployment scenarios
- **🐳 Docker-first** - Examples and instructions use Docker Compose
- **🔒 Security by default** - Security considerations integrated into every guide
- **📝 Clear structure** - Organized by user type and use case
- **✅ Tested examples** - All code examples are tested and verified

## 🛠️ Key Features Covered

### Core XMPP Server Features

- **Message Archive Management (MAM)** - XEP-0313
- **Message Carbons** - XEP-0280  
- **Stream Management (SMACKS)** - XEP-0198
- **HTTP File Upload** - XEP-0363
- **Multi-User Chat (MUC)** - XEP-0045
- **Push Notifications** - XEP-0357

### Enterprise Security

- **TLS 1.3** with perfect forward secrecy
- **SCRAM-SHA-256** authentication
- **Anti-spam & abuse protection**
- **Certificate validation** with DANE/TLSA

### Mobile Optimizations

- **Client State Indication (CSI)** - XEP-0352
- **Battery-saving configurations**
- **WebSocket and BOSH support**
- **Optimized offline message handling**

## 📋 Prerequisites

Before using this documentation, ensure you have:

- **Docker** 20.10+ with Docker Compose 2.0+
- **Domain name** with DNS control
- **Basic command line** familiarity
- **2GB RAM minimum** (4GB+ recommended for full deployment)
- **SSL certificate** capability (Let's Encrypt recommended)

## 🚀 Deployment Options

This server supports multiple deployment configurations:

```bash
# Minimal deployment (XMPP + Database only)
docker compose up -d xmpp-prosody xmpp-postgres

# Full deployment (includes TURN/STUN for voice/video)
docker compose up -d

# Minimal deployment (XMPP + Database only)
docker compose up -d xmpp-prosody xmpp-postgres
```

## 🔍 Finding What You Need

### 🆕 **New to XMPP?**

Start with [Quick Start](quick-start.md) → [User Guide](guides/users/user-guide.md)

### 🔧 **Setting up production?**

Read [Administration Guide](guides/administration/administration.md) → [Deployment Guide](guides/deployment/deployment.md)

### 🛡️ **Security focused?**

Check the Security sections in [Administration Guide](guides/administration/administration.md)

### 🏗️ **Understanding the system?**

Review [Architecture](dev/architecture.md) → [Modern Features](dev/prosody-modern-features.md)

### 📚 **Need technical details?**

Browse [Reference Documentation](reference/) → [XEP Compliance](reference/xep-compliance.md)

## 🤝 Contributing to Documentation

Found an issue or want to improve the documentation?

1. **[Open an issue](https://github.com/allthingslinux/xmpp.atl.chat/issues)** for bugs or suggestions
2. **Submit a pull request** with improvements
3. **Test all examples** before submitting changes
4. **Follow conventional commit** style for commit messages

### Documentation Standards

- **Use clear, actionable language**
- **Include working code examples**
- **Test all commands and configurations**
- **Update links when moving content**
- **Include XEP references** where applicable

## 📁 Directory Structure

```
docs/
├── README.md                    # This overview and navigation guide
├── quick-start.md              # Quick deployment guide
├── guides/                     # Comprehensive task-oriented guides
│   ├── users/
│   │   └── user-guide.md       # Complete user documentation
│   ├── administration/
│   │   ├── administration.md   # Complete admin guide with security & DNS
│   │   ├── prosody-manager-guide.md # CLI tool documentation
│   │   └── migration-guide.md  # Migration from legacy scripts to CLI
│   └── deployment/
│       ├── deployment.md       # Production deployment guide
│       └── turn-stun-setup.md # TURN/STUN server setup for voice/video
├── dev/                        # Developer and technical documentation
│   ├── architecture.md         # System design and components
│   ├── localhost-testing.md    # Development environment
│   └── prosody-modern-features.md # Advanced XMPP capabilities
├── reference/                  # Technical reference materials
│   ├── file-upload-reference.md # XEP-0363 complete reference
│   ├── message-archiving-reference.md # MAM (XEP-0313) reference
│   ├── xep-compliance.md       # Supported XMPP Extension Protocols
│   ├── modules.md              # Complete module documentation
│   ├── community-modules-setup.md # Third-party modules
│   ├── module-management.md    # Module system reference
│   └── certificate-monitoring-implementation.md # SSL certificate monitoring
└── assets/                     # Documentation assets and diagrams
    ├── architecture/           # Architecture diagrams
    ├── diagrams/               # Technical diagrams
    └── screenshots/            # UI screenshots and examples
```

## 🆘 Getting Help

- **📖 Start with documentation** - Most questions are answered in the guides above
- **🐛 Report bugs** - [Open an issue](https://github.com/allthingslinux/xmpp.atl.chat/issues) for problems
- **💡 Request features** - [Open an issue](https://github.com/allthingslinux/xmpp.atl.chat/issues) for enhancements
- **🤝 Contribute** - Submit pull requests with improvements

---

**⭐ Star the repository if this documentation helps you!**

For questions or support, please [open an issue](https://github.com/allthingslinux/xmpp.atl.chat/issues) or start with the [Quick Start Guide](quick-start.md).
