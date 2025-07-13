-- Layer 07: Interfaces - HTTP Configuration
-- HTTP interfaces, web admin, file upload, and web-based services
-- XEP-0363: HTTP File Upload, XEP-0066: Out of Band Data
-- Web administration and HTTP-based XMPP services
-- Based on official Prosody HTTP documentation

local http_config = {
	-- Core HTTP Services
	-- Essential HTTP functionality for web interfaces
	core_http = {
		"http", -- Core HTTP server (auto-loaded by other modules)
		"http_files", -- Static file serving (core)
	},

	-- File Upload Services
	-- XEP-0363: HTTP File Upload implementation
	file_upload = {
		"http_file_share", -- XEP-0363: HTTP File Upload (core, recommended)
		-- "http_upload", -- OBSOLETE: Use mod_http_file_share instead
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
		"http_openmetrics", -- OpenMetrics/Prometheus metrics (core)
		"http_altconnect", -- XEP-0156: Alternative connection methods (core)
		-- "http_auth_check", -- HTTP authentication checking (community)
		-- "http_host_status_check", -- Host status checking (community)
	},
}

-- HTTP Server Configuration
-- Configure HTTP server behavior according to official docs
local http_server_config = {
	-- Basic HTTP settings
	http_default_host = "localhost",

	-- Port configuration (official defaults since 0.12)
	http_ports = { 5280 },
	https_ports = { 5281 },

	-- Interface configuration (official defaults since 0.12)
	-- HTTP on localhost only for security, HTTPS on all interfaces
	http_interfaces = { "127.0.0.1", "::1" }, -- Localhost only (secure default)
	https_interfaces = { "*", "::" }, -- All interfaces (for public HTTPS)

	-- SSL/TLS configuration for HTTPS
	-- Note: Prosody 0.12+ automatically finds certificates
	https_ssl = {
		key = "certs/localhost.key",
		certificate = "certs/localhost.crt",
		-- Additional options for custom certificate setup
		-- protocol = "tlsv1_2+",
		-- ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
	},

	-- External URL configuration
	-- For reverse proxy setups
	-- http_external_url = "https://example.com/",

	-- Trusted reverse proxies (for X-Forwarded-For headers)
	-- Add your reverse proxy IPs here
	trusted_proxies = {
		"127.0.0.1",
		"::1",
		-- "192.168.1.0/24", -- Example CIDR notation (0.12+)
		-- "10.0.0.0/8",
	},

	-- Request limits
	http_max_content_size = 10 * 1024 * 1024, -- 10MB max request size
	http_max_buffer_size_bytes = 4 * 1024 * 1024, -- 4MB max buffer

	-- Security headers
	http_headers = {
		["X-Frame-Options"] = "DENY",
		["X-Content-Type-Options"] = "nosniff",
		["X-XSS-Protection"] = "1; mode=block",
		["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains",
		["Referrer-Policy"] = "strict-origin-when-cross-origin",
		["Content-Security-Policy"] = "default-src 'self'",
	},
}

-- CORS Configuration (Prosody 0.12+ automatic CORS)
-- Cross-Origin Resource Sharing settings
local cors_config = {
	-- Global CORS settings (0.12+ feature)
	access_control_allow_methods = { "GET", "POST", "PUT", "DELETE", "OPTIONS" },
	access_control_allow_headers = { "Content-Type", "Authorization", "X-Requested-With" },
	access_control_allow_credentials = false, -- Don't allow credentials by default
	access_control_allow_origins = { "*" }, -- Allow all origins (adjust for production)
	access_control_max_age = 7200, -- 2 hours cache time (default)

	-- Per-module CORS overrides
	http_cors_override = {
		-- Disable CORS for sensitive modules
		bosh = {
			enabled = false, -- Disable CORS for BOSH for security
		},
		websocket = {
			enabled = false, -- Disable CORS for WebSocket for security
		},
		-- Enable CORS for file upload
		file_share = {
			enabled = true,
			credentials = true,
			origins = { "*" }, -- Adjust for production
			headers = { "Content-Type", "Authorization" },
			methods = { "GET", "POST", "PUT", "OPTIONS" },
		},
	},
}

-- HTTP Path Configuration
-- Customize module paths (official feature)
local http_paths = {
	-- Customize BOSH path (default is /http-bind)
	bosh = "/http-bind", -- Standard BOSH path
	-- Alternative: bosh = "/bosh", -- Shorter path

	-- Customize WebSocket path (default is /xmpp-websocket)
	websocket = "/xmpp-websocket", -- Standard WebSocket path
	-- Alternative: websocket = "/websocket", -- Shorter path

	-- Customize file upload path
	file_share = "/upload", -- File upload endpoint

	-- Customize admin interface path
	admin = "/admin", -- Admin interface path

	-- Customize static files path
	files = "/files", -- Static files path
	-- Alternative: files = "/", -- Serve from root

	-- Customize metrics path
	openmetrics = "/metrics", -- Metrics endpoint

	-- Examples with $host variable for multi-host setups
	-- register_web = "/register-on-$host",
}

-- File Upload Configuration
-- XEP-0363: HTTP File Upload settings
local file_upload_config = {
	-- Upload limits
	http_file_share_size_limit = 100 * 1024 * 1024, -- 100MB max file size
	http_file_share_daily_quota = 1024 * 1024 * 1024, -- 1GB daily quota
	http_file_share_global_quota = 10 * 1024 * 1024 * 1024, -- 10GB global quota

	-- Storage settings
	http_file_share_path = "/var/lib/prosody/http_file_share",
	http_file_share_expire_after = 30 * 24 * 3600, -- 30 days expiry

	-- Security settings
	http_file_share_allowed_file_types = {
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
}

-- BOSH Configuration
-- XEP-0124: Bidirectional-streams Over Synchronous HTTP
-- Reference: https://prosody.im/doc/setting_up_bosh
local bosh_config = {
	-- BOSH settings
	bosh_max_inactivity = 60, -- 60 seconds
	bosh_max_polling = 5, -- 5 seconds
	bosh_max_requests = 2, -- Maximum concurrent requests
	bosh_max_wait = 120, -- Maximum wait time

	-- Security settings
	consider_bosh_secure = false, -- Set to true if behind HTTPS proxy

	-- CORS settings (disabled by default for security)
	cross_domain_bosh = false, -- Legacy setting (use http_cors_override instead)
}

-- WebSocket Configuration
-- RFC 7395: WebSocket XMPP Subprotocol
local websocket_config = {
	-- WebSocket settings
	websocket_frame_buffer_limit = 2 * 1024 * 1024, -- 2MB frame buffer
	websocket_frame_fragment_limit = 8, -- Maximum fragments per frame

	-- Security settings
	consider_websocket_secure = false, -- Set to true if behind HTTPS proxy

	-- CORS settings (disabled by default for security)
	cross_domain_websocket = false, -- Legacy setting (use http_cors_override instead)

	-- Custom response for HTTP GET requests
	websocket_get_response_text = "XMPP WebSocket endpoint - point your XMPP client here",
}

-- Virtual Host HTTP Configuration
-- Helper function for per-host HTTP settings
local function configure_virtual_host(host_name, external_url)
	return {
		http_host = host_name,
		http_external_url = external_url or ("https://" .. host_name .. "/"),

		-- File upload URL for this host
		http_file_share_external_base_url = external_url and (external_url .. "upload/")
			or ("https://" .. host_name .. "/upload/"),
	}
end

-- Production Security Hardening
-- Additional security measures for production
local security_hardening = {
	-- Hide server information
	http_server_name = false, -- Don't send Server header

	-- Request timeouts
	http_read_timeout = 30, -- 30 seconds read timeout
	http_write_timeout = 30, -- 30 seconds write timeout

	-- Connection limits
	http_max_concurrent_requests = 100, -- Maximum concurrent requests

	-- Rate limiting (if mod_limits is enabled)
	http_rate_limit = {
		rate = "10kb/s",
		burst = "50kb",
	},
}

-- Apply base configuration
for key, value in pairs(http_server_config) do
	_G[key] = value
end

-- Apply CORS configuration (0.12+ feature)
for key, value in pairs(cors_config) do
	_G[key] = value
end

-- Apply HTTP paths
_G.http_paths = http_paths

-- Apply file upload configuration
for key, value in pairs(file_upload_config) do
	_G[key] = value
end

-- Apply BOSH configuration
for key, value in pairs(bosh_config) do
	_G[key] = value
end

-- Apply WebSocket configuration
for key, value in pairs(websocket_config) do
	_G[key] = value
end

-- Apply security hardening
for key, value in pairs(security_hardening) do
	_G[key] = value
end

-- Load HTTP modules
modules_enabled = modules_enabled or {}

-- Add core HTTP modules
for _, module in ipairs(http_config.core_http) do
	table.insert(modules_enabled, module)
end

-- Add file upload modules
for _, module in ipairs(http_config.file_upload) do
	table.insert(modules_enabled, module)
end

-- Add web connection modules
for _, module in ipairs(http_config.web_connections) do
	table.insert(modules_enabled, module)
end

-- Add additional services
for _, module in ipairs(http_config.additional_services) do
	table.insert(modules_enabled, module)
end

-- Commented out web admin modules (enable as needed)
-- for _, module in ipairs(http_config.web_admin) do
-- 	table.insert(modules_enabled, module)
-- end

-- Export configuration utilities
return {
	configure_virtual_host = configure_virtual_host,
	modules = http_config,
	server = http_server_config,
	cors = cors_config,
	paths = http_paths,
	file_upload = file_upload_config,
	bosh = bosh_config,
	websocket = websocket_config,
	security = security_hardening,
}
