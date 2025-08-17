-- ===============================================
-- CORE SERVER SETTINGS
-- ===============================================

-- Process management
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
legacy_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_LEGACY_PORTS")) or 5223 }
c2s_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_C2S_PORT")) or 5222 }
c2s_direct_tls_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_C2S_DIRECT_TLS_PORT")) or 5223 }
s2s_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_S2S_PORT")) or 5269 }
s2s_direct_tls_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_S2S_DIRECT_TLS_PORT")) or 5270 }
component_ports = { 5347 }

-- HTTP services
http_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_HTTP_PORT")) or 5280 }
https_ports = { Lua.tonumber(Lua.os.getenv("PROSODY_HTTPS_PORT")) or 5281 }

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

-- ===============================================
-- PLUGIN INSTALLER CONFIGURATION
-- ===============================================

plugin_paths = { "/usr/local/lib/prosody/community-modules" }
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

default_storage = Lua.os.getenv("PROSODY_STORAGE") or "sql"

sql = {
	driver = Lua.os.getenv("PROSODY_DB_DRIVER") or "PostgreSQL",
	database = Lua.os.getenv("PROSODY_DB_NAME") or "prosody",
	username = Lua.os.getenv("PROSODY_DB_USER") or "prosody",
	password = Lua.os.getenv("PROSODY_DB_PASSWORD") or "changeme",
	host = Lua.os.getenv("PROSODY_DB_HOST") or "localhost",
	port = Lua.tonumber(Lua.os.getenv("PROSODY_DB_PORT")) or 5432,
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

archive_expires_after = Lua.os.getenv("PROSODY_ARCHIVE_EXPIRES_AFTER") or "1y"

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
	default_archive_policy = true
end

max_archive_query_results = Lua.tonumber(Lua.os.getenv("PROSODY_ARCHIVE_MAX_QUERY_RESULTS")) or 250
archive_store = Lua.os.getenv("PROSODY_ARCHIVE_STORE") or "archive"
mam_smart_enable = (Lua.os.getenv("PROSODY_MAM_SMART_ENABLE") == "true")

dont_archive_namespaces = {
	"http://jabber.org/protocol/chatstates",
	"urn:xmpp:jingle-message:0",
}

local archive_exclude_env = Lua.os.getenv("PROSODY_ARCHIVE_EXCLUDE_NAMESPACES")
if archive_exclude_env then
	local custom_namespaces = {}
	for ns in Lua.string.gmatch(archive_exclude_env, "([^,]+)") do
		Lua.table.insert(custom_namespaces, ns:match("^%s*(.-)%s*$"))
	end
	for _, ns in Lua.ipairs(custom_namespaces) do
		Lua.table.insert(dont_archive_namespaces, ns)
	end
end

archive_compression = (Lua.os.getenv("PROSODY_ARCHIVE_COMPRESSION") ~= "false")

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
