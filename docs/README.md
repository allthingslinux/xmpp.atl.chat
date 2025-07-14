# 📚 Documentation

Complete documentation for the Professional Prosody XMPP Server - a production-ready XMPP deployment with enterprise features and modern XMPP capabilities.

## 🚀 Quick Start

New to XMPP or need to deploy quickly? Start here:

- **[Getting Started](user/getting-started.md)** - Complete deployment walkthrough in 5 minutes
- **[Configuration Guide](user/configuration.md)** - Environment variables and customization options

## 📖 Documentation Structure

### 👥 **For Users**

*End-user deployment and configuration guides*

| Guide | Description | Audience |
|-------|-------------|----------|
| **[Getting Started](user/getting-started.md)** | Step-by-step deployment walkthrough | New users |
| **[Configuration](user/configuration.md)** | Environment variables and settings | All users |

### 🛠️ **For Administrators**

*Production deployment and management guides*

| Guide | Description | Audience |
|-------|-------------|----------|
| **[Administrator Guide](admin/README.md)** | Essential admin documentation and CLI tools | System administrators |
| **[DNS Setup](admin/dns-setup.md)** | Required DNS records and security considerations | Network administrators |
| **[Certificate Management](admin/certificate-management.md)** | SSL/TLS certificates and Let's Encrypt automation | DevOps teams |
| **[Security Hardening](admin/security.md)** | Production security configuration and best practices | Security teams |

### 💻 **For Developers**

*Technical documentation and architecture*

| Guide | Description | Audience |
|-------|-------------|----------|
| **[Architecture Overview](dev/architecture.md)** | System design, components, and data flow | Developers |
| **[Modern XMPP Features](dev/prosody-modern-features.md)** | Advanced XMPP capabilities and implementation | XMPP developers |

### 📋 **Reference Documentation**

*Technical specifications and compliance information*

| Reference | Description | Audience |
|-----------|-------------|----------|
| **[XEP Compliance](reference/xep-compliance.md)** | Supported XMPP Extension Protocols (50+ XEPs) | Technical users |
| **[Module Reference](reference/modules.md)** | Complete module documentation and configuration | Administrators |

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

Start with [Getting Started](user/getting-started.md) → [Configuration](user/configuration.md)

### 🔧 **Setting up production?**

Read [Administrator Guide](admin/README.md) → [DNS Setup](admin/dns-setup.md) → [Security](admin/security.md)

### 🛡️ **Security focused?**

Check [Security Hardening](admin/security.md) → [Certificate Management](admin/certificate-management.md)

### 🏗️ **Understanding the system?**

Review [Architecture](dev/architecture.md) → [Modern Features](dev/prosody-modern-features.md)

### 📚 **Need technical details?**

Browse [XEP Compliance](reference/xep-compliance.md) → [Module Reference](reference/modules.md)

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
├── user/                        # End-user deployment guides
│   ├── getting-started.md      # Quick deployment walkthrough
│   └── configuration.md        # Environment and settings
├── admin/                       # Administrator and operations guides
│   ├── README.md               # Admin CLI tools and essentials
│   ├── dns-setup.md            # DNS configuration and security
│   ├── certificate-management.md # SSL/TLS and Let's Encrypt
│   └── security.md             # Security hardening and best practices
├── dev/                         # Developer and technical documentation
│   ├── architecture.md         # System design and components
│   └── prosody-modern-features.md # Advanced XMPP capabilities
├── reference/                   # Technical reference materials
│   ├── xep-compliance.md       # Supported XMPP Extension Protocols
│   └── modules.md              # Complete module documentation
└── assets/                      # Documentation assets and diagrams
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

For questions or support, please [open an issue](https://github.com/allthingslinux/xmpp.atl.chat/issues) or start with the [Getting Started guide](user/getting-started.md).
