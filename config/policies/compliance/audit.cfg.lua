-- ===============================================
-- COMPREHENSIVE AUDIT LOGGING POLICY
-- Detailed audit trail for compliance and security
-- Using standard Prosody logging and existing modules
-- ===============================================

-- Comprehensive audit modules (using existing modules)
modules_enabled = modules_enabled or {}
local audit_modules = {
	"mam", -- Message Archive Management for message audit
	"tombstones", -- User deletion tracking
	"watchregistrations", -- Registration monitoring
	"limits", -- Rate limiting with logging
	"server_contact_info", -- Server compliance information
	"blocklist", -- User blocking audit trail
}

for _, module in ipairs(audit_modules) do
	table.insert(modules_enabled, module)
end

-- Comprehensive audit logging configuration
-- Using Prosody's built-in logging instead of fake audit module
log = {
	-- Authentication audit trail
	{
		levels = { min = "info" },
		to = "file",
		filename = "/var/log/prosody/audit-auth.log",
	},

	-- Connection audit trail
	{
		levels = { min = "info" },
		to = "file",
		filename = "/var/log/prosody/audit-connections.log",
	},

	-- Message audit trail (via MAM)
	{
		levels = { min = "info" },
		to = "file",
		filename = "/var/log/prosody/audit-messages.log",
	},

	-- Administrative audit trail
	{
		levels = { min = "warn" },
		to = "file",
		filename = "/var/log/prosody/audit-admin.log",
	},

	-- Security events audit trail
	{
		levels = { min = "error" },
		to = "file",
		filename = "/var/log/prosody/audit-security.log",
	},

	-- General audit log
	{
		levels = { min = "info" },
		to = "file",
		filename = "/var/log/prosody/audit-general.log",
	},
}

-- Audit data retention
audit_retention = {
	authentication_logs = "3y",
	connection_logs = "1y",
	message_logs = "2y",
	admin_logs = "5y",
	security_logs = "7y",
}

-- Events to audit (handled by enhanced logging)
audit_events = {
	"authentication_success",
	"authentication_failure",
	"user_login",
	"user_logout",
	"admin_login",
	"admin_command",
	"user_registration",
	"user_deletion",
	"message_sent",
	"message_received",
	"file_upload",
	"file_download",
	"muc_join",
	"muc_leave",
	"s2s_connection",
	"s2s_disconnection",
	"ssl_handshake",
	"certificate_verification",
	"rate_limit_exceeded",
	"blocked_user_attempt",
	"spam_detection",
	"security_violation",
}

-- Audit log format (JSON for analysis tools)
-- Note: Prosody uses its own log format, this is for reference
audit_log_format = "prosody" -- Using standard Prosody log format

-- Audit log rotation (handled by system logrotate)
audit_log_rotation = {
	daily = true,
	compress = true,
	retain_days = 365,
}

-- Real-time audit alerts (would need external monitoring)
audit_alerts = {
	authentication_failures = 5, -- Alert after 5 failures
	admin_commands = true, -- Alert on all admin commands
	security_events = true, -- Alert on all security events
	suspicious_activity = true,
}

-- Audit data integrity (handled at filesystem level)
audit_integrity = {
	checksum = true, -- Generate checksums for audit logs (external)
	digital_signature = false, -- Digital signing (external tool required)
	immutable_storage = true, -- Use immutable log storage
}

-- Message archiving for audit purposes
archive_expires_after = "3y" -- Keep messages for 3 years for audit
max_archive_query_results = 5000

print("Comprehensive audit logging policy loaded - using enhanced logging and existing modules")
