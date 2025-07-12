-- ============================================================================
-- PROFESSIONAL PROSODY XMPP SERVER CONFIGURATION
-- ============================================================================
-- Modular configuration system for maintainable and scalable XMPP deployment
-- Based on analysis of 42+ XMPP implementations with security-first approach

-- ============================================================================
-- CONFIGURATION OVERVIEW
-- ============================================================================
--
-- This configuration is split into logical modules for better maintainability:
--
-- ├── global.cfg.lua      - Global settings, admins, performance, logging
-- ├── security.cfg.lua    - Encryption, TLS, authentication, security policies
-- ├── database.cfg.lua    - Storage backends, database connections
-- ├── modules.cfg.lua     - Module management and loading logic
-- ├── vhosts.cfg.lua      - Virtual host definitions and settings
-- └── components.cfg.lua  - XMPP components (MUC, PubSub, HTTP Upload, etc.)
--
-- Each module is focused on a specific aspect of the server configuration,
-- making it easier to understand, maintain, and modify individual features.

-- ============================================================================
-- INCLUDE MODULAR CONFIGURATION FILES
-- ============================================================================

-- Global configuration (admins, performance, logging)
Include "/etc/prosody/global.cfg.lua"

-- Security configuration (TLS, authentication, firewall)
Include "/etc/prosody/security.cfg.lua"

-- Database configuration (storage backends, connections)
Include "/etc/prosody/database.cfg.lua"

-- Module management (loading logic, stability tracking)
Include "/etc/prosody/modules.cfg.lua"

-- Virtual hosts configuration (domain settings, SSL)
Include "/etc/prosody/vhosts.cfg.lua"

-- Components configuration (MUC, PubSub, HTTP services)
Include "/etc/prosody/components.cfg.lua"

-- ============================================================================
-- CONFIGURATION VALIDATION
-- ============================================================================

-- Validate critical configuration on startup
local function validate_configuration()
    -- Check if domain is properly set
    local domain = os.getenv("PROSODY_DOMAIN")
    if not domain or domain == "localhost" then
        module:log("warn", "PROSODY_DOMAIN not set or using default 'localhost'")
        module:log("warn", "Please set PROSODY_DOMAIN environment variable for production use")
    end
    
    -- Check if admins are configured
    if #admins == 0 then
        module:log("warn", "No administrators configured")
        module:log("warn", "Please set PROSODY_ADMINS environment variable")
    end
    
    -- Log configuration summary
    module:log("info", "Prosody XMPP Server Configuration Loaded")
    module:log("info", "Domain: %s", domain or "localhost")
    module:log("info", "Administrators: %d", #admins)
    module:log("info", "Storage backend: %s", default_storage or "unknown")
    module:log("info", "Security features: %s", os.getenv("PROSODY_ENABLE_SECURITY") ~= "false" and "enabled" or "disabled")
end

-- Call validation on startup
validate_configuration()

-- ============================================================================
-- PROSODY CONFIGURATION COMPLETE
-- ============================================================================
--
-- This modular configuration system provides:
--
-- ✅ Better maintainability through logical separation
-- ✅ Easier troubleshooting with focused configuration files
-- ✅ Simplified customization for specific deployment needs
-- ✅ Clear documentation and comments in each module
-- ✅ Environment-driven configuration for different deployments
-- ✅ Security-first approach with modern XMPP standards
--
-- For more information, see:
-- - docs/PROSODY_MODULES_XEP_ANALYSIS.md - XEP compliance analysis
-- - config/modules.d/README.md - Module organization documentation
-- - examples/env.example - Environment variable reference
--
-- ============================================================================ 