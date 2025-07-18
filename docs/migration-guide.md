# Migration Guide: From Legacy Scripts to Unified CLI

This guide helps you transition from the legacy standalone scripts to the new unified `prosody-manager` CLI tool.

## Overview

The project has consolidated all standalone scripts into a single, unified CLI tool called `prosody-manager`. This provides:

- **Consistent interface** - All operations use the same command structure
- **Better error handling** - Enhanced validation and user-friendly error messages
- **Interactive modes** - Run commands without arguments for guided workflows
- **Integrated help** - Built-in documentation and examples
- **Bash completion** - Auto-completion for commands and options

## Migration Table

### Setup Scripts

| Legacy Command | New Command | Notes |
|----------------|-------------|-------|
| `./scripts/setup/setup.sh` | `prosody-manager setup` | Interactive setup wizard with better validation |
| `./scripts/setup/setup-dev.sh` | `prosody-manager setup --dev` | Development environment setup |

### Development Tools

| Legacy Command | New Command | Notes |
|----------------|-------------|-------|
| `./scripts/dev/dev-tools.sh status` | `prosody-manager dev status` | Enhanced status display |
| `./scripts/dev/dev-tools.sh urls` | `prosody-manager dev urls` | Same functionality |
| `./scripts/dev/dev-tools.sh test` | `prosody-manager dev test` | Improved connectivity testing |
| `./scripts/dev/dev-tools.sh config` | `prosody-manager dev config` | Configuration validation |
| `./scripts/dev/dev-tools.sh users` | `prosody-manager dev users` | List development users |
| `./scripts/dev/dev-tools.sh adduser alice` | `prosody-manager dev adduser alice` | Create development user |
| `./scripts/dev/dev-tools.sh deluser alice` | `prosody-manager dev deluser alice` | Delete development user |
| `./scripts/dev/dev-tools.sh passwd alice` | `prosody-manager dev passwd alice` | Change user password |
| `./scripts/dev/dev-tools.sh logs` | `prosody-manager dev logs` | View logs with filtering |
| `./scripts/dev/dev-tools.sh restart` | `prosody-manager dev restart` | Restart services |
| `./scripts/dev/dev-tools.sh cleanup` | `prosody-manager dev cleanup` | Clean up environment |
| `./scripts/dev/dev-tools.sh backup` | `prosody-manager dev backup` | Backup development data |
| `./scripts/dev/dev-tools.sh perf` | `prosody-manager dev perf` | Performance testing |

### Maintenance Scripts

| Legacy Command | New Command | Notes |
|----------------|-------------|-------|
| `./scripts/maintenance/health-check.sh` | `prosody-manager health` | Integrated into main CLI |
| `./scripts/maintenance/renew-certificates.sh` | `prosody-manager cert renew <domain>` | Better certificate management |

## Interactive Mode

The new CLI supports interactive mode for complex operations. Simply run commands without arguments:

```bash
# Interactive setup
prosody-manager setup

# Interactive development tools
prosody-manager dev

# Interactive user management
prosody-manager prosodyctl

# Interactive certificate management
prosody-manager cert

# Interactive backup management
prosody-manager backup

# Interactive deployment
prosody-manager deploy

# Interactive module management
prosody-manager module
```

## Enhanced Features

### Better Error Handling

The new CLI provides:
- Clear error messages with actionable guidance
- Input validation with helpful suggestions
- Environment validation before operations
- Graceful handling of missing dependencies

### Improved Help System

```bash
# General help
prosody-manager help

# Development-specific help
prosody-manager help dev

# Production-specific help
prosody-manager help prod

# Command-specific help
prosody-manager dev help
prosody-manager cert help
prosody-manager module help
```

### Bash Completion

Install bash completion for better productivity:

```bash
# Install completion system-wide
prosody-manager completion install

# Or generate completion script
prosody-manager completion generate >> ~/.bashrc
```

## Migration Steps

### 1. Update Your Workflows

Replace legacy script calls in your documentation, CI/CD pipelines, and automation:

**Before:**
```bash
./scripts/setup/setup.sh
./scripts/dev/dev-tools.sh status
./scripts/maintenance/health-check.sh
```

**After:**
```bash
prosody-manager setup
prosody-manager dev status
prosody-manager health
```

### 2. Update Documentation

Update any project documentation that references the old scripts:

- README files
- Deployment guides
- Development setup instructions
- CI/CD configuration files

### 3. Update Automation

Update any automation scripts or CI/CD pipelines:

**Before:**
```yaml
# GitHub Actions example
- name: Setup development environment
  run: ./scripts/setup/setup-dev.sh

- name: Run health check
  run: ./scripts/maintenance/health-check.sh
```

**After:**
```yaml
# GitHub Actions example
- name: Setup development environment
  run: prosody-manager setup --dev

- name: Run health check
  run: prosody-manager health
```

### 4. Update Cron Jobs

Update any cron jobs that use the old scripts:

**Before:**
```bash
# Cron job
0 3 * * * /opt/xmpp.atl.chat/scripts/maintenance/renew-certificates.sh
```

**After:**
```bash
# Cron job
0 3 * * * cd /opt/xmpp.atl.chat && ./prosody-manager cert renew your-domain.com
```

## Backward Compatibility

During the transition period:

1. **Legacy scripts still work** - They show deprecation warnings but continue to function
2. **Gradual migration** - You can migrate commands one at a time
3. **No breaking changes** - Existing functionality is preserved

## Deprecation Timeline

- **Current**: Legacy scripts show deprecation warnings but continue to work
- **Next major version**: Legacy scripts will be removed
- **Recommendation**: Migrate to the new CLI as soon as possible

## Getting Help

If you encounter issues during migration:

1. **Check the help system**: `prosody-manager help`
2. **Use interactive mode**: Run commands without arguments
3. **Check command-specific help**: `prosody-manager <command> help`
4. **Review this migration guide**

## Examples

### Complete Development Setup Migration

**Legacy workflow:**
```bash
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat
./scripts/setup/setup-dev.sh
./scripts/dev/dev-tools.sh adduser alice alice123
./scripts/dev/dev-tools.sh status
```

**New workflow:**
```bash
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat
prosody-manager setup --dev
prosody-manager dev adduser alice alice123
prosody-manager dev status
```

### Production Deployment Migration

**Legacy workflow:**
```bash
./scripts/setup/setup.sh
./scripts/maintenance/health-check.sh
```

**New workflow:**
```bash
prosody-manager setup
prosody-manager health
```

### Certificate Management Migration

**Legacy workflow:**
```bash
./scripts/maintenance/renew-certificates.sh
```

**New workflow:**
```bash
prosody-manager cert renew your-domain.com
# Or interactive mode
prosody-manager cert
```

## Benefits of Migration

1. **Unified Interface** - Single command for all operations
2. **Better UX** - Interactive modes and better error messages
3. **Enhanced Features** - More functionality and options
4. **Future-Proof** - Active development and maintenance
5. **Better Integration** - Consistent behavior across all operations

## Support

The legacy scripts will continue to work during the transition period, but we recommend migrating to the new CLI for the best experience and future compatibility.