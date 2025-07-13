-- ===============================================
-- PARANOID SECURITY POLICY
-- Maximum security settings for high-risk environments
-- ===============================================

-- Mandatory encryption everywhere
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true
require_encryption = true

-- Paranoid TLS settings
ssl_protocol = "tlsv1_3+" -- Only TLS 1.3
ssl_ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:!aNULL:!MD5:!DSS:!RC4:!3DES"
ssl_options = { "no_sslv2", "no_sslv3", "no_tlsv1", "no_tlsv1_1", "no_compression" }

-- Ultra-strict authentication
authentication = "internal_hashed"
allow_unencrypted_plain_auth = false
sasl_mechanisms = { "SCRAM-SHA-256", "SCRAM-SHA-1" } -- Only secure SASL

-- Extreme rate limiting
limits = {
	c2s = {
		rate = "2kb/s",
		burst = "1s",
	},
	s2s = {
		rate = "10kb/s",
		burst = "1s",
	},
	http_upload = {
		rate = "500kb/s",
		burst = "2s",
	},
}

-- Maximum security modules
modules_enabled = modules_enabled or {}
local paranoid_security_modules = {
	"limits", -- Rate limiting
	"firewall", -- Advanced firewall
	"block_registrations", -- Block all registration
	"block_strangers", -- Block all strangers
	"block_subscriptions", -- Block subscription requests
	"watchregistrations", -- Monitor all registrations
	"log_auth", -- Log all authentication
	"log_events", -- Log all events
	"carbons_copies", -- Prevent carbon leaks
	"smacks_noerror", -- Secure stream management
	"filter_chatstates", -- Filter chat states
	"privacy_lists", -- Enhanced privacy
	"blocklist", -- User blocking (core)
}

for _, module in ipairs(paranoid_security_modules) do
	table.insert(modules_enabled, module)
end

-- Disable all potentially risky features
allow_registration = false
registration_whitelist = {}
cross_domain_bosh = false
cross_domain_websocket = false

-- Paranoid logging - log everything
log = {
	{ levels = { min = "debug" }, to = "file", filename = "/var/log/prosody/paranoid-debug.log" },
	{ levels = { min = "info" }, to = "file", filename = "/var/log/prosody/paranoid-info.log" },
	{ levels = { min = "warn" }, to = "file", filename = "/var/log/prosody/paranoid-security.log" },
	{ levels = { min = "error" }, to = "console" },
}

-- Maximum certificate security
s2s_insecure_domains = {}
s2s_secure_domains = {} -- All domains must be secure
s2s_timeout = 30 -- Short timeout

-- Minimal data retention for privacy
archive_expires_after = "30d" -- Only 30 days
default_archive_policy = "never" -- Don't archive by default
muc_log_expires_after = "7d" -- MUC logs only 7 days

-- Disable potentially leaky features
roster_versioning = false
stream_management_default = false

-- Paranoid connection limits
c2s_timeout = 60 -- 1 minute timeout
s2s_timeout = 30 -- 30 second timeout
bosh_max_inactivity = 30 -- 30 second BOSH timeout

print("PARANOID security policy loaded - MAXIMUM SECURITY MODE ACTIVE")
