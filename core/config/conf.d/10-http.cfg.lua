-- ===============================================
-- HTTP SERVICES
-- ===============================================

-- HTTP server settings
-- Prefer explicit HTTP host, then service host, then domain
local __http_host =
    Lua.os.getenv("PROSODY_HTTP_HOST")
    or Lua.os.getenv("PROSODY_SERVICE_HOST")
    or (Lua.os.getenv("PROSODY_DOMAIN") or "localhost")
local __http_scheme = Lua.os.getenv("PROSODY_HTTP_SCHEME") or "https"
http_default_host = __http_host
http_external_url = __http_scheme .. "://" .. __http_host .. "/"

-- Security interfaces (IPv4 only)
http_interfaces = { "0.0.0.0" }
https_interfaces = { "0.0.0.0" }

-- HTTP static file serving configuration (served by Prosody)
if Lua.os.getenv("PROSODY_HTTP_FILES_DIR") then
	http_files_dir = Lua.os.getenv("PROSODY_HTTP_FILES_DIR")
else
	-- Default to Prosody's web root when not set; nginx will proxy '/'
	http_files_dir = "/usr/share/prosody/www"
end

-- Optional: Additional static file serving
if Lua.os.getenv("PROSODY_HTTP_FILES_DIR") then
	http_files_dir = Lua.os.getenv("PROSODY_HTTP_FILES_DIR")
	http_index_files = { "index.html", "index.htm" }
	http_dir_listing = (Lua.os.getenv("PROSODY_HTTP_DIR_LISTING") == "true")
end

-- Trusted proxies for X-Forwarded-For headers (WebSocket/BOSH proxies)
trusted_proxies = {
	"127.0.0.1",
	"172.18.0.0/16",
	"10.0.0.0/8",
}

-- CORS support for web clients
http_cors_override = {
	bosh = { enabled = true },
	websocket = { enabled = true },
}

-- Enhanced HTTP security headers
http_headers = {
	["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload",
	["X-Frame-Options"] = "DENY",
	["X-Content-Type-Options"] = "nosniff",
	["X-XSS-Protection"] = "1; mode=block",
	["Referrer-Policy"] = "strict-origin-when-cross-origin",
	["Content-Security-Policy"] = "default-src 'self'",
}

-- File upload configuration (XEP-0363: HTTP File Upload)
http_file_share_size_limit = Lua.tonumber(Lua.os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or (100 * 1024 * 1024)
http_file_share_daily_quota = Lua.tonumber(Lua.os.getenv("PROSODY_UPLOAD_DAILY_QUOTA")) or (1024 * 1024 * 1024)
http_file_share_expire_after = Lua.tonumber(Lua.os.getenv("PROSODY_UPLOAD_EXPIRE_AFTER")) or (30 * 24 * 3600)
http_file_share_path = Lua.os.getenv("PROSODY_UPLOAD_PATH") or "/var/lib/prosody/http_file_share"

-- Optional: Global quota (total storage limit across all users)
if Lua.os.getenv("PROSODY_UPLOAD_GLOBAL_QUOTA") then
	http_file_share_global_quota = Lua.tonumber(Lua.os.getenv("PROSODY_UPLOAD_GLOBAL_QUOTA"))
end

-- Optional: Allowed file types restriction
local upload_types_env = Lua.os.getenv("PROSODY_UPLOAD_ALLOWED_TYPES")
if upload_types_env then
	local types = {}
	for type in Lua.string.gmatch(upload_types_env, "([^,]+)") do
		Lua.table.insert(types, type:match("^%s*(.-)%s*$"))
	end
	http_file_share_allowed_file_types = types
end

-- BOSH/WebSocket tuning
bosh_max_inactivity = 60
bosh_max_polling = 5
bosh_max_requests = 2
bosh_max_wait = 120
bosh_session_timeout = 300
bosh_hold_timeout = 60
bosh_window = 5
consider_bosh_secure = false

websocket_frame_buffer_limit = 2 * 1024 * 1024
websocket_frame_fragment_limit = 8
websocket_max_frame_size = 1024 * 1024

-- Serve uploads on main host at /file_share (nginx maps /upload -> /file_share)
-- Serve static files at root, and pastebin at /paste
http_paths = {
	file_share = "/upload",
	files = "/",
	pastebin = "/paste",
	-- Friendly paths for BOSH and WebSocket
	bosh = "/bosh",
	websocket = "/ws",
}
