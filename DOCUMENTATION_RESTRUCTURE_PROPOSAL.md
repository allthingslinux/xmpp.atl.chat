# 📚 Documentation Restructure Proposal

## Current Issues After Major Refactor

The project has undergone a significant refactor from a layered configuration approach to a single, opinionated configuration with a unified CLI tool. The current documentation structure has several issues:

1. **Outdated Architecture References**: Multiple docs still reference the old "layer-based" configuration system
2. **Missing Core Tool Documentation**: The `prosody-manager` unified CLI tool lacks comprehensive documentation
3. **Fragmented User Experience**: Too many specialized guides that overlap or could be consolidated
4. **Inconsistent Project Structure**: References to old directory layouts and missing new structure documentation

## Proposed New Structure

### 📁 Root Documentation Layout

```
docs/
├── README.md                           # Updated navigation hub
├── quick-start.md                      # Single comprehensive getting started
├── configuration.md                    # Unified configuration guide
│
├── guides/                             # Task-oriented guides
│   ├── deployment/
│   │   ├── production-deployment.md   # Production setup with security
│   │   ├── development-setup.md       # Local development environment
│   │   └── docker-deployment.md       # Docker-specific deployment
│   ├── administration/
│   │   ├── prosody-manager-guide.md   # Comprehensive CLI tool guide
│   │   ├── user-management.md         # User accounts and permissions
│   │   ├── certificate-management.md  # SSL/TLS certificates
│   │   ├── backup-and-restore.md      # Data backup procedures
│   │   └── monitoring-setup.md        # Prometheus/Grafana setup
│   ├── security/
│   │   ├── security-hardening.md      # Production security guide
│   │   ├── dns-setup.md               # DNS configuration
│   │   └── firewall-configuration.md  # Network security
│   └── features/
│       ├── file-sharing.md            # HTTP upload configuration
│       ├── group-chat.md              # MUC configuration
│       ├── push-notifications.md      # Mobile push setup
│       └── voice-video-calls.md       # TURN/STUN configuration
│
├── reference/                          # Technical reference
│   ├── architecture.md                # Updated system architecture
│   ├── configuration-reference.md     # Complete config options
│   ├── prosody-manager-reference.md   # CLI tool command reference
│   ├── xep-compliance.md              # XEP support matrix
│   ├── modules.md                     # Module documentation
│   └── troubleshooting.md             # Common issues and solutions
│
└── development/                        # Developer documentation
    ├── contributing.md                 # How to contribute
    ├── testing.md                      # Testing procedures
    ├── module-development.md           # Creating custom modules
    └── api-reference.md                # API documentation
```

## Key Changes and Consolidations

### 1. Simplified Entry Points

**Before**: Multiple entry points (`user/getting-started.md`, `user/configuration.md`, `admin/README.md`)
**After**: Single comprehensive `quick-start.md` that gets users from zero to running server in 10 minutes

### 2. Unified Configuration Documentation

**Before**: Scattered configuration info across multiple files
**After**: Single `configuration.md` covering all environment variables and options

### 3. Task-Oriented Guide Structure

**Before**: Role-based documentation (user/admin/dev)
**After**: Task-oriented guides that anyone can follow based on what they want to accomplish

### 4. Comprehensive Tool Documentation

**New**: `guides/administration/prosody-manager-guide.md` - Complete guide for the unified CLI tool
**New**: `reference/prosody-manager-reference.md` - Command reference for the CLI tool

### 5. Updated Architecture Documentation

**Before**: References to layered configuration and old project structure
**After**: Updated to reflect single configuration approach and current project structure

## Content Migration Plan

### Phase 1: Core Documentation

1. Create new `quick-start.md` consolidating getting started content
2. Create unified `configuration.md` from scattered config documentation
3. Update `README.md` with new navigation structure

### Phase 2: Tool Documentation

1. Create comprehensive `prosody-manager-guide.md`
2. Create `prosody-manager-reference.md` with all commands
3. Update all references to use unified CLI tool

### Phase 3: Architecture Updates

1. Update `reference/architecture.md` to remove layer-based references
2. Document current project structure and design philosophy
3. Remove outdated `dev/prosody-modern-features.md` or update significantly

### Phase 4: Guide Consolidation

1. Merge overlapping user guides into task-oriented guides
2. Reorganize admin documentation into logical task groups
3. Create security-focused guide consolidating security practices

### Phase 5: Reference Documentation

1. Create comprehensive configuration reference
2. Update XEP compliance documentation
3. Create troubleshooting guide with common issues

## Files to Remove/Archive

### Outdated Files

- `docs/dev/prosody-modern-features.md` (references non-existent layered config)
- `docs/user/static-files.md` (specialized, can be part of features guide)
- `docs/user/pastebin.md` (specialized, can be part of features guide)
- `docs/user/muc-archiving.md` (can be consolidated into group-chat guide)
- `docs/user/message-archiving.md` (can be part of configuration guide)
- `docs/user/service-discovery.md` (technical detail for reference section)

### Files to Consolidate

- All `docs/user/*.md` files → merge into appropriate task-oriented guides
- `docs/admin/docker-deployment.md` → merge into deployment guides
- Monitoring documentation → consolidate into single monitoring guide

## Benefits of New Structure

1. **Clearer User Journey**: Users can follow a logical path from quick start to advanced configuration
2. **Task-Oriented**: Users find documentation based on what they want to accomplish
3. **Reduced Duplication**: Eliminates overlapping content between user/admin docs
4. **Better Tool Coverage**: Comprehensive documentation for the unified CLI tool
5. **Updated Architecture**: Reflects current single-configuration approach
6. **Easier Maintenance**: Fewer files with clearer purposes

## Implementation Priority

### High Priority (Fix Immediately)

1. Update `docs/dev/prosody-modern-features.md` to remove layer-based references
2. Create basic `prosody-manager-guide.md`
3. Update main `README.md` to reflect current project structure

### Medium Priority (Next Sprint)

1. Create new `quick-start.md`
2. Consolidate configuration documentation
3. Update architecture documentation

### Low Priority (Future)

1. Complete guide reorganization
2. Create comprehensive reference documentation
3. Archive outdated specialized guides

This restructure will provide a much clearer, more maintainable documentation structure that accurately reflects the current state of the project after the major refactor.
