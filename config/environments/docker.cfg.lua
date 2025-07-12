-- ===============================================
-- DOCKER ENVIRONMENT CONFIGURATION
-- Container-specific settings and optimizations
-- ===============================================

-- Container-friendly logging (to stdout/stderr)
log = {
	{ levels = { min = "info" }, to = "console" },
}

-- Container paths
data_path = "/var/lib/prosody"
plugin_paths = { "/usr/local/lib/prosody/modules" }

-- Container networking
interfaces = { "*" } -- Listen on all interfaces in container

-- Container-optimized garbage collection
gc = { speed = 300 }

-- Container health check endpoint
modules_enabled = modules_enabled or {}
table.insert(modules_enabled, "http")
table.insert(modules_enabled, "http_files")

-- Health check configuration
http_ports = { 5280 }
http_interfaces = { "*" }

-- Container-specific SSL paths
ssl = {
	key = "/etc/prosody/certs/localhost.key",
	certificate = "/etc/prosody/certs/localhost.crt",
}

-- Container signal handling
daemonize = false -- Don't daemonize in containers

-- Container resource limits
limits = {
	c2s = {
		rate = "10kb/s",
		burst = "5s",
	},
	s2s = {
		rate = "30kb/s",
		burst = "5s",
	},
}

-- Container storage (use environment variables)
if os.getenv("PROSODY_DB_DRIVER") then
	storage = os.getenv("PROSODY_DB_DRIVER")
	sql = {
		driver = os.getenv("PROSODY_DB_DRIVER"),
		database = os.getenv("PROSODY_DB_NAME") or "prosody",
		username = os.getenv("PROSODY_DB_USER") or "prosody",
		password = os.getenv("PROSODY_DB_PASSWORD"),
		host = os.getenv("PROSODY_DB_HOST") or "localhost",
		port = tonumber(os.getenv("PROSODY_DB_PORT")) or 5432,
	}
end

print("Docker environment configuration loaded")
