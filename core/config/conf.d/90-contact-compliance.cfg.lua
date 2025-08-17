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

default_user_role = "prosody:user"
default_admin_role = "prosody:admin"

account_cleanup = {
	inactive_period = 365 * 24 * 3600,
	grace_period = 30 * 24 * 3600,
}
