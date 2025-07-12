-- ===============================================
-- UPLOAD DOMAIN CONFIGURATION
-- File upload and sharing service
-- XEP-0363: HTTP File Upload
-- ===============================================

local domain = os.getenv("PROSODY_DOMAIN") or "localhost"
local upload_domain = "upload." .. domain

-- Configure HTTP upload component
Component(upload_domain)("http_upload")

-- Upload-specific modules
modules_enabled = {
	"http_upload", -- XEP-0363: HTTP File Upload
	"http_upload_external", -- External upload service support
	"http_file_share", -- XEP-0385: Stateless File Sharing
	"http", -- HTTP server
	"http_files", -- Static file serving
}

-- Upload configuration
http_upload_file_size_limit = 100 * 1024 * 1024 -- 100MB
http_upload_expire_after = 60 * 60 * 24 * 30 -- 30 days
http_upload_quota = 1024 * 1024 * 1024 -- 1GB per user

-- Upload paths
http_upload_path = "/var/lib/prosody/upload"
http_upload_external_base_url = "https://" .. upload_domain .. "/upload/"

-- File type restrictions
http_upload_allowed_file_types = {
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
	-- Audio/Video
	"audio/mpeg",
	"audio/ogg",
	"video/mp4",
	"video/webm",
}

-- Security settings
http_upload_external_protocol = "https"
http_upload_external_file_size_limit = http_upload_file_size_limit

-- CORS settings for web uploads
http_cors_override = {
	["upload." .. domain] = {
		credentials = true,
		headers = "Authorization, Content-Type",
		methods = "GET, POST, PUT, OPTIONS",
		origin = "*",
	},
}

print("Upload domain configured: " .. upload_domain)
