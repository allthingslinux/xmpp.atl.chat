-- ============================================================================
-- NETWORKING MODULES (STABLE)
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Connection management, throttling, and network utilities

-- ============================================================================
-- mod_c2s_conn_throttle - C2S Connections Throttling Module
-- ============================================================================
-- Throttle client-to-server connections to prevent connection flooding
-- Limits number of connections per IP address within a time period

c2s_conn_throttle_max_connections = tonumber(os.getenv("PROSODY_C2S_MAX_CONNECTIONS")) or 10
c2s_conn_throttle_period = tonumber(os.getenv("PROSODY_C2S_THROTTLE_PERIOD")) or 60
c2s_conn_throttle_burst = tonumber(os.getenv("PROSODY_C2S_THROTTLE_BURST")) or 3

-- ============================================================================
-- mod_s2s_idle_timeout - Close Idle Server-to-Server Connections
-- ============================================================================
-- Automatically close idle server-to-server connections to save resources
-- Helps prevent connection leaks and reduces memory usage

s2s_idle_timeout = tonumber(os.getenv("PROSODY_S2S_IDLE_TIMEOUT")) or 300 -- 5 minutes
s2s_idle_timeout_check_interval = tonumber(os.getenv("PROSODY_S2S_IDLE_CHECK")) or 60 -- 1 minute

-- ============================================================================
-- mod_ipcheck - XEP-0279: Server IP Check
-- ============================================================================
-- Allow clients to discover their external IP address through the server
-- XEP-0279: https://xmpp.org/extensions/xep-0279.html

ipcheck_enable = os.getenv("PROSODY_ENABLE_IPCHECK") ~= "false"

-- ============================================================================
-- CONNECTION MONITORING (CONSOLIDATED)
-- ============================================================================
-- Additional connection limits and monitoring settings
-- Consolidated from firewall.cfg.lua to avoid duplication

-- Global connection limits per IP
max_connections_per_ip = tonumber(os.getenv("PROSODY_MAX_CONNECTIONS_PER_IP")) or 10

-- Failed authentication tracking
track_failed_auths = true
failed_auth_threshold = tonumber(os.getenv("PROSODY_FAILED_AUTH_THRESHOLD")) or 5
failed_auth_window = tonumber(os.getenv("PROSODY_FAILED_AUTH_WINDOW")) or 300 -- 5 minutes
