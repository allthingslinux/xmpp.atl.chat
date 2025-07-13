# 📚 Documentation

Complete documentation for the Professional Prosody XMPP Server - a single, opinionated configuration designed for production deployment.

## 🚀 Quick Links

- **[Getting Started](user/getting-started.md)** - Deploy your XMPP server in 5 minutes
- **[Docker Deployment](admin/docker-deployment-guide.md)** - Production deployment with Docker
- **[Certificate Management](admin/certificate-management.md)** - SSL/TLS setup and automation
- **[Security Guide](admin/security.md)** - Security features and best practices

## 👥 For Users

Get up and running quickly with these essential guides:

| Guide | Description |
|-------|-------------|
| **[Getting Started](user/getting-started.md)** | Complete deployment walkthrough |
| **[Configuration](user/configuration.md)** | Environment variables and settings |

## 🛠️ For Administrators

Production deployment and management guides:

| Guide | Description |
|-------|-------------|
| **[Docker Deployment](admin/docker-deployment-guide.md)** | Production Docker setup |
| **[Certificate Management](admin/certificate-management.md)** | SSL/TLS certificates with Let's Encrypt |
| **[Security Hardening](admin/security.md)** | Security features and best practices |
| **[WebSocket Configuration](admin/websocket-configuration.md)** | Reverse proxy and WebSocket setup |
| **[Prosodyctl Management](admin/prosodyctl-management.md)** | Server management with prosodyctl |
| **[Port Configuration](admin/port-configuration-guide.md)** | Network ports and firewall setup |
| **[DNS Setup](admin/dns-setup.md)** | DNS records and domain configuration |

## 💻 For Developers

Technical documentation and architecture:

| Guide | Description |
|-------|-------------|
| **[Architecture](dev/architecture.md)** | System design and components |
| **[Modern XMPP Features](dev/prosody-modern-features.md)** | Advanced XMPP capabilities |

## 📖 Reference

Technical specifications and compliance:

| Reference | Description |
|-----------|-------------|
| **[XEP Compliance](reference/xep-compliance.md)** | Supported XMPP Extension Protocols |
| **[Module Reference](reference/modules.md)** | Enabled modules and features |

## 🎯 Documentation Philosophy

This documentation follows the same **single, opinionated approach** as the server configuration:

- **Production-focused** - Guides assume production deployment
- **Docker-first** - All examples use Docker Compose
- **Security by default** - Security considerations built into every guide
- **No complex layers** - Simple, direct configuration approach

## 📋 What You Need

Before diving into the documentation:

- **Docker** 20.10+ with Docker Compose 2.0+
- **Domain name** with DNS control
- **Basic command line** familiarity
- **2GB RAM minimum** (4GB+ recommended)

## 🤝 Contributing

Found an issue or want to improve the documentation?

1. **[Open an issue](https://github.com/allthingslinux/xmpp.atl.chat/issues)** for bugs or suggestions
2. **Submit a pull request** with improvements
3. **Test all examples** before submitting changes

## 📄 Structure

```
docs/
├── README.md              # This overview
├── user/                  # End-user guides
│   ├── getting-started.md # Quick deployment guide
│   └── configuration.md   # Environment configuration
├── admin/                 # Administrator guides
│   ├── docker-deployment-guide.md
│   ├── certificate-management.md
│   ├── security.md
│   ├── websocket-configuration.md
│   ├── prosodyctl-management.md
│   ├── port-configuration-guide.md
│   └── dns-setup.md
├── dev/                   # Developer documentation
│   ├── architecture.md
│   └── prosody-modern-features.md
└── reference/             # Technical reference
    ├── xep-compliance.md
    └── modules.md
```

---

**Need help?** Check the [Getting Started guide](user/getting-started.md) or [open an issue](https://github.com/allthingslinux/xmpp.atl.chat/issues).
