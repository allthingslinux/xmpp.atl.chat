-- ============================================================================
-- FIREWALL AND RATE LIMITING MODULES
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Network security, rate limiting, and connection monitoring

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
-- CONNECTION MONITORING
-- ============================================================================

-- Connection limits and monitoring
max_connections_per_ip = tonumber(os.getenv("PROSODY_MAX_CONNECTIONS_PER_IP")) or 10

-- Failed authentication tracking
track_failed_auths = true
failed_auth_threshold = tonumber(os.getenv("PROSODY_FAILED_AUTH_THRESHOLD")) or 5
failed_auth_window = tonumber(os.getenv("PROSODY_FAILED_AUTH_WINDOW")) or 300 -- 5 minutes
