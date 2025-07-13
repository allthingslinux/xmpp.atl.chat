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
daemonize = true
pidfile = "/var/run/prosody/prosody.pid"
user = "prosody"
group = "prosody"

-- Server identity
server_name = os.getenv("PROSODY_DOMAIN") or "localhost"
admins = { os.getenv("PROSODY_ADMIN_JID") or "admin@localhost" }

-- ===============================================
-- NETWORK AND CONNECTION SETTINGS
-- ===============================================

-- Standard XMPP ports (RFC 6120/6121)
c2s_ports = { tonumber(os.getenv("PROSODY_C2S_PORT")) or 5222 } -- Client-to-server (STARTTLS)
legacy_ssl_ports = { tonumber(os.getenv("PROSODY_C2S_DIRECT_TLS_PORT")) or 5223 } -- Direct TLS (legacy support)
s2s_ports = { tonumber(os.getenv("PROSODY_S2S_PORT")) or 5269 } -- Server-to-server
s2s_direct_tls_ports = { tonumber(os.getenv("PROSODY_S2S_DIRECT_TLS_PORT")) or 5270 } -- Server-to-server Direct TLS
component_ports = { 5347 } -- External components

-- HTTP services
http_ports = { tonumber(os.getenv("PROSODY_HTTP_PORT")) or 5280 } -- HTTP (BOSH, file upload, admin)
https_ports = { tonumber(os.getenv("PROSODY_HTTPS_PORT")) or 5281 } -- HTTPS (secure services)

-- Interface bindings
interfaces = { "*" }
local_interfaces = { "127.0.0.1", "::1" }

-- IPv6 support
use_ipv6 = true

-- Network timeouts (critical for WebSocket proxies)
-- Proxy timeouts should be higher than this (900+ seconds)
-- Reference: https://prosody.im/doc/websocket
network_settings = {
	read_timeout = 840, -- 14 minutes (Prosody 0.12.0+ default)
}

-- ===============================================
-- TLS/SSL CONFIGURATION
-- ===============================================

-- Enhanced TLS settings for modern security
ssl = {
	protocol = "tlsv1_2+", -- TLS 1.2+ only
	ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
	curve = "secp384r1", -- Strong elliptic curve
	verifyext = { "lsExtKeyUsage" },
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
default_storage = os.getenv("PROSODY_STORAGE") or "sql"

-- SQL configuration for production scalability
sql = {
	driver = os.getenv("PROSODY_DB_DRIVER") or "PostgreSQL",
	database = os.getenv("PROSODY_DB_NAME") or "prosody",
	username = os.getenv("PROSODY_DB_USER") or "prosody",
	password = os.getenv("PROSODY_DB_PASSWORD") or "changeme",
	host = os.getenv("PROSODY_DB_HOST") or "localhost",
	port = tonumber(os.getenv("PROSODY_DB_PORT")) or 5432,

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

-- Archive settings with enhanced configuration
archive_expires_after = "1 year"
default_archive_policy = "roster"
max_archive_query_results = 250

-- Archive compression and cleanup (from archiving.cfg.lua)
archive_compression = true -- Compress archived messages
archive_cleanup_interval = 86400 -- Daily cleanup (seconds)

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
max_connections_per_ip = tonumber(os.getenv("PROSODY_MAX_CONNECTIONS_PER_IP")) or 5

-- Registration limits (production security)
allow_registration = os.getenv("PROSODY_ALLOW_REGISTRATION") == "true"
registration_throttle_max = tonumber(os.getenv("PROSODY_REGISTRATION_THROTTLE_MAX")) or 3
registration_throttle_period = tonumber(os.getenv("PROSODY_REGISTRATION_THROTTLE_PERIOD")) or 3600 -- 1 hour

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
http_default_host = os.getenv("PROSODY_DOMAIN") or "localhost"
http_external_url = "https://" .. (os.getenv("PROSODY_DOMAIN") or "localhost") .. "/"

-- Security interfaces (production best practice)
http_interfaces = { "*", "::" } -- HTTP accessible from internet for Let's Encrypt
https_interfaces = { "*", "::" } -- HTTPS on all interfaces

-- HTTP static file serving configuration
-- Let's Encrypt webroot (required for certificate validation)
http_files = {
	["/.well-known/acme-challenge/"] = "/var/www/certbot/.well-known/acme-challenge/",
}

-- Optional: Additional static file serving
-- Configure via PROSODY_HTTP_FILES_DIR environment variable
if os.getenv("PROSODY_HTTP_FILES_DIR") then
	http_files_dir = os.getenv("PROSODY_HTTP_FILES_DIR")
	http_index_files = { "index.html", "index.htm" }
	http_dir_listing = (os.getenv("PROSODY_HTTP_DIR_LISTING") == "true")
	log("info", "HTTP static files enabled: %s", http_files_dir)
end

-- Trusted proxies for X-Forwarded-For headers (WebSocket/BOSH proxies)
trusted_proxies = {
	"127.0.0.1", -- Local host
	"::1", -- Local host IPv6
	-- Add your reverse proxy/load balancer IPs:
	-- "192.168.1.0/24", -- Local network
	-- "10.0.0.0/8", -- Private network
}

-- CORS support for web clients
cross_domain_bosh = true
cross_domain_websocket = true

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
http_file_share_size_limit = tonumber(os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or (100 * 1024 * 1024) -- Configurable size limit
http_file_share_daily_quota = tonumber(os.getenv("PROSODY_UPLOAD_DAILY_QUOTA")) or (1024 * 1024 * 1024) -- 1GB per day default
http_file_share_expire_after = tonumber(os.getenv("PROSODY_UPLOAD_EXPIRE_AFTER")) or (30 * 24 * 3600) -- 30 days default
http_file_share_path = os.getenv("PROSODY_UPLOAD_PATH") or "/var/lib/prosody/http_file_share"

-- Optional: Global quota (total storage limit across all users)
if os.getenv("PROSODY_UPLOAD_GLOBAL_QUOTA") then
	http_file_share_global_quota = tonumber(os.getenv("PROSODY_UPLOAD_GLOBAL_QUOTA"))
end

-- Optional: Allowed file types restriction
if os.getenv("PROSODY_UPLOAD_ALLOWED_TYPES") then
	local types = {}
	for type in string.gmatch(os.getenv("PROSODY_UPLOAD_ALLOWED_TYPES"), "([^,]+)") do
		table.insert(types, type:match("^%s*(.-)%s*$")) -- trim whitespace
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
	{ levels = { min = os.getenv("PROSODY_LOG_LEVEL") or "info" }, to = "console" },
	{
		levels = { min = os.getenv("PROSODY_LOG_LEVEL") or "info" },
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
statistics_interval = os.getenv("PROSODY_STATISTICS_INTERVAL") or "manual"

-- OpenMetrics (Prometheus) configuration
-- Access control for /metrics endpoint (security critical)
openmetrics_allow_ips = {
	"127.0.0.1", -- Local access
	"::1", -- Local IPv6 access
}

-- Optional: Allow specific IP addresses for monitoring
if os.getenv("PROSODY_METRICS_ALLOW_IPS") then
	local custom_ips = {}
	for ip in string.gmatch(os.getenv("PROSODY_METRICS_ALLOW_IPS"), "([^,]+)") do
		table.insert(custom_ips, ip:match("^%s*(.-)%s*$")) -- trim whitespace
	end
	-- Merge with default IPs
	for _, ip in ipairs(custom_ips) do
		table.insert(openmetrics_allow_ips, ip)
	end
end

-- Optional: Allow CIDR ranges for monitoring networks
if os.getenv("PROSODY_METRICS_ALLOW_CIDR") then
	openmetrics_allow_cidr = os.getenv("PROSODY_METRICS_ALLOW_CIDR")
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
	"presence_dedup", -- Deduplicate presence stanzas
	"presence_cache", -- Cache presence information
	"message", -- Message handling (RFC 6121)
	"iq", -- Info/Query processing (RFC 6120)

	-- ===============================================
	-- SERVICE DISCOVERY AND CAPABILITIES
	-- ===============================================
	"disco", -- XEP-0030: Service Discovery
	"caps", -- XEP-0115: Entity Capabilities
	"ping", -- XEP-0199: XMPP Ping
	"time", -- XEP-0202: Entity Time
	"version", -- XEP-0092: Software Version
	"lastactivity", -- XEP-0012: Last Activity
	"last", -- XEP-0012: Last Activity (core module)
	"idle", -- XEP-0319: Last User Interaction in Presence
	"server_info", -- XEP-0157: Contact Addresses
	"extdisco", -- XEP-0215: External Service Discovery

	-- ===============================================
	-- MODERN MESSAGING FEATURES
	-- ===============================================
	"mam", -- XEP-0313: Message Archive Management
	"carbons", -- XEP-0280: Message Carbons
	"smacks", -- XEP-0198: Stream Management
	"smacks_offline", -- Offline message handling with SM
	"csi_simple", -- XEP-0352: Client State Indication
	"csi_battery_saver", -- Battery optimization for mobile clients
	"offline", -- Offline message storage
	"addressing", -- XEP-0033: Extended Stanza Addressing
	"receipts", -- XEP-0184: Message Delivery Receipts

	-- ===============================================
	-- MULTI-USER CHAT (MUC)
	-- ===============================================
	"muc", -- XEP-0045: Multi-User Chat
	"muc_mam", -- XEP-0313: MAM for MUC
	"muc_unique", -- XEP-0307: Unique Room Names

	-- ===============================================
	-- PERSONAL EVENTING PROTOCOL (PEP)
	-- ===============================================
	"pep", -- XEP-0163: Personal Eventing Protocol
	"pubsub", -- XEP-0060: Publish-Subscribe
	"bookmarks", -- XEP-0402: PEP Native Bookmarks
	"vcard4", -- XEP-0292: vCard4 Over XMPP
	"vcard_legacy", -- Legacy vCard support
	"private", -- XEP-0049: Private XML Storage

	-- ===============================================
	-- FILE TRANSFER AND SHARING
	-- ===============================================
	"http_file_share", -- XEP-0363: HTTP File Upload (recommended)
	"proxy65", -- XEP-0065: SOCKS5 Bytestreams

	-- ===============================================
	-- PUSH NOTIFICATIONS AND MOBILE
	-- ===============================================
	"cloud_notify", -- XEP-0357: Push Notifications

	-- ===============================================
	-- PRIVACY AND BLOCKING
	-- ===============================================
	"blocklist", -- XEP-0191: Blocking Command
	"privacy", -- XEP-0016: Privacy Lists (legacy support)

	-- ===============================================
	-- HTTP SERVICES AND WEB CLIENTS
	-- ===============================================
	"http", -- Core HTTP server
	"http_files", -- Static file serving
	"bosh", -- XEP-0124: BOSH (HTTP binding)
	"websocket", -- RFC 7395: WebSocket support
	"http_altconnect", -- XEP-0156: Alternative connection methods

	-- ===============================================
	-- EXTERNAL SERVICES
	-- ===============================================
	"external_services", -- XEP-0215: External Service Discovery
	"turncredentials", -- TURN credentials for WebRTC

	-- ===============================================
	-- SECURITY AND ANTI-SPAM
	-- ===============================================
	"limits", -- Rate limiting and abuse prevention
	"firewall", -- Advanced stanza firewall
	"filter_chatstates", -- Filter chat state notifications
	"spam_reporting", -- XEP-0377: Spam Reporting

	-- ===============================================
	-- COMPONENT PROTOCOL SUPPORT
	-- ===============================================
	"component", -- XEP-0114: Component Protocol

	-- ===============================================
	-- ADMINISTRATION AND MONITORING
	-- ===============================================
	"admin_web", -- Web administration interface
	"http_openmetrics", -- Prometheus metrics
	"statistics", -- Basic statistics
	"posix", -- POSIX system integration
	"watchdog", -- Process monitoring
	"uptime", -- Server uptime tracking

	-- ===============================================
	-- ENHANCED MONITORING (Production)
	-- ===============================================
	"measure_client_connections", -- Connection metrics
	"measure_stanza_counts", -- Stanza processing metrics
	"measure_message_e2ee", -- E2E encryption metrics
	"stanza_counter", -- Count and monitor stanzas

	-- ===============================================
	-- ACCOUNT MANAGEMENT (Prosody 13.0+)
	-- ===============================================
	"user_account_management", -- Enhanced account management
	"account_activity", -- Last login/logout tracking (13.0+)

	-- ===============================================
	-- PRODUCTION-SPECIFIC MODULES
	-- ===============================================
	"watchregistrations", -- Monitor registrations
	"tombstones", -- User deletion handling
	"server_contact_info", -- Server contact information
	"register_limits", -- Registration rate limiting
	"register_ibr", -- In-band registration support

	-- ===============================================
	-- PROSODY 13.0+ FEATURES
	-- ===============================================
	"flags", -- Enhanced metadata tracking
	"s2s_auth_dane_in", -- DANE authentication for S2S

	-- ===============================================
	-- COMPRESSION AND OPTIMIZATION
	-- ===============================================
	"compression", -- XEP-0138: Stream Compression

	-- ===============================================
	-- COMPONENT SUPPORT
	-- ===============================================
	"component", -- XEP-0114: Component Protocol
}

-- ===============================================
-- DOMAIN CONFIGURATION
-- ===============================================

-- Main domain configuration
VirtualHost(os.getenv("PROSODY_DOMAIN") or "localhost")
-- Authentication method for this domain
authentication = "internal_hashed"

-- SSL certificate for this domain
ssl = {
	key = "certs/" .. (os.getenv("PROSODY_DOMAIN") or "localhost") .. ".key",
	certificate = "certs/" .. (os.getenv("PROSODY_DOMAIN") or "localhost") .. ".crt",
}

-- ===============================================
-- SERVICE DISCOVERY CONFIGURATION (XEP-0030)
-- ===============================================

-- Service discovery items - clients can discover these services automatically
disco_items = {
	-- Multi-User Chat service
	{ "muc." .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "Multi-User Chat Rooms" },

	-- File upload service (XEP-0363)
	{ "upload." .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "HTTP File Upload" },

	-- File transfer proxy (XEP-0065)
	{ "proxy." .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "SOCKS5 File Transfer Proxy" },

	-- Optional: External services that can be discovered
	-- Add custom services here via environment variables
}

-- Optional: Additional disco items from environment variable
-- Format: PROSODY_DISCO_ITEMS="jid1,name1;jid2,name2"
if os.getenv("PROSODY_DISCO_ITEMS") then
	local custom_items = {}
	for item in string.gmatch(os.getenv("PROSODY_DISCO_ITEMS"), "([^;]+)") do
		local jid, name = item:match("([^,]+),(.+)")
		if jid and name then
			table.insert(custom_items, { jid:match("^%s*(.-)%s*$"), name:match("^%s*(.-)%s*$") })
		end
	end
	-- Merge custom items with default disco_items
	for _, item in ipairs(custom_items) do
		table.insert(disco_items, item)
	end
end

-- Admin discovery settings
disco_expose_admins = (os.getenv("PROSODY_DISCO_EXPOSE_ADMINS") == "true") -- Default: false for privacy

-- MUC (Multi-User Chat) domain
Component("muc." .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "muc")
name = "Multi-User Chat"
description = "Multi-User Chat rooms"

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

-- File upload domain
Component("upload." .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "http_file_share")
name = "File Upload Service"
description = "HTTP file upload and sharing service"

-- Proxy domain for file transfers
Component("proxy." .. (os.getenv("PROSODY_DOMAIN") or "localhost"), "proxy65")
name = "SOCKS5 Proxy"
description = "File transfer proxy service"
proxy65_address = os.getenv("PROSODY_DOMAIN") or "localhost"

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
		host = os.getenv("PROSODY_STUN_HOST") or "stun.l.google.com",
		port = 19302,
	},
	-- Production STUN server
	{
		type = "stun",
		transport = "udp",
		host = "stun." .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
	},
	-- TURN server (UDP)
	{
		type = "turn",
		transport = "udp",
		host = "turn." .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
		username = "prosody",
		password = os.getenv("TURN_PASSWORD") or "changeme",
		restricted = true,
	},
	-- TURN server (TCP)
	{
		type = "turn",
		transport = "tcp",
		host = "turn." .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
		username = "prosody",
		password = os.getenv("TURN_PASSWORD") or "changeme",
		restricted = true,
	},
}

-- ===============================================
-- CONTACT INFORMATION (Compliance)
-- ===============================================

contact_info = {
	admin = {
		"xmpp:" .. (os.getenv("PROSODY_ADMIN_JID") or "admin@localhost"),
		"mailto:" .. (os.getenv("PROSODY_CONTACT_ADMIN") or "admin@localhost"),
	},
	abuse = {
		"xmpp:abuse@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:" .. (os.getenv("PROSODY_CONTACT_ABUSE") or "abuse@localhost"),
	},
	support = {
		"xmpp:support@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:" .. (os.getenv("PROSODY_CONTACT_SUPPORT") or "support@localhost"),
	},
	security = {
		"mailto:" .. (os.getenv("PROSODY_CONTACT_SECURITY") or "security@localhost"),
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

-- ===============================================
-- PERFORMANCE OPTIMIZATIONS
-- ===============================================

-- Garbage collection tuning for production
gc = {
	speed = 200, -- More aggressive GC
	threshold = 120, -- Lower threshold
}

-- Lua memory management
lua_gc_step_size = 13
lua_gc_pause = 110

log("info", "=== PROFESSIONAL PROSODY XMPP SERVER LOADED ===")
log("info", "Domain: %s", os.getenv("PROSODY_DOMAIN") or "localhost")
log("info", "Storage: %s", default_storage)
log("info", "All modern XMPP features enabled - Production ready!")
log("info", "Modules loaded: %d", #modules_enabled)
log("info", "=== Configuration complete ===")
