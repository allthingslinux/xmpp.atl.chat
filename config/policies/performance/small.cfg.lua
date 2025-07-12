-- ===============================================
-- SMALL DEPLOYMENT PERFORMANCE POLICY
-- Optimized for <100 concurrent users
-- ===============================================

-- Conservative resource limits
limits = {
	c2s = {
		rate = "2kb/s",
		burst = "3s",
	},
	s2s = {
		rate = "10kb/s",
		burst = "3s",
	},
	http_upload = {
		rate = "1mb/s",
		burst = "5s",
	},
}

-- Memory management for small servers
gc = {
	speed = 100, -- Conservative garbage collection
	mode = "incremental", -- Less CPU intensive
}

-- Connection limits for small deployments
c2s_timeout = 300 -- 5 minutes
s2s_timeout = 180 -- 3 minutes
bosh_max_inactivity = 60 -- 1 minute

-- Storage optimization for small scale
storage = "internal" -- SQLite is fine for small deployments
archive_expires_after = "6m" -- 6 months retention
max_archive_query_results = 250

-- Small deployment modules (minimal overhead)
modules_enabled = modules_enabled or {}
local small_deployment_modules = {
	"statistics", -- Basic statistics
	"uptime", -- Uptime tracking
}

for _, module in ipairs(small_deployment_modules) do
	table.insert(modules_enabled, module)
end

-- Conservative caching
cache_size = 1024 -- 1MB cache
cache_ttl = 3600 -- 1 hour TTL

-- Small server HTTP settings
http_max_content_size = 10 * 1024 * 1024 -- 10MB max upload
http_upload_file_size_limit = 25 * 1024 * 1024 -- 25MB files

-- Reduced logging for performance
log = {
	{ levels = { min = "warn" }, to = "console" },
	{ levels = { min = "info" }, to = "file", filename = "/var/log/prosody/prosody.log" },
}

-- Statistics collection (lightweight)
statistics = "internal"
statistics_interval = 300 -- 5 minutes

print("Small deployment performance policy loaded (<100 users)")
