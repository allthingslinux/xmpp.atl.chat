# Prosody Directory Structure Analysis

## Executive Summary

This analysis examines the directory and file organization patterns across 42 XMPP/Prosody implementations, revealing best practices for configuration management, data organization, and deployment structures. The analysis identifies optimal patterns for maintainability, security, and scalability.

## Directory Structure Patterns

### 1. Traditional Debian/Ubuntu Layout ⭐⭐⭐⭐

**Representatives**: Official packages, LinuxBabe tutorials, DigitalOcean guides

**Structure**:
```
/etc/prosody/
├── prosody.cfg.lua              # Main configuration
├── certs/                       # SSL certificates
│   ├── domain.com.crt
│   ├── domain.com.key
│   └── localhost.crt
├── conf.d/                      # Additional configurations
│   ├── domain1.cfg.lua
│   └── domain2.cfg.lua
└── conf.avail/                  # Available configurations
    ├── example.cfg.lua
    └── template.cfg.lua

/var/lib/prosody/                # Data directory
├── accounts/                    # User accounts
├── roster/                      # Contact lists
├── offline/                     # Offline messages
├── private/                     # Private XML storage
└── prosody.sqlite              # Database file

/var/log/prosody/               # Log files
├── prosody.log
└── prosody.err

/usr/lib/prosody/               # Program files
├── modules/                    # Core modules
├── net/                        # Network libraries
├── util/                       # Utilities
└── prosody                     # Main executable
```

**Advantages**:
- Standard Linux filesystem hierarchy
- Clear separation of concerns
- Package manager friendly
- Well-documented permissions

### 2. Docker Container Layout ⭐⭐⭐⭐⭐

**Representatives**: SaraSmiseth/prosody, prosody/prosody-docker, tobi312/prosody

**Structure**:
```
/opt/prosody/                   # Application root
├── config/                     # Configuration
│   ├── prosody.cfg.lua
│   ├── modules.d/              # Modular configs
│   │   ├── core.cfg.lua
│   │   ├── security.cfg.lua
│   │   └── features.cfg.lua
│   └── templates/              # Config templates
│       ├── virtualhost.lua.tpl
│       └── component.lua.tpl
├── data/                       # Persistent data
│   ├── accounts/
│   ├── uploads/                # HTTP file uploads
│   ├── archives/               # Message archives
│   └── prosody.sqlite
├── certs/                      # SSL certificates
│   ├── auto/                   # Auto-generated
│   └── custom/                 # User-provided
├── logs/                       # Log files
│   ├── prosody.log
│   └── error.log
├── modules/                    # Modules
│   ├── core/                   # Core modules
│   ├── community/              # Community modules
│   └── custom/                 # Custom modules
└── scripts/                    # Helper scripts
    ├── entrypoint.sh
    ├── setup.sh
    └── backup.sh

# Volume mounts
/prosody/config -> /opt/prosody/config
/prosody/data   -> /opt/prosody/data
/prosody/certs  -> /opt/prosody/certs
/prosody/logs   -> /opt/prosody/logs
```

**Advantages**:
- Clear volume separation
- Easy backup strategies
- Development/production parity
- Container best practices

### 3. Enterprise/Multi-Tenant Layout ⭐⭐⭐⭐⭐

**Representatives**: prose-im/prose-pod-server, OpusVL/prosody-docker

**Structure**:
```
/srv/prosody/                   # Service root
├── config/
│   ├── global/                 # Global configuration
│   │   ├── prosody.cfg.lua
│   │   ├── security.cfg.lua
│   │   └── monitoring.cfg.lua
│   ├── hosts/                  # Per-host configs
│   │   ├── domain1.com.cfg.lua
│   │   ├── domain2.com.cfg.lua
│   │   └── admin.domain.cfg.lua
│   ├── components/             # Component configs
│   │   ├── muc.cfg.lua
│   │   ├── upload.cfg.lua
│   │   └── proxy.cfg.lua
│   └── includes/               # Shared includes
│       ├── ssl.cfg.lua
│       └── modules.cfg.lua
├── data/
│   ├── global/                 # Global data
│   │   ├── prosody.sqlite
│   │   └── statistics/
│   ├── hosts/                  # Per-host data
│   │   ├── domain1.com/
│   │   │   ├── accounts/
│   │   │   ├── roster/
│   │   │   └── archives/
│   │   └── domain2.com/
│   └── uploads/                # Shared uploads
│       ├── domain1.com/
│       └── domain2.com/
├── certs/
│   ├── ca/                     # CA certificates
│   ├── domains/                # Domain certificates
│   │   ├── domain1.com/
│   │   │   ├── fullchain.pem
│   │   │   └── privkey.pem
│   │   └── domain2.com/
│   └── admin/                  # Admin certificates
├── logs/
│   ├── global/                 # Global logs
│   │   ├── prosody.log
│   │   └── security.log
│   ├── hosts/                  # Per-host logs
│   │   ├── domain1.com.log
│   │   └── domain2.com.log
│   └── components/             # Component logs
│       ├── muc.log
│       └── upload.log
├── modules/
│   ├── core/                   # Core modules
│   ├── enterprise/             # Enterprise modules
│   ├── community/              # Community modules
│   └── custom/                 # Custom modules
├── scripts/
│   ├── deployment/             # Deployment scripts
│   ├── maintenance/            # Maintenance scripts
│   ├── monitoring/             # Monitoring scripts
│   └── backup/                 # Backup scripts
└── templates/
    ├── nginx/                  # Nginx configs
    ├── systemd/                # Systemd services
    └── docker/                 # Docker configs
```

**Advantages**:
- Scalable multi-tenant architecture
- Clear separation of concerns
- Enterprise monitoring support
- Professional deployment structure

### 4. Development/Testing Layout ⭐⭐⭐

**Representatives**: slidge/prosody-dev-container, community development setups

**Structure**:
```
prosody-dev/
├── src/                        # Source code
│   ├── prosody/               # Main prosody source
│   ├── modules/               # Custom modules
│   └── patches/               # Local patches
├── config/
│   ├── development.cfg.lua    # Dev configuration
│   ├── testing.cfg.lua        # Test configuration
│   └── production.cfg.lua     # Production template
├── data/
│   ├── dev/                   # Development data
│   ├── test/                  # Test data
│   └── fixtures/              # Test fixtures
├── tests/
│   ├── unit/                  # Unit tests
│   ├── integration/           # Integration tests
│   └── e2e/                   # End-to-end tests
├── tools/
│   ├── dev-server.sh          # Development server
│   ├── run-tests.sh           # Test runner
│   └── deploy.sh              # Deployment script
├── docs/
│   ├── api/                   # API documentation
│   ├── config/                # Configuration docs
│   └── deployment/            # Deployment guides
└── docker/
    ├── Dockerfile.dev         # Development image
    ├── Dockerfile.test        # Testing image
    └── docker-compose.yml     # Development stack
```

### 5. Minimal/Embedded Layout ⭐⭐⭐

**Representatives**: etherfoundry/prosody-docker, basic implementations

**Structure**:
```
/prosody/
├── prosody.cfg.lua            # Single config file
├── data/                      # Data directory
│   └── prosody.sqlite
├── certs/                     # Certificates
│   ├── cert.pem
│   └── key.pem
├── modules/                   # Basic modules
└── prosody.log               # Single log file
```

**Advantages**:
- Minimal footprint
- Simple deployment
- Easy to understand
- Resource efficient

## Configuration File Organization Patterns

### 1. Monolithic Configuration ⭐⭐

**Pattern**: Single large configuration file
```lua
-- prosody.cfg.lua (500+ lines)
-- Global settings
admins = { "admin@domain.com" }
modules_enabled = { ... }

-- VirtualHost definitions
VirtualHost "domain.com"
    ssl = { ... }

-- Component definitions  
Component "muc.domain.com" "muc"
    modules_enabled = { ... }
```

**Limitations**:
- Difficult to maintain
- No modularity
- Version control conflicts
- Hard to debug

### 2. Modular Configuration ⭐⭐⭐⭐⭐

**Pattern**: Separated configuration files by function
```lua
-- prosody.cfg.lua (main file)
Include "/etc/prosody/conf.d/*.cfg.lua"

-- conf.d/global.cfg.lua
admins = { "admin@domain.com" }
modules_enabled = { ... }

-- conf.d/ssl.cfg.lua
ssl = {
    key = "/etc/prosody/certs/domain.key";
    certificate = "/etc/prosody/certs/domain.crt";
}

-- conf.d/domain.com.cfg.lua
VirtualHost "domain.com"
    Include "/etc/prosody/includes/ssl.cfg.lua"

-- conf.d/components.cfg.lua
Component "muc.domain.com" "muc"
    name = "Multi-user chat"
```

**Advantages**:
- Easy to maintain
- Modular updates
- Clear separation
- Reusable components

### 3. Template-Based Configuration ⭐⭐⭐⭐

**Pattern**: Configuration generated from templates
```lua
-- templates/virtualhost.lua.tpl
VirtualHost "{{ domain }}"
{% if ssl_enabled %}
    ssl = {
        key = "/etc/prosody/certs/{{ domain }}.key";
        certificate = "/etc/prosody/certs/{{ domain }}.crt";
    }
{% endif %}
{% for module in enabled_modules %}
    "{{ module }}",
{% endfor %}
```

**Generated Configuration**:
```lua
-- generated/domain.com.cfg.lua
VirtualHost "domain.com"
    ssl = {
        key = "/etc/prosody/certs/domain.com.key";
        certificate = "/etc/prosody/certs/domain.com.crt";
    }
    modules_enabled = {
        "mam", "carbons", "smacks"
    }
```

## Data Organization Patterns

### 1. Flat File Structure ⭐⭐

**Pattern**: All data in single directory
```
/var/lib/prosody/
├── accounts.dat
├── roster.dat
├── offline.dat
├── private.dat
└── vcard.dat
```

### 2. Hierarchical Structure ⭐⭐⭐⭐

**Pattern**: Organized by domain and data type
```
/var/lib/prosody/
├── domain.com/
│   ├── accounts/
│   │   ├── user1.dat
│   │   └── user2.dat
│   ├── roster/
│   │   ├── user1.dat
│   │   └── user2.dat
│   └── archives/
│       ├── user1/
│       └── user2/
└── muc.domain.com/
    ├── rooms/
    └── archives/
```

### 3. Database-Centric Structure ⭐⭐⭐⭐⭐

**Pattern**: SQL database with file supplements
```
/var/lib/prosody/
├── prosody.sqlite             # Main database
├── uploads/                   # File uploads
│   ├── domain.com/
│   │   ├── 2024/01/
│   │   └── 2024/02/
│   └── muc.domain.com/
└── backups/                   # Database backups
    ├── daily/
    └── weekly/
```

## Certificate Management Patterns

### 1. Manual Certificate Management ⭐⭐

**Pattern**: Manually placed certificates
```
/etc/prosody/certs/
├── domain.com.crt
├── domain.com.key
├── muc.domain.com.crt
└── muc.domain.com.key
```

### 2. Automated Certificate Management ⭐⭐⭐⭐⭐

**Pattern**: Let's Encrypt integration with automation
```
/etc/prosody/certs/
├── auto/                      # Auto-generated
│   ├── domain.com/
│   │   ├── fullchain.pem
│   │   ├── privkey.pem
│   │   └── cert.pem
│   └── muc.domain.com/
├── manual/                    # Manually provided
└── scripts/
    ├── renew.sh              # Renewal script
    └── deploy.sh             # Deployment script
```

### 3. Centralized Certificate Management ⭐⭐⭐⭐

**Pattern**: Certificate distribution from central authority
```
/etc/prosody/certs/
├── ca/                       # Certificate authority
│   ├── ca.crt
│   └── ca.key
├── issued/                   # Issued certificates
│   ├── domain.com/
│   └── muc.domain.com/
├── pending/                  # Pending requests
└── revoked/                  # Revoked certificates
```

## Best Practices Identified

### 1. Volume Separation for Containers
```dockerfile
# Separate volumes for different data types
VOLUME ["/prosody/config"]     # Configuration
VOLUME ["/prosody/data"]       # User data
VOLUME ["/prosody/certs"]      # Certificates
VOLUME ["/prosody/logs"]       # Log files
VOLUME ["/prosody/uploads"]    # File uploads
```

### 2. Configuration Modularity
```
config/
├── prosody.cfg.lua           # Main config (includes only)
├── global/                   # Global settings
│   ├── core.cfg.lua
│   ├── security.cfg.lua
│   └── logging.cfg.lua
├── hosts/                    # Virtual hosts
│   ├── domain1.cfg.lua
│   └── domain2.cfg.lua
├── components/               # Components
│   ├── muc.cfg.lua
│   └── upload.cfg.lua
└── includes/                 # Shared includes
    ├── ssl.cfg.lua
    └── modules.cfg.lua
```

### 3. Data Organization by Domain
```
data/
├── global/                   # Server-wide data
│   ├── statistics/
│   └── prosody.sqlite
├── domains/                  # Per-domain data
│   ├── domain1.com/
│   │   ├── accounts/
│   │   ├── roster/
│   │   └── archives/
│   └── domain2.com/
└── uploads/                  # File uploads
    ├── domain1.com/
    └── domain2.com/
```

### 4. Security-Conscious Permissions
```bash
# Configuration files
chmod 644 /etc/prosody/*.cfg.lua
chown root:prosody /etc/prosody/

# Certificate files
chmod 640 /etc/prosody/certs/*.key
chmod 644 /etc/prosody/certs/*.crt
chown root:prosody /etc/prosody/certs/

# Data directory
chmod 750 /var/lib/prosody/
chown prosody:prosody /var/lib/prosody/

# Log files
chmod 640 /var/log/prosody/*.log
chown prosody:prosody /var/log/prosody/
```

### 5. Backup-Friendly Structure
```
backup/
├── config/                   # Configuration backup
│   ├── timestamp/
│   └── latest -> timestamp/
├── data/                     # Data backup
│   ├── full/                 # Full backups
│   └── incremental/          # Incremental backups
└── certs/                    # Certificate backup
    ├── current/
    └── archived/
```

## Implementation Recommendations

### For Small Personal Servers
```
/opt/prosody/
├── prosody.cfg.lua          # Single config file
├── data/                    # User data
│   └── prosody.sqlite
├── certs/                   # Let's Encrypt certs
│   ├── fullchain.pem
│   └── privkey.pem
├── uploads/                 # File uploads
└── logs/                    # Log files
    └── prosody.log
```

### For Family/Friends Servers
```
/srv/prosody/
├── config/
│   ├── prosody.cfg.lua      # Main config
│   ├── domains/             # Per-domain configs
│   └── components/          # Component configs
├── data/
│   ├── prosody.sqlite       # Main database
│   ├── uploads/             # File uploads
│   └── archives/            # Message archives
├── certs/                   # SSL certificates
└── logs/                    # Separated log files
```

### For Enterprise/Production
```
/srv/prosody/
├── config/
│   ├── global/              # Global configuration
│   ├── hosts/               # Virtual hosts
│   ├── components/          # Components
│   └── includes/            # Shared includes
├── data/
│   ├── global/              # Global data
│   ├── hosts/               # Per-host data
│   └── uploads/             # File uploads
├── certs/
│   ├── ca/                  # Certificate authority
│   ├── domains/             # Domain certificates
│   └── admin/               # Admin certificates
├── logs/
│   ├── global/              # Global logs
│   ├── hosts/               # Per-host logs
│   └── components/          # Component logs
├── modules/
│   ├── core/                # Core modules
│   ├── enterprise/          # Enterprise modules
│   └── custom/              # Custom modules
├── scripts/                 # Management scripts
└── backups/                 # Backup storage
```

## Conclusion

The analysis reveals that successful Prosody deployments use:

1. **Modular configuration** separated by function and domain
2. **Volume separation** for different data types in containers
3. **Hierarchical data organization** by domain and data type
4. **Automated certificate management** with proper permissions
5. **Backup-friendly structures** with clear separation

The most robust implementations (SaraSmiseth, prose-pod-server, enterprise setups) implement comprehensive directory structures that support scalability, maintainability, and security while remaining operationally simple. 