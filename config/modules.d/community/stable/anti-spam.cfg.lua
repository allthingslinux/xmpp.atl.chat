-- ============================================================================
-- ANTI-SPAM AND ABUSE PREVENTION MODULES (STABLE)
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Registration blocking and abuse prevention

-- ============================================================================
-- mod_block_registrations - Block User Registrations
-- ============================================================================
-- Prevent new user registrations except for administrators
-- Useful for private servers or during maintenance

block_registrations_except_admins = true
block_registrations_message = "Registration is currently disabled"

-- ============================================================================
-- REGISTRATION MONITORING (CORE MODULE)
-- ============================================================================
-- Configuration for mod_watchregistrations (core module)
-- Monitor and alert on new user registrations

watchregistrations_alert_admins = true
watchregistrations_registration_whitelist = "/etc/prosody/whitelist.txt"
watchregistrations_registration_blacklist = "/etc/prosody/blacklist.txt"

-- ============================================================================
-- DNS BLOCKLIST CONFIGURATION
-- ============================================================================
-- DNS blocklist providers for IP reputation checking
-- XMPP Safeguarding Manifesto compliant providers

blocklist_providers = {
	"zen.spamhaus.org",
	"sbl.spamhaus.org",
	"pbl.spamhaus.org",
	"bl.spamcop.net",
	"dnsbl.sorbs.net",
	"xmppbl.org",
}

-- Local blocklist file
blocklist_file = "/etc/prosody/blocklist.txt"
