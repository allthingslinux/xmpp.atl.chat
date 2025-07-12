-- Main Domain Configuration
-- Primary virtual host settings for the XMPP server

-- Get domain from environment or use localhost as default
local main_domain = os.getenv("PROSODY_DOMAIN") or "localhost"

-- Main virtual host configuration
VirtualHost(main_domain)
-- Authentication method (from stream layer configuration)
authentication = authentication_storage and authentication_storage.default or "internal_hashed"

-- Storage backend (will be overridden by storage layer)
storage = "internal"

-- Domain-specific modules
modules_enabled = {
	-- Core messaging
	"roster", -- Roster management (RFC 6121)
	"saslauth", -- SASL authentication
	"tls", -- TLS support
	"dialback", -- Server dialback (XEP-0220)
	"disco", -- Service discovery (XEP-0030)
	"carbons", -- Message carbons (XEP-0280)
	"pep", -- Personal eventing protocol (XEP-0163)
	"private", -- Private XML storage (XEP-0049)
	"blocklist", -- Blocking command (XEP-0191)
	"vcard4", -- vCard4 support (XEP-0292)
	"vcard_legacy", -- Legacy vCard support (XEP-0054)
	"version", -- Software version (XEP-0092)
	"uptime", -- Server uptime (XEP-0012)
	"time", -- Entity time (XEP-0202)
	"ping", -- XMPP ping (XEP-0199)
	"register", -- In-band registration (XEP-0077)
	"mam", -- Message archive management (XEP-0313)
	"csi_simple", -- Client state indication (XEP-0352)
	"smacks", -- Stream management (XEP-0198)
}

-- Domain-specific SSL certificate
ssl = {
	key = "certs/" .. main_domain .. ".key",
	certificate = "certs/" .. main_domain .. ".crt",
}

-- Domain-specific contact information
contact_info = {
	abuse = { "mailto:abuse@" .. main_domain, "xmpp:abuse@" .. main_domain },
	admin = { "mailto:admin@" .. main_domain, "xmpp:admin@" .. main_domain },
	feedback = { "mailto:feedback@" .. main_domain, "xmpp:feedback@" .. main_domain },
	sales = { "mailto:sales@" .. main_domain, "xmpp:sales@" .. main_domain },
	security = { "mailto:security@" .. main_domain, "xmpp:security@" .. main_domain },
	support = { "mailto:support@" .. main_domain, "xmpp:support@" .. main_domain },
}

-- Conference subdomain for group chats
local conference_domain = "conference." .. main_domain
Component(conference_domain, "muc")
name = "Group Chat Service"
modules_enabled = {
	"muc_mam", -- Message archiving for group chats
	"muc_limits", -- Room limits and restrictions
	"muc_log", -- Room logging
	"muc_room_list", -- Public room list
}

-- Group chat configuration
muc_room_locking = false
muc_room_lock_timeout = 300
muc_tombstones = true
muc_tombstone_expiry = 31 * 24 * 60 * 60 -- 31 days

-- Default room configuration
muc_room_default_public = false
muc_room_default_members_only = false
muc_room_default_moderated = false
muc_room_default_persistent = false
muc_room_default_history_length = 20

-- HTTP upload subdomain for file sharing
local upload_domain = "upload." .. main_domain
Component(upload_domain, "http_upload")
name = "File Upload Service"

-- HTTP upload configuration
http_upload_file_size_limit = 100 * 1024 * 1024 -- 100MB
http_upload_expire_after = 60 * 60 * 24 * 7 -- 7 days
http_upload_quota = 1024 * 1024 * 1024 -- 1GB per user

-- Proxy subdomain for external services (if needed)
local proxy_domain = "proxy." .. main_domain
-- Component(proxy_domain, "proxy65")
--     name = "File Transfer Proxy"
--     proxy65_address = main_domain
--     proxy65_acl = { main_domain }

-- PubSub subdomain for publish-subscribe services
local pubsub_domain = "pubsub." .. main_domain
Component(pubsub_domain, "pubsub")
name = "Publish-Subscribe Service"
modules_enabled = {
	"pubsub_feeds", -- RSS/Atom feed support
	"pubsub_github", -- GitHub webhook integration
}

-- Log domain configuration
log("info", "Configured main domain: %s", main_domain)
log("info", "Configured conference domain: %s", conference_domain)
log("info", "Configured upload domain: %s", upload_domain)
log("info", "Configured pubsub domain: %s", pubsub_domain)
