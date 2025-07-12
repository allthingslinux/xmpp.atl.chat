-- Professional Prosody XMPP Server Configuration
-- Based on analysis of 42+ XMPP implementations
-- Security-first approach with environment-driven configuration

-- ============================================================================
-- GLOBAL CONFIGURATION
-- ============================================================================

-- Administrator accounts
admins = {}
local admin_list = os.getenv("PROSODY_ADMINS") or "admin@localhost"
for admin in admin_list:gmatch("([^,]+)") do
    table.insert(admins, admin:match("^%s*(.-)%s*$"))
end

-- ============================================================================
-- SECURITY CONFIGURATION (MANDATORY)
-- ============================================================================

-- Enforce encryption for all connections
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true

-- Disable insecure authentication
allow_unencrypted_plain_auth = false
authentication = "internal_hashed"

-- SASL mechanisms with channel binding support (XMPP Safeguarding Manifesto)
sasl_mechanisms = { 
    "SCRAM-SHA-256-PLUS", "SCRAM-SHA-1-PLUS", 
    "SCRAM-SHA-256", "SCRAM-SHA-1" 
}

-- Modern TLS configuration
ssl = {
    -- Use TLS 1.3 and above (fallback to 1.2 for compatibility)
    protocol = "tlsv1_2+";
    -- Modern cipher suites - prioritize ECDHE and ChaCha20
    ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!SHA1:!AESCCM";
    -- Use secure curves
    curve = "secp384r1";
    -- Disable insecure versions
    options = { "no_sslv2", "no_sslv3", "no_tlsv1", "no_tlsv1_1" };
    -- Certificate verification options
    verifyext = { "lsec_continue", "lsec_ignore_purpose" };
    -- Enable TLS 1.3 specific options
    dhparam = "/etc/prosody/certs/dhparam.pem";
}

-- ============================================================================
-- PERFORMANCE AND RESOURCE MANAGEMENT
-- ============================================================================

-- Memory management
gc_settings = {
    mode = os.getenv("PROSODY_GC_MODE") or "incremental";
    threshold = tonumber(os.getenv("PROSODY_GC_THRESHOLD")) or 150;
    speed = tonumber(os.getenv("PROSODY_GC_SPEED")) or 500;
}

-- Connection limits and rate limiting
limits = {
    c2s = {
        rate = os.getenv("PROSODY_C2S_RATE") or "1mb/s";
        burst = os.getenv("PROSODY_C2S_BURST") or "2mb";
        -- Stanza size limits (XMPP Safeguarding Manifesto recommendation)
        stanza_size = tonumber(os.getenv("PROSODY_C2S_STANZA_LIMIT")) or 262144; -- 256KB
    };
    s2sin = {
        rate = os.getenv("PROSODY_S2S_RATE") or "500kb/s";
        burst = os.getenv("PROSODY_S2S_BURST") or "1mb";
        -- Stanza size limits (XMPP Safeguarding Manifesto recommendation)
        stanza_size = tonumber(os.getenv("PROSODY_S2S_STANZA_LIMIT")) or 524288; -- 512KB
    };
}

-- Stream management hibernation time (24 hours for mobile devices)
smacks_hibernation_time = tonumber(os.getenv("PROSODY_SMACKS_HIBERNATION")) or 86400

-- PEP (Personal Eventing Protocol) settings
pep_max_items = tonumber(os.getenv("PROSODY_PEP_MAX_ITEMS")) or 10000

-- ============================================================================
-- DATABASE CONFIGURATION
-- ============================================================================

-- Storage backend selection
local storage_backend = os.getenv("PROSODY_STORAGE") or "sql"
default_storage = storage_backend

if storage_backend == "sql" then
    sql = {
        driver = os.getenv("PROSODY_DB_DRIVER") or "PostgreSQL";
        database = os.getenv("PROSODY_DB_NAME") or "prosody";
        host = os.getenv("PROSODY_DB_HOST") or "localhost";
        port = tonumber(os.getenv("PROSODY_DB_PORT")) or 5432;
        username = os.getenv("PROSODY_DB_USER") or "prosody";
        password = os.getenv("PROSODY_DB_PASSWORD") or "prosody";
        -- Connection pooling
        pool_size = tonumber(os.getenv("PROSODY_DB_POOL_SIZE")) or 5;
        max_connections = tonumber(os.getenv("PROSODY_DB_MAX_CONNECTIONS")) or 20;
        connection_timeout = tonumber(os.getenv("PROSODY_DB_TIMEOUT")) or 30;
    }
elseif storage_backend == "sqlite" then
    sql = {
        driver = "SQLite3";
        database = "/var/lib/prosody/data/prosody.sqlite";
        -- SQLite optimization
        pragma = {
            journal_mode = "WAL";
            synchronous = "NORMAL";
            cache_size = 10000;
            temp_store = "MEMORY";
            mmap_size = 268435456; -- 256MB
        };
    }
end

-- ============================================================================
-- CONTACT INFORMATION AND COMPLIANCE
-- ============================================================================

-- Server contact information (required for compliance)
contact_info = {
    admin = { "xmpp:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "mailto:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost") };
    support = { "xmpp:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "mailto:support@" .. (os.getenv("PROSODY_DOMAIN") or "localhost") };
    abuse = { "xmpp:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "mailto:abuse@" .. (os.getenv("PROSODY_DOMAIN") or "localhost") };
}

-- Blocked usernames for registration
block_registrations_users = { 
    "admin", "administrator", "root", "xmpp", "postmaster", "webmaster", 
    "hostmaster", "abuse", "support", "help", "info", "noreply", "no-reply",
    "system", "daemon", "service", "test", "guest", "anonymous"
}

-- Tombstone configuration
user_tombstone_expire = 60*86400 -- 2 months

-- ============================================================================
-- MODULE MANAGEMENT (ORGANIZED BY OFFICIAL STATUS)
-- ============================================================================

-- Core modules (official Prosody core modules - always enabled)
local core_modules = {
    -- Authentication and TLS
    "roster", "saslauth", "tls", "dialback", "disco",
    
    -- Basic XMPP functionality
    "private", "vcard", "version", "uptime", "time", "ping", "iq", "message", "presence",
    
    -- Core server functionality
    "c2s", "s2s"
}

-- Official core modules (distributed with Prosody - stable)
local official_stable_modules = {
    -- Modern XMPP features (official)
    "carbons", "mam", "smacks", "csi", "csi_simple", "bookmarks",
    "blocklist", "lastactivity", "pep",
    
    -- Security and administration (official)
    "limits", "admin_adhoc", "admin_shell", "invites", "invites_adhoc", "invites_register",
    "tombstones", "server_contact_info", "watchregistrations",
    
    -- HTTP services (official)
    "http", "http_errors", "http_files", "http_file_share", "bosh", "websocket", "http_openmetrics",
    
    -- Multi-user chat (official)
    "muc", "muc_mam", "muc_unique",
    
    -- File transfer and media
    "proxy65", "turn_external",
    
    -- User profiles and vCard (official)
    "vcard4", "vcard_legacy",
    
    -- Miscellaneous official modules
    "motd", "welcome", "announce", "offline", "register_ibr", "register_limits",
    "user_account_management", "mimicking", "cloud_notify"
}

-- Community modules (third-party - use with caution)
local community_stable_modules = {
    -- Security modules from prosody-modules
    "firewall", "spam_reporting", "block_registrations"
}

-- Beta community modules (mostly stable third-party)
local community_beta_modules = {
    -- Advanced features from prosody-modules
    "password_reset", "http_altconnect", "pubsub_serverinfo",
    "cloud_notify_extensions", "push"
}

-- Alpha/Experimental modules (use with extreme caution)
local community_alpha_modules = {
    -- Monitoring and enterprise features
    "measure_cpu", "measure_memory", "measure_message_e2e",
    "json_logs", "audit", "compliance_policy"
}

-- Build module list based on environment and stability preferences
local function build_module_list()
    local modules = {}
    
    -- Always include core modules (essential XMPP functionality)
    for _, module in ipairs(core_modules) do
        table.insert(modules, module)
    end
    
    -- Official stable modules (enabled by default)
    if os.getenv("PROSODY_ENABLE_OFFICIAL") ~= "false" then
        for _, module in ipairs(official_stable_modules) do
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
        official_stable = #official_stable_modules,
        community_stable = #community_stable_modules,
        community_beta = #community_beta_modules,
        community_alpha = #community_alpha_modules
    }
    
    module:log("info", "Module profile: Core=%d, Official=%d, Community(Stable=%d, Beta=%d, Alpha=%d)", 
              stability_info.core, stability_info.official_stable, stability_info.community_stable,
              stability_info.community_beta, stability_info.community_alpha)
    
    -- Log total enabled modules
    module:log("info", "Total enabled modules: %d", #modules_enabled)
end

-- Call on startup
log_module_stability()

-- ============================================================================
-- LOGGING CONFIGURATION
-- ============================================================================

-- Log levels based on environment
local log_level = os.getenv("PROSODY_LOG_LEVEL") or "info"
local log_format = os.getenv("PROSODY_LOG_FORMAT") or "default"

if log_format == "json" then
    -- JSON logging for enterprise deployments
    log = {
        { levels = { "error" }, to = "file", filename = "/var/log/prosody/error.log", format = "json" };
        { levels = { "warn", "info" }, to = "file", filename = "/var/log/prosody/prosody.log", format = "json" };
    }
else
    -- Standard logging
    log = {
        { levels = { "error" }, to = "file", filename = "/var/log/prosody/error.log" };
        { levels = { "warn", "info" }, to = "file", filename = "/var/log/prosody/prosody.log" };
    }
end

-- Debug logging if enabled
if log_level == "debug" then
    table.insert(log, { levels = { "debug" }, to = "file", filename = "/var/log/prosody/debug.log" })
end

-- ============================================================================
-- FIREWALL CONFIGURATION
-- ============================================================================

-- Load firewall rules if security is enabled
if os.getenv("PROSODY_ENABLE_SECURITY") ~= "false" then
    firewall_scripts = {
        "/etc/prosody/firewall/anti-spam.pfw",
        "/etc/prosody/firewall/rate-limit.pfw",
        "/etc/prosody/firewall/blacklist.pfw"
    }
end

-- ============================================================================
-- VIRTUAL HOST CONFIGURATION
-- ============================================================================

-- Main domain
local main_domain = os.getenv("PROSODY_DOMAIN") or "localhost"

VirtualHost (main_domain)
    enabled = true
    
    -- SSL configuration
    ssl = {
        key = "/etc/prosody/certs/" .. main_domain .. ".key";
        certificate = "/etc/prosody/certs/" .. main_domain .. ".crt";
    }
    
    -- Registration settings
    allow_registration = os.getenv("PROSODY_ALLOW_REGISTRATION") == "true"
    
    -- HTTP upload settings (if enabled)
    if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
        http_upload_file_size_limit = tonumber(os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or 10485760 -- 10MB
        http_upload_expire_after = tonumber(os.getenv("PROSODY_UPLOAD_EXPIRE")) or 2592000 -- 30 days
        http_upload_path = "/var/lib/prosody/uploads"
    end
    
    -- Message Archive Management settings
    if os.getenv("PROSODY_ENABLE_MODERN") ~= "false" then
        default_archive_policy = os.getenv("PROSODY_ARCHIVE_POLICY") or "roster"
        archive_expires_after = os.getenv("PROSODY_ARCHIVE_EXPIRE") or "1y"
        max_archive_query_results = tonumber(os.getenv("PROSODY_ARCHIVE_MAX_RESULTS")) or 50
    end
    
    -- HTTP services configuration
    if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
        http_host = os.getenv("PROSODY_HTTP_HOST") or main_domain
        http_external_url = os.getenv("PROSODY_HTTP_EXTERNAL_URL") or ("https://" .. main_domain .. "/")
        trusted_proxies = { "127.0.0.1", "::1" }
        
        -- Web-based invitation system paths
        http_paths = {
            invites_page = "/join/$host/invite";
            invites_register_web = "/join/$host/register";
        }
    end

-- ============================================================================
-- COMPONENTS CONFIGURATION
-- ============================================================================

-- Multi-User Chat component
local muc_domain = "conference." .. main_domain
Component (muc_domain) "muc"
    name = "Multi-user chat"
    modules_enabled = {
        "muc_mam", "muc_limits", "muc_log", "muc_room_metadata",
        "muc_moderation", "muc_offline_delivery", "muc_hats_adhoc"
    }
    
    -- MUC-specific settings
    muc_log_expires_after = os.getenv("PROSODY_MUC_LOG_EXPIRE") or "1y"
    max_history_messages = tonumber(os.getenv("PROSODY_MUC_HISTORY")) or 50
    muc_room_default_public = os.getenv("PROSODY_MUC_DEFAULT_PUBLIC") == "true"

-- HTTP Upload component (if enabled)
if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
    local upload_domain = "upload." .. main_domain
    Component (upload_domain) "http_upload"
        http_upload_file_size_limit = tonumber(os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or 10485760
        http_upload_expire_after = tonumber(os.getenv("PROSODY_UPLOAD_EXPIRE")) or 2592000
        http_upload_path = "/var/lib/prosody/uploads"
end

-- HTTP File Share component (modern file sharing)
if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
    local files_domain = "files." .. main_domain
    Component (files_domain) "http_file_share"
        http_file_share_size_limit = tonumber(os.getenv("PROSODY_FILE_SHARE_SIZE_LIMIT")) or 104857600 -- 100 MiB
        http_file_share_expires_after = tonumber(os.getenv("PROSODY_FILE_SHARE_EXPIRE")) or 2592000 -- 30 days
        http_file_share_global_quota = tonumber(os.getenv("PROSODY_FILE_SHARE_QUOTA")) or 10737418240 -- 10 GiB
end

-- Proxy65 component for file transfers
local proxy_domain = "proxy." .. main_domain
Component (proxy_domain) "proxy65"
    proxy65_address = main_domain
    proxy65_port = 5000

-- PubSub component (publish-subscribe messaging)
local pubsub_domain = "pubsub." .. main_domain
Component (pubsub_domain) "pubsub"
    name = "Publish-Subscribe service"
    pubsub_max_items = tonumber(os.getenv("PROSODY_PUBSUB_MAX_ITEMS")) or 1000
    expose_publisher = true

-- ============================================================================
-- ADDITIONAL CONFIGURATION FILES
-- ============================================================================

-- Include modular configuration files based on enabled module categories

-- Always include official modules configuration (stable)
Include "/etc/prosody/modules.d/official/*.cfg.lua"

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