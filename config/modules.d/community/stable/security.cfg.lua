-- ============================================================================
-- STABLE SECURITY MODULES CONFIGURATION
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- These modules are well-tested and safe for production use

-- ============================================================================
-- ANTI-SPAM CONFIGURATION
-- ============================================================================

-- Spam reporting configuration
spam_reporting_threshold = tonumber(os.getenv("PROSODY_SPAM_THRESHOLD")) or 3
spam_reporting_notification = os.getenv("PROSODY_SPAM_NOTIFICATION") or "admin@localhost"

-- Registration monitoring
watchregistrations_alert_admins = true
watchregistrations_registration_whitelist = "/etc/prosody/whitelist.txt"
watchregistrations_registration_blacklist = "/etc/prosody/blacklist.txt"

-- Block registrations configuration
block_registrations_except_admins = true
block_registrations_message = "Registration is currently disabled"

-- ============================================================================
-- FIREWALL CONFIGURATION
-- ============================================================================

-- Rate limiting thresholds
firewall_rate_limit_c2s = os.getenv("PROSODY_FIREWALL_C2S_RATE") or "10/60"
firewall_rate_limit_s2s = os.getenv("PROSODY_FIREWALL_S2S_RATE") or "30/60"

-- Quarantine configuration
isolate_except_admins = true
isolate_stanza_types = { "message", "presence", "iq" }

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
-- SECURITY MONITORING
-- ============================================================================

-- Failed authentication tracking
track_failed_auths = true
failed_auth_threshold = tonumber(os.getenv("PROSODY_FAILED_AUTH_THRESHOLD")) or 5
failed_auth_window = tonumber(os.getenv("PROSODY_FAILED_AUTH_WINDOW")) or 300 -- 5 minutes

-- Connection monitoring
max_connections_per_ip = tonumber(os.getenv("PROSODY_MAX_CONNECTIONS_PER_IP")) or 10

-- ============================================================================
-- TOMBSTONES CONFIGURATION
-- ============================================================================

-- Tombstone expiry (for deleted users)
user_tombstone_expire = 60*86400 -- 2 months 