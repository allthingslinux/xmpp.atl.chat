-- ===============================================
-- LOGGING
-- ===============================================

log = {
	{ levels = { min = "info" }, to = "console" },
	-- { levels = { min = "info" }, to = "file", filename = "/var/log/prosody/prosody.log" },
	-- { levels = { min = "warn" }, to = "file", filename = "/var/log/prosody/prosody.err" },
	-- { levels = { "warn", "error" }, to = "file", filename = "/var/log/prosody/security.log" },
}

statistics = "internal"
statistics_interval = "manual"

-- By default restrict to loopback; allow-list is expanded via CIDR below
openmetrics_allow_ips = {
	"127.0.0.1",
}

-- Fixed CIDR allow-list for internal scraping
openmetrics_allow_cidr = "172.16.0.0/12"
