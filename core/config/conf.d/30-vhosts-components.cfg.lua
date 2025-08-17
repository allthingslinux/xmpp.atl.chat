-- ===============================================
-- VIRTUAL HOSTS + COMPONENTS
-- ===============================================

-- Main domain configuration
VirtualHost(Lua.os.getenv("PROSODY_DOMAIN") or "localhost")

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
	{ __service_host, "Pastebin Service" },
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

-- MUC moved to conf.d/31-muc.cfg.lua

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
