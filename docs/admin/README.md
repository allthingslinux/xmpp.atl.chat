# Administrator Documentation

Essential administration guides for Prosody XMPP Server operators.

## 🚀 Quick Start

For most administrative tasks, use the **unified CLI tool**:

```bash
# Show all available commands
./scripts/prosody-manager help

# User management
./scripts/prosody-manager prosodyctl adduser alice@example.com
./scripts/prosody-manager prosodyctl passwd alice@example.com

# Health monitoring
./scripts/prosody-manager health all

# Certificate management
./scripts/prosody-manager cert check example.com
./scripts/prosody-manager cert install example.com

# Backup operations
./scripts/prosody-manager backup create
./scripts/prosody-manager backup list

# Deployment management
./scripts/prosody-manager deploy status
./scripts/prosody-manager deploy logs prosody
```

## 📚 Administration Guides

### Essential Setup

- **[DNS Setup](dns-setup.md)** - Required DNS records (SRV, CAA, TLSA, DNSSEC)
- **[Certificate Management](certificate-management.md)** - SSL/TLS certificates, Let's Encrypt, renewal

### Security & Operations

- **[Security Hardening](security.md)** - Production security configuration and best practices

## 🔗 Related Documentation

- **[User Configuration](../user/configuration.md)** - Environment variables and deployment options
- **[Getting Started](../user/getting-started.md)** - Initial deployment walkthrough
- **[Architecture](../dev/architecture.md)** - System architecture and components

## 🛠️ Management Tools

### Prosody Manager CLI

The `prosody-manager` script provides unified access to all administrative functions:

- **User Management**: Add, remove, and manage user accounts
- **Health Monitoring**: Check service status, ports, certificates
- **Certificate Operations**: Install, check, and renew certificates
- **Backup Management**: Create and restore backups
- **Deployment Control**: Start, stop, restart services and view logs

### Docker Management

```bash
# View service status
docker compose ps

# View logs
docker compose logs -f prosody

# Restart services
docker compose restart prosody

# Update containers
docker compose pull && docker compose up -d
```

## 🆘 Troubleshooting

### Common Issues

**Service won't start:**

```bash
./scripts/prosody-manager health all
./scripts/prosody-manager deploy logs prosody
```

**Certificate issues:**

```bash
./scripts/prosody-manager cert check your-domain.com
./scripts/prosody-manager prosodyctl cert list
```

**Connection problems:**

```bash
./scripts/prosody-manager health ports
./scripts/prosody-manager prosodyctl status
```

### Support Resources

- **Configuration Validation**: `./scripts/prosody-manager health config`
- **Prosody Documentation**: <https://prosody.im/doc/>
- **XEP Compliance**: [Reference documentation](../reference/xep-compliance.md)
