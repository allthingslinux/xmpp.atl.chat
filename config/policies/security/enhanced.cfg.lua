-- ===============================================
-- ENHANCED SECURITY POLICY
-- Stricter security settings for sensitive environments
-- ===============================================

-- Mandatory encryption for all connections
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true

-- Strong TLS settings
ssl_protocol = "tlsv1_2+"
ssl_ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS"

-- Enhanced authentication
authentication = "internal_hashed"
allow_unencrypted_plain_auth = false

-- Strict rate limiting
limits = {
	c2s = {
		rate = "5kb/s",
		burst = "2s",
	},
	s2s = {
		rate = "20kb/s",
		burst = "2s",
	},
	http_upload = {
		rate = "1mb/s",
		burst = "5s",
	},
}

-- Enhanced security modules
modules_enabled = modules_enabled or {}
local enhanced_security_modules = {
	"limits", -- Rate limiting
	"firewall", -- Advanced firewall
	"block_registrations", -- Block open registration
	"block_strangers", -- Block messages from strangers
	"watchregistrations", -- Monitor registrations
	"log_auth", -- Authentication logging
	"carbons_copies", -- Prevent carbon copies leaks
	"smacks_noerror", -- Secure stream management
}

for _, module in ipairs(enhanced_security_modules) do
	table.insert(modules_enabled, module)
end

-- Disable potentially insecure features
allow_registration = false
registration_whitelist = {}

-- Enhanced logging for security events
log = {
	{ levels = { min = "warn" }, to = "console" },
	{ levels = { min = "info" }, to = "file", filename = "/var/log/prosody/security.log" },
}

-- Strict certificate validation
s2s_insecure_domains = {}
s2s_secure_domains = {} -- Empty means all domains must be secure

-- Enhanced privacy settings
archive_expires_after = "90d" -- Shorter retention for privacy
default_archive_policy = "roster" -- Only archive for roster contacts

print("Enhanced security policy loaded - strict security mode active")
