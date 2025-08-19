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
	-- http_file_share is served on dedicated component upload.$domain
	-- Admin/management
	"admin_adhoc",
	"admin_shell",
	-- Web services
	"http",
	"websocket",
	"bosh",
	"http_files",
	-- Web client integration handled by dedicated container (nginx proxy at /conversejs)
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

-- TURN/STUN disabled by default in barebones config
