-- ============================================================================
-- FIREWALL MODULES (STABLE)
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Network firewall rules and stanza filtering

-- ============================================================================
-- mod_firewall - Network Firewall Rules
-- ============================================================================
-- Advanced stanza filtering and firewall rules for XMPP traffic
-- Provides powerful rule-based filtering for security and policy enforcement

-- Rate limiting thresholds
firewall_rate_limit_c2s = os.getenv("PROSODY_FIREWALL_C2S_RATE") or "10/60"
firewall_rate_limit_s2s = os.getenv("PROSODY_FIREWALL_S2S_RATE") or "30/60"

-- Quarantine configuration
isolate_except_admins = true
isolate_stanza_types = { "message", "presence", "iq" }

-- Firewall script location
firewall_scripts = os.getenv("PROSODY_FIREWALL_SCRIPTS") or "/etc/prosody/firewall/"
