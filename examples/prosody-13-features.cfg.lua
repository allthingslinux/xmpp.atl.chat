-- ===============================================
-- PROSODY 13.0+ FEATURES DEMONSTRATION
-- ===============================================
-- Example configuration showcasing modern Prosody features
-- Based on official Prosody documentation best practices
-- Includes credential management, file directives, and advanced logging

-- ===============================================
-- MODERN FILE AND CREDENTIAL MANAGEMENT
-- ===============================================

-- Administrator list from external file (Prosody 13.0+)
-- Enables dynamic admin management without config reload
-- File format: one JID per line
-- admins = FileLines("config/security/admin-list.txt")

-- Message of the day from system MOTD
-- Integrates with system announcements
-- motd_text = FileContents("/etc/motd")

-- SSL certificate path from external config
-- Enables automated certificate rotation
-- ssl_certificate = FileLine("config/tls/cert-path.txt")

-- Secure credential management (requires CREDENTIALS_DIRECTORY)
-- Compatible with systemd LoadCredential= and podman secrets
local credentials_available = os.getenv("CREDENTIALS_DIRECTORY")
if credentials_available then
	-- Database credentials
	-- sql = {
	--     driver = "PostgreSQL",
	--     database = "prosody",
	--     username = "prosody",
	--     password = Credential("db_password"), -- Secure credential loading
	--     host = "localhost"
	-- }

	-- LDAP authentication credentials
	-- ldap_base = "dc=example,dc=com"
	-- ldap_password = Credential("ldap_password")

	-- External component secrets
	-- component_secret = Credential("component_secret")
end

-- ===============================================
-- ADVANCED LOGGING CONFIGURATION
-- ===============================================

-- Enhanced logging based on Prosody documentation
-- Supports multiple log targets with different levels
log = {
	-- Console output for development
	{
		levels = { min = "debug" },
		to = "console",
		timestamps = true,
	},

	-- Main application log
	{
		levels = { min = "info" },
		to = "file",
		filename = "/var/log/prosody/prosody.log",
		timestamps = true,
	},

	-- Security events log
	{
		levels = { "warn", "error" },
		to = "file",
		filename = "/var/log/prosody/security.log",
		timestamps = true,
	},

	-- Performance monitoring log
	{
		events = { "authentication-success", "authentication-failure", "s2s-authenticated" },
		to = "file",
		filename = "/var/log/prosody/audit.log",
		timestamps = true,
	},

	-- Syslog integration (when mod_posix loaded)
	{
		levels = { min = "warn" },
		to = "*syslog",
		syslog_name = "prosody",
		syslog_facility = "daemon",
	},
}

-- ===============================================
-- MODERN SECURITY CONFIGURATION
-- ===============================================

-- Enhanced TLS configuration
-- Based on Mozilla security guidelines
tls_profile = "intermediate" -- Options: modern, intermediate, old, legacy

-- Force encryption for all connections
c2s_require_encryption = true
s2s_require_encryption = true

-- Modern certificate management
-- Automatic certificate location (Prosody 12.0+)
-- certificates = "certs" -- Auto-discover certificates

-- Enhanced POSIX security (Prosody 13.0+)
-- No longer requires mod_posix
pidfile = "/run/prosody/prosody.pid"
umask = "027" -- Restrictive file permissions

-- ===============================================
-- HTTP/HTTPS CONFIGURATION
-- ===============================================

-- Modern HTTP server configuration
-- XEP-0124: BOSH, XEP-0206: XMPP over BOSH
-- RFC 7395: WebSocket subprotocol for XMPP

modules_enabled = {
	-- Core HTTP modules
	"http",
	"http_files",

	-- Modern web interfaces
	"websocket", -- RFC 7395: WebSocket support
	"bosh", -- XEP-0124/0206: BOSH support

	-- File upload (XEP-0363)
	"http_upload",
}

-- HTTP configuration
http_ports = { 5280 }
https_ports = { 5281 }

-- Cross-domain policy for web clients
cross_domain_bosh = true
cross_domain_websocket = true

-- ===============================================
-- MODERN XMPP EXTENSIONS
-- ===============================================

-- Message Archive Management (XEP-0313)
-- Modern message history and synchronization
archive_expires_after = "1y" -- One year retention
max_archive_query_results = 50

-- Stream Management (XEP-0198)
-- Resumable streams for mobile clients
smacks_hibernation_time = 600 -- 10 minutes

-- Client State Indication (XEP-0352)
-- Power-efficient mobile client support
csi_battery_optimization = true

-- Message Carbons (XEP-0280)
-- Multi-device message synchronization
carbons_admin_opt_out = false

-- ===============================================
-- PERFORMANCE OPTIMIZATIONS
-- ===============================================

-- Connection limits for production
limits = {
	c2s = {
		rate = "10mb/s",
		burst = "20mb",
		stanza_size = 262144, -- 256KB
	},
	s2sin = {
		rate = "5mb/s",
		burst = "10mb",
		stanza_size = 524288, -- 512KB
	},
}

-- Memory optimizations
-- Lua garbage collection tuning
statistics = "internal" -- Built-in statistics
statistics_interval = 60 -- 1 minute intervals

-- ===============================================
-- COMPLIANCE AND MONITORING
-- ===============================================

-- Enable compliance monitoring
-- Track XEP implementation status
-- compliance_monitoring = true

-- Health check endpoints
-- For load balancer integration
-- health_check_interval = 30

-- Example VirtualHost with modern features
VirtualHost("example.com")
-- Enable all modern messaging features
modules_enabled = {
	-- Core messaging
	"roster",
	"saslauth",
	"tls",
	"disco",
	"ping",

	-- Modern messaging
	"mam", -- XEP-0313: Message archiving
	"smacks", -- XEP-0198: Stream management
	"csi_simple", -- XEP-0352: Client state indication
	"carbons", -- XEP-0280: Message carbons

	-- File sharing
	"http_upload", -- XEP-0363: HTTP file upload

	-- Presence and roster
	"vcard", -- XEP-0054: vCard support
	"private", -- XEP-0049: Private storage
}

-- Enhanced authentication
authentication = "internal_hashed"

-- Message archiving configuration
archive_expires_after = "1y"
default_archive_policy = "roster" -- Archive messages from roster contacts

-- Example MUC component with modern features
Component("conference.example.com")("muc")
modules_enabled = {
	"muc_mam", -- Message archiving for chat rooms
	"muc_limits", -- Room size and rate limits
	"vcard_muc", -- Room information via vCard
}

-- Room defaults
muc_room_default_public = false
muc_room_default_members_only = true
muc_room_default_moderated = false
muc_room_default_persistent = true
muc_room_default_history_length = 20

-- ===============================================
-- DEVELOPMENT AND DEBUGGING
-- ===============================================

-- Development-specific settings
-- Remove or adjust for production

-- Enhanced debugging
debug = {
	stanza_log = true,
	auth_log = true,
	s2s_log = true,
}

-- Module development support
-- plugin_paths = { "./custom-modules" }

-- Configuration validation
-- validate_config = true

print("Prosody 13.0+ feature demonstration loaded")
print("Configuration includes modern security, logging, and XMPP features")
