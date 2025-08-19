-- ===============================================
-- VIRTUAL HOSTS + COMPONENTS
-- ===============================================

-- Simplified domain configuration - everything under xmpp.atl.chat
local __base_domain = Lua.os.getenv("PROSODY_DOMAIN") or "localhost"  -- atl.chat
local __main_host = Lua.os.getenv("PROSODY_HTTP_HOST") or ("xmpp." .. __base_domain)  -- xmpp.atl.chat

-- Main VirtualHost (xmpp.atl.chat)
VirtualHost(__main_host)
-- Use wildcard certificate that covers *.atl.chat
ssl = {
	key = "certs/live/" .. __base_domain .. "/privkey.pem",
	certificate = "certs/live/" .. __base_domain .. "/fullchain.pem",
}

-- Discovery items and service host mapping (simplified, keep components on *.atl.chat)
local __muc_host = "muc." .. __base_domain  -- muc.atl.chat
local __proxy_host = "proxy." .. __base_domain  -- proxy.atl.chat

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

-- Proxy65 component (simplified)
Component(__proxy_host, "proxy65")
-- Use the wildcard certificate 
ssl = {
	key = "certs/live/" .. __base_domain .. "/privkey.pem",
	certificate = "certs/live/" .. __base_domain .. "/fullchain.pem",
}
name = "SOCKS5 Proxy"
description = "File transfer proxy service (XEP-0065)"
proxy65_address = __proxy_host
