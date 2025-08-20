-- ===============================================
-- CONTACT INFO, ROLES, ACCOUNT CLEANUP
-- ===============================================

disco_items = {
	{ "discord.gg/linux", "Discord" },
	{ "irc.atl.chat", "IRC" },
}

contact_info = {
	admin = {
		"xmpp:admin@atl.chat",
		"mailto:admin@atl.chat",
	},
	abuse = {
		"xmpp:admin@atl.chat",
		"mailto:admin@atl.chat",
	},
	support = {
		"xmpp:admin@atl.chat",
		"mailto:admin@atl.chat",
	},
	security = {
		"xmpp:admin@atl.chat",
		"mailto:admin@atl.chat",
	},
}

server_info = {
	name = "atl.chat",
	website = "https://atl.chat",
	description = "atl.chat XMPP service",
}
-- Optional: add custom fields
server_info_extensions = {
	{ name = "Source", url = "https://github.com/allthingslinux/xmpp.atl.chat" },
}

account_cleanup = {
	inactive_period = 365 * 24 * 3600,
	grace_period = 30 * 24 * 3600,
}
