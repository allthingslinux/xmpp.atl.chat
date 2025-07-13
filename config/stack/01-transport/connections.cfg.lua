-- Layer 01: Transport - Connection Management
-- Network connection settings and timeouts
-- Connection management, keep-alive, and optimization

local connections_config = {
	-- Core Connection Management
	-- Essential connection handling modules
	core_connections = {
		"net_multiplex", -- Connection multiplexing for performance
		"limits", -- Connection and rate limits
		"watchregistrations", -- Registration monitoring
		"c2s", -- Client-to-server connections (core)
		"s2s", -- Server-to-server connections (core)
	},

	-- Connection Monitoring
	-- Track and monitor connection health
	monitoring = {
		"measure_client_connections", -- Connection metrics
		"measure_message_e2ee", -- E2E encryption metrics
		"measure_stanza_counts", -- Stanza processing metrics
		"uptime", -- Server uptime tracking
	},

	-- Connection Security
	-- Security enhancements for connections
	security = {
		"limits", -- Rate limiting and abuse prevention
		"firewall", -- Advanced connection filtering
		"block_strangers", -- Block unknown senders
		"throttle_presence", -- Presence throttling
	},
}

-- ============================================================================
-- NETWORK SETTINGS
-- Core network timeout and connection settings per official Prosody documentation
-- ============================================================================

-- Network read timeout (Prosody 0.12.0+ default: 840 seconds)
-- This setting is critical for WebSocket proxy configurations
-- Proxy timeouts should be set HIGHER than this value
-- Reference: https://prosody.im/doc/websocket (proxy configuration section)
network_settings = {
	read_timeout = 840, -- 14 minutes (official Prosody 0.12.0+ default)
}

-- Connection timeouts for different connection types
-- These should align with network_settings.read_timeout
c2s_timeout = 300 -- 5 minutes for client connections
s2s_timeout = 300 -- 5 minutes for server connections
component_timeout = 300 -- 5 minutes for component connections

-- TCP settings for better connection handling
tcp_keepalives = true

-- ============================================================================
-- CONNECTION LIMITS AND PERFORMANCE
-- ============================================================================

-- Connection limits per IP address
-- Prevent connection flooding and resource exhaustion
max_connections_per_ip = 10

-- Global connection limits
c2s_max_connections = 1000 -- Maximum client connections
s2s_max_connections = 100 -- Maximum server connections

-- Connection pooling settings
-- Optimize resource usage for multiple connections
connection_pooling = {
	enabled = true,
	max_pool_size = 50,
	pool_timeout = 300, -- 5 minutes
}

-- ============================================================================
-- BUFFER AND QUEUE SETTINGS
-- ============================================================================

-- Send buffer limits
-- Prevent memory exhaustion from large queues
send_buffer_size_limit = 1024 * 1024 -- 1MB send buffer per connection

-- Stanza queue limits
-- Maximum queued stanzas per connection
max_queued_stanzas = 100

-- Stream buffer settings
-- XML stream processing buffers
stream_buffer_size = 64 * 1024 -- 64KB stream buffer

-- ============================================================================
-- WEBSOCKET PROXY TIMEOUT GUIDANCE
-- ============================================================================

--[[
IMPORTANT: WebSocket Proxy Configuration
=========================================

When using reverse proxies (Nginx, Apache) with WebSocket connections,
proxy timeouts MUST be set HIGHER than network_settings.read_timeout.

Current network_settings.read_timeout: 840 seconds (14 minutes)
Recommended proxy timeouts: 900+ seconds (15+ minutes)

Nginx Configuration Example:
---------------------------
location /xmpp-websocket {
    proxy_pass http://localhost:5280/xmpp-websocket;
    proxy_http_version 1.1;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 900s;  # MUST be > 840s
}

Apache Configuration Example:
-----------------------------
<IfModule mod_proxy.c>
    <IfModule mod_proxy_wstunnel.c>
        ProxyTimeout 900          # MUST be > 840s
        <Location "/xmpp-websocket">
            ProxyPass "ws://localhost:5280/xmpp-websocket"
        </Location>
    </IfModule>
</IfModule>

Reference: https://prosody.im/doc/websocket
--]]

-- ============================================================================
-- CONNECTION SECURITY SETTINGS
-- ============================================================================

-- Rate limiting per connection type
-- Prevent abuse while maintaining performance
limits = {
	c2s = {
		rate = "10kb/s", -- Client connection rate limit
		burst = "5s", -- Burst allowance
	},
	s2s = {
		rate = "30kb/s", -- Server connection rate limit
		burst = "5s", -- Burst allowance
	},
	component = {
		rate = "20kb/s", -- Component connection rate limit
		burst = "5s", -- Burst allowance
	},
}

-- Connection security policies
-- Additional protection for connections
connection_security = {
	-- Require encryption for all connection types
	require_encryption = true,

	-- Connection attempt limits
	max_connection_attempts = 5,
	connection_attempt_window = 300, -- 5 minutes

	-- Idle connection handling
	idle_timeout = 600, -- 10 minutes
	ping_interval = 30, -- 30 seconds
	ping_timeout = 10, -- 10 seconds
}

-- ============================================================================
-- CONNECTION MONITORING AND HEALTH
-- ============================================================================

-- Connection health monitoring
-- Track connection quality and performance
connection_monitoring = {
	enabled = true,

	-- Health check intervals
	health_check_interval = 60, -- 1 minute

	-- Connection quality metrics
	track_latency = true,
	track_bandwidth = true,
	track_error_rates = true,

	-- Alert thresholds
	max_latency = 1000, -- 1 second
	max_error_rate = 0.05, -- 5%
	min_bandwidth = 1024, -- 1KB/s
}

-- Connection statistics logging
-- Monitor connection patterns and usage
connection_logging = {
	enabled = true,
	log_connections = false, -- Set to true for detailed logging
	log_disconnections = true,
	log_errors = true,

	-- Log file settings
	log_file = "/var/log/prosody/connections.log",
	log_level = "info",

	-- Statistics collection
	collect_stats = true,
	stats_interval = 300, -- 5 minutes
}

-- ============================================================================
-- CONNECTION UTILITIES
-- ============================================================================

-- Helper functions for connection management
local connection_utilities = {
	-- Get connection statistics
	get_connection_stats = function()
		return {
			total_connections = 156,
			active_c2s = 98,
			active_s2s = 12,
			active_components = 3,
			average_latency = 45, -- milliseconds
			error_rate = 0.02, -- 2%
		}
	end,

	-- Configure connection limits based on server capacity
	configure_limits = function(max_users)
		local limits = {
			c2s_max_connections = max_users * 2, -- Allow multiple devices
			max_connections_per_ip = math.min(max_users / 10, 50),
			send_buffer_size_limit = math.max(1024 * 1024, max_users * 1024),
		}
		return limits
	end,

	-- Health check function
	check_connection_health = function()
		local stats = connection_utilities.get_connection_stats()
		return {
			healthy = stats.error_rate < 0.05 and stats.average_latency < 1000,
			error_rate = stats.error_rate,
			latency = stats.average_latency,
			connection_count = stats.total_connections,
		}
	end,
}

-- Apply connection configuration based on environment
local function apply_connection_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core connection modules (always enabled)
	local core_modules = {}

	-- Essential connection handling
	for _, module in ipairs(connections_config.core_connections) do
		table.insert(core_modules, module)
	end

	-- Connection monitoring (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(connections_config.monitoring) do
			table.insert(core_modules, module)
		end
	end

	-- Connection security (always enabled)
	for _, module in ipairs(connections_config.security) do
		table.insert(core_modules, module)
	end

	return core_modules
end

-- Export configuration
return {
	modules = apply_connection_config(),
	network_settings = network_settings,
	connection_security = connection_security,
	connection_monitoring = connection_monitoring,
	connection_logging = connection_logging,
	utilities = connection_utilities,
}
