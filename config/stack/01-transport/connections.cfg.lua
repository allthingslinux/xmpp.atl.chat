-- Layer 01: Transport - Connection Management
-- Connection limits, timeouts, and resource management
-- Prevents abuse and manages server resources effectively

-- Connection limits per connection type
-- Prevent resource exhaustion and abuse
connection_limits = {
	-- Client-to-Server connection limits
	c2s = {
		max_total = 1000, -- Maximum total client connections
		max_per_ip = 10, -- Maximum connections per IP address
		max_per_user = 5, -- Maximum connections per authenticated user
		timeout = 300, -- 5 minute idle timeout
		handshake_timeout = 30, -- 30 second handshake timeout
	},

	-- Server-to-Server connection limits
	s2s = {
		max_total = 100, -- Maximum total server connections
		max_per_host = 5, -- Maximum connections per remote host
		timeout = 300, -- 5 minute idle timeout
		handshake_timeout = 60, -- 60 second handshake timeout
		dialback_timeout = 30, -- 30 second dialback timeout
	},

	-- Component connection limits
	component = {
		max_total = 50, -- Maximum component connections
		max_per_host = 3, -- Maximum per component host
		timeout = 300, -- 5 minute idle timeout
		handshake_timeout = 30, -- 30 second handshake timeout
	},

	-- HTTP connection limits
	http = {
		max_total = 500, -- Maximum HTTP connections
		max_per_ip = 20, -- Maximum per IP
		timeout = 60, -- 1 minute timeout for HTTP
		request_timeout = 30, -- 30 second request timeout
	},
}

-- Rate limiting configuration
-- Prevent flooding and abuse
rate_limits = {
	-- Stanza rate limiting
	stanzas = {
		c2s = {
			rate = "10/s", -- 10 stanzas per second per client
			burst = 20, -- Allow bursts up to 20 stanzas
			penalty = 5, -- 5 second penalty for exceeding
		},
		s2s = {
			rate = "50/s", -- 50 stanzas per second per server
			burst = 100, -- Allow bursts up to 100 stanzas
			penalty = 10, -- 10 second penalty for exceeding
		},
	},

	-- Connection rate limiting
	connections = {
		rate = "5/m", -- 5 new connections per minute per IP
		burst = 10, -- Allow bursts up to 10 connections
		penalty = 60, -- 1 minute penalty for exceeding
	},

	-- Authentication rate limiting
	auth = {
		rate = "3/m", -- 3 auth attempts per minute per IP
		burst = 5, -- Allow bursts up to 5 attempts
		penalty = 300, -- 5 minute penalty for exceeding
	},
}

-- Connection quality monitoring
-- Track and manage connection health
connection_monitoring = {
	-- Ping/keepalive configuration
	keepalive = {
		enabled = true,
		interval = 60, -- Send keepalive every 60 seconds
		timeout = 30, -- 30 second response timeout
		max_failures = 3, -- Disconnect after 3 failed pings
	},

	-- Connection metrics
	metrics = {
		enabled = true,
		track_bandwidth = true, -- Track bandwidth usage per connection
		track_latency = true, -- Track connection latency
		track_errors = true, -- Track connection errors
	},

	-- Quality of Service (QoS)
	qos = {
		enabled = true,
		priority_classes = {
			high = { "iq" }, -- High priority for IQ stanzas
			normal = { "message" }, -- Normal priority for messages
			low = { "presence" }, -- Low priority for presence
		},
	},
}

-- Resource management
-- Manage memory and CPU usage for connections
resource_management = {
	-- Memory limits
	memory = {
		max_per_connection = 1024 * 1024, -- 1MB per connection
		max_total = 512 * 1024 * 1024, -- 512MB total for connections
		gc_threshold = 0.8, -- Trigger GC at 80% usage
	},

	-- Buffer management
	buffers = {
		send_buffer_size = 64 * 1024, -- 64KB send buffer per connection
		recv_buffer_size = 32 * 1024, -- 32KB receive buffer per connection
		max_buffer_size = 1024 * 1024, -- 1MB maximum buffer size
	},

	-- File descriptor limits
	file_descriptors = {
		soft_limit = 1024, -- Soft limit for file descriptors
		hard_limit = 4096, -- Hard limit for file descriptors
		warning_threshold = 0.8, -- Warn at 80% usage
	},
}

-- Connection security
-- Security measures for connection management
connection_security = {
	-- IP-based restrictions
	ip_restrictions = {
		enabled = true,

		-- Blacklisted IP ranges
		blacklist = {
			-- "192.168.1.100";     -- Example: block specific IP
			-- "10.0.0.0/8";        -- Example: block private network
		},

		-- Whitelisted IP ranges (if enabled, only these IPs allowed)
		whitelist = {
			enabled = false,
			-- "192.168.1.0/24";    -- Example: allow local network
		},
	},

	-- Geographic restrictions
	geo_restrictions = {
		enabled = false, -- Enable if GeoIP database available
		blocked_countries = {
			-- "CN", "RU";          -- Example: block specific countries
		},
	},

	-- Connection fingerprinting
	fingerprinting = {
		enabled = true,
		track_user_agents = true, -- Track client user agents
		track_connection_patterns = true, -- Track connection patterns
		suspicious_threshold = 10, -- Flag after 10 suspicious patterns
	},
}

-- Connection cleanup and maintenance
-- Automatic cleanup of stale connections
connection_cleanup = {
	-- Automatic cleanup intervals
	cleanup_interval = 300, -- Run cleanup every 5 minutes

	-- Stale connection detection
	stale_detection = {
		enabled = true,
		timeout = 1800, -- Consider connections stale after 30 minutes
		ping_before_close = true, -- Try to ping before closing
	},

	-- Resource cleanup
	resource_cleanup = {
		enabled = true,
		memory_threshold = 0.9, -- Cleanup when memory usage > 90%
		fd_threshold = 0.9, -- Cleanup when FD usage > 90%
	},

	-- Connection pooling
	pooling = {
		enabled = true,
		pool_size = 10, -- Keep 10 connections in pool
		max_idle_time = 300, -- 5 minute max idle time in pool
	},
}

-- Load balancing and scaling
-- Configuration for handling high load
load_balancing = {
	-- Connection distribution
	distribution = {
		enabled = false, -- Enable for multi-process setups
		method = "round_robin", -- round_robin, least_connections, weighted
		worker_processes = 1, -- Number of worker processes
	},

	-- Auto-scaling triggers
	auto_scaling = {
		enabled = false, -- Enable for cloud deployments
		scale_up_threshold = 0.8, -- Scale up at 80% capacity
		scale_down_threshold = 0.3, -- Scale down at 30% capacity
		cooldown_period = 300, -- 5 minute cooldown between scaling
	},
}

-- Logging and debugging
-- Connection-related logging
connection_logging = {
	log_level = "info",

	-- What to log
	log_events = {
		connections = true, -- Log connection events
		disconnections = true, -- Log disconnection events
		rate_limits = true, -- Log rate limit violations
		security_events = true, -- Log security-related events
	},

	-- Log rotation
	log_rotation = {
		enabled = true,
		max_size = "100MB", -- Rotate at 100MB
		max_files = 10, -- Keep 10 old log files
	},
}
