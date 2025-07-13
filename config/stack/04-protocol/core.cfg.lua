-- Layer 04: Protocol - Core Configuration
-- RFC 6120: XMPP Core, RFC 6121: XMPP IM, RFC 3920/3921: Legacy XMPP
-- Essential XMPP protocol features and core functionality
-- Implements the fundamental building blocks of XMPP communication

local core_config = {
	-- RFC 6120: XMPP Core Features
	-- Essential core protocol implementation
	xmpp_core = {
		"roster", -- RFC 6121: Contact roster management
		"saslauth", -- RFC 6120: SASL authentication
		"tls", -- RFC 6120: Transport Layer Security
		"dialback", -- XEP-0220: Server Dialback (S2S authentication)
	},

	-- RFC 6121: XMPP Instant Messaging
	-- Core instant messaging features
	xmpp_im = {
		"presence", -- RFC 6121: Presence subscription and notification
		"message", -- RFC 6121: Message stanza handling
		"iq", -- RFC 6120: Info/Query stanza processing
		-- "roster_versioning", -- DOESN'T EXIST: Built into mod_roster
	},

	-- Essential Protocol Extensions
	-- Core XEPs that are fundamental to modern XMPP
	essential_xeps = {
		"ping", -- XEP-0199: XMPP Ping
		"time", -- XEP-0202: Entity Time
		"version", -- XEP-0092: Software Version
		"uptime", -- XEP-0012: Last Activity (server uptime)
	},

	-- Service Discovery Core
	-- Essential service discovery functionality
	disco_core = {
		"disco", -- XEP-0030: Service Discovery
		-- "caps", -- DOESN'T EXIST: Built into mod_disco
		-- "disco_forms", -- DOESN'T EXIST: Built into mod_disco
		"server_info", -- XEP-0157: Contact Addresses for XMPP Services
	},

	-- Stream Features
	-- Core stream feature negotiation
	stream_features = {
		-- "starttls", -- DOESN'T EXIST: Built into core stream processing
		-- "sasl", -- DOESN'T EXIST: Built into core stream processing
		-- "bind", -- DOESN'T EXIST: Built into core stream processing
		-- "session", -- DOESN'T EXIST: Built into core stream processing (legacy)
	},

	-- Error Handling
	-- Core error processing and reporting
	error_handling = {
		-- "error_routing", -- DOESN'T EXIST: Built into core stanza routing
		-- "stanza_error", -- DOESN'T EXIST: Built into core stanza processing
		-- "stream_error", -- DOESN'T EXIST: Built into core stream handling
		-- "connection_error", -- DOESN'T EXIST: Built into core connection handling
	},

	-- Core Utilities
	-- Essential utility functions
	core_utilities = {
		"posix", -- POSIX system integration
		"signal", -- Signal handling
		"watchdog", -- Process monitoring
		"statistics", -- Basic statistics collection
	},
}

-- Apply core configuration based on environment
local function apply_core_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core modules (always enabled)
	local core_modules = {}

	-- XMPP Core (RFC 6120) - always enabled
	for _, module in ipairs(core_config.xmpp_core) do
		table.insert(core_modules, module)
	end

	-- XMPP IM (RFC 6121) - always enabled
	for _, module in ipairs(core_config.xmpp_im) do
		table.insert(core_modules, module)
	end

	-- Essential XEPs - always enabled
	for _, module in ipairs(core_config.essential_xeps) do
		table.insert(core_modules, module)
	end

	-- Service Discovery - always enabled
	for _, module in ipairs(core_config.disco_core) do
		table.insert(core_modules, module)
	end

	-- Stream Features - always enabled
	for _, module in ipairs(core_config.stream_features) do
		table.insert(core_modules, module)
	end

	-- Error Handling - always enabled
	for _, module in ipairs(core_config.error_handling) do
		table.insert(core_modules, module)
	end

	-- Core Utilities - production and staging
	if env_type ~= "development" then
		for _, module in ipairs(core_config.core_utilities) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- XMPP Core Configuration (RFC 6120)
-- Fundamental XMPP protocol settings
xmpp_core_config = {
	-- Stream settings
	stream_settings = {
		default_namespace = "jabber:client", -- Default stream namespace
		version = "1.0", -- XMPP version

		-- Stream limits
		stanza_size_limit = 262144, -- Maximum stanza size (256KB)
		buffer_size_limit = 65536, -- Stream buffer size (64KB)

		-- Timeouts
		stream_timeout = 300, -- Stream timeout (5 minutes)
		handshake_timeout = 60, -- Handshake timeout (1 minute)
	},

	-- JID handling
	jid_settings = {
		-- JID validation
		strict_jid_validation = true, -- Strict JID format validation
		normalize_jids = true, -- Normalize JID format

		-- JID limits (RFC 6122)
		max_localpart_length = 1023, -- Maximum localpart length
		max_domainpart_length = 1023, -- Maximum domainpart length
		max_resourcepart_length = 1023, -- Maximum resourcepart length

		-- JID policies
		allow_empty_localpart = false, -- Allow JIDs without localpart
		case_sensitive_localpart = true, -- Case-sensitive localpart
		case_sensitive_resourcepart = true, -- Case-sensitive resourcepart
	},

	-- Namespace handling
	namespace_config = {
		-- Core namespaces
		core_namespaces = {
			"http://etherx.jabber.org/streams", -- Stream namespace
			"jabber:client", -- Client namespace
			"jabber:server", -- Server namespace
			"jabber:server:dialback", -- Dialback namespace
		},

		-- Namespace validation
		validate_namespaces = true, -- Validate namespace declarations
		require_namespace_prefixes = false, -- Require namespace prefixes
	},
}

-- XMPP IM Configuration (RFC 6121)
-- Instant messaging protocol settings
xmpp_im_config = {
	-- Roster management
	roster_config = {
		-- Roster limits
		max_roster_size = 1000, -- Maximum roster contacts
		max_roster_groups = 50, -- Maximum roster groups

		-- Roster behavior
		roster_versioning = true, -- Enable roster versioning
		auto_accept_subscriptions = false, -- Auto-accept subscription requests

		-- Roster storage
		roster_storage = "internal", -- Roster storage backend
		cache_roster = true, -- Cache roster in memory
		roster_cache_ttl = 3600, -- Roster cache TTL (1 hour)
	},

	-- Presence handling
	presence_config = {
		-- Presence limits
		max_presence_stanzas_per_second = 10, -- Max presence updates per second
		max_status_message_length = 1024, -- Max presence status length

		-- Presence behavior
		probe_presence_on_login = true, -- Probe presence on login
		broadcast_presence_to_roster = true, -- Broadcast presence to roster

		-- Presence optimization
		presence_deduplication = true, -- Deduplicate presence stanzas
		compress_presence = false, -- Compress presence stanzas
	},

	-- Message handling
	message_config = {
		-- Message limits
		max_message_size = 65536, -- Maximum message size (64KB)
		max_subject_length = 1024, -- Maximum subject length
		max_body_length = 65536, -- Maximum body length

		-- Message behavior
		store_offline_messages = true, -- Store offline messages
		max_offline_messages = 100, -- Maximum offline messages per user
		offline_message_ttl = 604800, -- Offline message TTL (7 days)

		-- Message processing
		validate_message_structure = true, -- Validate message structure
		filter_empty_messages = true, -- Filter empty messages
	},
}

-- Service Discovery Configuration
-- XEP-0030: Service Discovery core settings
service_discovery_config = {
	-- Server identity
	server_identity = {
		category = "server", -- Server category
		type = "im", -- Instant messaging type
		name = "AllThingsLinux XMPP Server", -- Server name
	},

	-- Additional identities
	additional_identities = {
		{ category = "conference", type = "text", name = "Multi-User Chat" },
		{ category = "pubsub", type = "service", name = "Publish-Subscribe" },
		{ category = "proxy", type = "bytestreams", name = "SOCKS5 Bytestreams" },
		{ category = "store", type = "file", name = "File Transfer" },
	},

	-- Server features
	server_features = {
		-- Core features
		"http://jabber.org/protocol/disco#info",
		"http://jabber.org/protocol/disco#items",
		"urn:xmpp:ping",
		"jabber:iq:version",
		"urn:xmpp:time",

		-- IM features
		"jabber:iq:roster",
		"urn:xmpp:roster-versioning:0",
		"jabber:iq:privacy",
		"urn:xmpp:blocking",

		-- Stream features
		"urn:ietf:params:xml:ns:xmpp-bind",
		"urn:ietf:params:xml:ns:xmpp-session",
		"urn:ietf:params:xml:ns:xmpp-stanzas",
	},

	-- Discovery settings
	discovery_settings = {
		cache_disco_info = true, -- Cache disco#info responses
		cache_ttl = 3600, -- Cache TTL (1 hour)
		max_cache_entries = 1000, -- Maximum cache entries

		-- Privacy settings
		hide_admin_addresses = false, -- Hide admin contact addresses
		show_server_version = true, -- Show server version in disco
		show_os_info = false, -- Show OS information
	},
}

-- Entity Capabilities Configuration
-- XEP-0115: Entity Capabilities settings
entity_capabilities_config = {
	-- Capabilities settings
	caps_settings = {
		hash_algorithm = "sha-1", -- Hash algorithm for capabilities

		-- Cache settings
		cache_capabilities = true, -- Cache capability information
		cache_size = 10000, -- Maximum cached capabilities
		cache_ttl = 86400, -- Cache TTL (24 hours)

		-- Verification settings
		verify_capabilities = true, -- Verify capability hashes
		strict_verification = false, -- Strict verification mode
	},

	-- Performance settings
	performance_settings = {
		lazy_loading = true, -- Load capabilities on demand
		background_verification = true, -- Verify capabilities in background
		batch_requests = true, -- Batch capability requests

		-- Rate limiting
		max_requests_per_second = 10, -- Max capability requests per second
		request_timeout = 30, -- Request timeout (30 seconds)
	},
}

-- Stream Management Configuration
-- Core stream management settings
stream_management_config = {
	-- Stream negotiation
	negotiation_settings = {
		require_tls = false, -- Require TLS for all streams
		allow_unencrypted = true, -- Allow unencrypted connections

		-- Feature advertisement
		advertise_starttls = true, -- Advertise STARTTLS
		advertise_sasl = true, -- Advertise SASL mechanisms
		advertise_bind = true, -- Advertise resource binding
		advertise_session = false, -- Advertise session establishment (legacy)
	},

	-- Resource binding
	binding_settings = {
		allow_resource_conflict = false, -- Allow resource conflicts
		generate_random_resource = true, -- Generate random resources
		max_resource_length = 1023, -- Maximum resource length

		-- Resource policies
		resource_policy = "replace", -- Resource conflict policy: replace, reject
		bind_timeout = 30, -- Resource binding timeout
	},

	-- Session management
	session_settings = {
		enable_legacy_session = false, -- Enable legacy session establishment
		session_timeout = 3600, -- Session timeout (1 hour)
		max_sessions_per_user = 10, -- Maximum sessions per user

		-- Session cleanup
		cleanup_interval = 300, -- Session cleanup interval (5 minutes)
		cleanup_idle_sessions = true, -- Cleanup idle sessions
	},
}

-- Error Handling Configuration
-- Core error processing and reporting
error_handling_config = {
	-- Error generation
	error_generation = {
		generate_error_responses = true, -- Generate error responses
		include_error_text = true, -- Include human-readable error text
		localize_errors = false, -- Localize error messages

		-- Error details
		include_stack_traces = false, -- Include stack traces (debug only)
		max_error_text_length = 1024, -- Maximum error text length
	},

	-- Error routing
	error_routing = {
		route_errors_to_sender = true, -- Route errors back to sender
		log_routing_errors = true, -- Log routing errors

		-- Error forwarding
		forward_service_unavailable = false, -- Forward service-unavailable errors
		forward_feature_not_implemented = false, -- Forward feature-not-implemented errors
	},

	-- Error recovery
	error_recovery = {
		attempt_error_recovery = true, -- Attempt to recover from errors
		max_recovery_attempts = 3, -- Maximum recovery attempts
		recovery_timeout = 60, -- Recovery timeout (1 minute)

		-- Graceful degradation
		graceful_degradation = true, -- Enable graceful degradation
		fallback_mechanisms = true, -- Enable fallback mechanisms
	},
}

-- Performance and Monitoring
-- Core performance settings
performance_config = {
	-- General performance
	general_performance = {
		enable_performance_monitoring = false, -- Enable performance monitoring
		collect_statistics = true, -- Collect basic statistics
		statistics_interval = 300, -- Statistics interval (5 minutes)

		-- Memory management
		garbage_collection_interval = 60, -- GC interval (1 minute)
		memory_limit_warning = 0.8, -- Memory warning threshold (80%)
		memory_limit_critical = 0.95, -- Memory critical threshold (95%)
	},

	-- Connection performance
	connection_performance = {
		connection_pooling = true, -- Enable connection pooling
		keep_alive_interval = 300, -- Keep-alive interval (5 minutes)

		-- Buffer management
		read_buffer_size = 8192, -- Read buffer size (8KB)
		write_buffer_size = 8192, -- Write buffer size (8KB)
		max_buffer_size = 65536, -- Maximum buffer size (64KB)
	},
}

-- Export configuration
return {
	modules = apply_core_config(),
	xmpp_core_config = xmpp_core_config,
	xmpp_im_config = xmpp_im_config,
	service_discovery_config = service_discovery_config,
	entity_capabilities_config = entity_capabilities_config,
	stream_management_config = stream_management_config,
	error_handling_config = error_handling_config,
	performance_config = performance_config,
}
