-- ===============================================
-- VIRTUAL HOSTS + COMPONENTS
-- ===============================================

-- Simplified single-domain configuration (hardcoded)
local __base_domain = "atl.chat"

-- Single VirtualHost for everything (simple and works)
VirtualHost(__base_domain)
-- Use wildcard certificate that covers *.atl.chat
ssl = {
	key = "certs/live/" .. __base_domain .. "/privkey.pem",
	certificate = "certs/live/" .. __base_domain .. "/fullchain.pem",
}

-- Discovery items and service host mapping (simplified, keep components on *.atl.chat)
local __muc_host = "muc." .. __base_domain -- muc.atl.chat
local __upload_host = "upload." .. __base_domain -- upload.atl.chat
local __proxy_host = "proxy." .. __base_domain -- proxy.atl.chat

-- Automatic discovery: Prosody links direct subdomains (muc/upload/proxy) to the
-- main VirtualHost automatically. Avoid manual duplicates. Only define
-- disco_items if provided via environment.
local disco_items_env = Lua.os.getenv("PROSODY_DISCO_ITEMS")
if disco_items_env then
	disco_items = {}
	for item in Lua.string.gmatch(disco_items_env, "([^;]+)") do
		local jid, name = item:match("([^,]+),(.+)")
		if jid and name then
			Lua.table.insert(disco_items, { jid:match("^%s*(.-)%s*$"), name:match("^%s*(.-)%s*$") })
		end
	end
end

disco_expose_admins = false

-- MUC moved to conf.d/31-muc.cfg.lua

-- HTTP File Upload dedicated component host (upload.atl.chat)
Component(__upload_host, "http_file_share")
ssl = {
	key = "certs/live/" .. __base_domain .. "/privkey.pem",
	certificate = "certs/live/" .. __base_domain .. "/fullchain.pem",
}
name = "File Upload Service"
description = "HTTP file upload and sharing (XEP-0363)"
-- Advertise clean external URL for uploads
http_external_url = "https://" .. __upload_host .. "/"

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
