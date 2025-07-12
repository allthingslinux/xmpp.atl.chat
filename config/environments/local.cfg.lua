-- ===============================================
-- LOCAL DEVELOPMENT ENVIRONMENT
-- Settings for local development and testing
-- ===============================================

-- Development-friendly logging
log = {
	{ levels = { min = "debug" }, to = "console" },
	{ levels = { min = "debug" }, to = "file", filename = "/var/log/prosody/prosody-dev.log" },
}

-- Relaxed security for development
c2s_require_encryption = false
s2s_require_encryption = false
s2s_insecure_domains = { "localhost" }

-- Allow self-signed certificates
s2s_secure_auth = false

-- Development modules
modules_enabled = modules_enabled or {}
table.insert(modules_enabled, "admin_telnet")
table.insert(modules_enabled, "console")

-- Fast garbage collection for development
gc = { speed = 100 }

-- Allow registration for testing
allow_registration = true
registration_throttle_max = 100

-- Development database (SQLite)
storage = "internal"

-- Hot reload support
reload_modules = true

-- Development-specific limits (more permissive)
limits = {
	c2s = {
		rate = "100kb/s",
		burst = "10s",
	},
	s2s = {
		rate = "500kb/s",
		burst = "10s",
	},
}

print("Local development environment loaded")
