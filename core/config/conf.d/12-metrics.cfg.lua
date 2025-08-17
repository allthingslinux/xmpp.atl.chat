-- ===============================================
-- MONITORING / METRICS
-- ===============================================

statistics = "internal"
statistics_interval = Lua.os.getenv("PROSODY_STATISTICS_INTERVAL") or "manual"

openmetrics_allow_ips = {
	"127.0.0.1",
	"172.18.0.0/16",
	"10.0.0.0/8",
}

local metrics_ips_env = Lua.os.getenv("PROSODY_METRICS_ALLOW_IPS")
if metrics_ips_env then
	local custom_ips = {}
	for ip in Lua.string.gmatch(metrics_ips_env, "([^,]+)") do
		Lua.table.insert(custom_ips, ip:match("^%s*(.-)%s*$"))
	end
	for _, ip in Lua.ipairs(custom_ips) do
		Lua.table.insert(openmetrics_allow_ips, ip)
	end
end

if Lua.os.getenv("PROSODY_METRICS_ALLOW_CIDR") then
	openmetrics_allow_cidr = Lua.os.getenv("PROSODY_METRICS_ALLOW_CIDR")
end


