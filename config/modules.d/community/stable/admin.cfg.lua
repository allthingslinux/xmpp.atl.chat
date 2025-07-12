-- ============================================================================
-- ADMINISTRATION MODULES (STABLE)
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Server monitoring, administration, and performance tracking

-- ============================================================================
-- mod_log_slow_events - Log Warning When Event Handlers Take Too Long
-- ============================================================================
-- Monitor and log slow event handlers to identify performance bottlenecks
-- Helps optimize server performance and identify problematic modules

log_slow_events_threshold = tonumber(os.getenv("PROSODY_SLOW_EVENTS_THRESHOLD")) or 0.5 -- 500ms
log_slow_events_file = os.getenv("PROSODY_SLOW_EVENTS_LOG") or "/var/log/prosody/slow_events.log"

-- ============================================================================
-- mod_reload_modules - Automatically Reload Modules with the Config
-- ============================================================================
-- Automatically reload modules when configuration files change
-- Enables hot-reloading of module configurations without server restart

reload_modules_auto = os.getenv("PROSODY_AUTO_RELOAD_MODULES") ~= "false"
reload_modules_watch_config = os.getenv("PROSODY_WATCH_CONFIG_CHANGES") ~= "false"

-- ============================================================================
-- mod_server_status - Server Status Plugin
-- ============================================================================
-- Provide detailed server status information via HTTP endpoint
-- Useful for monitoring, health checks, and administrative dashboards

server_status_show_os = os.getenv("PROSODY_STATUS_SHOW_OS") ~= "false"
server_status_show_lua = os.getenv("PROSODY_STATUS_SHOW_LUA") ~= "false"
server_status_show_prosody = os.getenv("PROSODY_STATUS_SHOW_PROSODY") ~= "false"

-- Status page configuration
server_status_json = os.getenv("PROSODY_STATUS_JSON") ~= "false"
server_status_http_path = os.getenv("PROSODY_STATUS_HTTP_PATH") or "/server-status"

-- ============================================================================
-- mod_stanza_counter - Simple Incoming and Outgoing Stanza Counter
-- ============================================================================
-- Track and count XMPP stanzas for monitoring and statistics
-- Provides basic metrics for server activity and usage patterns

stanza_counter_reset_interval = tonumber(os.getenv("PROSODY_STANZA_COUNTER_RESET")) or 3600 -- 1 hour
stanza_counter_log_stats = os.getenv("PROSODY_STANZA_COUNTER_LOG") ~= "false"
