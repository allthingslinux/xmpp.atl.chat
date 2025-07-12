-- ============================================================================
-- VIRTUAL HOSTS CONFIGURATION
-- ============================================================================
-- Virtual host definitions, SSL certificates, and host-specific settings

-- ============================================================================
-- MAIN VIRTUAL HOST
-- ============================================================================

-- Main domain
local main_domain = os.getenv("PROSODY_DOMAIN") or "localhost"

VirtualHost(main_domain)
enabled = true

-- ========================================================================
-- SSL CONFIGURATION
-- ========================================================================

-- SSL configuration
ssl = {
	key = "/etc/prosody/certs/" .. main_domain .. ".key",
	certificate = "/etc/prosody/certs/" .. main_domain .. ".crt",
}

-- ========================================================================
-- REGISTRATION SETTINGS
-- ========================================================================

-- Registration settings
allow_registration = os.getenv("PROSODY_ALLOW_REGISTRATION") == "true"

-- ========================================================================
-- MESSAGE ARCHIVE MANAGEMENT
-- ========================================================================

-- Message Archive Management settings are handled in core.cfg.lua
if os.getenv("PROSODY_ENABLE_MODERN") ~= "false" then
	default_archive_policy = os.getenv("PROSODY_ARCHIVE_POLICY") or "roster"
end

-- ========================================================================
-- HTTP SERVICES CONFIGURATION
-- ========================================================================

-- HTTP upload settings (if enabled)
if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
	http_upload_file_size_limit = tonumber(os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or 10485760 -- 10MB
	http_upload_expire_after = tonumber(os.getenv("PROSODY_UPLOAD_EXPIRE")) or 2592000 -- 30 days
	http_upload_path = "/var/lib/prosody/uploads"

	-- HTTP services configuration
	http_host = os.getenv("PROSODY_HTTP_HOST") or main_domain
	http_external_url = os.getenv("PROSODY_HTTP_EXTERNAL_URL") or ("https://" .. main_domain .. "/")
	trusted_proxies = { "127.0.0.1", "::1" }

	-- Web-based invitation system paths
	http_paths = {
		invites_page = "/join/$host/invite",
		invites_register_web = "/join/$host/register",
	}
end

-- ============================================================================
-- ADDITIONAL VIRTUAL HOSTS
-- ============================================================================

-- Add additional virtual hosts here if needed
-- Example:
--[[
VirtualHost "example.org"
    enabled = true
    ssl = {
        key = "/etc/prosody/certs/example.org.key";
        certificate = "/etc/prosody/certs/example.org.crt";
    }
    allow_registration = false
--]]
