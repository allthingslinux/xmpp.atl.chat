# Prosodyctl Management

This document describes the enhanced `prosodyctl-manager.sh` script which provides a comprehensive wrapper around Prosody's `prosodyctl` utility.

## Overview

The `prosodyctl-manager.sh` script leverages all available `prosodyctl` features to provide enhanced server management, health monitoring, and administrative capabilities for your Prosody XMPP server.

## Features

### User Management

- **Add Users**: Create new user accounts with proper JID validation
- **Password Management**: Securely change user passwords
- **User Deletion**: Remove user accounts with confirmation prompts

### Process Management

- **Status Monitoring**: Check Prosody service status
- **Configuration Reload**: Reload configuration without service restart

### Comprehensive Health Checks

- **Configuration Validation**: Syntax and semantic configuration checks
- **Feature Analysis**: Identify missing or unconfigured features
- **DNS Verification**: Validate DNS records against configured domains
- **Certificate Monitoring**: Check certificate validity and expiration
- **Connectivity Testing**: External connectivity validation via observe.jabber.network
- **Component Status**: Report on disabled VirtualHosts and Components
- **TURN Configuration**: Validate TURN/STUN server configuration

### Certificate Management

- **Self-Signed Generation**: Create development certificates
- **Certificate Import**: Import production certificates with proper validation

### Plugin Management

- **Plugin Installation**: Install community plugins via Plugin Installer
- **Plugin Removal**: Safely remove installed plugins
- **Plugin Listing**: View all installed plugins

### Administrative Tools

- **System Information**: Display installation details and versions
- **Console Access**: Secure connection to Prosody's administrative console

## Usage

### Basic Commands

```bash
# Check overall system health
./scripts/prosodyctl-manager.sh check

# Add a new user
./scripts/prosodyctl-manager.sh adduser admin@example.com

# Check server status
./scripts/prosodyctl-manager.sh status

# Reload configuration
./scripts/prosodyctl-manager.sh reload
```

### Health Monitoring

```bash
# Comprehensive health check
./scripts/prosodyctl-manager.sh check

# Individual checks
./scripts/prosodyctl-manager.sh check-config
./scripts/prosodyctl-manager.sh check-dns
./scripts/prosodyctl-manager.sh check-certs
./scripts/prosodyctl-manager.sh check-connectivity
```

### Certificate Management

```bash
# Generate self-signed certificate
./scripts/prosodyctl-manager.sh cert generate example.com

# Import Let's Encrypt certificate
./scripts/prosodyctl-manager.sh cert import example.com /path/to/cert
```

### Plugin Management

```bash
# Install a plugin
./scripts/prosodyctl-manager.sh install mod_carbons

# Remove a plugin
./scripts/prosodyctl-manager.sh remove mod_carbons

# List installed plugins
./scripts/prosodyctl-manager.sh list-plugins
```

## Environment Variables

The script supports several environment variables for configuration:

| Variable | Description | Default |
|----------|-------------|---------|
| `PROSODY_CONFIG` | Alternative config file path | System default |
| `PROSODY_DOMAIN` | Primary domain for checks | None |
| `PROSODY_ENABLE_TURN` | Enable TURN configuration checks | `false` |
| `STUN_SERVER` | STUN server for TURN testing | None |

### Examples with Environment Variables

```bash
# Run DNS check for specific domain
PROSODY_DOMAIN=example.com ./scripts/prosodyctl-manager.sh check-dns

# Use custom configuration file
PROSODY_CONFIG=/path/to/custom.cfg.lua ./scripts/prosodyctl-manager.sh check

# Test TURN with specific STUN server
PROSODY_ENABLE_TURN=true STUN_SERVER=stun.example.com ./scripts/prosodyctl-manager.sh check-turn
```

## Integration with Existing Scripts

The enhanced prosodyctl functionality has been integrated into existing management scripts:

### Health Check Integration

- `health-check.sh` now uses `prosodyctl status` for more reliable process monitoring
- Enhanced configuration validation includes features, certificates, and DNS checks

### Validation Enhancement

- `validate-config.sh` includes comprehensive prosodyctl-based validation
- Added DNS, features, disabled components, and TURN configuration checks

## Docker Usage

When running in Docker containers, ensure proper permissions and user context:

```bash
# Run as prosody user in container
docker exec -u prosody prosody_container ./scripts/prosodyctl-manager.sh check

# With environment variables
docker exec -e PROSODY_DOMAIN=example.com prosody_container ./scripts/prosodyctl-manager.sh check-dns
```

## Monitoring and Automation

### Health Check Automation

```bash
# Add to cron for regular health monitoring
0 */6 * * * /path/to/prosodyctl-manager.sh check > /var/log/prosody-health.log 2>&1
```

### Alert Integration

The script returns appropriate exit codes for integration with monitoring systems:

- `0`: All checks passed
- `1`: Critical checks failed
- `2`: Configuration errors

## Security Considerations

### Permissions

- The script requires appropriate permissions to read Prosody configuration
- User management operations require elevated privileges
- Certificate operations need write access to certificate directories

### User Context

- Run as the same user that Prosody runs as
- Use `sudo` when necessary for system-level operations
- Ensure proper file ownership for generated certificates

## Troubleshooting

### Common Issues

1. **prosodyctl not found**
   - Ensure Prosody is properly installed
   - Check PATH includes Prosody installation directory

2. **Permission denied**
   - Run with appropriate user privileges
   - Use `--root` flag when running as root

3. **Configuration validation failures**
   - Check configuration syntax with `check-config`
   - Review log files for detailed error messages

### Debug Mode

Enable verbose output by setting environment variables:

```bash
DEBUG=true ./scripts/prosodyctl-manager.sh check
```

## Related Documentation

- [Prosody Official prosodyctl Documentation](https://prosody.im/doc/prosodyctl)
- [Certificate Management](certificate-management.md)
- [Security Configuration](security.md)
- [DNS Setup](dns-setup.md)

## Contributing

When extending the prosodyctl-manager.sh script:

1. Follow the existing logging patterns
2. Include proper error handling
3. Update this documentation
4. Test with various environment configurations
5. Ensure compatibility with Docker deployments
