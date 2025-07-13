-- ===============================================
-- UPLOAD DOMAIN CONFIGURATION
-- File upload and sharing service
-- XEP-0363: HTTP File Upload
-- Based on official Prosody documentation
-- ===============================================

local domain = os.getenv("PROSODY_DOMAIN") or "localhost"
local upload_domain = "upload." .. domain

-- Configure HTTP file share component (recommended over http_upload)
Component(upload_domain)("http_file_share")

-- Upload-specific modules
modules_enabled = {
	"http_file_share", -- XEP-0363: HTTP File Upload (core, recommended)
	"http", -- HTTP server (auto-loaded)
	"http_files", -- Static file serving
	-- "http_upload", -- OBSOLETE: Use http_file_share instead
	-- "http_upload_external", -- External upload service support
}

-- File upload configuration (using http_file_share settings)
http_file_share_size_limit = 100 * 1024 * 1024 -- 100MB max file size
http_file_share_expire_after = 30 * 24 * 3600 -- 30 days expiry
http_file_share_daily_quota = 1024 * 1024 * 1024 -- 1GB daily quota per user
http_file_share_global_quota = 10 * 1024 * 1024 * 1024 -- 10GB global quota

-- Storage paths (using http_file_share convention)
http_file_share_path = "/var/lib/prosody/http_file_share"

-- External URL configuration
http_external_url = "https://" .. upload_domain .. "/"
http_file_share_external_base_url = "https://" .. upload_domain .. "/upload/"

-- File type restrictions (security)
http_file_share_allowed_file_types = {
	-- Images
	"image/jpeg",
	"image/png",
	"image/gif",
	"image/webp",
	"image/svg+xml",
	-- Documents
	"application/pdf",
	"text/plain",
	"text/markdown",
	-- Archives
	"application/zip",
	"application/x-tar",
	"application/gzip",
	-- Audio/Video
	"audio/mpeg",
	"audio/mp4",
	"audio/ogg",
	"audio/wav",
	"video/mp4",
	"video/webm",
	"video/ogg",
	"video/quicktime",
}

-- Security settings
http_file_share_external_protocol = "https"

-- CORS settings for web uploads (using new 0.12+ configuration)
http_cors_override = {
	file_share = {
		enabled = true,
		credentials = true,
		headers = { "Authorization", "Content-Type", "X-Requested-With" },
		methods = { "GET", "POST", "PUT", "DELETE", "OPTIONS" },
		origins = { "*" }, -- Adjust for production security
		max_age = 3600, -- 1 hour
	},
}

-- Path configuration
http_paths = {
	file_share = "/upload", -- Custom upload endpoint
	files = "/files", -- Static files endpoint
}

-- Additional security headers
http_headers = {
	["X-Frame-Options"] = "DENY",
	["X-Content-Type-Options"] = "nosniff",
	["X-XSS-Protection"] = "1; mode=block",
	["Content-Security-Policy"] = "default-src 'self'; img-src 'self' data:; object-src 'none';",
}

-- Rate limiting for uploads (if mod_limits is enabled)
http_rate_limit = {
	rate = "1mb/s", -- 1MB/s upload rate
	burst = "5mb", -- 5MB burst allowance
}

-- Monitoring and logging
log_level = "info"
log = {
	{ levels = { min = "info" }, to = "file", filename = "/var/log/prosody/upload.log" },
	{ levels = { min = "warn" }, to = "console" },
}

-- Contact information for this service
contact_info = {
	admin = { "xmpp:admin@" .. domain, "mailto:admin@" .. domain },
	abuse = { "xmpp:abuse@" .. domain, "mailto:abuse@" .. domain },
}

-- Service discovery
disco_items = {
	{ upload_domain, "File Upload Service" },
}

print("Upload domain configured: " .. upload_domain)
print("Using http_file_share (XEP-0363) - recommended over http_upload")
print("Max file size: " .. (http_file_share_size_limit / 1024 / 1024) .. "MB")
print("Daily quota: " .. (http_file_share_daily_quota / 1024 / 1024) .. "MB")
print("File expiry: " .. (http_file_share_expire_after / 60 / 60 / 24) .. " days")
