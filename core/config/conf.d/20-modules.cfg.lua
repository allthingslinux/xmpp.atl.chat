-- ===============================================
-- MODULES
-- ===============================================

modules_enabled = {
	-- Core protocol
	"roster",
	"saslauth",
	"tls",
	"dialback",
	"presence",
	"message",
	"iq",
	-- Discovery & capabilities
	"disco",
	"ping",
	"time",
	"version",
	"lastactivity",
	-- Messaging features
	"mam",
	"carbons",
	"smacks",
	"csi_simple",
	"offline",
	-- Multi-device
	"bookmarks",
	"pep",
	-- Profiles
	"vcard_legacy",
	-- Push
	"cloud_notify",
	"cloud_notify_extensions",
	-- File/media
	"http_file_share",
	-- Admin/management
	"admin_adhoc",
	"admin_shell",
	-- Web services
	"http",
	"websocket",
	"bosh",
	"http_files",
	-- Web client integration
	-- conversejs: Serve Converse.js web client at /conversejs with auto-generated config
	-- Docs: https://modules.prosody.im/mod_conversejs.html | Project: https://conversejs.org/
	"conversejs",
	-- Security & privacy
	"blocklist",
	"private",
	-- Community modules
	"firewall",
	"anti_spam",
	"spam_reporting",
	"admin_blocklist",
	"invites",
	"csi_battery_saver",
	"muc_notifications",
	"register",
	-- Monitoring
	"http_openmetrics",
	-- Dev/Debug
	"motd",
	"welcome",
}

-- XEP-0215 External Service Discovery (TURN/STUN)
-- Enable only when TURN_SECRET is provided to avoid startup errors
local __turn_secret = Lua.os.getenv("TURN_SECRET")
if __turn_secret then
	-- Enable module dynamically
	Lua.table.insert(modules_enabled, "turn_external")
	-- Configure options
	turn_external_secret = __turn_secret
	local __turn_host = Lua.os.getenv("TURN_DOMAIN")
	if __turn_host then
		turn_external_host = __turn_host
	end
	local __turn_port = Lua.tonumber(Lua.os.getenv("TURN_PORT"))
	if __turn_port then
		turn_external_port = __turn_port
	end
	turn_external_ttl = Lua.tonumber(Lua.os.getenv("TURN_TTL")) or 86400 -- 24h
end
