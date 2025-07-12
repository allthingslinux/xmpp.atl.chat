-- ============================================================================
-- MODULE MANAGEMENT CONFIGURATION
-- ============================================================================
-- Module loading, organization by source and requirements

-- ============================================================================
-- CORE MODULES (SHIPPED WITH PROSODY)
-- ============================================================================

-- All modules shipped with Prosody - includes required, autoloaded, and distributed modules
-- Simplified organization: all Prosody-shipped modules in one category
local core_modules = {
    -- Essential modules (required - cannot be disabled)
    "roster", "saslauth", "tls", "dialback", "disco", "c2s", "s2s",
    "private", "vcard", "version", "uptime", "time", "ping",
    
    -- Autoloaded modules (loaded by default but can be disabled)
    "presence", "message", "iq", "offline", "s2s_auth_certs",
    
    -- Modern XMPP features (shipped with Prosody)
    "carbons", "mam", "smacks", "csi", "csi_simple", "bookmarks",
    "blocklist", "lastactivity", "pep",
    
    -- Security and administration
    "limits", "admin_adhoc", "admin_shell", "invites", "invites_adhoc", "invites_register",
    "tombstones", "server_contact_info", "watchregistrations",
    
    -- HTTP services
    "http", "http_errors", "http_files", "http_file_share", "bosh", "websocket", "http_openmetrics",
    
    -- Multi-user chat
    "muc", "muc_mam", "muc_unique",
    
    -- File transfer and media
    "proxy65", "turn_external",
    
    -- User profiles and vCard
    "vcard4", "vcard_legacy",
    
    -- Miscellaneous modules
    "motd", "welcome", "announce", "register_ibr", "register_limits",
    "user_account_management", "mimicking", "cloud_notify"
}

-- ============================================================================
-- COMMUNITY MODULES (THIRD-PARTY)
-- ============================================================================

-- Community modules (third-party - use with caution)
local community_stable_modules = {
    -- Security modules from prosody-modules
    "firewall", "spam_reporting", "block_registrations",
    
    -- User experience modules (stable)
    "pep_vcard_avatar", "filter_chatstates", "offline_hints", "profile",
    "watch_spam_reports", "admin_blocklist"
}

-- Beta community modules (mostly stable third-party)
local community_beta_modules = {
    -- Advanced features from prosody-modules
    "password_reset", "http_altconnect", "pubsub_serverinfo",
    "cloud_notify_extensions", "push",
    
    -- Modern authentication and security
    "sasl2", "sasl2_bind2", "sasl2_fast", "sasl_ssdp", "isr",
    
    -- Compliance and standards
    "compliance_2023", "service_outage_status", "server_info", "extdisco"
}

-- Alpha/Experimental modules (use with extreme caution)
local community_alpha_modules = {
    -- Monitoring and enterprise features
    "measure_cpu", "measure_memory", "measure_message_e2e",
    "json_logs", "audit", "compliance_policy"
}

-- ============================================================================
-- MODULE LOADING LOGIC
-- ============================================================================

-- Build module list based on environment and requirements
local function build_module_list()
    local modules = {}
    
    -- Core modules (all Prosody-shipped modules, enabled by default)
    if os.getenv("PROSODY_ENABLE_CORE") ~= "false" then
        for _, module in ipairs(core_modules) do
            table.insert(modules, module)
        end
    end
    
    -- Community stable modules (security-focused, enabled by default)
    if os.getenv("PROSODY_ENABLE_SECURITY") ~= "false" then
        for _, module in ipairs(community_stable_modules) do
            table.insert(modules, module)
        end
    end
    
    -- Community beta modules (opt-in for modern features)
    if os.getenv("PROSODY_ENABLE_BETA") == "true" then
        for _, module in ipairs(community_beta_modules) do
            table.insert(modules, module)
        end
    end
    
    -- Community alpha modules (explicitly opt-in only)
    if os.getenv("PROSODY_ENABLE_ALPHA") == "true" then
        for _, module in ipairs(community_alpha_modules) do
            table.insert(modules, module)
        end
    end
    
    return modules
end

modules_enabled = build_module_list()

-- ============================================================================
-- MODULE STABILITY INFORMATION
-- ============================================================================

-- Log module stability information on startup
local function log_module_stability()
    local stability_info = {
        core = #core_modules,
        community_stable = #community_stable_modules,
        community_beta = #community_beta_modules,
        community_alpha = #community_alpha_modules
    }
    
    module:log("info", "Module profile: Core=%d, Community(Stable=%d, Beta=%d, Alpha=%d)", 
              stability_info.core, stability_info.community_stable, 
              stability_info.community_beta, stability_info.community_alpha)
    
    -- Log total enabled modules
    module:log("info", "Total enabled modules: %d", #modules_enabled)
end

-- Call on startup
log_module_stability()

-- ============================================================================
-- MODULE CONFIGURATION INCLUDES
-- ============================================================================

-- Include modular configuration files based on enabled module categories

-- Always include core modules configuration (shipped with Prosody)
Include "/etc/prosody/modules.d/core/*.cfg.lua"

-- Include community stable modules configuration (security-focused)
if os.getenv("PROSODY_ENABLE_SECURITY") ~= "false" then
    Include "/etc/prosody/modules.d/community/stable/*.cfg.lua"
end

-- Include community beta modules configuration if enabled
if os.getenv("PROSODY_ENABLE_BETA") == "true" then
    Include "/etc/prosody/modules.d/community/beta/*.cfg.lua"
end

-- Include community alpha modules configuration if explicitly enabled
if os.getenv("PROSODY_ENABLE_ALPHA") == "true" then
    Include "/etc/prosody/modules.d/community/alpha/*.cfg.lua"
end

-- Include any additional configuration
Include "/etc/prosody/conf.d/*.cfg.lua" 