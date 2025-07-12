-- ===============================================
-- PROXY DOMAIN CONFIGURATION
-- Gateway and proxy services
-- ===============================================

local domain = os.getenv("PROSODY_DOMAIN") or "localhost"
local proxy_domain = "proxy." .. domain

-- Configure proxy component
Component(proxy_domain)("proxy65")

-- Proxy-specific modules
modules_enabled = {
	"proxy65", -- SOCKS5 proxy for file transfers
	"proxy65_whitelist", -- Whitelist for proxy access
}

-- Proxy configuration
proxy65_address = proxy_domain
proxy65_port = 5000
proxy65_acl = { domain } -- Only allow local domain

print("Proxy domain configured: " .. proxy_domain)
