-- ============================================================================
-- MAIN DOMAIN CONFIGURATION
-- ============================================================================
-- Primary domain setup with component integration
-- Integrates with layer-based stack configuration

local domain = os.getenv("PROSODY_DOMAIN") or "localhost"

-- ============================================================================
-- VIRTUAL HOST CONFIGURATION
-- ============================================================================

VirtualHost(domain)
-- Enable core XMPP features
enabled = true

-- Authentication configuration (from stream layer)
authentication = authentication_method or "internal_hashed"

-- Storage configuration (from storage layer)
storage = storage_backend or "internal"

-- Message archive retention (from storage layer)
archive_expires_after = archive_retention_period or "1y"

-- SSL/TLS configuration (from transport layer)
ssl = ssl_config
	or {
		key = "/etc/prosody/certs/" .. domain .. ".key",
		certificate = "/etc/prosody/certs/" .. domain .. ".crt",
	}

-- HTTP file upload limits (from interfaces layer)
http_file_share_size_limit = http_upload_file_size_limit or 50 * 1024 * 1024 -- 50MB
http_file_share_expire_after = http_upload_expire_after or 60 * 60 * 24 * 7 -- 1 week

-- User registration settings (from stream layer)
allow_registration = allow_user_registration or false
registration_watchers = registration_notification_contacts or { "admin@" .. domain }

-- Contact information (compliance requirement)
contact_info = {
	admin = { "xmpp:admin@" .. domain, "mailto:admin@" .. domain },
	support = { "xmpp:support@" .. domain, "mailto:support@" .. domain },
	abuse = { "xmpp:abuse@" .. domain, "mailto:abuse@" .. domain },
}

-- ============================================================================
-- COMPONENT CONFIGURATIONS
-- ============================================================================

-- Multi-User Chat (MUC) Component
-- Provides chatroom functionality
Component("conference." .. domain)("muc")
name = "Chatrooms"
restrict_room_creation = false
max_history_messages = 50

-- Room configuration defaults
muc_room_default_language = "en"
muc_room_default_public = false
muc_room_default_persistent = true
muc_room_default_members_only = false
muc_room_default_moderated = false
muc_room_default_change_subject = true
muc_room_default_history_length = 20

-- Archive integration (from storage layer)
modules_enabled = {
	"muc_mam", -- Message Archive Management for MUC
	"muc_unique", -- Unique room names
}

-- Storage configuration
storage = {
	muc_log = storage_backend or "internal",
	muc_config = storage_backend or "internal",
}

-- HTTP Upload Component
-- Provides file upload and sharing
Component("upload." .. domain)("http_file_share")
http_file_share_size_limit = http_upload_file_size_limit or 50 * 1024 * 1024 -- 50MB
http_file_share_expire_after = http_upload_expire_after or 60 * 60 * 24 * 7 -- 1 week
http_file_share_daily_quota = http_upload_daily_quota or 500 * 1024 * 1024 -- 500MB per day

-- Storage for uploaded files
http_file_share_path = "/var/lib/prosody/upload"

-- Publish-Subscribe (PubSub) Component
-- Provides publish-subscribe functionality
Component("pubsub." .. domain)("pubsub")
name = "Publish-Subscribe Service"

-- Node configuration
autocreate_on_publish = true
autocreate_on_subscribe = true
default_admin = "admin@" .. domain

-- Storage configuration
storage = {
	pubsub_nodes = storage_backend or "internal",
	pubsub_data = storage_backend or "internal",
}

-- SOCKS5 Bytestreams Proxy
-- Provides file transfer proxy
Component("proxy." .. domain)("proxy65")
proxy65_address = domain
proxy65_acl = { domain }

-- ============================================================================
-- EXTERNAL SERVICE DISCOVERY
-- ============================================================================

-- External services for service discovery
external_services = {
	-- STUN/TURN servers for voice/video calls
	{
		type = "stun",
		host = "stun." .. domain,
		port = 3478,
	},
	{
		type = "turn",
		host = "turn." .. domain,
		port = 3478,
		username = "prosody",
		password = os.getenv("TURN_PASSWORD") or "changeme",
		restricted = true,
	},
}

-- ============================================================================
-- FEATURE ADVERTISEMENT
-- ============================================================================

-- Service discovery items
disco_items = {
	{ "conference." .. domain, "Chatrooms" },
	{ "upload." .. domain, "File Upload" },
	{ "pubsub." .. domain, "Publish-Subscribe" },
	{ "proxy." .. domain, "File Transfer Proxy" },
}

-- ============================================================================
-- COMPLIANCE AND SECURITY
-- ============================================================================

-- Welcome message for new users
welcome_message = "Welcome to "
	.. domain
	.. "! "
	.. "This server supports modern XMPP features including "
	.. "message encryption, file sharing, and group chat. "
	.. "For support, contact admin@"
	.. domain

-- Message of the day
motd_text = [[Welcome to ]]
	.. domain
	.. [[!

This server features:
• End-to-end encryption (OMEMO)
• Message Archive Management (MAM)
• File upload and sharing
• Group chat (MUC)
• Push notifications
• Modern authentication

For help: admin@]]
	.. domain

-- User account management
-- Allow users to manage their accounts
user_account_management_enabled = true

-- Blocked usernames for registration
block_registrations_users = {
	"admin",
	"administrator",
	"root",
	"xmpp",
	"prosody",
	"postmaster",
	"webmaster",
	"hostmaster",
	"abuse",
	"support",
	"help",
	"info",
	"noreply",
	"no-reply",
	"system",
	"daemon",
	"service",
	"test",
	"guest",
	"anonymous",
	"api",
	"www",
	"mail",
	"email",
	"conference",
	"upload",
	"pubsub",
	"proxy",
	"muc",
	"register",
	"registration",
}
