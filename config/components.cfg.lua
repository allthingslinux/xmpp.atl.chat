-- ============================================================================
-- COMPONENTS CONFIGURATION
-- ============================================================================
-- XMPP component definitions (MUC, PubSub, HTTP Upload, etc.)

-- Get main domain for component subdomains
local main_domain = os.getenv("PROSODY_DOMAIN") or "localhost"

-- ============================================================================
-- MULTI-USER CHAT (MUC) COMPONENT
-- ============================================================================

-- Multi-User Chat component
local muc_domain = "conference." .. main_domain
Component (muc_domain) "muc"
    name = "Multi-user chat"
    modules_enabled = {
        "muc_mam", "muc_limits", "muc_log", "muc_room_metadata",
        "muc_moderation", "muc_offline_delivery", "muc_hats_adhoc",
        "muc_markers", "muc_mention_notifications", "muc_mam_hints"
    }
    
    -- MUC-specific settings
    muc_log_expires_after = os.getenv("PROSODY_MUC_LOG_EXPIRE") or "1y"
    max_history_messages = tonumber(os.getenv("PROSODY_MUC_HISTORY")) or 50
    muc_room_default_public = os.getenv("PROSODY_MUC_DEFAULT_PUBLIC") == "true"

-- ============================================================================
-- HTTP UPLOAD COMPONENT
-- ============================================================================

-- HTTP Upload component (if enabled)
if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
    local upload_domain = "upload." .. main_domain
    Component (upload_domain) "http_upload"
        http_upload_file_size_limit = tonumber(os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or 10485760
        http_upload_expire_after = tonumber(os.getenv("PROSODY_UPLOAD_EXPIRE")) or 2592000
        http_upload_path = "/var/lib/prosody/uploads"
end

-- ============================================================================
-- HTTP FILE SHARE COMPONENT
-- ============================================================================

-- HTTP File Share component (modern file sharing)
if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
    local files_domain = "files." .. main_domain
    Component (files_domain) "http_file_share"
        http_file_share_size_limit = tonumber(os.getenv("PROSODY_FILE_SHARE_SIZE_LIMIT")) or 104857600 -- 100 MiB
        http_file_share_expires_after = tonumber(os.getenv("PROSODY_FILE_SHARE_EXPIRE")) or 2592000 -- 30 days
        http_file_share_global_quota = tonumber(os.getenv("PROSODY_FILE_SHARE_QUOTA")) or 10737418240 -- 10 GiB
end

-- ============================================================================
-- PROXY65 COMPONENT (FILE TRANSFER)
-- ============================================================================

-- Proxy65 component for file transfers
local proxy_domain = "proxy." .. main_domain
Component (proxy_domain) "proxy65"
    proxy65_address = main_domain
    proxy65_port = 5000

-- ============================================================================
-- PUBSUB COMPONENT
-- ============================================================================

-- PubSub component (publish-subscribe messaging)
local pubsub_domain = "pubsub." .. main_domain
Component (pubsub_domain) "pubsub"
    name = "Publish-Subscribe service"
    pubsub_max_items = tonumber(os.getenv("PROSODY_PUBSUB_MAX_ITEMS")) or 1000
    expose_publisher = true

-- ============================================================================
-- ADDITIONAL COMPONENTS
-- ============================================================================

-- Add additional components here if needed
-- Examples:

-- VJUD (User Directory) Component
--[[
if os.getenv("PROSODY_ENABLE_VJUD") == "true" then
    local vjud_domain = "vjud." .. main_domain
    Component (vjud_domain) "vjud"
        name = "User Directory"
        vjud_mode = "opt-in"
end
--]]

-- External Authentication Component
--[[
if os.getenv("PROSODY_ENABLE_EXTERNAL_AUTH") == "true" then
    local auth_domain = "auth." .. main_domain
    Component (auth_domain) "external_auth"
        name = "External Authentication Service"
end
--]] 