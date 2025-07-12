-- Layer 07: Interfaces - HTTP Configuration
-- HTTP interfaces, web admin, file upload, and web-based services
-- XEP-0363: HTTP File Upload, XEP-0066: Out of Band Data
-- Web administration and HTTP-based XMPP services

local http_config = {
	-- Core HTTP Services
	-- Essential HTTP functionality for web interfaces
	core_http = {
		"http", -- Core HTTP server (core)
		"http_files", -- Static file serving (core)
	},

	-- File Upload Services
	-- XEP-0363: HTTP File Upload implementation
	file_upload = {
		"http_upload", -- XEP-0363: HTTP File Upload (community)
	},

	-- Web Administration
	-- Web-based administration interfaces
	web_admin = {
		"admin_web", -- Web administration interface (community)
		-- "admin_rest", -- REST API for administration (community)
	},

	-- BOSH and WebSocket
	-- HTTP-based XMPP connections
	web_connections = {
		"bosh", -- XEP-0124: BOSH (core)
		"websocket", -- RFC 7395: WebSocket (core)
	},

	-- Additional HTTP Services
	-- Extra HTTP-based functionality
	additional_services = {
		-- "http_auth_check", -- HTTP authentication checking (community)
		-- "http_host_status_check", -- Host status checking (community)
	},
}

-- HTTP Server Configuration
-- Configure HTTP server behavior and security
local http_server_config = {
	-- Basic HTTP settings
	http_default_host = "localhost",
	http_host = "localhost",

	-- HTTP ports
	http_ports = { 5280 },
	https_ports = { 5281 },

	-- SSL/TLS configuration for HTTPS
	https_ssl = {
		key = "/etc/prosody/certs/localhost.key",
		certificate = "/etc/prosody/certs/localhost.crt",
	},

	-- Security headers
	http_headers = {
		["X-Frame-Options"] = "DENY",
		["X-Content-Type-Options"] = "nosniff",
		["X-XSS-Protection"] = "1; mode=block",
		["Strict-Transport-Security"] = "max-age=31536000",
	},

	-- CORS configuration
	cross_domain_bosh = false, -- Disable cross-domain BOSH by default
	cross_domain_websocket = false, -- Disable cross-domain WebSocket by default

	-- Request limits
	http_max_content_size = 10 * 1024 * 1024, -- 10MB max request size
	http_max_buffer_size_bytes = 4 * 1024 * 1024, -- 4MB max buffer
}

-- File Upload Configuration
-- XEP-0363: HTTP File Upload settings
local file_upload_config = {
	-- Upload limits
	http_upload_file_size_limit = 50 * 1024 * 1024, -- 50MB max file size
	http_upload_quota = 1024 * 1024 * 1024, -- 1GB quota per user

	-- Storage settings
	http_upload_path = "/var/lib/prosody/upload",
	http_upload_expire_after = 60 * 60 * 24 * 7, -- 7 days

	-- Security settings
	http_upload_allowed_file_types = {
		"image/jpeg",
		"image/png",
		"image/gif",
		"image/webp",
		"video/mp4",
		"video/webm",
		"audio/mp3",
		"audio/ogg",
		"audio/wav",
		"application/pdf",
		"text/plain",
	},

	-- URL configuration
	http_upload_external_base_url = nil, -- Use default internal URL

	-- Cleanup settings
	http_upload_purge_interval = 60 * 60, -- Clean up every hour
}

-- BOSH Configuration
-- XEP-0124: Bidirectional-streams Over Synchronous HTTP
local bosh_config = {
	-- BOSH settings
	bosh_max_inactivity = 60, -- 60 seconds
	bosh_max_polling = 5, -- 5 seconds
	bosh_max_requests = 2, -- Maximum concurrent requests

	-- Session management
	bosh_max_wait = 120, -- Maximum wait time
	consider_bosh_secure = false, -- Set to true if behind HTTPS proxy

	-- Cross-domain settings (security consideration)
	cross_domain_bosh = false, -- Disable by default for security
}

-- WebSocket Configuration
-- RFC 7395: An Extensible Messaging and Presence Protocol (XMPP) Subprotocol for WebSocket
local websocket_config = {
	-- WebSocket settings
	websocket_frame_buffer_limit = 2 * 1024 * 1024, -- 2MB frame buffer
	websocket_frame_fragment_limit = 8, -- Maximum fragments per frame

	-- Connection settings
	consider_websocket_secure = false, -- Set to true if behind HTTPS proxy
	websocket_get_response_text = "It works! Now point your XMPP client to this URL to connect via WebSocket.",

	-- Cross-domain settings (security consideration)
	cross_domain_websocket = false, -- Disable by default for security
}

-- Web Administration Configuration
-- Web-based administration interface settings
local web_admin_config = {
	-- Admin interface settings
	admin_interface = {
		enabled = false, -- Disabled by default for security
		interface = "127.0.0.1", -- Local access only
		port = 5280,
		ssl_port = 5281,
	},

	-- Authentication settings
	admin_auth = {
		-- Require admin privileges for web admin access
		require_admin = true,

		-- Session timeout
		session_timeout = 30 * 60, -- 30 minutes
	},

	-- Security settings
	admin_security = {
		-- CSRF protection
		csrf_protection = true,

		-- Rate limiting
		rate_limit = {
			max_requests = 100,
			time_window = 60, -- 1 minute
		},
	},
}

-- HTTP Interface Utilities
-- Helper functions for HTTP interface management
local http_utilities = {
	-- Configure virtual hosts for HTTP
	configure_http_host = function(host, config)
		return {
			http_host = host,
			http_external_url = "https://" .. host .. "/",

			-- File upload URL for this host
			http_upload_external_base_url = "https://" .. host .. "/upload/",
		}
	end,

	-- Security hardening for HTTP interfaces
	apply_security_hardening = function()
		return {
			-- Disable unnecessary HTTP methods
			http_methods_allowed = { "GET", "POST", "PUT", "DELETE" },

			-- Enable security headers
			security_headers_enabled = true,

			-- Disable server information disclosure
			hide_server_info = true,
		}
	end,

	-- Performance optimization for HTTP
	optimize_performance = function()
		return {
			-- Enable HTTP compression
			http_compression = true,

			-- Cache static files
			http_cache_static = true,
			cache_max_age = 86400, -- 24 hours

			-- Connection pooling
			http_connection_pooling = true,
		}
	end,
}

-- Export configuration
return {
	modules = {
		-- Core HTTP services
		core = http_config.core_http,

		-- File upload services
		upload = http_config.file_upload,

		-- Web connections (BOSH/WebSocket)
		connections = http_config.web_connections,

		-- Web administration (commented out by default for security)
		-- admin = http_config.web_admin,
		-- additional = http_config.additional_services,
	},

	server = http_server_config,
	file_upload = file_upload_config,
	bosh = bosh_config,
	websocket = websocket_config,
	web_admin = web_admin_config,
	utilities = http_utilities,
}
