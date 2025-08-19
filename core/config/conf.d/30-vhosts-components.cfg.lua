-- ===============================================
-- VIRTUAL HOSTS + COMPONENTS
-- ===============================================

-- Single VirtualHost
VirtualHost("atl.chat")
ssl = {
	key = "certs/live/atl.chat/privkey.pem",
	certificate = "certs/live/atl.chat/fullchain.pem",
}

disco_expose_admins = false

-- HTTP File Upload component
Component("upload.atl.chat", "http_file_share")
ssl = {
	key = "certs/live/atl.chat/privkey.pem",
	certificate = "certs/live/atl.chat/fullchain.pem",
}

name = "File Upload Service"
description = "HTTP file upload and sharing (XEP-0363)"
http_external_url = "https://upload.atl.chat/"

-- SOCKS5 Proxy component
Component("proxy.atl.chat", "proxy65")
ssl = {
	key = "certs/live/atl.chat/privkey.pem",
	certificate = "certs/live/atl.chat/fullchain.pem",
}
name = "SOCKS5 Proxy"
description = "File transfer proxy service (XEP-0065)"
proxy65_address = "proxy.atl.chat"
