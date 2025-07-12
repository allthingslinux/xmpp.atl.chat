-- ===============================================
-- LARGE DEPLOYMENT PERFORMANCE POLICY
-- Optimized for >1000 concurrent users
-- ===============================================

-- High-performance resource limits
limits = {
	c2s = {
		rate = "50kb/s",
		burst = "20s",
	},
	s2s = {
		rate = "200kb/s",
		burst = "20s",
	},
	http_upload = {
		rate = "10mb/s",
		burst = "30s",
	},
}

-- Aggressive memory management for large servers
gc = {
	speed = 1000, -- Aggressive garbage collection
	mode = "generational", -- More efficient for large heaps
}

-- Optimized connection handling
c2s_timeout = 900 -- 15 minutes
s2s_timeout = 600 -- 10 minutes
bosh_max_inactivity = 300 -- 5 minutes

-- High-performance storage
storage = "sql" -- Database required for large deployments
archive_expires_after = "2y" -- 2 years retention
max_archive_query_results = 5000

-- Large deployment modules (performance monitoring)
modules_enabled = modules_enabled or {}
local large_deployment_modules = {
	"statistics", -- Detailed statistics
	"measure_memory", -- Memory monitoring
	"measure_cpu", -- CPU monitoring
	"measure_storage", -- Storage monitoring
	"prometheus", -- Prometheus metrics
	"http_openmetrics", -- OpenMetrics endpoint
	"admin_shell", -- Advanced administration
}

for _, module in ipairs(large_deployment_modules) do
	table.insert(modules_enabled, module)
end

-- High-performance caching
cache_size = 100 * 1024 -- 100MB cache
cache_ttl = 7200 -- 2 hour TTL

-- Large server HTTP settings
http_max_content_size = 500 * 1024 * 1024 -- 500MB max upload
http_upload_file_size_limit = 200 * 1024 * 1024 -- 200MB files

-- Comprehensive logging for large deployments
log = {
	{ levels = { min = "info" }, to = "console" },
	{ levels = { min = "debug" }, to = "file", filename = "/var/log/prosody/debug.log" },
	{ levels = { min = "info" }, to = "file", filename = "/var/log/prosody/info.log" },
	{ levels = { min = "warn" }, to = "file", filename = "/var/log/prosody/warnings.log" },
}

-- High-frequency statistics collection
statistics = "internal"
statistics_interval = 30 -- 30 seconds

-- Connection pooling for databases
sql = sql or {}
sql.pool_size = 20 -- Connection pool
sql.max_overflow = 10 -- Additional connections

-- Performance optimizations
tcp_keepalives = true
tcp_nodelay = true

-- Load balancing support
cluster_backend = "redis" -- For clustering
session_cache = "redis" -- Distributed session cache

print("Large deployment performance policy loaded (>1000 users)")
