-- ===============================================
-- COMPREHENSIVE AUDIT LOGGING POLICY
-- Detailed audit trail for compliance and security
-- ===============================================

-- Comprehensive audit modules
modules_enabled = modules_enabled or {}
local audit_modules = {
	"audit", -- Core audit logging
	"log_auth", -- Authentication events
	"log_events", -- All server events
	"log_rate_limit", -- Rate limiting events
	"log_slow_events", -- Performance monitoring
	"watchregistrations", -- Registration monitoring
	"mam", -- Message archiving
	"muc_mam", -- Group chat archiving
}

for _, module in ipairs(audit_modules) do
	table.insert(modules_enabled, module)
end

-- Detailed audit logging configuration
log = {
	-- Authentication audit trail
	{
		levels = { "info", "warn", "error" },
		to = "file",
		filename = "/var/log/prosody/audit-auth.log",
		filter = "auth",
	},

	-- Connection audit trail
	{
		levels = { "info", "warn", "error" },
		to = "file",
		filename = "/var/log/prosody/audit-connections.log",
		filter = "connections",
	},

	-- Message audit trail
	{
		levels = { "info", "warn", "error" },
		to = "file",
		filename = "/var/log/prosody/audit-messages.log",
		filter = "messages",
	},

	-- Administrative actions
	{
		levels = { "info", "warn", "error" },
		to = "file",
		filename = "/var/log/prosody/audit-admin.log",
		filter = "admin",
	},

	-- Security events
	{
		levels = { "warn", "error" },
		to = "file",
		filename = "/var/log/prosody/audit-security.log",
		filter = "security",
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
	auth_logs = "3y", -- Authentication logs: 3 years
	connection_logs = "1y", -- Connection logs: 1 year
	message_logs = "7y", -- Message logs: 7 years
	admin_logs = "10y", -- Admin logs: 10 years
	security_logs = "10y", -- Security logs: 10 years
}

-- Events to audit
audit_events = {
	-- Authentication events
	"authentication-success",
	"authentication-failure",
	"session-opened",
	"session-closed",

	-- Authorization events
	"resource-bind",
	"resource-unbind",

	-- Communication events
	"message-sent",
	"message-received",
	"presence-sent",
	"presence-received",

	-- Administrative events
	"user-created",
	"user-deleted",
	"user-modified",
	"config-changed",

	-- Security events
	"rate-limit-exceeded",
	"invalid-certificate",
	"encryption-failure",
	"firewall-block",
}

-- Audit log format (structured for analysis)
audit_log_format = "json" -- JSON format for log analysis tools

-- Audit log rotation
audit_log_rotation = {
	size = "100MB", -- Rotate at 100MB
	count = 50, -- Keep 50 rotated files
	compress = true, -- Compress rotated logs
}

-- Real-time audit alerts
audit_alerts = {
	-- Alert on multiple failed logins
	failed_auth_threshold = 5,
	failed_auth_window = 300, -- 5 minutes

	-- Alert on admin actions
	admin_action_alert = true,

	-- Alert on security events
	security_event_alert = true,
}

-- Audit data integrity
audit_integrity = {
	checksum = true, -- Generate checksums for audit logs
	digital_signature = true, -- Digitally sign audit logs
	tamper_detection = true, -- Detect log tampering
}

print("Comprehensive audit logging policy loaded - full audit trail active")
