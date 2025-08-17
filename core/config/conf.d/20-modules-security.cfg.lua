-- ===============================================
-- MODULES + SECURITY
-- ===============================================

modules_enabled = {
	-- Core protocol
	"roster", "saslauth", "tls", "dialback", "presence", "message", "iq",
	-- Discovery & capabilities
	"disco", "ping", "time", "version", "lastactivity",
	-- Messaging features
	"mam", "carbons", "smacks", "csi_simple", "offline",
	-- Multi-device
	"bookmarks", "pep",
	-- Profiles
	"vcard_legacy",
	-- Push
	"cloud_notify", "cloud_notify_extensions",
	-- File/media
	"http_file_share", "turn_external",
	-- Admin/management
	"admin_adhoc", "admin_shell",
	-- Web services
	"http", "websocket", "bosh",
	-- Security & privacy
	"blocklist", "private",
	-- Community modules
	"firewall", "anti_spam", "spam_reporting", "admin_blocklist", "invites",
	"csi_battery_saver", "muc_notifications",
	-- Monitoring
	"http_openmetrics",
	-- Dev/Debug
	"motd", "welcome",
}

-- Rate limits
limits = {
	c2s = { rate = "10kb/s", burst = "25kb", stanza_size = 1024 * 256 },
	s2s = { rate = "30kb/s", burst = "100kb", stanza_size = 1024 * 512 },
	http_upload = { rate = "2mb/s", burst = "10mb" },
}

max_connections_per_ip = Lua.tonumber(Lua.os.getenv("PROSODY_MAX_CONNECTIONS_PER_IP")) or 5

-- Registration
allow_registration = Lua.os.getenv("PROSODY_ALLOW_REGISTRATION") == "true"
registration_throttle_max = Lua.tonumber(Lua.os.getenv("PROSODY_REGISTRATION_THROTTLE_MAX")) or 3
registration_throttle_period = Lua.tonumber(Lua.os.getenv("PROSODY_REGISTRATION_THROTTLE_PERIOD")) or 3600

-- Firewall rules
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


