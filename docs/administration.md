# 🛡️ Complete Administrator Guide

Comprehensive guide for XMPP server administrators using the unified `prosody-manager` CLI tool.

## 📋 Table of Contents

1. [Initial Setup](#-initial-setup)
2. [Daily Operations](#-daily-operations)
3. [User Management](#-user-management)
4. [Health Monitoring](#-health-monitoring)
5. [Certificate Management](#-certificate-management)
6. [Backup & Recovery](#-backup--recovery)
7. [Module Management](#-module-management)
8. [Security & Maintenance](#-security--maintenance)
9. [Troubleshooting](#-troubleshooting)
10. [Advanced Administration](#-advanced-administration)

## 🚀 Initial Setup

### Prerequisites Checklist

Before starting, ensure you have:

- **Domain name** with DNS control
- **DNS records** configured (detailed setup below)
- **Docker & Docker Compose** installed
- **SSL certificate** or Let's Encrypt access
- **Server resources**: 2GB+ RAM, 20GB+ storage

### DNS Configuration

**Required DNS Records:**

For clean domain separation (users get `@your-domain.com`, server runs on `xmpp.your-domain.com`):

```dns
# A record for XMPP server
xmpp.your-domain.com.    3600  IN  A     YOUR.SERVER.IP.ADDRESS

# SRV records for service delegation
_xmpp-client._tcp.your-domain.com.    3600  IN  SRV  0  5  5222  xmpp.your-domain.com.
_xmpp-server._tcp.your-domain.com.    3600  IN  SRV  0  5  5269  xmpp.your-domain.com.
_xmpps-client._tcp.your-domain.com.   3600  IN  SRV  0  5  5223  xmpp.your-domain.com.
_xmpps-server._tcp.your-domain.com.   3600  IN  SRV  0  5  5270  xmpp.your-domain.com.

# MUC service delegation
_xmpp-server._tcp.muc.your-domain.com.    3600  IN  SRV  0  5  5269  xmpp.your-domain.com.
```

**Security DNS Records:**

```dns
# CAA records (Certificate Authority Authorization)
your-domain.com. CAA 0 issue "letsencrypt.org"
your-domain.com. CAA 0 iodef "mailto:admin@your-domain.com"

# TLSA records (for DANE) - generated after certificate installation
_5222._tcp.your-domain.com. TLSA 3 1 1 <certificate-sha256-hash>
_5269._tcp.your-domain.com. TLSA 3 1 1 <certificate-sha256-hash>
```

**DNS Verification:**

```bash
# Test SRV records
dig SRV _xmpp-client._tcp.your-domain.com
dig SRV _xmpp-server._tcp.your-domain.com

# Test with prosody
./prosody-manager prosodyctl check dns your-domain.com
```

### First-Time Deployment

**1. Clone and Setup:**

```bash
git clone https://github.com/allthingslinux/xmpp.atl.chat.git
cd xmpp.atl.chat
./prosody-manager setup
```

**2. Configure Environment:**

```bash
cp templates/env/env.example .env
nano .env  # Configure your domain and credentials
```

**3. Start Services:**

```bash
# Production deployment
docker-compose up -d

# Verify services
./prosody-manager deploy status
```

**4. Initial Configuration:**

```bash
# Run health check
./prosody-manager health

# Create admin user
./prosody-manager prosodyctl adduser admin@your-domain.com

# Install SSL certificate
./prosody-manager cert install your-domain.com
```

### Post-Deployment Verification

```bash
# Comprehensive health check
./prosody-manager health --all

# Test user creation
./prosody-manager prosodyctl adduser test@your-domain.com

# Verify external connectivity
./prosody-manager health --ports --external
```

## ⚙️ Daily Operations

### Essential Daily Commands

**Quick Status Check:**

```bash
# Overall system health
./prosody-manager health

# Service status
./prosody-manager deploy status

# Recent logs
./prosody-manager deploy logs --tail 50
```

**User Operations:**

```bash
# List recent users
./prosody-manager user list --recent

# Check user activity
./prosody-manager user activity

# Handle user issues
./prosody-manager user reset-password username@domain.com
```

**System Monitoring:**

```bash
# Resource usage
./prosody-manager health --resources

# Database status
./prosody-manager health --database

# Certificate expiry
./prosody-manager cert check --all
```

### Weekly Maintenance Tasks

**Certificate Management:**

```bash
# Check certificate expiry
./prosody-manager cert check --expiry

# Renew if needed
./prosody-manager cert renew --auto
```

**Backup Operations:**

```bash
# Create weekly backup
./prosody-manager backup create --type weekly

# Clean old backups
./prosody-manager backup cleanup --older-than 30d
```

**Health Monitoring:**

```bash
# Generate weekly report
./prosody-manager health --report --email admin@domain.com

# Check for module updates
./prosody-manager module update --check
```

## 👥 User Management

### Creating Users

**Standard User Creation:**

```bash
# Create regular user (interactive password prompt)
./prosody-manager prosodyctl adduser username@domain.com

# Create with specific password
./prosody-manager prosodyctl adduser username@domain.com password123

# Create admin user (same command, admin privileges set in config)
./prosody-manager prosodyctl adduser admin@domain.com
```

### Managing Existing Users

**User Modifications:**

```bash
# Change user password (interactive prompt)
./prosody-manager prosodyctl passwd username@domain.com

# Change user password (with password)
./prosody-manager prosodyctl passwd username@domain.com newpassword123

# Delete user
./prosody-manager prosodyctl deluser username@domain.com

# Check Prosody status (shows connected users)
./prosody-manager prosodyctl status
```

## 🔍 Health Monitoring

### System Health Checks

**Comprehensive Health Check:**

```bash
# Full system health
./prosody-manager health all

# Specific components
./prosody-manager health config
./prosody-manager health ports
./prosody-manager health certs
./prosody-manager health process
```

### Log Management

**Log Analysis:**

```bash
# View real-time logs
./prosody-manager deploy logs --follow

# Search logs
./prosody-manager logs search "error" --last 24h

# Export logs
./prosody-manager logs export --date 2024-01-01 --format json
```

**Log Rotation:**

```bash
# Configure log rotation
./prosody-manager logs rotate --size 100MB --keep 30

# Compress old logs
./prosody-manager logs compress --older-than 7d
```

## 🔐 Certificate Management

### SSL/TLS Certificate Operations

**Certificate Installation:**

```bash
# Install certificate for domain
./prosody-manager cert install domain.com

# Install certificate from specific path
./prosody-manager cert install domain.com /path/to/certs

# Generate self-signed certificate
./prosody-manager prosodyctl cert generate domain.com
```

**Certificate Monitoring:**

```bash
# Check certificate status for domain
./prosody-manager cert check domain.com

# List certificates
./prosody-manager prosodyctl cert list

# Import certificate
./prosody-manager prosodyctl cert import domain.com
```

**Certificate Renewal:**

```bash
# Renew certificate for domain
./prosody-manager cert renew domain.com
```

### Certificate Troubleshooting

**Common Certificate Issues:**

```bash
# Fix certificate permissions
./prosody-manager cert fix-permissions

# Regenerate certificate
./prosody-manager cert regenerate

# Check certificate validation
./prosody-manager cert validate --external
```

**Certificate Backup:**

```bash
# Backup certificates
./prosody-manager cert backup

# Restore certificates
./prosody-manager cert restore /path/to/backup
```

## 💾 Backup & Recovery

### Backup Operations

**Creating Backups:**

```bash
# Create backup with default name
./prosody-manager backup create

# Create backup with custom name
./prosody-manager backup create my_backup_name

# List available backups
./prosody-manager backup list
```

### Recovery Operations

**Restore from Backup:**

```bash
# Restore from backup file
./prosody-manager backup restore backup-2024-01-01.tar.gz
```

**Disaster Recovery:**

```bash
# Emergency restore
./prosody-manager recovery emergency --backup /path/to/backup

# Rebuild from configuration
./prosody-manager recovery rebuild --config-only

# Migrate to new server
./prosody-manager recovery migrate --source old-server --target new-server
```

## 🧩 Module Management

### Installing Modules

**Module Management:**

```bash
# List installed modules
./prosody-manager module list

# Search for modules
./prosody-manager module search cloud

# Install module
./prosody-manager module install mod_cloud_notify

# Remove module
./prosody-manager module remove mod_cloud_notify

# Update modules
./prosody-manager module update

# Show module information
./prosody-manager module info mod_cloud_notify

# Sync module repository
./prosody-manager module sync
```

### Module Management

**Module Information:**

```bash
# List installed modules
./prosody-manager module list

# Show module details
./prosody-manager module info mod_mam

# Check module dependencies
./prosody-manager module deps mod_http_upload
```

**Module Updates:**

```bash
# Check for updates
./prosody-manager module update --check

# Update specific module
./prosody-manager module update mod_cloud_notify

# Update all modules
./prosody-manager module update --all
```

### Custom Module Development

**Development Tools:**

```bash
# Create module template
./prosody-manager module create --name mod_custom --template basic

# Test module
./prosody-manager module test mod_custom

# Package module
./prosody-manager module package mod_custom
```

## 🔒 Security & Maintenance

### Security Hardening

**Transport Layer Security:**

Configure strong TLS settings in your `.env` file:

```bash
# TLS Configuration
PROSODY_TLS_VERSION=1.3                    # Minimum TLS 1.3
PROSODY_TLS_FALLBACK=1.2                   # TLS 1.2 fallback
PROSODY_CERT_VALIDATION=strict             # Strict certificate validation
PROSODY_S2S_SECURE_AUTH=true              # Secure server-to-server
PROSODY_S2S_REQUIRE_ENCRYPTION=true       # Require S2S encryption
```

**Authentication Security:**

```bash
# Strong authentication settings
PROSODY_AUTH_METHOD=internal_hashed        # SCRAM-SHA-256
PROSODY_PASSWORD_MIN_LENGTH=12             # 12+ character passwords
PROSODY_AUTH_FAIL_THRESHOLD=5              # Block after 5 failures
PROSODY_AUTH_LOCKOUT_DURATION=300          # 5-minute lockout
PROSODY_MFA_ENABLED=true                   # Multi-factor authentication
```

**Network Security:**

```bash
# Firewall configuration (UFW example)
sudo ufw allow 5222/tcp                    # Client connections
sudo ufw allow 5269/tcp                    # Server connections
sudo ufw allow 80/tcp                      # HTTP (cert validation)
sudo ufw allow 443/tcp                     # HTTPS
sudo ufw enable

# Rate limiting in .env
PROSODY_MAX_CLIENTS_PER_IP=10
PROSODY_CONNECTION_THROTTLE=true
PROSODY_C2S_RATE_LIMIT=10kb/s
PROSODY_S2S_RATE_LIMIT=30kb/s
```

**Anti-Spam Protection:**

```bash
# DNS blocklists in .env
PROSODY_DNSBL_ENABLED=true
PROSODY_DNSBL_SERVERS=zen.spamhaus.org,xbl.spamhaus.org
PROSODY_DNSBL_ACTION=reject

# Registration controls
PROSODY_ALLOW_REGISTRATION=false
PROSODY_INVITE_ONLY=true
PROSODY_REGISTRATION_CAPTCHA=true
```

### Security Monitoring

**Real-time Monitoring:**

```bash
# Check overall health including security
./prosody-manager health all

# Monitor authentication failures
./prosody-manager deploy logs | grep -i "auth.*fail"

# Check blocked connections
./prosody-manager deploy logs | grep -i "blocked\|denied"

# View recent security events
./prosody-manager deploy logs --since 1h | grep -E "(fail|error|denied|blocked)"
```

**Security Auditing:**

```bash
# Enable comprehensive logging in .env
PROSODY_AUDIT_ENABLED=true
PROSODY_AUDIT_EVENTS=auth,admin,security,compliance
PROSODY_AUDIT_FORMAT=json
PROSODY_LOG_RETENTION=90d
PROSODY_SECURITY_LOG_RETENTION=1y

# Check security metrics
curl http://localhost:5280/metrics | grep -i security
```

### System Maintenance

**Regular Updates:**

```bash
# Update containers
docker-compose pull && docker-compose up -d

# Check certificate status
./prosody-manager cert check your-domain.com

# Renew certificates if needed
./prosody-manager cert renew your-domain.com
```

**Database Maintenance:**

```bash
# Check database health
./prosody-manager health all | grep -i database

# View database logs
./prosody-manager deploy logs postgres

# Backup database
./prosody-manager backup create
```

**Performance Monitoring:**

```bash
# Check resource usage
./prosody-manager health all

# Monitor service status
./prosody-manager deploy status

# View system metrics
curl http://localhost:5280/metrics
```

## 🔧 Troubleshooting

### Common Issues

**Connection Problems:**

```bash
# Diagnose connection issues
./prosody-manager diagnose connection

# Test external connectivity
./prosody-manager diagnose external --domain domain.com

# Check port accessibility
./prosody-manager diagnose ports
```

**Performance Issues:**

```bash
# Analyze performance bottlenecks
./prosody-manager diagnose performance

# Check resource usage
./prosody-manager diagnose resources

# Database performance analysis
./prosody-manager diagnose database --performance
```

**Configuration Issues:**

```bash
# Validate configuration
./prosody-manager diagnose config

# Check module conflicts
./prosody-manager diagnose modules

# Test configuration changes
./prosody-manager config test
```

### Diagnostic Tools

**System Diagnostics:**

```bash
# Generate diagnostic report
./prosody-manager diagnose --full --output /tmp/diagnostic-report.txt

# Network diagnostics
./prosody-manager diagnose network

# SSL/TLS diagnostics
./prosody-manager diagnose tls
```

**Log Analysis:**

```bash
# Analyze error patterns
./prosody-manager logs analyze --errors

# Find performance issues
./prosody-manager logs analyze --performance

# Generate log summary
./prosody-manager logs summary --last 24h
```

## 🎛️ Advanced Administration

### Configuration Management

**Configuration Templates:**

```bash
# Export current configuration
./prosody-manager config export --template

# Apply configuration template
./prosody-manager config apply --template production

# Compare configurations
./prosody-manager config diff --source current --target template
```

**Environment Management:**

```bash
# Manage multiple environments
./prosody-manager env create staging

# Switch environments
./prosody-manager env switch production

# Clone environment
./prosody-manager env clone production staging
```

### Integration & APIs

**API Management:**

```bash
# Enable admin API
./prosody-manager api enable --admin

# Create API keys
./prosody-manager api key create --name monitoring --permissions read

# Configure webhooks
./prosody-manager api webhook --url https://monitoring.example.com/webhook
```

**External Integrations:**

```bash
# Setup LDAP integration
./prosody-manager integration ldap --server ldap.company.com

# Configure monitoring integration
./prosody-manager integration monitoring --prometheus --grafana

# Setup backup integration
./prosody-manager integration backup --s3 --bucket backups
```

### Scaling & High Availability

**Load Balancing:**

```bash
# Configure load balancer
./prosody-manager scale loadbalancer --enable

# Add backend servers
./prosody-manager scale add-backend server2.domain.com

# Health check configuration
./prosody-manager scale healthcheck --interval 30s
```

**Database Clustering:**

```bash
# Setup database replication
./prosody-manager database replicate --master db1 --slave db2

# Configure database failover
./prosody-manager database failover --enable

# Monitor database cluster
./prosody-manager database cluster-status
```

## 📊 Reporting & Analytics

### Usage Reports

**Generate Reports:**

```bash
# User activity report
./prosody-manager report users --monthly

# Message statistics
./prosody-manager report messages --weekly

# Resource usage report
./prosody-manager report resources --daily
```

**Custom Analytics:**

```bash
# Export data for analysis
./prosody-manager analytics export --format csv --period last-month

# Generate custom queries
./prosody-manager analytics query "SELECT COUNT(*) FROM messages WHERE date > '2024-01-01'"
```

### Compliance & Auditing

**Compliance Reports:**

```bash
# GDPR compliance report
./prosody-manager compliance gdpr --user username@domain.com

# Security compliance audit
./prosody-manager compliance security --standard iso27001

# Data retention report
./prosody-manager compliance retention --check
```

## 🆘 Emergency Procedures

### Emergency Response

**Service Recovery:**

```bash
# Emergency restart
./prosody-manager emergency restart

# Safe mode startup
./prosody-manager emergency safe-mode

# Rollback to last known good
./prosody-manager emergency rollback
```

**Data Recovery:**

```bash
# Emergency backup
./prosody-manager emergency backup

# Restore from emergency backup
./prosody-manager emergency restore

# Data integrity check
./prosody-manager emergency verify-data
```

### Incident Management

**Incident Response:**

```bash
# Create incident report
./prosody-manager incident create --severity critical --description "Database connection lost"

# Update incident status
./prosody-manager incident update INC-001 --status investigating

# Close incident
./prosody-manager incident close INC-001 --resolution "Database restored from backup"
```

---

## 📚 Additional Resources

- **[prosody-manager Reference](prosody-manager-guide.md)** - Complete CLI tool documentation
- **[Security Guide](security.md)** - Detailed security configuration
- **[DNS Setup](dns-setup.md)** - DNS configuration requirements
- **[Certificate Management](certificate-management.md)** - SSL/TLS certificate details
- **[Configuration Reference](../../reference/configuration-reference.md)** - Complete configuration options

---

*This guide covers comprehensive server administration using the unified prosody-manager tool. For specific technical details, refer to the reference documentation.*
