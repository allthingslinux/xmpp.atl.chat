-- ===============================================
-- CONTACT INFO, ROLES, ACCOUNT CLEANUP
-- ===============================================

contact_info = {
	admin = {
		"xmpp:" .. (Lua.os.getenv("PROSODY_ADMIN_JID") or "admin@localhost"),
		"mailto:" .. (Lua.os.getenv("PROSODY_CONTACT_ADMIN") or "admin@localhost"),
	},
	abuse = {
		"xmpp:abuse@" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:" .. (Lua.os.getenv("PROSODY_CONTACT_ABUSE") or "abuse@localhost"),
	},
	support = {
		"xmpp:support@" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:" .. (Lua.os.getenv("PROSODY_CONTACT_SUPPORT") or "support@localhost"),
	},
	security = {
		"mailto:" .. (Lua.os.getenv("PROSODY_CONTACT_SECURITY") or "security@localhost"),
	},
}

server_info = {
	name = "atl.chat",
	website = "https://atl.chat",
	description = "atl.chat XMPP service",
	-- icon = "https://xmpp.atl.chat/files/icon.png",
	-- terms_of_service = "https://atl.chat/terms",
	-- privacy_policy = "https://atl.chat/privacy",
}
-- Optional: add custom fields
server_info_extensions = {
	{ name = "Source", url = "https://github.com/allthingslinux/xmpp.atl.chat" },
}

account_cleanup = {
	inactive_period = 365 * 24 * 3600,
	grace_period = 30 * 24 * 3600,
}
