-- ===============================================
-- PROFESSIONAL PROSODY XMPP SERVER
-- Production-Ready Configuration
-- ===============================================
-- Consolidates all layer-based configurations into a single,
-- opinionated setup for public/professional XMPP deployment
-- Supports Prosody 13.0+ with all modern features enabled

-- ===============================================
-- CORE SERVER SETTINGS
-- ===============================================

-- Process management
-- daemonize = true -- Deprecated: use command line flags instead
pidfile = "/var/run/prosody/prosody.pid"
user = "prosody"
group = "prosody"

-- Server identity
server_name = Lua.os.getenv("PROSODY_DOMAIN") or "localhost"
admins = { Lua.os.getenv("PROSODY_ADMIN_JID") or "admin@localhost" }

-- ===============================================
-- NETWORK AND CONNECTION SETTINGS
-- ===============================================

-- Standard XMPP ports (RFC 6120/6121)
c2s_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_C2S_PORT")) or 5222 } -- Client-to-server (STARTTLS)
c2s_direct_tls_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_C2S_DIRECT_TLS_PORT")) or 5223 } -- Direct TLS
s2s_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_S2S_PORT")) or 5269 } -- Server-to-server
s2s_direct_tls_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_S2S_DIRECT_TLS_PORT")) or 5270 } -- Server-to-server Direct TLS
component_ports = { 5347 } -- External components (XEP-0114: Jabber Component Protocol)

-- HTTP services
http_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_HTTP_PORT")) or 5280 } -- HTTP (BOSH, file upload, admin)
https_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_HTTPS_PORT")) or 5281 } -- HTTPS (secure services)

-- Interface bindings (IPv4 only)
interfaces = { "0.0.0.0" }  -- IPv4 only, all interfaces
local_interfaces = { "127.0.0.1" }  -- IPv4 localhost only

-- IPv6 support (disabled)
use_ipv6 = false

-- Network timeouts (critical for WebSocket proxies)
-- Proxy timeouts should be higher than this (900+ seconds)
-- Reference: https://prosody.im/doc/websocket
network_settings = {
	read_timeout = 840, -- 14 minutes (Prosody 0.12.0+ default)
}

-- ===============================================
-- PLUGIN INSTALLER CONFIGURATION
-- ===============================================

plugin_paths = { "/usr/local/lib/prosody/community-modules" }

-- Official Prosody modules repository for prosodyctl install
-- Reference: https://prosody.im/doc/plugin_installer
plugin_server = "https://modules.prosody.im/rocks/"

-- ===============================================
-- TLS/SSL CONFIGURATION
-- ===============================================

-- Enhanced TLS settings for modern security
ssl = {
	protocol = "tlsv1_2+", -- TLS 1.2+ only
	ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
	curve = "secp384r1", -- Strong elliptic curve
	-- verifyext = { "lsExtKeyUsage" }, -- Disabled due to compatibility issue
	options = { "cipher_server_preference", "single_dh_use", "single_ecdh_use" },
}

-- Certificate configuration (Prosody auto-discovery)
certificates = "certs"

-- Require encryption for all connection types
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true

-- Disable insecure authentication
allow_unencrypted_plain_auth = false

-- ===============================================
-- AUTHENTICATION CONFIGURATION
-- ===============================================

-- Authentication method
authentication = "internal_hashed" -- Secure password hashing

-- SASL mechanisms (modern and secure)
sasl_mechanisms = {
	"SCRAM-SHA-256", -- Preferred modern method
	"SCRAM-SHA-1", -- Fallback modern method
	"DIGEST-MD5", -- Legacy support
	"PLAIN", -- Only over TLS
}

-- Channel binding support
tls_channel_binding = true

-- Account management (Prosody 13.0+)
user_account_management = {
	grace_period = 7 * 24 * 3600, -- 7 days grace period for deletion
	deletion_confirmation = true,
}

-- ===============================================
-- STORAGE CONFIGURATION
-- ===============================================

-- Default storage backend
default_storage = Lua.os.getenv("PROSODY_STORAGE") or "sql"

-- SQL configuration for production scalability
sql = {
	driver = Lua.os.getenv("PROSODY_DB_DRIVER") or "PostgreSQL",
	database = Lua.os.getenv("PROSODY_DB_NAME") or "prosody",
	username = Lua.os.getenv("PROSODY_DB_USER") or "prosody",
	password = Lua.os.getenv("PROSODY_DB_PASSWORD") or "changeme",
	host = Lua.os.getenv("PROSODY_DB_HOST") or "localhost",
	port = Lua.tonumber(Lua.os.getenv("PROSODY_DB_PORT")) or 5432,

	-- Production connection pooling
	pool_size = 10,
	pool_overflow = 20,
	pool_timeout = 30,

	-- SSL/TLS for database connections
	ssl = {
		mode = "prefer",
		protocol = "tlsv1_2+",
	},
}

-- Optimized storage mapping for production
storage = {
	-- Core user data in SQL for reliability and scalability
	accounts = "sql",
	roster = "sql",
	vcard = "sql",
	private = "sql",
	blocklist = "sql",

	-- Message archives in SQL for persistence and compliance
	archive = "sql",
	muc_log = "sql",
	offline = "sql",

	-- PubSub in SQL for multi-server setups
	pubsub_nodes = "sql",
	pubsub_data = "sql",
	pep = "sql",

	-- File upload tracking in SQL
	http_file_share = "sql",

	-- Account management in SQL (Prosody 13.0+)
	account_activity = "sql",

	-- Keep performance-critical data in memory
	caps = "memory",
	carbons = "memory",
}

-- ===============================================
-- MESSAGE ARCHIVE MANAGEMENT (MAM) CONFIGURATION
-- ===============================================

-- Message archive expiry (how long messages are stored)
-- Supports: "1d", "1w", "1m", "1y", "never", or seconds as number
-- Default: "1w" (1 week), Production: "1y" (1 year) for compliance
archive_expires_after = Lua.os.getenv("PROSODY_ARCHIVE_EXPIRES_AFTER") or "1y"

-- Archive policy: who gets messages archived by default
-- false = no archiving, true = all messages, "roster" = contacts only, "always" = all messages, "never" = no archiving
-- Default: "always", but "roster" is more privacy-friendly
-- Archive policy: false, true, "always", "roster", "never"
local archive_policy_env = Lua.os.getenv("PROSODY_ARCHIVE_POLICY")
if archive_policy_env == "false" then
	default_archive_policy = false
elseif archive_policy_env == "true" or archive_policy_env == "always" then
	default_archive_policy = true
elseif archive_policy_env == "roster" then
	default_archive_policy = "roster"
elseif archive_policy_env == "never" then
	default_archive_policy = "never"
else
	default_archive_policy = true -- Default to true for development
end

-- Maximum messages returned per query (pagination)
-- Too low = many queries, too high = resource intensive
-- Default: 50, Production: 250 for better UX
max_archive_query_results = Lua.tonumber(Lua.os.getenv("PROSODY_ARCHIVE_MAX_QUERY_RESULTS")) or 250

-- Archive store name (usually should not be changed)
-- Default: "archive", Legacy: "archive2" for old installations
archive_store = Lua.os.getenv("PROSODY_ARCHIVE_STORE") or "archive"

-- Smart archiving: only enable for users who actually use MAM
-- Default: false (archive for all), true = only after first MAM query
mam_smart_enable = (Lua.os.getenv("PROSODY_MAM_SMART_ENABLE") == "true")

-- Namespaces to exclude from archiving (reduce storage)
-- Default excludes chat state notifications (typing indicators)
dont_archive_namespaces = {
	"http://jabber.org/protocol/chatstates", -- Typing indicators
	"urn:xmpp:jingle-message:0", -- Jingle messages (calls)
}

-- Optional: Add custom namespaces to exclude
local archive_exclude_env = Lua.os.getenv("PROSODY_ARCHIVE_EXCLUDE_NAMESPACES")
if archive_exclude_env then
	local custom_namespaces = {}
	for ns in Lua.string.gmatch(archive_exclude_env, "([^,]+)") do
		Lua.table.insert(custom_namespaces, ns:match("^%s*(.-)%s*$")) -- trim whitespace
	end
	-- Merge with default exclusions
	for _, ns in Lua.ipairs(custom_namespaces) do
		Lua.table.insert(dont_archive_namespaces, ns)
	end
end

-- Archive compression (save storage space)
-- Default: true for production efficiency
archive_compression = (Lua.os.getenv("PROSODY_ARCHIVE_COMPRESSION") ~= "false")

-- ===============================================
-- PROSODY 13.0+ FEATURES
-- ===============================================

-- Sub-second timestamp precision (New in 13.0)
sub_second_precision = true

-- Enhanced timestamp handling
timestamp_precision = "milliseconds"
archive_precision = "milliseconds"
log_precision = "milliseconds"

-- Channel binding enforcement
channel_binding_enforcement = "optional" -- tls-exporter binding

-- ===============================================
-- RATE LIMITING AND SECURITY
-- ===============================================

-- Connection limits and timeouts
c2s_timeout = 300 -- 5 minutes
s2s_timeout = 300 -- 5 minutes
component_timeout = 300

-- Enhanced rate limiting for production
limits = {
	c2s = {
		rate = "10kb/s",
		burst = "25kb",
		stanza_size = 1024 * 256, -- 256KB max stanza
	},
	s2s = {
		rate = "30kb/s",
		burst = "100kb",
		stanza_size = 1024 * 512, -- 512KB max stanza
	},
	http_upload = {
		rate = "2mb/s",
		burst = "10mb",
	},
}

-- Connection limits per IP
max_connections_per_ip = Lua.tonumber(Lua.os.getenv("PROSODY_MAX_CONNECTIONS_PER_IP")) or 5

-- Registration limits (production security)
allow_registration = Lua.os.getenv("PROSODY_ALLOW_REGISTRATION") == "true"
registration_throttle_max = Lua.tonumber(Lua.os.getenv("PROSODY_REGISTRATION_THROTTLE_MAX")) or 3
registration_throttle_period = Lua.tonumber(Lua.os.getenv("PROSODY_REGISTRATION_THROTTLE_PERIOD")) or 3600 -- 1 hour

-- ===============================================
-- MOBILE AND CLIENT OPTIMIZATIONS
-- ===============================================

mobile_client_patterns = {
	"Conversations",
	"ChatSecure",
	"Monal",
	"Siskin",
	"Xabber",
	"Blabber",
}

-- Enhanced CSI (Client State Indication) configuration
csi_config = {
	enabled = true,
	default_state = "active",
	-- Inactive state optimizations
	queue_presence = true,
	queue_chatstates = true,
	queue_pep = false, -- Keep PEP real-time
	delivery_delay = 30, -- 30 second delay for inactive clients
	max_delay = 300, -- Maximum 5 minute delay
	batch_stanzas = true,
	max_batch_size = 10,
	batch_timeout = 60,
}

-- Stream Management configuration with mobile optimizations
smacks_config = {
	resumption_timeout = 300, -- 5 minutes default
	max_resumption_timeout = 3600, -- 1 hour maximum
	hibernation_timeout = 60, -- 1 minute hibernation
	max_hibernation_timeout = 300, -- 5 minute maximum
	max_unacked_stanzas = 500,
	max_queue_size = 1000,
	ack_frequency = 5,
	ack_timeout = 60,
	-- Mobile-specific optimizations
	mobile_resumption_timeout = 900, -- 15 minutes for mobile
	mobile_hibernation_timeout = 300, -- 5 minutes hibernation for mobile
	mobile_ack_frequency = 10, -- Less frequent acks for mobile
}

-- ===============================================
-- HTTP SERVICES CONFIGURATION
-- ===============================================

-- HTTP server settings
http_default_host = Lua.os.getenv("PROSODY_DOMAIN") or "localhost"
http_external_url = "https://" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost") .. "/"

-- Security interfaces (IPv4 only)
http_interfaces = { "0.0.0.0" } -- HTTP accessible from all IPv4 interfaces
https_interfaces = { "0.0.0.0" } -- HTTPS on all IPv4 interfaces

-- HTTP static file serving configuration
http_files = {}

-- Optional: Additional static file serving
-- Configure via PROSODY_HTTP_FILES_DIR environment variable
if Lua.os.getenv("PROSODY_HTTP_FILES_DIR") then
	http_files_dir = Lua.os.getenv("PROSODY_HTTP_FILES_DIR")
	http_index_files = { "index.html", "index.htm" }
	http_dir_listing = (Lua.os.getenv("PROSODY_HTTP_DIR_LISTING") == "true")
	-- module:Lua.log("info", "HTTP static files enabled: %s", http_files_dir)
end

-- Trusted proxies for X-Forwarded-For headers (WebSocket/BOSH proxies)
trusted_proxies = {
	"127.0.0.1", -- Local host
	-- "::1", -- Local host IPv6
	-- Add your reverse proxy/load balancer IPs:
	-- "192.168.1.0/24", -- Local network
	-- "10.0.0.0/8", -- Private network
}

-- CORS support for web clients
-- Modern CORS configuration (replaces deprecated cross_domain_* options)
http_cors_override = {
	bosh = {
		enabled = true,
	},
	websocket = {
		enabled = true,
	},
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
http_file_share_size_limit = Lua.tonumber(Lua.os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or (100 * 1024 * 1024) -- Configurable size limit
http_file_share_daily_quota = Lua.tonumber(Lua.os.getenv("PROSODY_UPLOAD_DAILY_QUOTA")) or (1024 * 1024 * 1024) -- 1GB per day default
http_file_share_expire_after = Lua.tonumber(Lua.os.getenv("PROSODY_UPLOAD_EXPIRE_AFTER")) or (30 * 24 * 3600) -- 30 days default
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
		Lua.table.insert(types, type:match("^%s*(.-)%s*$")) -- trim whitespace
	end
	http_file_share_allowed_file_types = types
end

-- Enhanced BOSH configuration (from bosh.cfg.lua)
bosh_max_inactivity = 60 -- 60 seconds maximum inactivity
bosh_max_polling = 5 -- 5 seconds maximum polling interval
bosh_max_requests = 2 -- Maximum concurrent requests per session
bosh_max_wait = 120 -- Maximum wait time for long polling
bosh_session_timeout = 300 -- 5 minutes session timeout
bosh_hold_timeout = 60 -- 1 minute hold timeout
bosh_window = 5 -- Maximum simultaneous requests
consider_bosh_secure = false -- Set to true if behind HTTPS proxy

-- WebSocket configuration
websocket_frame_buffer_limit = 2 * 1024 * 1024 -- 2MB
websocket_frame_fragment_limit = 8
websocket_max_frame_size = 1024 * 1024 -- 1MB

-- ===============================================
-- LOGGING CONFIGURATION
-- ===============================================

-- Production logging with rotation
log = {
	{ levels = { min = Lua.os.getenv("PROSODY_LOG_LEVEL") or "info" }, to = "console" },
	{
		levels = { min = Lua.os.getenv("PROSODY_LOG_LEVEL") or "info" },
		to = "file",
		filename = "/var/log/prosody/prosody.log",
	},
	{ levels = { min = "warn" }, to = "file", filename = "/var/log/prosody/prosody.err" },
	{ levels = { "warn", "error" }, to = "file", filename = "/var/log/prosody/security.log" },
}

-- ===============================================
-- MONITORING AND METRICS CONFIGURATION
-- ===============================================

-- Statistics provider (required for metrics collection)
statistics = "internal"

-- Statistics collection interval
-- Use "manual" for single Prometheus instance (optimal performance)
-- Use scrape interval (e.g., 30) for multiple Prometheus instances
statistics_interval = Lua.os.getenv("PROSODY_STATISTICS_INTERVAL") or "manual"

-- OpenMetrics (Prometheus) configuration
-- Access control for /metrics endpoint (security critical)
openmetrics_allow_ips = {
	"127.0.0.1", -- Local access
	-- "::1", -- Local IPv6 access
}

-- Optional: Allow specific IP addresses for monitoring
local metrics_ips_env = Lua.os.getenv("PROSODY_METRICS_ALLOW_IPS")
if metrics_ips_env then
	local custom_ips = {}
	for ip in Lua.string.gmatch(metrics_ips_env, "([^,]+)") do
		Lua.table.insert(custom_ips, ip:match("^%s*(.-)%s*$")) -- trim whitespace
	end
	-- Merge with default IPs
	for _, ip in Lua.ipairs(custom_ips) do
		Lua.table.insert(openmetrics_allow_ips, ip)
	end
end

-- Optional: Allow CIDR ranges for monitoring networks
if Lua.os.getenv("PROSODY_METRICS_ALLOW_CIDR") then
	openmetrics_allow_cidr = Lua.os.getenv("PROSODY_METRICS_ALLOW_CIDR")
end

-- ===============================================
-- COMPREHENSIVE MODULE CONFIGURATION
-- ===============================================

modules_enabled = {
	-- ===============================================
	-- CORE XMPP PROTOCOL (RFC 6120/6121)
	-- ===============================================
	"roster", -- Contact management (RFC 6121)
	"saslauth", -- SASL authentication (RFC 6120)
	"tls", -- Transport Layer Security (RFC 6120)
	"dialback", -- Server dialback (XEP-0220)
	"presence", -- Presence management (RFC 6121)
	"message", -- Message handling (RFC 6121)
	"iq", -- Info/Query processing (RFC 6120)

	-- ===============================================
	-- SERVICE DISCOVERY AND CAPABILITIES
	-- ===============================================
	"disco", -- XEP-0030: Service Discovery
	"ping", -- XEP-0199: XMPP Ping
	"time", -- XEP-0202: Entity Time
	"version", -- XEP-0092: Software Version
	"lastactivity", -- XEP-0012: Last Activity

	-- ===============================================
	-- MODERN MESSAGING FEATURES (Built-in only)
	-- ===============================================
	"mam", -- XEP-0313: Message Archive Management
	"carbons", -- XEP-0280: Message Carbons
	"smacks", -- XEP-0198: Stream Management
	"csi_simple", -- XEP-0352: Client State Indication
	"offline", -- Offline message storage

	-- ===============================================
	-- MULTI-DEVICE SYNCHRONIZATION
	-- ===============================================
	"bookmarks", -- XEP-0048: Bookmarks for multi-device sync
	"pep", -- XEP-0163: Personal Eventing Protocol

	-- ===============================================
	-- USER PROFILES AND PRESENCE
	-- ===============================================
	"vcard_legacy", -- XEP-0054: vCard-temp for user profiles

	-- ===============================================
	-- PUSH NOTIFICATIONS
	-- ===============================================
	"cloud_notify", -- XEP-0357: Push Notifications (community module)

	-- ===============================================
	-- MULTI-USER CHAT (MUC)
	-- ===============================================
	-- Note: mod_muc_mam is loaded on MUC component, not main VirtualHost

	-- ===============================================
	-- FILE TRANSFER AND MEDIA
	-- ===============================================
	"http_file_share", -- XEP-0363: HTTP File Upload
	"turn_external", -- XEP-0215: External Service Discovery (TURN/STUN)

	-- ===============================================
	-- ADMINISTRATION AND MANAGEMENT
	-- ===============================================
	"admin_adhoc", -- XEP-0050: Ad-Hoc Commands for administration
	"admin_shell", -- Administrative shell interface

	-- ===============================================
	-- WEB SERVICES
	-- ===============================================
	"http", -- HTTP server for web services
	"websocket", -- XEP-0156: WebSocket support for web clients
	"bosh", -- XEP-0124/0206: BOSH support for web clients

	-- ===============================================
	-- SECURITY AND PRIVACY
	-- ===============================================
	"blocklist", -- XEP-0191: Blocking Command
	"private", -- XEP-0049: Private XML Storage

	-- ===============================================
	-- COMMUNITY MODULES (from prosody-modules)
	-- ===============================================

	-- Security and Anti-Spam
	"firewall", -- Advanced firewall rules and filtering (https://modules.prosody.im/mod_firewall.html)
	"anti_spam", -- Anti-spam filtering for messages (https://modules.prosody.im/mod_anti_spam.html)
	"spam_reporting", -- XEP-0377: Spam Reporting (https://modules.prosody.im/mod_spam_reporting.html)

	-- Administrative Tools
	"admin_blocklist", -- Administrative blocklist management (https://modules.prosody.im/mod_admin_blocklist.html)
	-- "server_contact_info", -- XEP-0157: Contact Addresses for XMPP Services - DISABLED: conflicts with built-in server_info
	"invites", -- User invitation system (https://modules.prosody.im/mod_invites.html)

	-- Mobile and Client Optimizations
	"csi_battery_saver", -- Enhanced CSI for mobile battery saving (https://modules.prosody.im/mod_csi_battery_saver.html)

	-- MUC Enhancements
	"muc_notifications", -- Enhanced MUC notifications (https://modules.prosody.im/mod_muc_notifications.html)

	-- Monitoring and Metrics
	"http_openmetrics", -- Built-in Prometheus/OpenMetrics export

	-- ===============================================
	-- DEVELOPMENT AND DEBUGGING
	-- ===============================================
	"motd", -- Message of the day
	"welcome", -- Welcome message for new users
}

-- ===============================================
-- PERFORMANCE OPTIMIZATIONS
-- ===============================================

-- Lua memory management
lua_gc_step_size = 13
lua_gc_pause = 110

-- Garbage collection tuning for production
gc = {
	speed = 200, -- More aggressive GC
	threshold = 120, -- Lower threshold
}

-- ===============================================
-- DOMAIN CONFIGURATION
-- ===============================================

-- Main domain configuration
VirtualHost(Lua.os.getenv("PROSODY_DOMAIN") or "localhost")
-- Authentication method for this domain
authentication = "internal_hashed"

-- SSL certificate for this domain
ssl = {
	key = "certs/" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost") .. ".key",
	certificate = "certs/" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost") .. ".crt",
}

-- TURN external configuration (XEP-0215)
turn_external_secret = Lua.os.getenv("TURN_SECRET") or "devsecret"
turn_external_host = Lua.os.getenv("TURN_DOMAIN") or "localhost"  
turn_external_port = Lua.tonumber(Lua.os.getenv("TURN_PORT")) or 3478
turn_external_ttl = 86400 -- 24 hours

-- ===============================================
-- SERVICE DISCOVERY CONFIGURATION (XEP-0030)
-- ===============================================

-- Service discovery items - clients can discover these services automatically
-- Components are automatically linked to VirtualHosts if they are direct subdomains
-- For example: muc.example.com is automatically linked to example.com
-- Manual linking via disco_items is needed for non-subdomain components
-- Reference: https://prosody.im/doc/components#discovery

disco_items = {
	-- Multi-User Chat service (XEP-0045)
	{ "muc." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"), "Multi-User Chat Rooms" },

	-- File upload service (XEP-0363)
	{ "upload." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"), "HTTP File Upload" },

	-- File transfer proxy (XEP-0065)
	{ "proxy." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"), "SOCKS5 File Transfer Proxy" },

	-- Pastebin service (automatic for long messages)
	{ Lua.os.getenv("PROSODY_DOMAIN") or "localhost", "Pastebin Service" },

	-- Optional: External services that can be discovered
	-- Add custom services here via environment variables
}

-- Optional: Additional disco items from environment variable
-- Format: PROSODY_DISCO_ITEMS="jid1,name1;jid2,name2"
local disco_items_env = Lua.os.getenv("PROSODY_DISCO_ITEMS")
if disco_items_env then
	local custom_items = {}
	for item in Lua.string.gmatch(disco_items_env, "([^;]+)") do
		local jid, name = item:match("([^,]+),(.+)")
		if jid and name then
			Lua.table.insert(custom_items, { jid:match("^%s*(.-)%s*$"), name:match("^%s*(.-)%s*$") })
		end
	end
	-- Merge custom items with default disco_items
	for _, item in Lua.ipairs(custom_items) do
		Lua.table.insert(disco_items, item)
	end
end

-- Admin discovery settings
disco_expose_admins = (Lua.os.getenv("PROSODY_DISCO_EXPOSE_ADMINS") == "true") -- Default: false for privacy

-- MUC (Multi-User Chat) domain
-- XEP-0045: Multi-User Chat - Group chat rooms and conferences
-- https://xmpp.org/extensions/xep-0045.html
Component("muc." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"), "muc")
name = "Multi-User Chat"
description = "Multi-User Chat rooms and conferences (XEP-0045)"

-- MUC-specific modules (must be loaded on MUC component)
modules_enabled = {
	"muc_mam", -- Message Archive Management for MUC (XEP-0313)
	"pastebin", -- Automatic pastebin for long messages (community module from prosody-modules)
}

-- Enhanced MUC configuration
max_history_messages = 50
muc_room_locking = false
muc_room_lock_timeout = 300
muc_tombstones = true
muc_room_cache_size = 1000

-- Default room configuration
muc_room_default_public = false
muc_room_default_members_only = false
muc_room_default_moderated = false
muc_room_default_persistent = true
muc_room_default_language = "en"
muc_room_default_change_subject = true

-- ===============================================
-- MUC MESSAGE ARCHIVE MANAGEMENT (MAM) CONFIGURATION
-- ===============================================

-- MUC archiving enabled by default for new rooms
-- When true, all new rooms will have archiving enabled by default
-- When false, room admins must manually enable archiving per room
-- Default: true (recommended for compliance and user experience)
muc_log_by_default = (Lua.os.getenv("PROSODY_MUC_LOG_BY_DEFAULT") ~= "false")

-- Archive presence information (joins/parts/status changes)
-- Useful for web interfaces and room activity tracking
-- Can increase storage usage significantly in busy rooms
-- Default: false (presence changes are frequent and less important)
muc_log_presences = (Lua.os.getenv("PROSODY_MUC_LOG_PRESENCES") == "true")

-- Force archiving for all rooms (disables room-level configuration)
-- When true, all rooms are archived regardless of room settings
-- When false, rooms can individually enable/disable archiving
-- Default: false (allows room-level control)
log_all_rooms = (Lua.os.getenv("PROSODY_MUC_LOG_ALL_ROOMS") == "true")

-- MUC archive expiry (how long room messages are stored)
-- Supports: "1d", "1w", "1m", "1y", "never", or seconds as number
-- Default: "1w" (1 week), Production: "1y" (1 year) for compliance
-- Note: This is separate from personal MAM expiry settings
muc_log_expires_after = Lua.os.getenv("PROSODY_MUC_LOG_EXPIRES_AFTER") or "1y"

-- MUC archive cleanup interval (how often to remove expired messages)
-- Default: 4*60*60 (4 hours), Production: 86400 (daily) for efficiency
-- Frequent cleanup reduces storage but increases CPU usage
muc_log_cleanup_interval = Lua.tonumber(Lua.os.getenv("PROSODY_MUC_LOG_CLEANUP_INTERVAL")) or 86400

-- Maximum messages returned per MUC MAM query (pagination)
-- Too low = many queries, too high = resource intensive
-- Default: 50, Production: 100-250 for better UX
muc_max_archive_query_results = Lua.tonumber(Lua.os.getenv("PROSODY_MUC_MAX_ARCHIVE_QUERY_RESULTS")) or 100

-- MUC archive store name (usually should not be changed)
-- Default: "muc_log", Legacy: "muc_archive" for old installations
muc_log_store = Lua.os.getenv("PROSODY_MUC_LOG_STORE") or "muc_log"

-- Archive compression for MUC messages (save storage space)
-- Default: true for production efficiency
muc_log_compression = (Lua.os.getenv("PROSODY_MUC_LOG_COMPRESSION") ~= "false")

-- Smart MUC archiving: only enable for rooms that actually use MAM
-- Default: false (archive for all configured rooms)
-- true = only start archiving after first MAM query in the room
muc_mam_smart_enable = (Lua.os.getenv("PROSODY_MUC_MAM_SMART_ENABLE") == "true")

-- MUC-specific namespaces to exclude from archiving
-- Reduces storage overhead by excluding less important stanzas
muc_dont_archive_namespaces = {
	"http://jabber.org/protocol/chatstates", -- Typing indicators
	"urn:xmpp:jingle-message:0", -- Jingle messages (calls)
	"http://jabber.org/protocol/muc#user", -- MUC status codes (optional)
}

-- Optional: Add custom namespaces to exclude from MUC archiving
local muc_exclude_env = Lua.os.getenv("PROSODY_MUC_ARCHIVE_EXCLUDE_NAMESPACES")
if muc_exclude_env then
	local custom_namespaces = {}
	for ns in Lua.string.gmatch(muc_exclude_env, "([^,]+)") do
		Lua.table.insert(custom_namespaces, ns:match("^%s*(.-)%s*$")) -- trim whitespace
	end
	-- Merge with default exclusions
	for _, ns in Lua.ipairs(custom_namespaces) do
		Lua.table.insert(muc_dont_archive_namespaces, ns)
	end
end

-- Archive policy for MUC rooms
-- Controls which messages get archived by default
-- "all" = archive all messages, "none" = archive nothing by default
-- Default: "all" (recommended for group chat compliance)
muc_archive_policy = Lua.os.getenv("PROSODY_MUC_ARCHIVE_POLICY") or "all"

-- Room archiving notification
-- Notify users when they join a room that has archiving enabled
-- Helps with privacy compliance (GDPR, etc.)
-- Default: true (recommended for transparency)
muc_log_notification = (Lua.os.getenv("PROSODY_MUC_LOG_NOTIFICATION") ~= "false")

-- ===============================================
-- MUC PASTEBIN CONFIGURATION
-- ===============================================

-- Maximum message length before pastebin conversion (characters)
-- Messages longer than this will be automatically converted to pastebin URLs
-- Default: 500 characters, Production: 800-1000 for better UX
pastebin_threshold = Lua.tonumber(Lua.os.getenv("PROSODY_PASTEBIN_THRESHOLD")) or 800

-- Maximum number of lines before pastebin conversion
-- Messages with more lines than this will be converted to pastebin
-- Default: 4 lines, Production: 6-8 lines for better tolerance
pastebin_line_threshold = Lua.tonumber(Lua.os.getenv("PROSODY_PASTEBIN_LINE_THRESHOLD")) or 6

-- Trigger string to force pastebin (optional)
-- If a message starts with this string, it's always sent to pastebin
-- Useful for intentionally sharing code/logs regardless of length
-- Default: not set, Example: "!paste" or "```"
local pastebin_trigger_env = Lua.os.getenv("PROSODY_PASTEBIN_TRIGGER")
if pastebin_trigger_env then
	pastebin_trigger = pastebin_trigger_env
end

-- Pastebin expiry time (hours)
-- How long pastes are stored before automatic deletion
-- Default: 24 hours, Production: 168 hours (1 week) for better UX
-- Set to 0 for permanent storage (not recommended)
pastebin_expire_after = Lua.tonumber(Lua.os.getenv("PROSODY_PASTEBIN_EXPIRE_AFTER")) or 168

-- Pastebin URL path customization
-- Customize the URL path for pastebin service
-- Default: "/pastebin/", Custom: "/$host-paste/" or "/paste/"
local pastebin_path_env = Lua.os.getenv("PROSODY_PASTEBIN_PATH")
if pastebin_path_env then
	http_paths = http_paths or {}
	http_paths.pastebin = pastebin_path_env
end

-- File upload domain
-- XEP-0363: HTTP File Upload - Allows clients to upload files via HTTP
-- https://xmpp.org/extensions/xep-0363.html
Component("upload." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"), "http_file_share")
name = "File Upload Service"
description = "HTTP file upload and sharing service (XEP-0363)"

-- File upload specific modules (if any additional modules are needed)
-- modules_enabled = {
--     -- Additional file upload modules would go here
-- }

-- Proxy domain for file transfers
-- XEP-0065: SOCKS5 Bytestreams - File transfer proxy service
-- https://xmpp.org/extensions/xep-0065.html
Component("proxy." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"), "proxy65")
name = "SOCKS5 Proxy"
description = "File transfer proxy service (XEP-0065)"
proxy65_address = Lua.os.getenv("PROSODY_DOMAIN") or "localhost"

-- ===============================================
-- EXTERNAL COMPONENTS (XEP-0114)
-- ===============================================

-- External components connect to Prosody using the component protocol (XEP-0114)
-- They run as separate processes and connect to Prosody on port 5347 (default)
-- Reference: https://prosody.im/doc/components#adding-an-external-component

-- Example external component configuration (commented out):
-- Component "bridge.example.com"
--     component_secret = "your-secret-password-here"
--     -- This would allow an external bridge (like Slidge) to connect

-- Example Telegram bridge component:
-- Component "telegram.example.com"
--     component_secret = "telegram-bridge-secret"

-- Example Discord bridge component:
-- Component "discord.example.com"
--     component_secret = "discord-bridge-secret"

-- Note: External components must be configured with the same domain and secret
-- in both Prosody's config and the external component's configuration

-- ===============================================
-- FIREWALL RULES
-- ===============================================

-- Production firewall rules for security
firewall_scripts = {
	-- Rate limiting for spam prevention
	[[
    %ZONE spam: log=debug
    RATE: 10 (burst 15) on full-jid
    TO: spam
    DROP.
    ]],

	-- Block messages from non-contacts (optional - can be enabled)
	-- [[
	-- KIND: message
	-- TYPE: chat
	-- NOT SUBSCRIBED TO SENDER: user@%MYDOMAIN%
	-- BOUNCE: service-unavailable (Messages from non-contacts not allowed)
	-- ]],

	-- Limit stanza size for DoS prevention
	[[
    %LENGTH > 262144
    BOUNCE: policy-violation (Stanza too large)
    ]],

	-- Allow registration attempts (registration is enabled)
	-- [[
	-- KIND: iq
	-- TYPE: set
	-- PAYLOAD: jabber:iq:register
	-- BOUNCE: registration-required (Registration is disabled)
	-- ]],
}

-- ===============================================
-- COMPRESSION CONFIGURATION
-- ===============================================

compression = {
	level = {
		c2s = 6, -- Moderate compression for clients
		s2s = 4, -- Lower compression for servers
	},
	algorithms = { "zlib" },
	threshold = {
		c2s = 256, -- Compress stanzas > 256 bytes
		s2s = 512, -- Compress stanzas > 512 bytes
	},
}

-- ===============================================
-- EXTERNAL SERVICES (TURN/STUN)
-- ===============================================



external_services = {
	-- Public STUN server (fallback)
	{
		type = "stun",
		host = Lua.os.getenv("PROSODY_STUN_HOST") or "stun.l.google.com",
		port = 19302,
	},
	-- Production STUN server
	{
		type = "stun",
		transport = "udp",
		host = "stun." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
	},
	-- TURN server (UDP)
	{
		type = "turn",
		transport = "udp",
		host = "turn." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
		username = "prosody",
		password = Lua.os.getenv("TURN_PASSWORD") or "changeme",
		restricted = true,
	},
	-- TURN server (TCP)
	{
		type = "turn",
		transport = "tcp",
		host = "turn." .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
		username = "prosody",
		password = Lua.os.getenv("TURN_PASSWORD") or "changeme",
		restricted = true,
	},
}

-- ===============================================
-- CONTACT INFORMATION (Compliance)
-- ===============================================

contact_info = {
	admin = {
		"xmpp:" .. (Lua.os.getenv("PROSODY_ADMIN_JID") or "admin@localhost"),
		"mailto:" .. (Lua.os.getenv("PROSODY_CONTACT_ADMIN") or "admin@localhost"),
	},
	abuse = {
		"xmpp:abuse@" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:" .. (Lua.os.getenv("PROSODY_CONTACT_ABUSE") or "abuse@localhost"),
	},
	support = {
		"xmpp:support@" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:" .. (Lua.os.getenv("PROSODY_CONTACT_SUPPORT") or "support@localhost"),
	},
	security = {
		"mailto:" .. (Lua.os.getenv("PROSODY_CONTACT_SECURITY") or "security@localhost"),
	},
}

-- ===============================================
-- PROSODY 13.0+ FEATURES
-- ===============================================

-- Enhanced roles and permissions
default_user_role = "prosody:user"
default_admin_role = "prosody:admin"

-- Account cleanup configuration
account_cleanup = {
	inactive_period = 365 * 24 * 3600, -- 1 year
	grace_period = 30 * 24 * 3600, -- 30 days notice
}

Lua.log("info", "=== PROFESSIONAL PROSODY XMPP SERVER LOADED ===")
Lua.log("info", "Domain: %s", Lua.os.getenv("PROSODY_DOMAIN") or "localhost")
Lua.log("info", "All modern XMPP features enabled - Production ready!")
-- Lua.log("info", "Modules loaded: %d", #modules_enabled) -- Temporarily disabled due to scope issue
Lua.log("info", "=== Configuration complete ===")
