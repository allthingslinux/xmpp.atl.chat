-- ============================================================================
-- ANTI-SPAM AND ABUSE PREVENTION MODULES
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Modules focused on preventing spam, abuse, and unwanted registrations

-- ============================================================================
-- SPAM REPORTING - XEP-0377
-- ============================================================================

-- Spam reporting configuration
spam_reporting_threshold = tonumber(os.getenv("PROSODY_SPAM_THRESHOLD")) or 3
spam_reporting_notification = os.getenv("PROSODY_SPAM_NOTIFICATION") or "admin@localhost"

-- ============================================================================
-- REGISTRATION MONITORING
-- ============================================================================

-- Registration monitoring and alerts
watchregistrations_alert_admins = true
watchregistrations_registration_whitelist = "/etc/prosody/whitelist.txt"
watchregistrations_registration_blacklist = "/etc/prosody/blacklist.txt"

-- Block registrations configuration
block_registrations_except_admins = true
block_registrations_message = "Registration is currently disabled"

-- ============================================================================
-- BLOCKLIST CONFIGURATION
-- ============================================================================

-- DNS blocklist providers (XMPP Safeguarding Manifesto compliant)
blocklist_providers = {
    "zen.spamhaus.org",
    "sbl.spamhaus.org",
    "pbl.spamhaus.org",
    "bl.spamcop.net",
    "dnsbl.sorbs.net",
    "xmppbl.org"
}

-- Local blocklist file
blocklist_file = "/etc/prosody/blocklist.txt"

-- ============================================================================
-- USER TOMBSTONES
-- ============================================================================

-- Tombstone expiry is configured in global.cfg.lua 