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

-- Modern TLS configuration
ssl = {
    -- Use TLS 1.2 and above only
    protocol = "tlsv1_2+";
    -- Modern cipher suites - prioritize ECDHE and ChaCha20
    ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!SHA1:!AESCCM";
    -- Use secure curves
    curve = "secp384r1";
    -- Disable insecure versions
    options = { "no_sslv2", "no_sslv3", "no_tlsv1", "no_tlsv1_1" };
    -- Certificate verification options
    verifyext = { "lsec_continue", "lsec_ignore_purpose" };
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
        rate = os.getenv("PROSODY_C2S_RATE") or "10kb/s";
        burst = os.getenv("PROSODY_C2S_BURST") or "25kb";
    };
    s2sin = {
        rate = os.getenv("PROSODY_S2S_RATE") or "30kb/s";
        burst = os.getenv("PROSODY_S2S_BURST") or "100kb";
    };
}

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
-- MODULE MANAGEMENT (ENVIRONMENT-DRIVEN)
-- ============================================================================

-- Core modules (always enabled)
local core_modules = {
    "roster", "saslauth", "tls", "dialback", "disco",
    "private", "vcard", "version", "uptime", "time", "ping"
}

-- Security modules
local security_modules = {
    "firewall", "limits", "blocklist", "spam_reporting",
    "watchregistrations", "block_registrations"
}

-- Modern XMPP features
local modern_modules = {
    "carbons", "mam", "smacks", "csi_simple",
    "cloud_notify", "push", "bookmarks", "vcard4"
}

-- HTTP services
local http_modules = {
    "bosh", "websocket", "http_upload", "http_file_share"
}

-- Administration modules
local admin_modules = {
    "admin_adhoc", "admin_shell", "statistics", "prometheus"
}

-- Enterprise modules
local enterprise_modules = {
    "measure_cpu", "measure_memory", "measure_message_e2e",
    "json_logs", "audit", "compliance_policy"
}

-- Build module list based on environment
local function build_module_list()
    local modules = {}
    
    -- Always include core modules
    for _, module in ipairs(core_modules) do
        table.insert(modules, module)
    end
    
    -- Security modules (enabled by default)
    if os.getenv("PROSODY_ENABLE_SECURITY") ~= "false" then
        for _, module in ipairs(security_modules) do
            table.insert(modules, module)
        end
    end
    
    -- Modern XMPP features (enabled by default)
    if os.getenv("PROSODY_ENABLE_MODERN") ~= "false" then
        for _, module in ipairs(modern_modules) do
            table.insert(modules, module)
        end
    end
    
    -- HTTP services (optional)
    if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
        for _, module in ipairs(http_modules) do
            table.insert(modules, module)
        end
    end
    
    -- Administration modules (optional)
    if os.getenv("PROSODY_ENABLE_ADMIN") == "true" then
        for _, module in ipairs(admin_modules) do
            table.insert(modules, module)
        end
    end
    
    -- Enterprise modules (optional)
    if os.getenv("PROSODY_ENABLE_ENTERPRISE") == "true" then
        for _, module in ipairs(enterprise_modules) do
            table.insert(modules, module)
        end
    end
    
    return modules
end

modules_enabled = build_module_list()

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

-- ============================================================================
-- COMPONENTS CONFIGURATION
-- ============================================================================

-- Multi-User Chat component
local muc_domain = "conference." .. main_domain
Component (muc_domain) "muc"
    name = "Multi-user chat"
    modules_enabled = {
        "muc_mam", "muc_limits", "muc_log", "muc_room_metadata"
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

-- Proxy65 component for file transfers
local proxy_domain = "proxy." .. main_domain
Component (proxy_domain) "proxy65"
    proxy65_address = main_domain
    proxy65_port = 5000

-- ============================================================================
-- ADDITIONAL CONFIGURATION FILES
-- ============================================================================

-- Include modular configuration files
Include "/etc/prosody/modules.d/*.cfg.lua"

-- Include any additional configuration
Include "/etc/prosody/conf.d/*.cfg.lua" 