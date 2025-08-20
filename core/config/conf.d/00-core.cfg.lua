-- ===============================================
-- CORE SERVER SETTINGS
-- ===============================================

-- Process management
pidfile = "/var/run/prosody/prosody.pid"
user = "prosody"
group = "prosody"

admins = { "admin@atl.chat" }

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
-- archive_expires_after = "1y" -- Keep messages for 1 year
-- default_archive_policy = true -- Archive all conversations by default
-- archive_compression = true -- Compress archived messages
-- archive_store = "archive" -- Storage backend for archives

-- Query limits
-- max_archive_query_results = 250 -- Limit results per query
-- mam_smart_enable = false -- Disable smart archiving

-- Namespaces to exclude from archiving
-- dont_archive_namespaces = {
-- 	"http://jabber.org/protocol/chatstates", -- Chat state notifications
-- 	"urn:xmpp:jingle-message:0", -- Jingle messages
-- }

-- ===============================================
-- MOBILE CLIENT OPTIMIZATIONS
-- ===============================================

-- Client detection patterns
-- mobile_client_patterns = {
-- 	"Conversations",
-- 	"ChatSecure",
-- 	"Monal",
-- 	"Siskin",
-- 	"Xabber",
-- 	"Blabber",
-- }

-- Client State Indication (XEP-0352)
-- csi_config = {
-- 	enabled = true,
-- 	default_state = "active",
-- 	queue_presence = true, -- Queue presence updates when inactive
-- 	queue_chatstates = true, -- Queue chat state notifications
-- 	queue_pep = false, -- Don't queue PEP events
-- 	delivery_delay = 30, -- Delay before batching (seconds)
-- 	max_delay = 300, -- Maximum delay (5 minutes)
-- 	batch_stanzas = true, -- Batch multiple stanzas
-- 	max_batch_size = 10, -- Maximum stanzas per batch
-- 	batch_timeout = 60, -- Batch timeout (seconds)
-- }

-- Stream Management (XEP-0198)
-- smacks_config = {
-- 	-- Session resumption timeouts
-- 	resumption_timeout = 300, -- 5 minutes
-- 	max_resumption_timeout = 3600, -- 1 hour maximum
-- 	hibernation_timeout = 60, -- 1 minute
-- 	max_hibernation_timeout = 300, -- 5 minutes maximum

-- 	-- Queue management
-- 	max_unacked_stanzas = 500, -- Maximum unacknowledged stanzas
-- 	max_queue_size = 1000, -- Maximum queue size

-- 	-- Acknowledgment settings
-- 	ack_frequency = 5, -- Request ack every 5 stanzas
-- 	ack_timeout = 60, -- Timeout for ack requests

-- 	-- Mobile-specific settings
-- 	mobile_resumption_timeout = 900, -- 15 minutes for mobile
-- 	mobile_hibernation_timeout = 300, -- 5 minutes for mobile
-- 	mobile_ack_frequency = 10, -- Less frequent acks for mobile
-- }

-- Lua garbage collection
lua_gc_step_size = 13 -- GC step size
lua_gc_pause = 110 -- GC pause percentage

-- Enhanced garbage collection
gc = {
	speed = 200, -- Collection speed
	threshold = 120, -- Memory threshold percentage
}
