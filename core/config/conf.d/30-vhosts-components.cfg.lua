-- ===============================================
-- VIRTUAL HOSTS + COMPONENTS
-- ===============================================

-- Single VirtualHost
VirtualHost("atl.chat")
ssl = {
	key = "certs/live/atl.chat/privkey.pem",
	certificate = "certs/live/atl.chat/fullchain.pem",
}

Component("muc.atl.chat", "muc")
ssl = {
	key = "certs/live/atl.chat/privkey.pem",
	certificate = "certs/live/atl.chat/fullchain.pem",
}
name = "muc.atl.chat"

-- MUC-specific modules
modules_enabled = {
	-- "muc",
	"muc_mam", -- Message Archive Management for MUC events
	-- "vcard_muc", -- vCard support for MUC users (conflicts with built-in muc_vcard on Prosody 13)
	"muc_notifications", -- Push notifications for MUC events
	"muc_offline_delivery", -- Offline delivery for MUC events
	-- "pastebin",
}

restrict_room_creation = false
muc_room_default_public = true
muc_room_default_persistent = true
muc_room_locking = false
vcard_to_pep = true

-- General MUC configuration
-- max_history_messages = 50
-- muc_room_lock_timeout = 300
-- muc_tombstones = true
-- muc_room_cache_size = 1000
-- muc_room_default_public = true
-- muc_room_default_members_only = false
-- muc_room_default_moderated = false
-- muc_room_default_persistent = true
-- muc_room_default_language = "en"
-- muc_room_default_change_subject = true

-- MUC Message Archive Management (MAM)
-- muc_log_by_default = true
-- muc_log_presences = false
-- log_all_rooms = false
-- muc_log_expires_after = "1y"
-- muc_log_cleanup_interval = 86400
-- muc_max_archive_query_results = 100
-- muc_log_store = "muc_log"
-- muc_log_compression = true
-- muc_mam_smart_enable = false

muc_dont_archive_namespaces = {
	-- "http://jabber.org/protocol/chatstates",
	-- "urn:xmpp:jingle-message:0",
	-- "http://jabber.org/protocol/muc#user",
}

-- muc_archive_policy = "all"
-- muc_log_notification = true

-- Pastebin settings
-- pastebin_threshold = 800
-- pastebin_line_threshold = 6

-- HTTP File Upload component
Component("upload.atl.chat", "http_file_share")
ssl = {
	key = "certs/live/atl.chat/privkey.pem",
	certificate = "certs/live/atl.chat/fullchain.pem",
}
name = "upload.atl.chat"
http_external_url = "https://upload.atl.chat/"

-- SOCKS5 Proxy component
Component("proxy.atl.chat", "proxy65")
ssl = {
	key = "certs/live/atl.chat/privkey.pem",
	certificate = "certs/live/atl.chat/fullchain.pem",
}
name = "proxy.atl.chat"
proxy65_address = "proxy.atl.chat"
