-- ===============================================
-- KUBERNETES ENVIRONMENT CONFIGURATION
-- Kubernetes cluster deployment settings
-- ===============================================

-- Kubernetes-friendly logging (structured JSON)
log = {
	{ levels = { min = "info" }, to = "console", format = "json" },
}

-- Kubernetes networking
interfaces = { "*" } -- Listen on all interfaces
cross_domain_bosh = true
consider_bosh_secure = true

-- Kubernetes health checks
modules_enabled = modules_enabled or {}
table.insert(modules_enabled, "http")
table.insert(modules_enabled, "health_check")

-- Health check endpoints for Kubernetes probes
http_ports = { 5280 }
http_interfaces = { "*" }

-- Kubernetes service discovery
if os.getenv("KUBERNETES_SERVICE_HOST") then
	-- Running in Kubernetes cluster
	cluster_mode = true

	-- Use Kubernetes secrets for SSL
	ssl = {
		key = "/etc/ssl/private/tls.key",
		certificate = "/etc/ssl/certs/tls.crt",
	}

	-- Kubernetes-managed storage
	if os.getenv("POSTGRES_SERVICE_HOST") then
		storage = "sql"
		sql = {
			driver = "PostgreSQL",
			database = os.getenv("POSTGRES_DB") or "prosody",
			username = os.getenv("POSTGRES_USER") or "prosody",
			password = os.getenv("POSTGRES_PASSWORD"),
			host = os.getenv("POSTGRES_SERVICE_HOST"),
			port = tonumber(os.getenv("POSTGRES_SERVICE_PORT")) or 5432,
		}
	end
end

-- Kubernetes resource management
gc = { speed = 400 } -- Aggressive GC for K8s

-- Kubernetes metrics for monitoring
statistics = "internal"
statistics_interval = 60

-- Kubernetes-specific limits
limits = {
	c2s = {
		rate = "20kb/s",
		burst = "10s",
	},
	s2s = {
		rate = "100kb/s",
		burst = "10s",
	},
}

-- Graceful shutdown for Kubernetes
shutdown_timeout = 30

print("Kubernetes environment configuration loaded")
