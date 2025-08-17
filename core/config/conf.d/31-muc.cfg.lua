-- ===============================================
-- MUC (Multi-User Chat) Component and Settings
-- ===============================================

local __domain = Lua.os.getenv("PROSODY_DOMAIN") or "localhost"
local __service_host = Lua.os.getenv("PROSODY_SERVICE_HOST") or __domain
-- MUC host override (default: muc.<domain>)
local __muc_host = Lua.os.getenv("PROSODY_MUC_HOST") or ("muc." .. __domain)

-- MUC component
Component(__muc_host, "muc")
-- Use the domain lineage cert (wildcard covers muc.*)
ssl = {
	key = "certs/live/" .. __domain .. "/privkey.pem",
	certificate = "certs/live/" .. __domain .. "/fullchain.pem",
}
name = "Multi-User Chat"
description = "Multi-User Chat rooms and conferences (XEP-0045)"

-- MUC-specific modules
modules_enabled = {
	"muc",
	"muc_mam",
	"pastebin",
	"muc_offline_delivery",
}

-- General MUC configuration
max_history_messages = 50
muc_room_locking = false
muc_room_lock_timeout = 300
muc_tombstones = true
muc_room_cache_size = 1000
muc_room_default_public = true
muc_room_default_members_only = false
muc_room_default_moderated = false
muc_room_default_persistent = true
muc_room_default_language = "en"
muc_room_default_change_subject = true

-- MUC Message Archive Management (MAM)
muc_log_by_default = (Lua.os.getenv("PROSODY_MUC_LOG_BY_DEFAULT") ~= "false")
muc_log_presences = (Lua.os.getenv("PROSODY_MUC_LOG_PRESENCES") == "true")
log_all_rooms = (Lua.os.getenv("PROSODY_MUC_LOG_ALL_ROOMS") == "true")
muc_log_expires_after = Lua.os.getenv("PROSODY_MUC_LOG_EXPIRES_AFTER") or "1y"
muc_log_cleanup_interval = Lua.tonumber(Lua.os.getenv("PROSODY_MUC_LOG_CLEANUP_INTERVAL")) or 86400
muc_max_archive_query_results = Lua.tonumber(Lua.os.getenv("PROSODY_MUC_MAX_ARCHIVE_QUERY_RESULTS")) or 100
muc_log_store = Lua.os.getenv("PROSODY_MUC_LOG_STORE") or "muc_log"
muc_log_compression = (Lua.os.getenv("PROSODY_MUC_LOG_COMPRESSION") ~= "false")
muc_mam_smart_enable = (Lua.os.getenv("PROSODY_MUC_MAM_SMART_ENABLE") == "true")

muc_dont_archive_namespaces = {
	"http://jabber.org/protocol/chatstates",
	"urn:xmpp:jingle-message:0",
	"http://jabber.org/protocol/muc#user",
}

local muc_exclude_env = Lua.os.getenv("PROSODY_MUC_ARCHIVE_EXCLUDE_NAMESPACES")
if muc_exclude_env then
	local custom_namespaces = {}
	for ns in Lua.string.gmatch(muc_exclude_env, "([^,]+)") do
		Lua.table.insert(custom_namespaces, ns:match("^%s*(.-)%s*$"))
	end
	for _, ns in Lua.ipairs(custom_namespaces) do
		Lua.table.insert(muc_dont_archive_namespaces, ns)
	end
end

muc_archive_policy = Lua.os.getenv("PROSODY_MUC_ARCHIVE_POLICY") or "all"
muc_log_notification = (Lua.os.getenv("PROSODY_MUC_LOG_NOTIFICATION") ~= "false")

-- Pastebin settings
pastebin_threshold = Lua.tonumber(Lua.os.getenv("PROSODY_PASTEBIN_THRESHOLD")) or 800
pastebin_line_threshold = Lua.tonumber(Lua.os.getenv("PROSODY_PASTEBIN_LINE_THRESHOLD")) or 6
local pastebin_trigger_env = Lua.os.getenv("PROSODY_PASTEBIN_TRIGGER")
if pastebin_trigger_env then
	pastebin_trigger = pastebin_trigger_env
end
local pastebin_path_env = Lua.os.getenv("PROSODY_PASTEBIN_PATH")
if pastebin_path_env then
	http_paths = http_paths or {}
	http_paths.pastebin = pastebin_path_env
else
	http_paths = http_paths or {}
	http_paths.pastebin = "/paste"
end
