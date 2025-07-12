-- Production Environment Configuration
-- Optimizations and settings for production deployment

-- Production-specific logging
log = {
	-- Production log files
	info = "/var/log/prosody/prosody.log",
	error = "/var/log/prosody/prosody.err",
	warn = "/var/log/prosody/prosody.warn",

	-- Structured logging for production monitoring
	{ levels = { "error", "warn" }, to = "syslog" },
}

-- Production performance optimizations
-- Optimize garbage collection for production load
gc = {
	speed = 1000, -- Faster garbage collection
	threshold = 200, -- Lower threshold for more frequent GC
}

-- Connection limits for production
if connection_limits then
	-- Increase connection limits for production
	connection_limits.c2s.max_total = 5000
	connection_limits.c2s.max_per_ip = 20
	connection_limits.s2s.max_total = 500
	connection_limits.http.max_total = 2000
end

-- Rate limiting adjustments for production
if rate_limits then
	-- More restrictive rate limits for production
	rate_limits.stanzas.c2s.rate = "5/s"
	rate_limits.stanzas.c2s.burst = 10
	rate_limits.connections.rate = "3/m"
	rate_limits.auth.rate = "2/m"
	rate_limits.auth.penalty = 600 -- 10 minute penalty
end

-- Production TLS configuration
if ssl then
	-- Require modern TLS for production
	ssl.c2s.protocol = "tlsv1_3+"
	ssl.s2s.protocol = "tlsv1_3+"
	ssl.https.protocol = "tlsv1_3+"

	-- Stricter cipher suites for production
	ssl.c2s.ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:!aNULL:!MD5:!DSS:!RC4"
	ssl.s2s.ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:!aNULL:!MD5:!DSS:!RC4"
	ssl.https.ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:!aNULL:!MD5:!DSS:!RC4"
end

-- Production authentication security
if auth_security then
	-- Stricter authentication security for production
	auth_security.brute_force.max_attempts = 3
	auth_security.brute_force.lockout_duration = 600 -- 10 minutes
	auth_security.account_lockout.max_failures = 5
	auth_security.account_lockout.lockout_duration = 7200 -- 2 hours
end

-- Production registration restrictions
if registration_config then
	-- Disable open registration in production
	registration_config.inband.enabled = false
	registration_config.web.enabled = false

	-- If registration is enabled, make it more restrictive
	if registration_config.inband.enabled then
		registration_config.inband.restrictions.ip_limit = 1
		registration_config.inband.restrictions.require_email = true
		registration_config.inband.restrictions.require_invitation = true
	end
end

-- Production stream management optimizations
if smacks_config then
	-- Optimize for production load
	smacks_config.max_unacked_stanzas = 200
	smacks_config.max_queue_size = 500
	smacks_config.resumption_timeout = 600 -- 10 minutes
	smacks_config.max_resumption_timeout = 1800 -- 30 minutes
end

-- Production compression settings
if compression then
	-- Enable compression for production bandwidth savings
	compression.level.c2s = 4 -- Lower CPU usage
	compression.level.s2s = 3 -- Even lower for server connections
	compression.threshold.c2s = 512 -- Higher threshold
	compression.threshold.s2s = 1024
end

-- Production monitoring and metrics
statistics = "internal"
statistics_interval = 30 -- More frequent statistics in production

-- Production storage optimizations
storage = {
	accounts = "sql",
	roster = "sql",
	vcard = "sql",
	private = "sql",
	blocklist = "sql",
	archive2 = "sql", -- Message archives
	pubsub = "sql",
	pep = "sql",
}

-- Production SQL configuration
sql = {
	driver = "PostgreSQL", -- Use PostgreSQL for production
	host = os.getenv("PROSODY_DB_HOST") or "localhost",
	port = tonumber(os.getenv("PROSODY_DB_PORT")) or 5432,
	database = os.getenv("PROSODY_DB_NAME") or "prosody",
	username = os.getenv("PROSODY_DB_USER") or "prosody",
	password = os.getenv("PROSODY_DB_PASS") or "",

	-- Connection pooling for production
	pool = {
		size = 10, -- Connection pool size
		overflow = 5, -- Additional connections when needed
		timeout = 30, -- Connection timeout
		recycle = 3600, -- Recycle connections every hour
	},
}

-- Production security hardening
-- Disable unnecessary features for production
modules_disabled = {
	"register", -- Disable registration unless specifically needed
	"welcome", -- Disable welcome messages
	"motd", -- Disable message of the day
}

-- Production backup configuration
if backup_config then
	backup_config.enabled = true
	backup_config.interval = 21600 -- Every 6 hours
	backup_config.retention_days = 30
	backup_config.compress = true
	backup_config.encrypt = true
end

-- Production alerting configuration
if alerts then
	alerts.enabled = true
	alerts.email = os.getenv("PROSODY_ALERT_EMAIL") or "admin@localhost"
	alerts.webhook = os.getenv("PROSODY_ALERT_WEBHOOK")

	-- Production alert thresholds
	alerts.cpu_threshold = 80
	alerts.memory_threshold = 85
	alerts.disk_threshold = 90
	alerts.connection_threshold = 4000
end

-- Production HTTPS security headers
if https_security_headers then
	https_security_headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains; preload"
	https_security_headers["Content-Security-Policy"] =
		"default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
	https_security_headers["X-Frame-Options"] = "DENY"
	https_security_headers["X-Content-Type-Options"] = "nosniff"
	https_security_headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
end

-- Production certificate management
if certificates_config then
	-- Enable Let's Encrypt for production
	certificates_config.acme.enabled = true
	certificates_config.acme.staging = false -- Use production ACME
	certificates_config.acme.email = os.getenv("PROSODY_ADMIN_EMAIL") or "admin@localhost"

	-- Disable self-signed certificates in production
	certificates_config.self_signed.enabled = false
end

-- Production log retention
if auth_logging then
	auth_logging.retention_days = 365 -- Keep auth logs for 1 year in production
end

-- Production resource limits
limits = {
	c2s = {
		rate = "5kb/s", -- Conservative rate limit
		burst = "10kb", -- Small burst allowance
	},
	s2s = {
		rate = "20kb/s", -- Higher rate for server connections
		burst = "50kb",
	},
	http = {
		rate = "10kb/s", -- HTTP rate limit
		burst = "20kb",
	},
}

-- Production interface bindings
-- Only bind to specific interfaces in production
interfaces = {
	os.getenv("PROSODY_BIND_IP") or "*", -- Allow override via environment
}

-- Production process limits
-- Set appropriate process limits for production
ulimit = {
	files = 65536, -- File descriptor limit
	processes = 1024, -- Process limit
}

-- Production maintenance window
maintenance_window = {
	enabled = true,
	start_hour = 3, -- 3 AM maintenance window
	duration_hours = 2, -- 2 hour window
	timezone = "UTC",
	notification_hours = 24, -- Notify 24 hours in advance
}

log("info", "Production environment configuration loaded")
log("info", "Enhanced security, performance, and monitoring enabled")
