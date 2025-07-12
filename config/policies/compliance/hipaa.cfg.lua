-- ===============================================
-- HIPAA COMPLIANCE POLICY
-- Healthcare compliance settings (US)
-- ===============================================

-- HIPAA requires encryption in transit and at rest
c2s_require_encryption = true
s2s_require_encryption = true
require_encryption = true

-- Strong authentication required
authentication = "internal_hashed"
allow_unencrypted_plain_auth = false

-- HIPAA compliance modules
modules_enabled = modules_enabled or {}
local hipaa_modules = {
	"audit", -- Comprehensive audit logging
	"log_auth", -- Authentication logging
	"log_events", -- Event logging
	"mam", -- Message archiving for audit
	"carbons", -- Message synchronization
	"blocking", -- User blocking capability
	"privacy", -- Privacy controls
}

for _, module in ipairs(hipaa_modules) do
	table.insert(modules_enabled, module)
end

-- HIPAA data retention requirements
archive_expires_after = "6y" -- 6 years minimum retention
muc_log_expires_after = "6y" -- Group chat retention
default_archive_policy = "always" -- Archive all messages

-- Access controls
allow_registration = false -- No open registration
registration_whitelist = {} -- Controlled user creation

-- Audit logging requirements
log = {
	{ levels = { min = "info" }, to = "file", filename = "/var/log/prosody/hipaa-audit.log" },
	{ levels = { min = "warn" }, to = "file", filename = "/var/log/prosody/hipaa-security.log" },
	{ levels = { min = "error" }, to = "console" },
}

-- Data protection settings
strip_metadata = true -- Remove metadata from files
anonymize_ips = true -- Anonymize IP addresses in logs

-- Session management for HIPAA
c2s_timeout = 900 -- 15 minute timeout for security
bosh_max_inactivity = 600 -- 10 minute BOSH timeout

-- Disable features that could leak PHI
cross_domain_bosh = false
cross_domain_websocket = false

-- Backup and disaster recovery
backup_frequency = "daily"
backup_retention = "7y" -- 7 years backup retention
backup_encryption = true

-- User access controls
max_user_sessions = 3 -- Limit concurrent sessions
session_timeout = 900 -- 15 minute session timeout

print("HIPAA compliance policy loaded - healthcare data protection active")
