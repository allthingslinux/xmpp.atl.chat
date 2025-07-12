-- Layer 07: Interfaces - BOSH Configuration
-- BOSH (Bidirectional-streams Over Synchronous HTTP) interface
-- XEP-0124: Bidirectional-streams Over Synchronous HTTP (BOSH)
-- XEP-0206: XMPP Over BOSH for web-based XMPP clients

local bosh_config = {
	-- Core BOSH Module
	-- XEP-0124/0206 BOSH implementation
	core_bosh = {
		"bosh", -- XEP-0124: BOSH (core)
	},

	-- BOSH Security
	-- Security enhancements for BOSH connections
	security = {
		-- Security is typically handled through HTTP layer and core BOSH module
		-- Additional security via rate limiting and connection management
	},

	-- BOSH Extensions
	-- Additional BOSH-related functionality
	extensions = {
		-- Most BOSH extensions are handled by the core module
		-- Additional features through HTTP and session management
	},
}

-- BOSH Server Configuration
-- Configure BOSH server behavior and session management
local bosh_server_config = {
	-- Basic BOSH settings
	bosh_max_inactivity = 60, -- 60 seconds maximum inactivity
	bosh_max_polling = 5, -- 5 seconds maximum polling interval
	bosh_max_requests = 2, -- Maximum concurrent requests per session
	bosh_max_wait = 120, -- Maximum wait time for long polling

	-- Session management
	bosh_session_timeout = 300, -- 5 minutes session timeout
	bosh_hold_timeout = 60, -- 1 minute hold timeout
	bosh_window = 5, -- Maximum number of simultaneous requests

	-- Connection settings
	consider_bosh_secure = false, -- Set to true if behind HTTPS proxy
	bosh_max_content_length = 10 * 1024 * 1024, -- 10MB max content length

	-- Cross-domain settings (security consideration)
	cross_domain_bosh = false, -- Disable by default for security
	allowed_origins = {
		-- Add allowed origins for cross-domain requests
		-- "https://example.com",
		-- "https://app.example.com",
	},

	-- BOSH URL configuration
	bosh_url = "http://localhost:5280/http-bind",
	bosh_ssl_url = "https://localhost:5281/http-bind",
}

-- BOSH Performance Configuration
-- Optimize BOSH performance for different network conditions
local bosh_performance = {
	-- Request handling
	request_handling = {
		max_concurrent_requests = 100, -- Maximum concurrent BOSH requests
		request_timeout = 30, -- Request timeout in seconds
		keep_alive_timeout = 60, -- Keep-alive timeout
	},

	-- Session pooling
	session_pooling = {
		enabled = true,
		max_pool_size = 200,
		pool_cleanup_interval = 300, -- 5 minutes
	},

	-- Buffering settings
	buffering = {
		input_buffer_size = 32 * 1024, -- 32KB input buffer
		output_buffer_size = 32 * 1024, -- 32KB output buffer
		max_queued_stanzas = 50, -- Maximum queued stanzas per session
	},

	-- Polling optimization
	polling = {
		adaptive_polling = true, -- Adjust polling based on activity
		min_polling_interval = 1, -- Minimum polling interval (seconds)
		max_polling_interval = 60, -- Maximum polling interval (seconds)
		burst_polling_limit = 10, -- Maximum burst requests
	},
}

-- BOSH Security Configuration
-- Security settings specific to BOSH connections
local bosh_security = {
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
		max_requests_per_minute = 120, -- 2 requests per second average
		max_sessions_per_ip = 10,
		burst_limit = 20,
		rate_limit_window = 60, -- 1 minute window
	},

	-- Session security
	session_security = {
		session_key_length = 32, -- 32-byte session keys
		session_encryption = false, -- Enable if sensitive data is transmitted
		secure_session_cookies = true,
		httponly_cookies = true,
	},

	-- Connection limits
	connection_limits = {
		max_total_sessions = 1000,
		max_sessions_per_user = 5,
		session_cleanup_interval = 60, -- Clean up expired sessions every minute
	},
}

-- BOSH Client Support
-- Configuration for different client types and network conditions
local bosh_client_support = {
	-- Browser compatibility
	browser_support = {
		-- Support for older browsers
		legacy_browser_support = true,
		cors_support = false, -- Disabled by default for security

		-- Modern browser features
		streaming_support = true, -- Support for streaming responses
		compression_support = true, -- Support for HTTP compression
	},

	-- Mobile client optimization
	mobile_optimization = {
		enabled = true,

		-- Longer polling intervals for mobile to save battery
		mobile_polling_interval = 30, -- 30 seconds for mobile clients

		-- Reduced session timeouts for mobile
		mobile_session_timeout = 180, -- 3 minutes for mobile

		-- Data usage optimization
		compress_responses = true,
		minimize_polling = true,
	},

	-- Network condition adaptation
	network_adaptation = {
		enabled = true,

		-- Slow network optimization
		slow_network_mode = {
			polling_interval = 60, -- 1 minute for slow networks
			request_timeout = 60, -- Longer timeout for slow networks
			max_wait = 180, -- Longer wait time
		},

		-- Fast network optimization
		fast_network_mode = {
			polling_interval = 1, -- 1 second for fast networks
			request_timeout = 10, -- Shorter timeout for fast networks
			max_wait = 30, -- Shorter wait time
		},
	},
}

-- BOSH Session Management
-- Advanced session management and state handling
local bosh_session_management = {
	-- Session persistence
	session_persistence = {
		enabled = true,
		persistence_backend = "memory", -- memory, file, or database
		session_recovery = true, -- Allow session recovery after disconnection
	},

	-- Session monitoring
	session_monitoring = {
		enabled = true,
		track_session_stats = true,
		log_session_events = false, -- Set to true for detailed logging
		stats_update_interval = 60, -- Update stats every minute
	},

	-- Session cleanup
	session_cleanup = {
		enabled = true,
		cleanup_interval = 300, -- Clean up every 5 minutes
		expired_session_timeout = 600, -- Remove sessions after 10 minutes
		orphaned_session_timeout = 120, -- Remove orphaned sessions after 2 minutes
	},

	-- Session state management
	state_management = {
		preserve_state_on_disconnect = true,
		state_timeout = 300, -- Keep state for 5 minutes after disconnect
		max_state_size = 1024 * 1024, -- 1MB maximum state size per session
	},
}

-- BOSH Monitoring and Diagnostics
-- Tools for monitoring BOSH connections and performance
local bosh_monitoring = {
	-- Connection statistics
	connection_stats = {
		enabled = true,
		track_active_sessions = true,
		track_request_rates = true,
		track_error_rates = true,
	},

	-- Performance metrics
	performance_metrics = {
		enabled = true,
		track_response_times = true,
		track_throughput = true,
		track_session_duration = true,
	},

	-- Health checks
	health_checks = {
		enabled = true,
		check_interval = 30, -- Check every 30 seconds
		endpoint_health = true,
		session_health = true,
	},

	-- Logging configuration
	logging = {
		log_level = "info", -- debug, info, warn, error
		log_requests = false, -- Only enable for debugging
		log_sessions = false, -- Only enable for debugging
		log_errors = true,
	},
}

-- BOSH Utilities
-- Helper functions for BOSH management
local bosh_utilities = {
	-- Configure BOSH for virtual host
	configure_bosh_host = function(host, ssl_enabled)
		local protocol = ssl_enabled and "https" or "http"
		local port = ssl_enabled and "5281" or "5280"

		return {
			bosh_url = protocol .. "://" .. host .. ":" .. port .. "/http-bind",
			consider_bosh_secure = ssl_enabled,
		}
	end,

	-- Apply security hardening
	apply_security_hardening = function()
		return {
			origin_validation_enabled = true,
			rate_limiting_enabled = true,
			session_security_enabled = true,
			cross_domain_disabled = true,
		}
	end,

	-- Optimize for high traffic
	optimize_for_high_traffic = function()
		return {
			max_concurrent_requests = 500,
			session_pool_size = 1000,
			request_timeout = 15, -- Shorter timeout for high traffic
			cleanup_interval = 60, -- More frequent cleanup
		}
	end,

	-- Optimize for mobile clients
	optimize_for_mobile = function()
		return {
			polling_interval = 30, -- Longer interval for battery saving
			session_timeout = 180, -- Shorter timeout for mobile
			max_queued_stanzas = 25, -- Fewer queued stanzas
		}
	end,

	-- Get session statistics
	get_session_stats = function()
		-- This would return real-time session statistics
		return {
			active_sessions = 67,
			total_requests = 1234,
			average_response_time = 45, -- milliseconds
			error_rate = 0.2, -- percentage
			sessions_per_minute = 8.5,
		}
	end,
}

-- Export configuration
return {
	modules = {
		-- Core BOSH module
		core = bosh_config.core_bosh,

		-- Additional BOSH features (most are built-in)
		-- security = bosh_config.security,
		-- extensions = bosh_config.extensions,
	},

	server = bosh_server_config,
	performance = bosh_performance,
	security = bosh_security,
	client_support = bosh_client_support,
	session_management = bosh_session_management,
	monitoring = bosh_monitoring,
	utilities = bosh_utilities,
}
