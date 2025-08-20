# 🛠️ Prosody Manager - Unified CLI Guide

The `prosody-manager` is a comprehensive command-line tool that provides unified management for your Prosody XMPP server. It consolidates all administrative tasks into a single, easy-to-use interface.

## 📋 Overview

The prosody-manager tool provides:

- **User Management** - Create, delete, and manage user accounts
- **Health Monitoring** - Check server status, ports, certificates, and configuration
- **Certificate Management** - Install, check, and renew SSL certificates
- **Backup Operations** - Create and restore server backups
- **Deployment Control** - Start, stop, restart services and view logs
- **Module Management** - Install, remove, and manage both official and community modules

## 🚀 Getting Started

### Basic Usage

```bash
# Show all available commands
./prosody-manager help

# Check server health
./prosody-manager health all

# Show version
./prosody-manager version
```

### Container Detection

The tool automatically detects whether it's running inside a container or needs to connect to a container:

- **Inside Container**: Runs commands directly
- **Outside Container**: Automatically connects to the appropriate Prosody container
- **Multiple Containers**: Intelligently selects the correct container name

## 👥 User Management

### Adding Users

```bash
# Interactive password prompt
./prosody-manager prosodyctl adduser alice@atl.chat

# With password (non-interactive)
./prosody-manager prosodyctl adduser alice@atl.chat secretpassword
```

### Managing Existing Users

```bash
# Change user password
./prosody-manager prosodyctl passwd alice@atl.chat

# Change password non-interactively
./prosody-manager prosodyctl passwd alice@atl.chat newpassword

# Delete user account
./prosody-manager prosodyctl deluser alice@atl.chat
```

### Server Status

```bash
# Check Prosody server status
./prosody-manager prosodyctl status

# Reload configuration
./prosody-manager prosodyctl reload

# Restart server (Docker environment)
./prosody-manager prosodyctl restart
```

## 🏥 Health Monitoring

### Comprehensive Health Checks

```bash
# Run all health checks
./prosody-manager health all

# Individual health checks
./prosody-manager health process    # Check if Prosody is running
./prosody-manager health ports      # Check if ports are listening
./prosody-manager health config     # Validate configuration
./prosody-manager health certs      # Check certificate status
```

### Health Check Details

- **Process Check**: Verifies Prosody is running and responding
- **Port Check**: Confirms ports 5222, 5269, and 5280 are listening
- **Config Check**: Validates Prosody configuration syntax
- **Certificate Check**: Verifies SSL certificate validity and expiration

## 🔐 Certificate Management

### Certificate Operations

```bash
# Check certificate status for a domain
./prosody-manager cert check atl.chat

# Install certificate for a domain
./prosody-manager cert install atl.chat

# Install certificate from specific file
./prosody-manager cert install atl.chat /path/to/certificate.crt

# Renew certificate
./prosody-manager cert renew atl.chat
```

### Certificate Integration

The tool integrates with:

- **Let's Encrypt** - Automatic certificate generation and renewal
- **Cloudflare DNS** - DNS-01 challenge support for wildcard certificates
- **Manual Certificates** - Support for custom certificate installation

## 💾 Backup and Restore

### Creating Backups

```bash
# Create backup with timestamp
./prosody-manager backup create

# Create backup with custom name
./prosody-manager backup create my-backup-name

# List available backups
./prosody-manager backup list
```

### Restoring Backups

```bash
# Restore from backup file
./prosody-manager backup restore backup-20231201-120000.tar.gz

# Interactive backup selection
./prosody-manager backup restore
```

### Backup Contents

Backups include:

- **Database** - All user accounts, rosters, and message archives
- **Configuration** - Server configuration files
- **Certificates** - SSL certificates and keys
- **Uploads** - File upload data
- **Logs** - Recent log files for troubleshooting

## 🚀 Deployment Management

### Service Control

```bash
# Start services
./prosody-manager deploy up

# Start minimal deployment (Prosody + Database only)
./prosody-manager deploy up minimal

# Start full deployment (all services)
./prosody-manager deploy up full

# Stop services
./prosody-manager deploy down

# Restart services
./prosody-manager deploy restart

# Restart specific service
./prosody-manager deploy restart prosody
```

### Monitoring Deployment

```bash
# Check deployment status
./prosody-manager deploy status

# View logs
./prosody-manager deploy logs

# View logs for specific service
./prosody-manager deploy logs prosody

# Follow logs in real-time
./prosody-manager deploy logs prosody -f
```

## 📦 Module Management

The prosody-manager supports two types of modules:

### Official Modules (LuaRocks)

```bash
# Install official module with automatic dependencies
./prosody-manager module rocks install mod_cloud_notify

# Remove official module
./prosody-manager module rocks remove mod_cloud_notify

# List installed official modules
./prosody-manager module rocks list

# Check for outdated official modules
./prosody-manager module rocks outdated
```

### Community Modules

```bash
# Install community module
./prosody-manager module install mod_pastebin

# Remove community module
./prosody-manager module remove mod_pastebin

# Search for modules
./prosody-manager module search push

# Get module information
./prosody-manager module info mod_cloud_notify
```

### Module Management Best Practices

**For Production:**

- Use official modules (`rocks install`) when available
- Official modules have automatic dependency management
- Better stability and support

**For Development:**

- Use community modules (`install`) for latest features
- Manual dependency management required
- Access to experimental features

### General Module Commands

```bash
# List all installed modules
./prosody-manager module list

# Update all modules
./prosody-manager module update

# Sync module repositories
./prosody-manager module sync
```

## ⚙️ Advanced Usage

### Environment Variables

```bash
# Enable debug output
DEBUG=true ./prosody-manager health all

# Set default domain
PROSODY_DOMAIN=atl.chat ./prosody-manager cert check

# Custom backup directory
BACKUP_DIR=/custom/backup/path ./prosody-manager backup create
```

### Integration with Scripts

```bash
#!/bin/bash
# Example automated backup script

# Create backup
BACKUP_FILE=$(./prosody-manager backup create | grep "Created:" | awk '{print $2}')

# Upload to remote storage
rsync "$BACKUP_FILE" user@backup-server:/backups/

# Clean up old backups
./prosody-manager backup list | tail -n +6 | xargs rm -f
```

### Health Check Automation

```bash
#!/bin/bash
# Example health monitoring script

if ! ./prosody-manager health all >/dev/null 2>&1; then
    echo "Health check failed!" | mail -s "XMPP Server Alert" admin@atl.chat
    ./prosody-manager deploy restart
fi
```

## 🔧 Troubleshooting

### Common Issues

**Container Not Found:**

```bash
# Check running containers
docker ps | grep prosody

# Specify container name explicitly
CONTAINER_NAME=custom-prosody ./prosody-manager health all
```

**Permission Issues:**

```bash
# Ensure proper permissions for certificates
./prosody-manager cert install atl.chat
```

**Configuration Errors:**

```bash
# Validate configuration
./prosody-manager health config

# Check Prosody logs
./prosody-manager deploy logs prosody
```

### Debug Mode

```bash
# Enable verbose output
DEBUG=true ./prosody-manager health all
```

## 📚 Command Reference

### Quick Reference

| Command | Description |
|---------|-------------|
| `prosodyctl adduser <user@domain>` | Add user account |
| `prosodyctl deluser <user@domain>` | Delete user account |
| `prosodyctl passwd <user@domain>` | Change user password |
| `health all` | Run all health checks |
| `cert check <domain>` | Check certificate status |
| `backup create` | Create server backup |
| `deploy up` | Start services |
| `module list` | List installed modules |

### Complete Command List

```bash
# User Management
./prosody-manager prosodyctl adduser <user@domain> [password]
./prosody-manager prosodyctl deluser <user@domain>
./prosody-manager prosodyctl passwd <user@domain> [password]
./prosody-manager prosodyctl status
./prosody-manager prosodyctl reload

# Health Monitoring
./prosody-manager health [process|ports|config|certs|all]

# Certificate Management
./prosody-manager cert check <domain>
./prosody-manager cert install <domain> [cert_path]
./prosody-manager cert renew <domain>

# Backup Management
./prosody-manager backup create [name]
./prosody-manager backup restore <backup_file>
./prosody-manager backup list

# Deployment Management
./prosody-manager deploy up [minimal|full]
./prosody-manager deploy down
./prosody-manager deploy restart [service]
./prosody-manager deploy logs [service]
./prosody-manager deploy status

# Module Management
./prosody-manager module list [filter]
./prosody-manager module search <query>
./prosody-manager module install <module>
./prosody-manager module remove <module>
./prosody-manager module update [module]
./prosody-manager module info <module>
./prosody-manager module sync
./prosody-manager module rocks install <module>
./prosody-manager module rocks remove <module>
./prosody-manager module rocks list
./prosody-manager module rocks outdated

# Utility Commands
./prosody-manager help
./prosody-manager version
```

## 🔗 Related Documentation

- [Configuration Guide](../../configuration.md) - Environment variable configuration
- [Module Management](../../reference/module-management.md) - Detailed module management
- [Certificate Management](certificate-management.md) - SSL certificate setup
- [Backup and Restore](backup-and-restore.md) - Backup procedures
- [Monitoring Setup](monitoring-setup.md) - Monitoring configuration

## 💡 Tips and Best Practices

1. **Regular Health Checks**: Run `./prosody-manager health all` regularly
2. **Automated Backups**: Set up cron jobs for regular backups
3. **Module Management**: Use official modules for production, community for development
4. **Certificate Monitoring**: Check certificate expiration regularly
5. **Log Monitoring**: Use `deploy logs` to monitor server activity
6. **Environment Variables**: Use `.env` file for consistent configuration

The prosody-manager tool is designed to make XMPP server administration simple and efficient. For additional help with any command, use `./prosody-manager <command> --help` or consult the related documentation sections.
