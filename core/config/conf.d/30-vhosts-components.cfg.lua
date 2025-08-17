-- ===============================================
-- VIRTUAL HOSTS + COMPONENTS
-- ===============================================

-- Main domain configuration
VirtualHost(Lua.os.getenv("PROSODY_DOMAIN") or "localhost")
-- Map HTTP host to public hostname so Prosody recognizes Host: xmpp.atl.chat
http_host = Lua.os.getenv("PROSODY_HTTP_HOST") or (Lua.os.getenv("PROSODY_DOMAIN") or "localhost")

-- Domain TLS (atl.chat lineage by default)
ssl = {
	key = "certs/live/" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost") .. "/privkey.pem",
	certificate = "certs/live/" .. (Lua.os.getenv("PROSODY_DOMAIN") or "localhost") .. "/fullchain.pem",
}

-- Discovery items and service host mapping
local __domain = Lua.os.getenv("PROSODY_DOMAIN") or "localhost"
local __service_host = Lua.os.getenv("PROSODY_SERVICE_HOST") or __domain
-- Allow MUC to live on a different host (e.g., muc.atl.chat)
local __muc_host = Lua.os.getenv("PROSODY_MUC_HOST") or ("muc." .. __domain)

disco_items = {
	-- { __muc_host, "Multi-User Chat Rooms" },
	-- { "proxy." .. __domain, "SOCKS5 File Transfer Proxy" },
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

-- HTTP File Upload is served on the main VirtualHost via mod_http_file_share
-- No dedicated upload component is used

-- Proxy65 component
Component("proxy." .. __domain, "proxy65")
-- Use the domain lineage cert (wildcard covers subdomains)
ssl = {
	key = "certs/live/" .. __domain .. "/privkey.pem",
	certificate = "certs/live/" .. __domain .. "/fullchain.pem",
}
name = "SOCKS5 Proxy"
description = "File transfer proxy service (XEP-0065)"
proxy65_address = "proxy." .. __domain
