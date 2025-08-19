-- ===============================================
-- CORE SERVER SETTINGS
-- ===============================================

-- Process management
pidfile = "/var/run/prosody/prosody.pid"
user = "prosody"
group = "prosody"

-- Server identity (hardcoded)
server_name = "atl.chat"
admins = { "admin@atl.chat" }

-- ===============================================
-- NETWORK AND CONNECTION SETTINGS
-- ===============================================

c2s_ports = { 5222 }
c2s_direct_tls_ports = { 5223 }
s2s_ports = { 5269 }
s2s_direct_tls_ports = { 5270 }
component_ports = { 5347 }

http_ports = { 5280 }
https_ports = { 5281 }

-- Interface bindings (IPv4 only)
interfaces = { "0.0.0.0" }
local_interfaces = { "127.0.0.1" }

external_addresses = {}

-- IPv6 support (disabled)
use_ipv6 = false

-- Network timeouts (critical for WebSocket proxies)
-- Proxy timeouts should be higher than this (900+ seconds)
network_settings = {
	read_timeout = 840,
}

-- Use libevent-backed network loop for high concurrency
network_backend = "event"

-- ===============================================
-- PLUGIN INSTALLER CONFIGURATION
-- ===============================================

plugin_paths = { "/usr/local/lib/prosody/community-modules", "/var/lib/prosody/custom_plugins" }
plugin_server = "https://modules.prosody.im/rocks/"

-- ===============================================
-- TLS/SSL CONFIGURATION
-- ===============================================

ssl = {
	protocol = "tlsv1_2+",
	ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
	curve = "secp384r1",
	options = { "cipher_server_preference", "single_dh_use", "single_ecdh_use" },
}

-- Using Let's Encrypt live certs mounted at /etc/prosody/certs
certificates = "certs"

c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true
allow_unencrypted_plain_auth = false

-- ===============================================
-- AUTHENTICATION CONFIGURATION
-- ===============================================

authentication = "internal_hashed"

sasl_mechanisms = {
	"SCRAM-SHA-256",
	"SCRAM-SHA-1",
	"DIGEST-MD5",
	"PLAIN",
}

tls_channel_binding = true

user_account_management = {
	grace_period = 7 * 24 * 3600,
	deletion_confirmation = true,
}

-- ===============================================
-- STORAGE CONFIGURATION
-- ===============================================

default_storage = "sql"

sql = {
	driver = "PostgreSQL",
	database = "prosody",
	username = "prosody",
	password = "changeme",
	host = "xmpp-postgres",
	port = 5432,
	pool_size = 10,
	pool_overflow = 20,
	pool_timeout = 30,
	ssl = { mode = "prefer", protocol = "tlsv1_2+" },
}

storage = {
	accounts = "sql",
	roster = "sql",
	vcard = "sql",
	private = "sql",
	blocklist = "sql",
	archive = "sql",
	muc_log = "sql",
	offline = "sql",
	pubsub_nodes = "sql",
	pubsub_data = "sql",
	pep = "sql",
	http_file_share = "sql",
	account_activity = "sql",
	caps = "memory",
	carbons = "memory",
}

-- ===============================================
-- MESSAGE ARCHIVE MANAGEMENT (GLOBAL)
-- ===============================================

archive_expires_after = "1y"

default_archive_policy = true

max_archive_query_results = 250
archive_store = "archive"
mam_smart_enable = false

dont_archive_namespaces = {
	"http://jabber.org/protocol/chatstates",
	"urn:xmpp:jingle-message:0",
}

archive_compression = true

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

csi_config = {
	enabled = true,
	default_state = "active",
	queue_presence = true,
	queue_chatstates = true,
	queue_pep = false,
	delivery_delay = 30,
	max_delay = 300,
	batch_stanzas = true,
	max_batch_size = 10,
	batch_timeout = 60,
}

smacks_config = {
	resumption_timeout = 300,
	max_resumption_timeout = 3600,
	hibernation_timeout = 60,
	max_hibernation_timeout = 300,
	max_unacked_stanzas = 500,
	max_queue_size = 1000,
	ack_frequency = 5,
	ack_timeout = 60,
	mobile_resumption_timeout = 900,
	mobile_hibernation_timeout = 300,
	mobile_ack_frequency = 10,
}

-- ===============================================
-- PERFORMANCE OPTIMIZATIONS
-- ===============================================

lua_gc_step_size = 13
lua_gc_pause = 110

gc = {
	speed = 200,
	threshold = 120,
}
