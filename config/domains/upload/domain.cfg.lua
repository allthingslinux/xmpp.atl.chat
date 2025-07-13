-- ============================================================================
-- UPLOAD DOMAIN CONFIGURATION - Enhanced for Prosody 13.0
-- ============================================================================
-- HTTP File Upload component with enhanced permissions and security
-- XEP-0363: HTTP File Upload with Prosody 13.0 role-based permissions

local upload_domain = os.getenv("PROSODY_UPLOAD_DOMAIN") or "upload.localhost"
local main_domain = os.getenv("PROSODY_DOMAIN") or "localhost"

-- ============================================================================
-- UPLOAD COMPONENT CONFIGURATION (Enhanced for 13.0)
-- ============================================================================

Component(upload_domain, "http_file_share")

-- ============================================================================
-- PROSODY 13.0 PERMISSION CHANGES
-- ============================================================================

-- Component permissions (New in 13.0)
-- Required due to changes in the roles and permissions framework
-- See: https://prosody.im/doc/release/13.0.0#component-permissions

-- Option 1: Single VirtualHost setup (recommended)
-- If the component is used by a single VirtualHost and is a direct subdomain
if upload_domain:match("^[^%.]+%." .. main_domain:gsub("%.", "%%.") .. "$") then
	-- Direct subdomain configuration - automatic permissions
	print("Upload component: Using automatic permissions (direct subdomain)")
else
	-- Non-direct subdomain - explicit parent_host configuration
	parent_host = main_domain
	print("Upload component: Using explicit parent_host = " .. main_domain)
end

-- Option 2: Multiple VirtualHost setup (alternative)
-- If the component is used by multiple VirtualHosts, use server-wide role
-- Uncomment if needed for multi-domain setups:
-- server_user_role = "prosody:registered"

-- ============================================================================
-- ENHANCED SECURITY CONFIGURATION (13.0+)
-- ============================================================================

-- Role-based access control (New in 13.0)
-- Define who can upload files
upload_access_roles = {
	"prosody:user", -- Standard registered users
	"prosody:admin", -- Administrators
	-- Add custom roles as needed
}

-- Enhanced upload restrictions
http_file_share_size_limit = 50 * 1024 * 1024 -- 50MB limit
http_file_share_expire_after = 60 * 60 * 24 * 7 -- 7 days retention

-- Allowed file types (security enhancement)
http_file_share_allowed_file_types = {
	-- Images
	"image/jpeg",
	"image/png",
	"image/gif",
	"image/webp",

	-- Documents
	"application/pdf",
	"text/plain",

	-- Archives
	"application/zip",
	"application/x-tar",

	-- Audio/Video (be cautious with these)
	"audio/mpeg",
	"audio/ogg",
	"video/mp4",
	"video/webm",
}

-- Blocked file types (security)
http_file_share_blocked_file_types = {
	"application/x-executable",
	"application/x-msdownload",
	"application/x-sharedlib",
	"text/html", -- Prevent XSS via HTML uploads
	"application/javascript",
	"text/javascript",
}

-- Upload quotas per user (Enhanced in 13.0)
http_file_share_daily_quota = 100 * 1024 * 1024 -- 100MB per day per user
http_file_share_global_quota = 10 * 1024 * 1024 * 1024 -- 10GB total storage

-- ============================================================================
-- STORAGE AND PATH CONFIGURATION
-- ============================================================================

-- Storage backend for uploads
http_file_share_storage_path = "/var/lib/prosody/uploads"

-- HTTP path for file access
http_file_share_url_base = "https://" .. upload_domain .. "/upload/"

-- ============================================================================
-- SECURITY AND MONITORING
-- ============================================================================

-- Virus scanning integration (if available)
-- http_file_share_virus_scan_command = "/usr/bin/clamdscan --no-summary --infected %s"

-- Content-type validation
http_file_share_validate_content_type = true

-- Logging configuration
log_file_uploads = true
log_upload_attempts = true
log_security_events = true

-- Rate limiting for uploads
upload_rate_limit = {
	rate = "10mb/minute", -- 10MB per minute per user
	burst = "50mb", -- Allow burst up to 50MB
}

-- ============================================================================
-- INTEGRATION WITH MAIN DOMAIN
-- ============================================================================

-- Service discovery integration
-- Advertise upload service to main domain users
disco_items = {
	{ upload_domain, "File Upload Service" },
}

-- Cross-domain CORS configuration for web clients
http_cors_enabled = true
http_cors_allowed_origins = {
	"https://" .. main_domain,
	-- Add additional allowed origins as needed
}

-- ============================================================================
-- MONITORING AND STATISTICS
-- ============================================================================

-- Enable statistics collection for uploads
statistics_enabled = true
statistics_config = {
	-- Track upload metrics
	track_uploads = true,
	track_bandwidth = true,
	track_storage_usage = true,
	track_user_quotas = true,
}

-- Health check endpoint for load balancers
http_health_check_enabled = true
http_health_check_path = "/health"

-- ============================================================================
-- CLEANUP AND MAINTENANCE
-- ============================================================================

-- Automatic cleanup of expired files
http_file_share_cleanup_interval = 3600 -- Check every hour
http_file_share_cleanup_age = http_file_share_expire_after

-- Orphaned file cleanup
cleanup_orphaned_files = true
orphaned_file_max_age = 24 * 3600 -- 24 hours

-- ============================================================================
-- PROSODY 13.0+ COMPATIBILITY NOTES
-- ============================================================================

-- Migration notes for existing installations:
-- 1. Component permissions now use the roles framework
-- 2. parent_host may be required for non-direct subdomains
-- 3. server_user_role can grant access to all VirtualHosts
-- 4. mod_vcard_muc is now built-in (remove if previously using community version)

print("Upload component configuration loaded (Prosody 13.0+ compatible)")
print("Domain: " .. upload_domain)
print("Parent host: " .. (parent_host or "auto-detected"))
print("Storage path: " .. (http_file_share_storage_path or "default"))

-- Validate configuration
if not http_file_share_size_limit then
	print("Warning: No upload size limit set - using default")
end

if not http_file_share_allowed_file_types then
	print("Warning: No file type restrictions - all types allowed")
end
