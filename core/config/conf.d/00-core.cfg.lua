-- ===============================================
-- CORE SERVER SETTINGS
-- ===============================================

-- Process management
pidfile = "/var/run/prosody/prosody.pid"
user = "prosody"
group = "prosody"

-- Server identity
server_name = "atl.chat"
admins = { "admin@atl.chat" }

-- ===============================================
-- NETWORK CONFIGURATION
-- ===============================================

-- Standard XMPP ports
c2s_ports = { 5222 } -- Client-to-server connections
c2s_direct_tls_ports = { 5223 } -- Direct TLS C2S connections
s2s_ports = { 5269 } -- Server-to-server connections
s2s_direct_tls_ports = { 5270 } -- Direct TLS S2S connections
component_ports = { 5347 } -- Component connections

-- HTTP ports for web services
http_ports = { 5280 } -- HTTP (insecure)
https_ports = { 5281 } -- HTTPS (secure)

-- Network interfaces
interfaces = { "0.0.0.0" } -- All IPv4 interfaces
local_interfaces = { "127.0.0.1" } -- Localhost only
external_addresses = {} -- Auto-detect external IP

-- IPv6 configuration
use_ipv6 = false -- Disabled for simplicity

-- Network performance settings
network_backend = "event" -- Use libevent for high concurrency
network_settings = {
	read_timeout = 840, -- 14 minutes (proxy timeouts should be 900+)
}

-- ===============================================
-- TLS/SSL SECURITY
-- ===============================================

-- Global TLS configuration
ssl = {
	protocol = "tlsv1_2+",
	ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
	curve = "secp384r1",
	options = { "cipher_server_preference", "single_dh_use", "single_ecdh_use" },
}

-- Certificate location (Let's Encrypt)
certificates = "certs"

-- Encryption requirements
c2s_require_encryption = true -- Force TLS for client connections
s2s_require_encryption = true -- Force TLS for server connections
s2s_secure_auth = true -- Verify server certificates
allow_unencrypted_plain_auth = false -- Block plaintext authentication

-- ===============================================
-- AUTHENTICATION
-- ===============================================

authentication = "internal_hashed" -- Hashed password storage

-- Supported SASL mechanisms (ordered by preference)
sasl_mechanisms = {
	"SCRAM-SHA-256", -- Most secure
	"SCRAM-SHA-1",
	"DIGEST-MD5",
	"PLAIN", -- Fallback (encrypted channel only)
}

tls_channel_binding = true -- Enhanced security via channel binding

-- Account management
user_account_management = {
	grace_period = 7 * 24 * 3600, -- 7 days before deletion
	deletion_confirmation = true, -- Require confirmation
}

-- ===============================================
-- DATA STORAGE
-- ===============================================

default_storage = "sql"

-- PostgreSQL configuration
sql = {
	driver = "PostgreSQL",
	database = "prosody",
	username = "prosody",
	password = "ChangeMe123!", -- TODO: Use environment variable
	host = "xmpp-postgres",
	port = 5432,

	-- Connection pooling
	pool_size = 10,
	pool_overflow = 20,
	pool_timeout = 30,

	-- TLS for database connection
	ssl = { mode = "prefer", protocol = "tlsv1_2+" },
}

-- Storage backend assignments
storage = {
	-- User data
	accounts = "sql",
	roster = "sql",
	vcard = "sql",
	private = "sql",
	blocklist = "sql",

	-- Message archives
	archive = "sql",
	muc_log = "sql",
	offline = "sql",

	-- PubSub and PEP
	pubsub_nodes = "sql",
	pubsub_data = "sql",
	pep = "sql",

	-- File sharing
	http_file_share = "sql",

	-- Activity tracking
	account_activity = "sql",

	-- Memory-only (ephemeral)
	caps = "memory", -- Entity capabilities cache
	carbons = "memory", -- Message carbons state
}

-- ===============================================
-- MESSAGE ARCHIVING (MAM)
-- ===============================================

-- Archive retention and policy
archive_expires_after = "1y" -- Keep messages for 1 year
default_archive_policy = true -- Archive all conversations by default
archive_compression = true -- Compress archived messages
archive_store = "archive" -- Storage backend for archives

-- Query limits
max_archive_query_results = 250 -- Limit results per query
mam_smart_enable = false -- Disable smart archiving

-- Namespaces to exclude from archiving
dont_archive_namespaces = {
	"http://jabber.org/protocol/chatstates", -- Chat state notifications
	"urn:xmpp:jingle-message:0", -- Jingle messages
}

-- ===============================================
-- MOBILE CLIENT OPTIMIZATIONS
-- ===============================================

-- Client detection patterns
mobile_client_patterns = {
	"Conversations",
	"ChatSecure",
	"Monal",
	"Siskin",
	"Xabber",
	"Blabber",
}

-- Client State Indication (XEP-0352)
csi_config = {
	enabled = true,
	default_state = "active",
	queue_presence = true, -- Queue presence updates when inactive
	queue_chatstates = true, -- Queue chat state notifications
	queue_pep = false, -- Don't queue PEP events
	delivery_delay = 30, -- Delay before batching (seconds)
	max_delay = 300, -- Maximum delay (5 minutes)
	batch_stanzas = true, -- Batch multiple stanzas
	max_batch_size = 10, -- Maximum stanzas per batch
	batch_timeout = 60, -- Batch timeout (seconds)
}

-- Stream Management (XEP-0198)
smacks_config = {
	-- Session resumption timeouts
	resumption_timeout = 300, -- 5 minutes
	max_resumption_timeout = 3600, -- 1 hour maximum
	hibernation_timeout = 60, -- 1 minute
	max_hibernation_timeout = 300, -- 5 minutes maximum

	-- Queue management
	max_unacked_stanzas = 500, -- Maximum unacknowledged stanzas
	max_queue_size = 1000, -- Maximum queue size

	-- Acknowledgment settings
	ack_frequency = 5, -- Request ack every 5 stanzas
	ack_timeout = 60, -- Timeout for ack requests

	-- Mobile-specific settings
	mobile_resumption_timeout = 900, -- 15 minutes for mobile
	mobile_hibernation_timeout = 300, -- 5 minutes for mobile
	mobile_ack_frequency = 10, -- Less frequent acks for mobile
}

-- ===============================================
-- PLUGIN MANAGEMENT
-- ===============================================

plugin_paths = {
	"/usr/local/lib/prosody/community-modules",
	"/var/lib/prosody/custom_plugins",
}
plugin_server = "https://modules.prosody.im/rocks/"

-- ===============================================
-- PERFORMANCE TUNING
-- ===============================================

-- Lua garbage collection
lua_gc_step_size = 13 -- GC step size
lua_gc_pause = 110 -- GC pause percentage

-- Enhanced garbage collection
gc = {
	speed = 200, -- Collection speed
	threshold = 120, -- Memory threshold percentage
}
