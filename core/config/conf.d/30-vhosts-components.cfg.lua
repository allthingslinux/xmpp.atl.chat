-- ===============================================
-- VIRTUAL HOSTS + COMPONENTS
-- ===============================================

-- Main domain configuration
VirtualHost(Lua.os.getenv("PROSODY_DOMAIN") or "localhost")
authentication = "internal_hashed"

-- Domain TLS (atl.chat lineage by default)
ssl = {
	key = "certs/live/" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost") .. "/privkey.pem",
	certificate = "certs/live/" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost") .. "/fullchain.pem",
}

-- Discovery items and service host mapping
local __domain = Lua.os.getenv("PROSODY_DOMAIN") or "localhost"
local __service_host = Lua.os.getenv("PROSODY_SERVICE_HOST") or __domain

disco_items = {
	{ "muc." .. __service_host, "Multi-User Chat Rooms" },
	{ "upload." .. __service_host, "HTTP File Upload" },
	{ "proxy." .. __service_host, "SOCKS5 File Transfer Proxy" },
	{ (Lua.os.getenv("PROSODY_HTTP_HOST") or __domain), "Pastebin Service" },
}

local disco_items_env = Lua.os.getenv("PROSODY_DISCO_ITEMS")
if disco_items_env then
	local custom_items = {}
	for item in Lua.string.gmatch(disco_items_env, "([^;]+)") do
		local jid, name = item:match("([^,]+),(.+)")
		if jid and name then
			Lua.table.insert(custom_items, { jid:match("^%s*(.-)%s*$"), name:match("^%s*(.-)%s*$") })
		end
	end
	for _, item in Lua.ipairs(custom_items) do
		Lua.table.insert(disco_items, item)
	end
end

disco_expose_admins = (Lua.os.getenv("PROSODY_DISCO_EXPOSE_ADMINS") == "true")

-- MUC component
Component("muc." .. __service_host, "muc")
ssl = {
	key = "certs/live/" .. __service_host .. "/privkey.pem",
	certificate = "certs/live/" .. __service_host .. "/fullchain.pem",
}
name = "Multi-User Chat"
description = "Multi-User Chat rooms and conferences (XEP-0045)"

modules_enabled = { "muc", "muc_mam", "pastebin", "muc_offline_delivery" }

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
if pastebin_trigger_env then pastebin_trigger = pastebin_trigger_env end
local pastebin_path_env = Lua.os.getenv("PROSODY_PASTEBIN_PATH")
if pastebin_path_env then
	http_paths = http_paths or {}
	http_paths.pastebin = pastebin_path_env
else
	http_paths = http_paths or {}
	http_paths.pastebin = "/paste"
end

-- Upload component
Component("upload." .. __service_host, "http_file_share")
ssl = {
	key = "certs/live/" .. __service_host .. "/privkey.pem",
	certificate = "certs/live/" .. __service_host .. "/fullchain.pem",
}
name = "File Upload Service"
description = "HTTP file upload and sharing service (XEP-0363)"

-- Proxy65 component
Component("proxy." .. __service_host, "proxy65")
ssl = {
	key = "certs/live/" .. __service_host .. "/privkey.pem",
	certificate = "certs/live/" .. __service_host .. "/fullchain.pem",
}
name = "SOCKS5 Proxy"
description = "File transfer proxy service (XEP-0065)"
proxy65_address = __service_host


