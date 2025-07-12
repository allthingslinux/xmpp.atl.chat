-- Layer 07: Interfaces - WebSocket Configuration
-- WebSocket interface for modern web-based XMPP clients
-- RFC 7395: An Extensible Messaging and Presence Protocol (XMPP) Subprotocol for WebSocket
-- Real-time web applications and browser-based XMPP clients

local websocket_config = {
	-- Core WebSocket Module
	-- RFC 7395 WebSocket subprotocol implementation
	core_websocket = {
		"websocket", -- RFC 7395: WebSocket subprotocol (core)
	},

	-- WebSocket Security
	-- Security enhancements for WebSocket connections
	security = {
		-- Security modules are typically built into the core websocket module
		-- Additional security handled via HTTP layer configuration
	},

	-- WebSocket Extensions
	-- Additional WebSocket-related functionality
	extensions = {
		-- Most WebSocket extensions are handled by the core module
		-- Additional features through HTTP and connection management
	},
}

-- WebSocket Server Configuration
-- Configure WebSocket server behavior and performance
local websocket_server_config = {
	-- Basic WebSocket settings
	websocket_url = "ws://localhost:5280/xmpp-websocket",
	websocket_ssl_url = "wss://localhost:5281/xmpp-websocket",

	-- Frame and buffer limits
	websocket_frame_buffer_limit = 2 * 1024 * 1024, -- 2MB frame buffer
	websocket_frame_fragment_limit = 8, -- Maximum fragments per frame
	websocket_max_frame_size = 1024 * 1024, -- 1MB max frame size

	-- Connection settings
	websocket_ping_interval = 30, -- Send ping every 30 seconds
	websocket_pong_timeout = 10, -- Wait 10 seconds for pong response
	websocket_close_timeout = 5, -- Wait 5 seconds for close confirmation

	-- Security settings
	consider_websocket_secure = false, -- Set to true if behind HTTPS proxy
	websocket_origin_check = true, -- Enable origin checking for security

	-- Cross-domain settings (security consideration)
	cross_domain_websocket = false, -- Disable by default for security
	allowed_origins = {
		-- Add allowed origins for cross-domain requests
		-- "https://example.com",
		-- "https://app.example.com",
	},

	-- Response text for HTTP GET requests
	websocket_get_response_text = "It works! Now point your XMPP client to this URL to connect via WebSocket.",
	websocket_get_response_body = [[
<!DOCTYPE html>
<html>
<head>
	<title>XMPP WebSocket Endpoint</title>
</head>
<body>
	<h1>XMPP WebSocket Endpoint</h1>
	<p>This is an XMPP WebSocket endpoint. Point your XMPP client to this URL to connect via WebSocket.</p>
	<p>WebSocket URL: <code>ws://localhost:5280/xmpp-websocket</code></p>
	<p>Secure WebSocket URL: <code>wss://localhost:5281/xmpp-websocket</code></p>
</body>
</html>
]],
}

-- WebSocket Performance Configuration
-- Optimize WebSocket performance for different use cases
local websocket_performance = {
	-- Connection pooling
	connection_pooling = {
		enabled = true,
		max_pool_size = 100,
		pool_timeout = 300, -- 5 minutes
	},

	-- Compression settings
	compression = {
		enabled = false, -- Disabled by default (handled by HTTP layer)
		compression_level = 6, -- 1-9, higher = better compression but more CPU
	},

	-- Buffering settings
	buffering = {
		input_buffer_size = 64 * 1024, -- 64KB input buffer
		output_buffer_size = 64 * 1024, -- 64KB output buffer
		max_queued_stanzas = 100, -- Maximum queued stanzas per connection
	},

	-- Keep-alive settings
	keepalive = {
		enabled = true,
		interval = 30, -- Ping interval in seconds
		timeout = 10, -- Pong timeout in seconds
		max_missed_pings = 3, -- Close connection after missing 3 pings
	},
}

-- WebSocket Security Configuration
-- Security settings specific to WebSocket connections
local websocket_security = {
	-- Origin validation
	origin_validation = {
		enabled = true,
		strict_mode = false, -- Set to true for strict origin checking
		allowed_origins = {
			-- List of allowed origins for cross-origin requests
			-- "https://example.com",
			-- "https://app.example.com",
		},
		default_policy = "deny", -- deny or allow
	},

	-- Rate limiting
	rate_limiting = {
		enabled = true,
		max_connections_per_ip = 10,
		max_stanzas_per_minute = 100,
		burst_limit = 20,
	},

	-- Connection limits
	connection_limits = {
		max_total_connections = 1000,
		max_connections_per_user = 5,
		connection_timeout = 300, -- 5 minutes
	},

	-- Protocol security
	protocol_security = {
		require_tls = false, -- Set to true to require TLS for all connections
		min_tls_version = "1.2",
		allowed_ciphers = "HIGH:!aNULL:!MD5",
	},
}

-- WebSocket Client Support
-- Configuration for different client types and capabilities
local websocket_client_support = {
	-- Browser compatibility
	browser_support = {
		-- Support for older browsers
		fallback_enabled = true,
		fallback_transport = "bosh", -- Fallback to BOSH for older browsers

		-- Modern browser features
		binary_support = true, -- Support binary frames
		extension_support = true, -- Support WebSocket extensions
	},

	-- Mobile client optimization
	mobile_optimization = {
		enabled = true,

		-- Reduce keep-alive frequency for mobile
		mobile_ping_interval = 60, -- 1 minute for mobile clients

		-- Battery optimization
		background_timeout = 300, -- 5 minutes in background

		-- Data usage optimization
		compress_stanzas = false, -- Handled by HTTP layer
	},

	-- Desktop client support
	desktop_support = {
		enabled = true,

		-- Desktop-specific optimizations
		desktop_ping_interval = 30, -- 30 seconds for desktop clients

		-- Performance optimizations
		large_stanza_support = true,
		bulk_operations = true,
	},
}

-- WebSocket Monitoring and Diagnostics
-- Tools for monitoring WebSocket connections and performance
local websocket_monitoring = {
	-- Connection statistics
	connection_stats = {
		enabled = true,
		log_connections = false, -- Set to true for detailed logging
		stats_interval = 60, -- Update stats every minute
	},

	-- Performance metrics
	performance_metrics = {
		enabled = true,
		track_latency = true,
		track_throughput = true,
		track_error_rates = true,
	},

	-- Health checks
	health_checks = {
		enabled = true,
		check_interval = 30, -- Check every 30 seconds
		endpoint_health = true,
		connection_health = true,
	},

	-- Logging configuration
	logging = {
		log_level = "info", -- debug, info, warn, error
		log_connections = false,
		log_stanzas = false, -- Only enable for debugging
		log_errors = true,
	},
}

-- WebSocket Utilities
-- Helper functions for WebSocket management
local websocket_utilities = {
	-- Configure WebSocket for virtual host
	configure_websocket_host = function(host, ssl_enabled)
		local base_url = ssl_enabled and "wss://" or "ws://"
		local port = ssl_enabled and "5281" or "5280"

		return {
			websocket_url = base_url .. host .. ":" .. port .. "/xmpp-websocket",
			consider_websocket_secure = ssl_enabled,
		}
	end,

	-- Apply security hardening
	apply_security_hardening = function()
		return {
			origin_validation_enabled = true,
			rate_limiting_enabled = true,
			connection_limits_enabled = true,
			require_tls = true,
		}
	end,

	-- Optimize for mobile clients
	optimize_for_mobile = function()
		return {
			ping_interval = 60, -- Longer interval for battery saving
			frame_buffer_limit = 512 * 1024, -- Smaller buffer for mobile
			max_queued_stanzas = 50, -- Fewer queued stanzas
		}
	end,

	-- Get connection statistics
	get_connection_stats = function()
		-- This would return real-time connection statistics
		return {
			total_connections = 45,
			active_connections = 32,
			connections_per_minute = 5.2,
			average_latency = 25, -- milliseconds
			error_rate = 0.1, -- percentage
		}
	end,
}

-- Export configuration
return {
	modules = {
		-- Core WebSocket module
		core = websocket_config.core_websocket,

		-- Additional WebSocket features (most are built-in)
		-- security = websocket_config.security,
		-- extensions = websocket_config.extensions,
	},

	server = websocket_server_config,
	performance = websocket_performance,
	security = websocket_security,
	client_support = websocket_client_support,
	monitoring = websocket_monitoring,
	utilities = websocket_utilities,
}
