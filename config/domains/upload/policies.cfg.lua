-- ===============================================
-- UPLOAD POLICIES AND LIMITS
-- File upload restrictions and security policies
-- ===============================================

-- File size limits by user type
upload_limits = {
	-- Regular users
	user = {
		max_file_size = 50 * 1024 * 1024, -- 50MB
		daily_quota = 500 * 1024 * 1024, -- 500MB per day
		total_quota = 1024 * 1024 * 1024, -- 1GB total
		max_files_per_day = 50,
	},

	-- Premium users (if applicable)
	premium = {
		max_file_size = 200 * 1024 * 1024, -- 200MB
		daily_quota = 2 * 1024 * 1024 * 1024, -- 2GB per day
		total_quota = 10 * 1024 * 1024 * 1024, -- 10GB total
		max_files_per_day = 200,
	},

	-- Administrators
	admin = {
		max_file_size = 1024 * 1024 * 1024, -- 1GB
		daily_quota = 10 * 1024 * 1024 * 1024, -- 10GB per day
		total_quota = 100 * 1024 * 1024 * 1024, -- 100GB total
		max_files_per_day = 1000,
	},
}

-- File type security policies
security_policies = {
	-- Blocked file extensions
	blocked_extensions = {
		"exe",
		"bat",
		"cmd",
		"com",
		"scr",
		"pif",
		"vbs",
		"js",
		"jar",
		"app",
		"deb",
		"rpm",
		"dmg",
		"pkg",
		"msi",
	},

	-- Allowed MIME types (whitelist approach)
	allowed_mime_types = {
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
		"application/msword",
		"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
		"application/vnd.ms-excel",
		"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
		"application/vnd.ms-powerpoint",
		"application/vnd.openxmlformats-officedocument.presentationml.presentation",
		-- Archives
		"application/zip",
		"application/x-tar",
		"application/gzip",
		"application/x-7z-compressed",
		-- Audio
		"audio/mpeg",
		"audio/ogg",
		"audio/wav",
		"audio/flac",
		-- Video
		"video/mp4",
		"video/webm",
		"video/ogg",
		"video/avi",
		"video/quicktime",
	},

	-- Content scanning
	virus_scanning = true,
	malware_detection = true,

	-- Privacy protection
	strip_metadata = true,
	anonymize_filenames = false,
}

-- Retention policies
retention_policies = {
	-- Default retention period
	default_expiry = 60 * 60 * 24 * 30, -- 30 days

	-- Retention by file type
	by_type = {
		["image/*"] = 60 * 60 * 24 * 90, -- Images: 90 days
		["video/*"] = 60 * 60 * 24 * 30, -- Videos: 30 days
		["audio/*"] = 60 * 60 * 24 * 60, -- Audio: 60 days
		["application/pdf"] = 60 * 60 * 24 * 180, -- PDFs: 180 days
		["text/*"] = 60 * 60 * 24 * 365, -- Text: 1 year
	},

	-- Cleanup policies
	cleanup_frequency = 60 * 60 * 24, -- Daily cleanup
	cleanup_batch_size = 100,

	-- Archive old files before deletion
	archive_before_delete = true,
	archive_location = "/var/lib/prosody/upload/archive/",
}

-- Access control
access_control = {
	-- Who can upload
	upload_permissions = {
		"registered_users", -- Only registered users
		"local_users", -- Only local domain users
	},

	-- Download restrictions
	download_permissions = {
		"anyone", -- Anyone can download with valid link
		"authenticated", -- Require authentication for downloads
	},

	-- IP-based restrictions
	ip_restrictions = {
		enabled = false,
		whitelist = {},
		blacklist = {},
	},

	-- Rate limiting
	rate_limits = {
		uploads_per_minute = 5,
		downloads_per_minute = 20,
		bandwidth_limit = "10MB/s",
	},
}

print("Upload policies configured with security restrictions")
