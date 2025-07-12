-- ============================================================================
-- PRODUCTION ENVIRONMENT CONFIGURATION
-- ============================================================================
-- Production-specific settings for performance, security, and reliability
-- Applied after layer configurations for environment-specific overrides

-- ============================================================================
-- SECURITY HARDENING
-- ============================================================================

-- Enhanced authentication requirements
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true

-- Disable insecure features
allow_unencrypted_plain_auth = false
allow_registration = false -- Disable open registration in production

-- Enhanced certificate verification
s2s_insecure_domains = {} -- No insecure domains allowed
s2s_secure_domains = {} -- All domains must use secure auth

-- ============================================================================
-- PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Connection limits for production load
limits = {
	c2s = {
		rate = "10mb/s",
		burst = "20mb",
		stanza_size = 262144, -- 256KB
		max_connections = 1000,
	},
	s2sin = {
		rate = "5mb/s",
		burst = "10mb",
		stanza_size = 524288, -- 512KB
		max_connections = 100,
	},
	s2sout = {
		rate = "5mb/s",
		burst = "10mb",
		stanza_size = 524288, -- 512KB
		max_connections = 100,
	},
}

-- Enhanced garbage collection for production
gc = {
	speed = 200, -- More aggressive GC
	threshold = 120, -- Lower threshold
}

-- Memory management
lua_gc_step_size = 13
lua_gc_pause = 110

-- ============================================================================
-- LOGGING CONFIGURATION
-- ============================================================================

-- Production logging - structured and comprehensive
log = {
	-- Error logging with rotation
	{
		levels = { "error" },
		to = "file",
		filename = "/var/log/prosody/error.log",
		timestamps = true,
	},

	-- Warning and info logging
	{
		levels = { "warn", "info" },
		to = "file",
		filename = "/var/log/prosody/prosody.log",
		timestamps = true,
	},

	-- Security events logging
	{
		levels = { "warn", "error" },
		to = "file",
		filename = "/var/log/prosody/security.log",
		timestamps = true,
		filter = { "auth", "tls", "cert", "s2s" },
	},

	-- No console logging in production
}

-- Enable comprehensive statistics
statistics = "internal"
statistics_interval = 300 -- 5 minutes for production monitoring

-- ============================================================================
-- STORAGE OPTIMIZATION
-- ============================================================================

-- Production storage configuration
default_storage = "sql"
storage = {
	accounts = "sql",
	roster = "sql",
	vcard = "sql",
	private = "sql",
	blocklist = "sql",
	archive2 = "sql", -- Message Archive Management
	muc_log = "sql", -- MUC archives
	pubsub_nodes = "sql",
	pubsub_data = "sql",
	pep = "sql",

	-- Keep some data in memory for performance
	caps = "memory",
	carbons = "memory",
}

-- SQL database configuration for production
sql = {
	driver = os.getenv("PROSODY_DB_DRIVER") or "PostgreSQL",
	database = os.getenv("PROSODY_DB_NAME") or "prosody",
	username = os.getenv("PROSODY_DB_USER") or "prosody",
	password = os.getenv("PROSODY_DB_PASSWORD") or "prosody",
	host = os.getenv("PROSODY_DB_HOST") or "localhost",
	port = tonumber(os.getenv("PROSODY_DB_PORT")) or 5432,

	-- Connection pooling for production
	pool_size = 10,
	pool_overflow = 20,
	pool_timeout = 30,

	-- Performance optimizations
	ssl = {
		mode = "require",
		protocol = "tlsv1_2+",
	},
}

-- ============================================================================
-- ARCHIVE MANAGEMENT
-- ============================================================================

-- Production archive retention policies
archive_expires_after = "2y" -- 2 years retention
muc_log_expires_after = "1y" -- 1 year for MUC logs
default_archive_policy = "roster" -- Archive for roster contacts

-- Archive cleanup intervals
archive_cleanup_interval = 24 * 60 * 60 -- Daily cleanup

-- ============================================================================
-- HTTP SERVICES CONFIGURATION
-- ============================================================================

-- HTTP interface configuration for production
http_default_host = os.getenv("PROSODY_DOMAIN") or "localhost"
http_external_url = "https://" .. (os.getenv("PROSODY_DOMAIN") or "localhost") .. "/"

-- HTTPS enforcement
https_redirect = true
hsts_header = "max-age=31536000; includeSubDomains; preload"

-- File upload limits for production
http_file_share_size_limit = 100 * 1024 * 1024 -- 100MB
http_file_share_daily_quota = 1024 * 1024 * 1024 -- 1GB per day
http_file_share_expire_after = 30 * 24 * 60 * 60 -- 30 days

-- ============================================================================
-- MONITORING AND HEALTH CHECKS
-- ============================================================================

-- Health check endpoint
http_health_check_path = "/health"
http_health_check_auth = false

-- Metrics endpoint (secured)
http_openmetrics_path = "/metrics"
http_openmetrics_auth = true

-- ============================================================================
-- COMPLIANCE FEATURES
-- ============================================================================

-- Server contact information (required for compliance)
contact_info = {
	admin = {
		"xmpp:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"https://" .. (os.getenv("PROSODY_DOMAIN") or "localhost") .. "/contact",
	},
	support = {
		"xmpp:support@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:support@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
	},
	abuse = {
		"xmpp:abuse@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:abuse@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
	},
	security = {
		"mailto:security@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
	},
}

-- ============================================================================
-- ANTI-SPAM AND ABUSE PREVENTION
-- ============================================================================

-- Enhanced rate limiting for production
c2s_rate_limit = "10kb/s"
s2s_rate_limit = "50kb/s"

-- Registration limits (if enabled)
registration_throttle_max = 5
registration_throttle_period = 300 -- 5 minutes

-- Connection throttling
c2s_conn_throttle_max = 20
c2s_conn_throttle_period = 60

-- ============================================================================
-- BACKUP AND MAINTENANCE
-- ============================================================================

-- Backup configuration
backup_retention_days = 30
backup_interval_hours = 6

-- Maintenance windows
maintenance_mode = false
maintenance_message = "Server maintenance in progress. Please try again later."

-- ============================================================================
-- EXTERNAL INTEGRATIONS
-- ============================================================================

-- External service discovery for production
external_services = {
	{
		type = "stun",
		host = "stun." .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
	},
	{
		type = "turn",
		host = "turn." .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
		username = "prosody",
		password = os.getenv("TURN_PASSWORD") or "changeme",
		restricted = true,
		transport = "udp",
	},
	{
		type = "turn",
		host = "turn." .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		port = 3478,
		username = "prosody",
		password = os.getenv("TURN_PASSWORD") or "changeme",
		restricted = true,
		transport = "tcp",
	},
}

-- ============================================================================
-- PRODUCTION SPECIFIC MODULES
-- ============================================================================

-- Additional modules for production monitoring
production_modules = {
	"http_openmetrics", -- Prometheus metrics
	"server_contact_info", -- Compliance
	"limits", -- Rate limiting
	"watchregistrations", -- Monitor registrations
	"tombstones", -- User deletion handling
}

-- Merge with existing modules
if modules_enabled then
	for _, module in ipairs(production_modules) do
		table.insert(modules_enabled, module)
	end
else
	modules_enabled = production_modules
end
