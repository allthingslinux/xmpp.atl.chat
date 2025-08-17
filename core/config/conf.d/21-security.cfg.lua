-- ===============================================
-- SECURITY (limits, registration, firewall)
-- ===============================================

limits = {
	c2s = { rate = "10kb/s", burst = "25kb", stanza_size = 1024 * 256 },
	s2s = { rate = "30kb/s", burst = "100kb", stanza_size = 1024 * 512 },
	http_upload = { rate = "2mb/s", burst = "10mb" },
}

max_connections_per_ip = Lua.tonumber(Lua.os.getenv("PROSODY_MAX_CONNECTIONS_PER_IP")) or 5

allow_registration = Lua.os.getenv("PROSODY_ALLOW_REGISTRATION") == "true"
registration_throttle_max = Lua.tonumber(Lua.os.getenv("PROSODY_REGISTRATION_THROTTLE_MAX")) or 3
registration_throttle_period = Lua.tonumber(Lua.os.getenv("PROSODY_REGISTRATION_THROTTLE_PERIOD")) or 3600

firewall_scripts = {
	[[
	%ZONE spam: log=debug
	RATE: 10 (burst 15) on full-jid
	TO: spam
	DROP.
	]],
	[[
	%LENGTH > 262144
	BOUNCE: policy-violation (Stanza too large)
	]],
}
