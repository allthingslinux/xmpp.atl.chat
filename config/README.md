# XMPP Server Configuration

This repository contains a comprehensive XMPP server configuration using **Prosody** with a modern **layer-based architecture**. The configuration is designed for production use with enterprise-grade features, security, and mobile optimization.

## Architecture Overview

The configuration follows the XMPP protocol stack layers for optimal organization and maintainability:

```
08 - Integration Layer    (LDAP, OAuth, Webhooks, APIs)
07 - Interfaces Layer     (HTTP, WebSocket, BOSH, Components)  
06 - Storage Layer        (Backends, Archiving, Caching, Migration)
05 - Services Layer       (Messaging, Presence, Groupchat, PubSub)
04 - Protocol Layer       (Core XMPP, Extensions, Legacy, Experimental)
03 - Stanza Layer         (Routing, Filtering, Validation, Processing)
02 - Stream Layer         (Authentication, Encryption, Management, Negotiation)
01 - Transport Layer      (Ports, TLS, Compression, Connections)
```

## Directory Structure

```
config/
├── prosody.cfg.lua              # Main configuration file
├── stack/                       # Layer-based configurations
│   ├── 01-transport/           # Network and transport layer
│   ├── 02-stream/              # Stream management and auth
│   ├── 03-stanza/              # Stanza processing
│   ├── 04-protocol/            # XMPP protocol features
│   ├── 05-services/            # Core XMPP services
│   ├── 06-storage/             # Data storage backends
│   ├── 07-interfaces/          # External interfaces
│   └── 08-integration/         # Third-party integrations
├── domains/                    # Domain-specific configurations
├── environments/               # Environment-specific settings
├── policies/                   # Security and compliance policies
├── tools/                      # Configuration utilities
└── firewall/                   # Firewall rules
```

## Quick Start

### 1. Environment Setup

Create your environment file:

```bash
cp examples/env.example .env
```

Edit `.env` with your specific settings:

```bash
# Core Configuration
PROSODY_DOMAIN=your-domain.com
PROSODY_ENV=production
PROSODY_DATA_PATH=/var/lib/prosody
PROSODY_CONFIG_PATH=/etc/prosody

# Security
PROSODY_ADMIN_JID=admin@your-domain.com
```

### 2. Docker Deployment

```bash
# Build and start the server
docker-compose up -d

# Check logs
docker-compose logs -f prosody
```

### 3. Configuration Validation

```bash
# Validate configuration
./scripts/validate-config.sh

# Test connectivity
./scripts/health-check.sh
```

## Configuration Layers

### Layer 01: Transport

- **Ports**: Standard XMPP ports (5222, 5269, 5280, 5281)
- **TLS**: Modern TLS 1.2+ with strong ciphers
- **Compression**: Stream compression for bandwidth optimization
- **Connections**: Connection limits and timeouts

### Layer 02: Stream

- **Authentication**: SASL mechanisms, SCRAM-SHA-256
- **Encryption**: Mandatory encryption for client/server connections
- **Management**: Stream resumption and acknowledgments
- **Negotiation**: Feature negotiation and capabilities

### Layer 03: Stanza

- **Routing**: Intelligent message routing
- **Filtering**: Content filtering and validation
- **Validation**: XML schema validation
- **Processing**: Stanza preprocessing and postprocessing

### Layer 04: Protocol

- **Core**: Essential XMPP features (RFC 6120/6121)
- **Extensions**: Modern XEPs for enhanced functionality
- **Legacy**: Backward compatibility features
- **Experimental**: Cutting-edge features for testing

### Layer 05: Services

- **Messaging**: One-to-one messaging with delivery receipts
- **Presence**: Rich presence with mood and activity
- **Groupchat**: Multi-user chat with advanced features
- **PubSub**: Publish-subscribe for real-time notifications

### Layer 06: Storage

- **Backends**: Multiple storage options (SQL, NoSQL)
- **Archiving**: Message archiving and retrieval (MAM)
- **Caching**: Performance optimization caching
- **Migration**: Data migration utilities

### Layer 07: Interfaces

- **HTTP**: Web-based administration and file uploads
- **WebSocket**: Modern web client connectivity
- **BOSH**: Legacy web client support
- **Components**: External component integration

### Layer 08: Integration

- **LDAP**: Enterprise directory integration
- **OAuth**: Modern authentication delegation
- **Webhooks**: External service notifications
- **APIs**: RESTful APIs for automation

## Environment Configuration

### Development Environment

- Debug logging enabled
- Relaxed security for testing
- Local certificate generation
- Hot-reload capabilities

### Production Environment

- Enhanced security policies
- Performance optimizations
- Comprehensive monitoring
- Backup automation

## Security Features

- **Modern TLS**: TLS 1.2+ with perfect forward secrecy
- **SASL SCRAM**: Secure authentication without plaintext
- **Rate Limiting**: Protection against abuse and DoS
- **Firewall Integration**: Advanced packet filtering
- **Certificate Management**: Automated Let's Encrypt integration

## Mobile Optimization

- **Push Notifications**: Native mobile push support
- **Stream Management**: Connection resumption for mobile networks
- **Carbons**: Message synchronization across devices
- **CSI**: Client state indication for battery optimization

## Compliance Features

- **GDPR**: Data protection and privacy controls
- **Message Archiving**: Configurable retention policies
- **Audit Logging**: Comprehensive audit trails
- **Data Export**: User data portability

## Monitoring and Administration

- **Prometheus Metrics**: Comprehensive server metrics
- **Health Checks**: Automated health monitoring
- **Admin Interface**: Web-based administration
- **Log Management**: Structured logging with rotation

## Customization

### Adding Custom Modules

1. Place modules in the appropriate layer directory
2. Add module configuration to the layer's config file
3. Restart Prosody to load new modules

### Environment-Specific Overrides

Create environment-specific files in `environments/`:

```lua
-- environments/staging.cfg.lua
log = {
    {levels = {min = "debug"}, to = "console"};
    {levels = {min = "info"}, to = "file", filename = "/var/log/prosody/staging.log"};
}
```

### Policy Customization

Modify policies in `policies/` directory:

- `security.cfg.lua` - Security policies
- `compliance.cfg.lua` - Compliance settings  
- `performance.cfg.lua` - Performance tuning

## Troubleshooting

### Common Issues

1. **Module Loading Errors**

   ```bash
   # Check module availability
   prosodyctl check config
   ```

2. **Certificate Issues**

   ```bash
   # Generate certificates
   ./scripts/generate-dhparam.sh
   ```

3. **Permission Problems**

   ```bash
   # Fix ownership
   chown -R prosody:prosody /var/lib/prosody
   ```

### Debug Mode

Enable debug logging:

```bash
export PROSODY_ENV=development
docker-compose restart prosody
```

## Performance Tuning

### High-Load Environments

- Adjust connection limits in transport layer
- Enable caching in storage layer
- Configure load balancing in interfaces layer
- Optimize database connections

### Resource Monitoring

Monitor key metrics:

- Memory usage and garbage collection
- Connection counts and rates
- Message throughput
- Storage performance

## Backup and Recovery

### Automated Backups

```bash
# Run backup script
./scripts/backup.sh
```

### Data Recovery

```bash
# Restore from backup
./scripts/restore.sh /path/to/backup
```

## Contributing

When modifying the configuration:

1. Follow the layer-based organization
2. Include XEP references in module descriptions [[memory:3030509]]
3. Use consistent module naming [[memory:3030813]]
4. Test changes in development environment
5. Update documentation accordingly

## Support

For issues and questions:

- Check the troubleshooting section
- Review Prosody documentation
- Consult XEP specifications for protocol details

---

**Note**: This configuration provides an "everything enabled" approach with intelligent organization. All features are available and can be fine-tuned through environment variables and policy configurations.
