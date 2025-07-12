-- Production Environment Configuration
-- Optimized settings for production deployment
-- Enhanced security, performance monitoring, and reliability features

-- Production-specific module adjustments
-- Override community module settings for production use
local production_overrides = {
	-- Enhanced security settings
	security = {
		-- Stricter TLS requirements
		require_encryption = true,
		c2s_require_encryption = true,
		s2s_require_encryption = true,

		-- Enhanced certificate validation
		s2s_secure_auth = true,

		-- Stricter connection limits
		max_auth_attempts = 3,
		auth_failure_delay = 5,
	},

	-- Performance optimizations
	performance = {
		-- Connection management
		max_connections = 1000,
		connection_timeout = 300,

		-- Memory management
		gc_stepmul = 200, -- More aggressive garbage collection

		-- Cache settings
		disco_cache_ttl = 3600, -- 1 hour disco cache
	},

	-- Logging configuration for production
	logging = {
		level = "info", -- Info level logging

		-- Structured logging for production
		format = "structured",

		-- Log rotation
		rotate_size = "100MB",
		rotate_count = 10,
	},

	-- Monitoring and metrics
	monitoring = {
		-- Statistics collection
		statistics_interval = 60, -- 1 minute intervals

		-- Health checks
		health_check_interval = 30, -- 30 second health checks

		-- Performance monitoring
		track_performance = true,
	},
}

-- Production storage configuration
-- Optimized storage settings for production workloads
local production_storage = {
	-- Default storage backend
	default_storage = "sql",

	-- Archive storage for MAM
	archive_storage = "sql",

	-- Storage-specific settings
	storage_settings = {
		sql = {
			driver = "PostgreSQL", -- Production database
			database = os.getenv("PROSODY_DB_NAME") or "prosody",
			host = os.getenv("PROSODY_DB_HOST") or "localhost",
			port = tonumber(os.getenv("PROSODY_DB_PORT")) or 5432,
			username = os.getenv("PROSODY_DB_USER") or "prosody",
			password = os.getenv("PROSODY_DB_PASS"),

			-- Connection pooling
			pool_size = 10,
			pool_timeout = 30,
		},
	},

	-- Specific storage assignments
	mam = "sql",
	muc_log = "sql",
	pubsub = "sql",
	pep = "sql",
	offline = "sql",
	roster = "sql",
	vcard = "sql",
	private = "sql",
}

-- Production security enhancements
-- Additional security measures for production deployment
local production_security = {
	-- Rate limiting
	limits = {
		c2s = {
			rate = "10kb/s",
			burst = "2s",
		},
		s2s = {
			rate = "50kb/s",
			burst = "5s",
		},
	},

	-- TLS security
	tls_security = {
		-- Minimum TLS version
		protocol = "tlsv1_2+",

		-- Strong cipher suites only
		ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",

		-- Certificate verification
		verify_ext_key_usage = true,
		verify_chain = true,
	},

	-- Access control
	access_control = {
		-- Admin access restrictions
		admin_interfaces = {
			"127.0.0.1",
			"::1",
		},

		-- Component access
		component_interface = "127.0.0.1",
	},
}

-- Apply production configuration
-- Set all production-specific settings
for category, settings in pairs(production_overrides) do
	for setting, value in pairs(settings) do
		_G[setting] = value
	end
end

-- Apply storage configuration
for setting, value in pairs(production_storage) do
	_G[setting] = value
end

-- Apply security configuration
for category, settings in pairs(production_security) do
	for setting, value in pairs(settings) do
		_G[setting] = value
	end
end

log("info", "Production environment: Enhanced security and performance settings applied")
log(
	"info",
	"Storage backend: %s, TLS: %s",
	production_storage.default_storage,
	production_security.tls_security.protocol
)
