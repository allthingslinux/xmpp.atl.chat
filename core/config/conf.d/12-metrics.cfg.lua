-- ===============================================
-- MONITORING / METRICS
-- ===============================================

statistics = "internal"
statistics_interval = "manual"

-- By default restrict to loopback; allow-list is expanded via CIDR below
openmetrics_allow_ips = {
	"127.0.0.1",
	"::1",
}

-- Fixed CIDR allow-list for internal scraping
openmetrics_allow_cidr = "172.16.0.0/12"


