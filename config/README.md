# Prosody Configuration Structure

This directory contains a modular Prosody XMPP server configuration designed for maintainability, scalability, and ease of management.

## 📁 **Directory Structure**

```text
config/
├── README.md                    # This file
├── prosody.cfg.lua             # Main configuration (includes all modules)
├── global.cfg.lua              # Global settings and performance
├── security.cfg.lua            # Security, TLS, and authentication
├── database.cfg.lua            # Storage backends and database
├── modules.cfg.lua             # Module management and loading
├── vhosts.cfg.lua              # Virtual host definitions
├── components.cfg.lua          # XMPP components (MUC, PubSub, etc.)
├── firewall/                   # Firewall rules and policies
│   └── anti-spam.pfw
└── modules.d/                  # Module-specific configurations
    ├── core/                   # Core Prosody modules
    │   └── core.cfg.lua
    └── community/              # Community modules by stability
        ├── stable/             # Production-ready third-party
        ├── beta/               # Mostly stable third-party
        └── alpha/              # Experimental third-party
```

## 🔧 **Configuration Modules**

### **Main Configuration (`prosody.cfg.lua`)**

- **Purpose**: Entry point that includes all modular configuration files
- **Size**: ~80 lines (down from 442 lines)
- **Content**: Include statements, validation, and documentation
- **Benefits**: Clean overview, easy to understand structure

### **Global Configuration (`global.cfg.lua`)**

- **Purpose**: Basic server settings, administrators, performance tuning
- **Includes**:
  - Administrator accounts management
  - Memory and garbage collection settings
  - Connection limits and rate limiting
  - Contact information and compliance
  - Logging configuration
- **When to modify**: Changing admins, performance tuning, logging setup

### **Security Configuration (`security.cfg.lua`)**

- **Purpose**: All security-related settings and policies
- **Includes**:
  - Encryption enforcement (C2S/S2S)
  - SASL authentication mechanisms
  - Modern TLS configuration
  - Firewall script loading
  - HTTP security headers
- **When to modify**: Security policy changes, TLS updates, firewall rules

### **Database Configuration (`database.cfg.lua`)**

- **Purpose**: Storage backend configuration and data management
- **Includes**:
  - SQL/SQLite database settings
  - Connection pooling configuration
  - Archive and storage policies
  - Backup and maintenance settings
- **When to modify**: Database changes, storage policies, performance tuning

### **Modules Configuration (`modules.cfg.lua`)**

- **Purpose**: Module loading logic and stability management
- **Includes**:
  - Core, official, and community module definitions
  - Environment-based module loading
  - Stability tracking and logging
  - Module configuration includes
- **When to modify**: Adding/removing modules, changing stability levels

### **Virtual Hosts Configuration (`vhosts.cfg.lua`)**

- **Purpose**: Virtual host definitions and host-specific settings
- **Includes**:
  - Main domain configuration
  - SSL certificate settings
  - Registration policies
  - HTTP services configuration
- **When to modify**: Adding domains, SSL changes, host-specific settings

### **Components Configuration (`components.cfg.lua`)**

- **Purpose**: XMPP component definitions and settings
- **Includes**:
  - Multi-User Chat (MUC) component
  - HTTP Upload/File Share components
  - PubSub component
  - Proxy65 for file transfers
- **When to modify**: Adding/configuring components, changing component settings

## 🎯 **Benefits of Modular Structure**

### **Maintainability**

- ✅ **Focused files**: Each file has a single responsibility
- ✅ **Easier debugging**: Issues can be isolated to specific modules
- ✅ **Reduced complexity**: Smaller, more manageable configuration files
- ✅ **Clear documentation**: Each module is well-documented

### **Scalability**

- ✅ **Environment-specific configs**: Easy to customize for different deployments
- ✅ **Conditional loading**: Features can be enabled/disabled per environment
- ✅ **Team collaboration**: Different team members can work on different modules
- ✅ **Version control**: Changes are easier to track and review

### **Security**

- ✅ **Security isolation**: All security settings in one place
- ✅ **Audit-friendly**: Security configurations are easy to review
- ✅ **Compliance**: Easier to ensure compliance with security standards
- ✅ **Updates**: Security updates can be applied to specific modules

## 🔄 **Migration from Monolithic Configuration**

The modular structure maintains **100% compatibility** with the previous monolithic configuration:

| **Before** | **After** | **Status** |
|------------|-----------|------------|
| Single 442-line file | 7 focused modules | ✅ Complete |
| Mixed concerns | Separated by function | ✅ Complete |
| Hard to maintain | Easy to understand | ✅ Complete |
| Difficult debugging | Isolated troubleshooting | ✅ Complete |

## 📋 **Common Tasks**

### **Adding a New Administrator**

```bash
# Edit environment variable
PROSODY_ADMINS=admin@example.com,newadmin@example.com
```

*Configuration file*: `global.cfg.lua`

### **Enabling Beta Modules**

```bash
# Edit environment variable
PROSODY_ENABLE_BETA=true
```

*Configuration file*: `modules.cfg.lua`

### **Adding a New Virtual Host**

```lua
-- Edit vhosts.cfg.lua
VirtualHost "newdomain.com"
    enabled = true
    ssl = {
        key = "/etc/prosody/certs/newdomain.com.key";
        certificate = "/etc/prosody/certs/newdomain.com.crt";
    }
```

*Configuration file*: `vhosts.cfg.lua`

### **Updating TLS Settings**

```lua
-- Edit security.cfg.lua ssl section
ssl = {
    protocol = "tlsv1_3+";  -- Update TLS version
    -- ... other settings
}
```

*Configuration file*: `security.cfg.lua`

### **Changing Database Backend**

```bash
# Edit environment variable
PROSODY_STORAGE=postgresql
PROSODY_DB_HOST=db.example.com
```

*Configuration file*: `database.cfg.lua`

## 🚀 **Best Practices**

### **Development Workflow**

1. **Identify the module** that needs modification
2. **Edit the specific file** rather than the main configuration
3. **Test changes** in staging environment
4. **Review security implications** if modifying security.cfg.lua
5. **Document changes** in commit messages

### **Environment Management**

- **Development**: Enable alpha/beta modules for testing
- **Staging**: Mirror production with additional logging
- **Production**: Stable modules only, security-first approach

### **Backup Strategy**

- **Configuration backup**: All `.cfg.lua` files
- **Environment backup**: `.env` file with all variables
- **Module backup**: `modules.d/` directory structure

## 📚 **Related Documentation**

- **[Module Organization](modules.d/README.md)** - Detailed module structure
- **[XEP Analysis](../docs/PROSODY_MODULES_XEP_ANALYSIS.md)** - Compliance and recommendations
- **[Environment Reference](../examples/env.example)** - All configuration variables
- **[Quick Start Guide](../docs/QUICK_START.md)** - Getting started

## 🔍 **Troubleshooting**

### **Configuration Validation**

The main configuration includes validation that checks:

- ✅ Domain is properly set (not localhost)
- ✅ Administrators are configured
- ✅ Storage backend is valid
- ✅ Security features are enabled

### **Common Issues**

| **Issue** | **Module** | **Solution** |
|-----------|------------|--------------|
| Modules not loading | `modules.cfg.lua` | Check environment variables |
| SSL errors | `security.cfg.lua` | Verify certificate paths |
| Database connection | `database.cfg.lua` | Check connection settings |
| Virtual host issues | `vhosts.cfg.lua` | Verify domain configuration |
| Component failures | `components.cfg.lua` | Check component settings |

### **Log Analysis**

Each module logs its configuration status:

```
[info] Prosody XMPP Server Configuration Loaded
[info] Domain: example.com
[info] Administrators: 2
[info] Storage backend: sql
[info] Security features: enabled
[info] Module profile: Core=16, Official=29, Community(Stable=6, Beta=9, Alpha=6)
```

---

*This modular configuration system provides a professional, maintainable, and scalable foundation for XMPP server deployment while maintaining full compatibility with existing setups.*
