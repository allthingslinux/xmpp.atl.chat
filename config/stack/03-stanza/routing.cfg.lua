-- Layer 03: Stanza - Routing Configuration
-- XEP-0124: BOSH, XEP-0206: XMPP Over BOSH, XEP-0199: XMPP Ping, XEP-0016: Privacy Lists
-- XEP-0191: Blocking Command, XEP-0085: Chat State Notifications, XEP-0184: Message Delivery Receipts
-- Handles stanza routing, delivery, and connection management

local routing_config = {
	-- Core Stanza Routing
	-- Essential routing and delivery mechanisms
	core_routing = {
		"ping", -- XEP-0199: XMPP Ping
		"time", -- XEP-0202: Entity Time
		"uptime", -- Server uptime reporting
		"dialback", -- XEP-0220: Server Dialback (S2S authentication)
	},

	-- BOSH and HTTP Binding (XEP-0124, XEP-0206)
	-- HTTP-based XMPP connections for web clients
	bosh_routing = {
		"bosh", -- XEP-0124: Bidirectional-streams Over Synchronous HTTP
		"websocket", -- RFC 7395: An Extensible Messaging and Presence Protocol (XMPP) Subprotocol for WebSocket
		"http_cors", -- Cross-Origin Resource Sharing for HTTP
		"http_host_status_check", -- HTTP host status checking
	},

	-- Privacy and Blocking (XEP-0016, XEP-0191)
	-- User privacy controls and blocking
	privacy_routing = {
		"privacy", -- XEP-0016: Privacy Lists (legacy)
		"blocking", -- XEP-0191: Blocking Command (modern)
		"blocklist", -- Simple blocking implementation
		"filter_chatstates", -- Filter chat state notifications
	},

	-- Message Delivery and Receipts
	-- Reliable message delivery mechanisms
	delivery_routing = {
		"receipts", -- XEP-0184: Message Delivery Receipts
		"carbons", -- XEP-0280: Message Carbons
		"csi", -- XEP-0352: Client State Indication
		"smacks", -- XEP-0198: Stream Management
	},

	-- Chat State and Presence Routing
	-- Real-time communication state management
	presence_routing = {
		"presence_dedup", -- Deduplicate presence stanzas
		"presence_cache", -- Cache presence information
		"last", -- XEP-0012: Last Activity
		"idle", -- XEP-0319: Last User Interaction in Presence
	},

	-- Advanced Routing Features
	-- Enhanced routing capabilities
	advanced_routing = {
		"stanza_counter", -- Count and monitor stanzas
		"measure_stanza_counts", -- Measure stanza statistics
		"firewall", -- Advanced stanza filtering and firewall
		"limits", -- Rate limiting and resource limits
	},

	-- Component and External Service Routing
	-- Routing to external components and services
	component_routing = {
		"component", -- XEP-0114: Jabber Component Protocol
		"external_services", -- XEP-0215: External Service Discovery
		"turncredentials", -- TURN credentials for WebRTC
		"extdisco", -- External service discovery
	},
}

-- Apply routing configuration based on environment
local function apply_routing_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core routing modules (always enabled)
	local core_modules = {}

	-- Essential routing
	for _, module in ipairs(routing_config.core_routing) do
		table.insert(core_modules, module)
	end

	-- BOSH and WebSocket support (always enabled for web clients)
	for _, module in ipairs(routing_config.bosh_routing) do
		table.insert(core_modules, module)
	end

	-- Privacy and blocking (always enabled)
	for _, module in ipairs(routing_config.privacy_routing) do
		table.insert(core_modules, module)
	end

	-- Message delivery (always enabled)
	for _, module in ipairs(routing_config.delivery_routing) do
		table.insert(core_modules, module)
	end

	-- Presence routing (always enabled)
	for _, module in ipairs(routing_config.presence_routing) do
		table.insert(core_modules, module)
	end

	-- Advanced routing (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(routing_config.advanced_routing) do
			table.insert(core_modules, module)
		end
	end

	-- Component routing (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(routing_config.component_routing) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- BOSH Configuration
-- XEP-0124: Bidirectional-streams Over Synchronous HTTP
bosh_config = {
	-- Basic BOSH settings
	enabled = true, -- Enable BOSH support

	-- Connection settings
	max_requests = 2, -- Maximum concurrent requests per session
	max_inactivity = 60, -- Maximum inactivity timeout (seconds)
	max_wait = 120, -- Maximum wait time for responses (seconds)

	-- Session management
	session_timeout = 300, -- Session timeout (5 minutes)
	max_sessions_per_user = 10, -- Maximum BOSH sessions per user

	-- Performance settings
	consider_bosh_secure = false, -- Consider BOSH connections secure
	cross_domain_bosh = false, -- Allow cross-domain BOSH (security risk)

	-- Buffer settings
	buffer_size_limit = 8192, -- Buffer size limit in bytes
	stanza_size_limit = 65536, -- Maximum stanza size in bytes
}

-- WebSocket Configuration
-- RFC 7395: XMPP Subprotocol for WebSocket
websocket_config = {
	-- Basic WebSocket settings
	enabled = true, -- Enable WebSocket support

	-- Connection settings
	ping_interval = 30, -- WebSocket ping interval (seconds)
	ping_timeout = 10, -- WebSocket ping timeout (seconds)

	-- Frame settings
	max_frame_size = 1048576, -- Maximum frame size (1MB)
	max_buffer_size = 2097152, -- Maximum buffer size (2MB)

	-- Compression settings
	compression = {
		enabled = true, -- Enable WebSocket compression
		level = 6, -- Compression level (1-9)
		window_bits = 15, -- Compression window size
	},

	-- Security settings
	consider_websocket_secure = false, -- Consider WebSocket connections secure
	origins = {}, -- Allowed origins (empty = all)
}

-- Privacy Lists Configuration
-- XEP-0016: Privacy Lists (legacy support)
privacy_config = {
	-- Legacy privacy lists support
	legacy_support = true, -- Support legacy privacy lists

	-- Default list behavior
	default_list_policy = "allow", -- Default policy: allow, deny

	-- List limits
	max_lists_per_user = 10, -- Maximum privacy lists per user
	max_items_per_list = 100, -- Maximum items per privacy list

	-- Performance settings
	cache_lists = true, -- Cache privacy lists
	cache_ttl = 3600, -- Cache TTL in seconds
}

-- Blocking Command Configuration
-- XEP-0191: Blocking Command (modern blocking)
blocking_config = {
	-- Basic blocking settings
	enabled = true, -- Enable blocking command

	-- Block limits
	max_blocked_users = 1000, -- Maximum blocked users per account
	max_blocked_domains = 100, -- Maximum blocked domains per account

	-- Blocking behavior
	block_presence = true, -- Block presence from blocked users
	block_messages = true, -- Block messages from blocked users
	block_iq = true, -- Block IQ from blocked users

	-- Storage settings
	persistent_blocking = true, -- Persist blocking lists
	sync_on_login = true, -- Sync blocking list on login
}

-- Message Delivery Receipts Configuration
-- XEP-0184: Message Delivery Receipts
receipts_config = {
	-- Basic receipt settings
	enabled = true, -- Enable delivery receipts

	-- Receipt behavior
	auto_request_receipts = false, -- Automatically request receipts
	honor_receipt_requests = true, -- Honor receipt requests from others

	-- Storage settings
	store_receipts = false, -- Store receipt information
	receipt_timeout = 300, -- Receipt timeout (5 minutes)

	-- Privacy settings
	respect_privacy = true, -- Respect privacy settings for receipts
}

-- XMPP Ping Configuration
-- XEP-0199: XMPP Ping
ping_config = {
	-- Ping intervals
	ping_interval = 300, -- Client ping interval (5 minutes)
	ping_timeout = 30, -- Ping timeout (30 seconds)

	-- S2S ping settings
	s2s_ping_interval = 600, -- S2S ping interval (10 minutes)
	s2s_ping_timeout = 60, -- S2S ping timeout (60 seconds)

	-- Behavior settings
	respond_to_ping = true, -- Respond to ping requests
	log_ping_failures = false, -- Log ping failures
}

-- External Services Configuration
-- XEP-0215: External Service Discovery
external_services_config = {
	-- STUN/TURN services for WebRTC
	services = {
		-- Example STUN server
		{
			type = "stun",
			host = "stun.example.com",
			port = 3478,
			transport = "udp",
		},
		-- Example TURN server
		{
			type = "turn",
			host = "turn.example.com",
			port = 3478,
			transport = "udp",
			username = "turn_user",
			password = "turn_pass",
			restricted = true,
		},
	},

	-- Service discovery settings
	discovery_enabled = true, -- Enable service discovery
	cache_services = true, -- Cache service information
	service_ttl = 3600, -- Service TTL (1 hour)
}

-- Rate Limiting Configuration
-- Stanza rate limiting and resource management
limits_config = {
	-- Connection limits
	max_connections_per_ip = 10, -- Maximum connections per IP
	max_connections_per_user = 5, -- Maximum connections per user

	-- Stanza rate limits
	stanza_rate_limit = {
		burst = 100, -- Burst limit
		rate = 10, -- Sustained rate (per second)
		period = 60, -- Rate period (seconds)
	},

	-- Bandwidth limits
	bandwidth_limit = {
		incoming = 1048576, -- Incoming bandwidth limit (1MB/s)
		outgoing = 1048576, -- Outgoing bandwidth limit (1MB/s)
	},

	-- Resource limits
	memory_limit = 134217728, -- Memory limit per connection (128MB)
	cpu_limit = 10, -- CPU usage limit (percentage)
}

-- Export configuration
return {
	modules = apply_routing_config(),
	bosh_config = bosh_config,
	websocket_config = websocket_config,
	privacy_config = privacy_config,
	blocking_config = blocking_config,
	receipts_config = receipts_config,
	ping_config = ping_config,
	external_services_config = external_services_config,
	limits_config = limits_config,
}
