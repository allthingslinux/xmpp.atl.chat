-- ===============================================
-- LOGGING
-- ===============================================

log = {
	{ levels = { min = Lua.os.getenv("PROSODY_LOG_LEVEL") or "info" }, to = "console" },
	{ levels = { min = Lua.os.getenv("PROSODY_LOG_LEVEL") or "info" }, to = "file", filename = "/var/log/prosody/prosody.log" },
	{ levels = { min = "warn" }, to = "file", filename = "/var/log/prosody/prosody.err" },
	{ levels = { "warn", "error" }, to = "file", filename = "/var/log/prosody/security.log" },
}


