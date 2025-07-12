-- Layer 04: Protocol - Legacy Configuration
-- Backwards compatibility with older XMPP implementations and deprecated features
-- RFC 3920/3921: Legacy XMPP specifications, deprecated XEPs, and compatibility modules
-- Provides support for older clients and servers while maintaining security

local legacy_config = {
	-- Legacy Authentication
	-- Support for older authentication methods
	legacy_auth = {
		"auth_internal_plain", -- Legacy plaintext authentication (insecure)
		"auth_internal_hashed", -- Legacy hashed authentication
		"legacy_auth", -- XEP-0078: Non-SASL Authentication (deprecated)
		"compat_muc_admin", -- Legacy MUC admin compatibility
	},

	-- Legacy Session Management
	-- Support for older session establishment
	legacy_session = {
		"session", -- RFC 3921: Session establishment (deprecated)
		"legacy_ssl", -- Legacy SSL support (pre-TLS)
		"compat_bind", -- Legacy resource binding compatibility
		"compat_vcard", -- Legacy vCard compatibility
	},

	-- Legacy Privacy and Blocking
	-- Support for older privacy implementations
	legacy_privacy = {
		"privacy", -- XEP-0016: Privacy Lists (legacy)
		"compat_privacy", -- Privacy list compatibility layer
		"legacy_blocking", -- Legacy blocking implementation
		"simple_blocking", -- Simple blocking for older clients
	},

	-- Legacy Service Discovery
	-- Support for older service discovery
	legacy_disco = {
		"disco_legacy", -- Legacy service discovery
		"browse", -- XEP-0011: Jabber Browsing (deprecated)
		"agents", -- Legacy agent support
		"iq_roster_legacy", -- Legacy roster IQ handling
	},

	-- Legacy File Transfer
	-- Support for older file transfer methods
	legacy_file_transfer = {
		"legacy_ft", -- Legacy file transfer
		"oob", -- XEP-0066: Out of Band Data (legacy)
		"iq_oob", -- IQ-based out of band data
		"legacy_bytestreams", -- Legacy bytestream support
	},

	-- Legacy Presence and Messaging
	-- Support for older presence and messaging features
	legacy_presence = {
		"presence_legacy", -- Legacy presence handling
		"legacy_roster", -- Legacy roster management
		"message_legacy", -- Legacy message handling
		"iq_legacy", -- Legacy IQ handling
	},

	-- Protocol Compatibility
	-- General protocol compatibility features
	protocol_compat = {
		"compat_dialback", -- Dialback compatibility
		"legacy_namespaces", -- Legacy namespace support
		"xml_legacy", -- Legacy XML handling
		"stanza_compat", -- Legacy stanza compatibility
	},
}

-- Apply legacy configuration based on environment and settings
local function apply_legacy_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"
	local enable_legacy = prosody.config.get("*", "enable_legacy_support") or false

	-- Only enable legacy support if explicitly requested
	if not enable_legacy then
		return {}
	end

	local core_modules = {}

	-- Legacy authentication (with security warnings)
	if env_type == "development" then
		for _, module in ipairs(legacy_config.legacy_auth) do
			table.insert(core_modules, module)
		end
	end

	-- Legacy session management (generally safe)
	for _, module in ipairs(legacy_config.legacy_session) do
		table.insert(core_modules, module)
	end

	-- Legacy privacy (safe, provides compatibility)
	for _, module in ipairs(legacy_config.legacy_privacy) do
		table.insert(core_modules, module)
	end

	-- Legacy service discovery (safe)
	for _, module in ipairs(legacy_config.legacy_disco) do
		table.insert(core_modules, module)
	end

	-- Legacy file transfer (generally safe)
	for _, module in ipairs(legacy_config.legacy_file_transfer) do
		table.insert(core_modules, module)
	end

	-- Legacy presence and messaging (safe)
	for _, module in ipairs(legacy_config.legacy_presence) do
		table.insert(core_modules, module)
	end

	-- Protocol compatibility (safe)
	for _, module in ipairs(legacy_config.protocol_compat) do
		table.insert(core_modules, module)
	end

	return core_modules
end

-- Legacy Authentication Configuration
-- Support for older authentication methods (with security warnings)
legacy_auth_config = {
	-- Legacy authentication settings
	enabled = false, -- Disabled by default for security

	-- Authentication methods
	auth_methods = {
		-- Legacy methods (INSECURE - only for development)
		plain_auth = {
			enabled = false, -- Plaintext auth (VERY INSECURE)
			require_tls = true, -- Require TLS if enabled
			warn_insecure = true, -- Warn about insecurity
		},

		-- Digest authentication (legacy but more secure)
		digest_auth = {
			enabled = false, -- Digest authentication
			algorithm = "md5", -- Hash algorithm (legacy)
			require_tls = false, -- TLS not required for digest
		},

		-- Legacy SASL (older implementations)
		legacy_sasl = {
			enabled = true, -- Legacy SASL support
			mechanisms = { -- Supported legacy mechanisms
				"DIGEST-MD5", -- Legacy DIGEST-MD5
				"CRAM-MD5", -- Legacy CRAM-MD5
			},
			warn_deprecated = true, -- Warn about deprecated mechanisms
		},
	},

	-- Security settings
	security_settings = {
		log_legacy_auth = true, -- Log legacy authentication attempts
		rate_limit_legacy = true, -- Rate limit legacy auth attempts
		max_attempts = 3, -- Maximum failed attempts
		lockout_duration = 300, -- Lockout duration (5 minutes)
	},
}

-- Legacy Session Configuration
-- Support for RFC 3921 session establishment
legacy_session_config = {
	-- Session establishment
	session_establishment = {
		enable_legacy_session = true, -- Enable legacy session establishment
		require_session = false, -- Require session establishment
		session_timeout = 3600, -- Session timeout (1 hour)

		-- Session features
		advertise_session = true, -- Advertise session in stream features
		auto_establish_session = false, -- Auto-establish session
	},

	-- Legacy SSL support
	legacy_ssl = {
		enable_legacy_ssl = false, -- Enable legacy SSL (insecure)
		ssl_versions = { -- Supported SSL versions
			"SSLv3", -- SSL 3.0 (INSECURE)
			"TLSv1.0", -- TLS 1.0 (deprecated)
		},
		warn_insecure_ssl = true, -- Warn about insecure SSL
	},

	-- Compatibility settings
	compatibility_settings = {
		strict_xml = false, -- Relaxed XML parsing for legacy clients
		allow_empty_elements = true, -- Allow empty XML elements
		ignore_unknown_attributes = true, -- Ignore unknown attributes
	},
}

-- Legacy Privacy Configuration
-- XEP-0016: Privacy Lists (legacy support)
legacy_privacy_config = {
	-- Privacy lists support
	privacy_lists = {
		enabled = true, -- Enable privacy lists

		-- List management
		max_lists_per_user = 20, -- Maximum lists per user
		max_items_per_list = 100, -- Maximum items per list
		default_list_name = "default", -- Default list name

		-- Compatibility settings
		legacy_format = true, -- Support legacy list format
		auto_migrate_to_blocking = false, -- Auto-migrate to XEP-0191
	},

	-- Privacy list behavior
	list_behavior = {
		default_action = "allow", -- Default action for unlisted items
		order_matters = true, -- Order of rules matters

		-- Rule types
		supported_rule_types = {
			"jid", -- JID-based rules
			"group", -- Group-based rules
			"subscription", -- Subscription-based rules
		},

		-- Actions
		supported_actions = {
			"allow", -- Allow communication
			"deny", -- Deny communication
		},
	},

	-- Performance settings
	performance_settings = {
		cache_privacy_lists = true, -- Cache privacy lists
		cache_ttl = 3600, -- Cache TTL (1 hour)
		lazy_loading = true, -- Load lists on demand
	},
}

-- Legacy Service Discovery Configuration
-- Support for older service discovery methods
legacy_disco_config = {
	-- Legacy browsing support
	browsing_support = {
		enable_browsing = false, -- XEP-0011: Jabber Browsing (deprecated)
		browse_timeout = 30, -- Browse request timeout
		max_browse_depth = 3, -- Maximum browse depth
	},

	-- Agent support
	agent_support = {
		enable_agents = false, -- Legacy agent support
		agent_list = {}, -- List of supported agents
		agent_timeout = 30, -- Agent request timeout
	},

	-- Legacy roster support
	legacy_roster = {
		enable_legacy_roster = true, -- Legacy roster IQ support
		roster_versioning = false, -- Disable versioning for legacy

		-- Roster behavior
		auto_subscribe = false, -- Auto-subscribe to contacts
		allow_roster_groups = true, -- Allow roster groups
		max_roster_size = 500, -- Maximum roster size for legacy
	},

	-- Compatibility settings
	compatibility_settings = {
		relaxed_jid_validation = true, -- Relaxed JID validation
		allow_malformed_queries = true, -- Allow malformed disco queries
		provide_fallback_info = true, -- Provide fallback disco info
	},
}

-- Legacy File Transfer Configuration
-- Support for older file transfer methods
legacy_file_transfer_config = {
	-- Out of Band Data support
	oob_support = {
		enable_oob = true, -- XEP-0066: Out of Band Data

		-- OOB settings
		max_url_length = 2048, -- Maximum URL length
		allowed_protocols = { -- Allowed URL protocols
			"http",
			"https",
			"ftp",
		},

		-- Security settings
		validate_urls = true, -- Validate OOB URLs
		check_url_accessibility = false, -- Check if URLs are accessible
	},

	-- Legacy bytestreams
	legacy_bytestreams = {
		enable_legacy_bytestreams = true, -- Legacy bytestream support

		-- Bytestream settings
		max_streams = 10, -- Maximum concurrent streams
		stream_timeout = 300, -- Stream timeout (5 minutes)
		buffer_size = 8192, -- Stream buffer size
	},

	-- Legacy file transfer
	legacy_ft = {
		enable_legacy_ft = false, -- Legacy file transfer protocol
		max_file_size = 10485760, -- Maximum file size (10MB)
		allowed_file_types = { -- Allowed file types
			"image/*",
			"text/*",
			"audio/*",
		},
	},
}

-- Legacy Message and Presence Configuration
-- Support for older message and presence handling
legacy_messaging_config = {
	-- Legacy message handling
	message_handling = {
		enable_legacy_messages = true, -- Legacy message support

		-- Message compatibility
		allow_empty_body = true, -- Allow messages with empty body
		preserve_legacy_attributes = true, -- Preserve legacy attributes
		auto_add_delay = true, -- Auto-add delay stamps

		-- Message limits (relaxed for legacy)
		max_message_size = 32768, -- Maximum message size (32KB)
		max_subject_length = 512, -- Maximum subject length
	},

	-- Legacy presence handling
	presence_handling = {
		enable_legacy_presence = true, -- Legacy presence support

		-- Presence compatibility
		broadcast_legacy_presence = true, -- Broadcast to legacy clients
		preserve_presence_priority = true, -- Preserve presence priority

		-- Presence limits (relaxed for legacy)
		max_status_length = 512, -- Maximum status length
		max_show_length = 32, -- Maximum show value length
	},

	-- Legacy IQ handling
	iq_handling = {
		enable_legacy_iq = true, -- Legacy IQ support

		-- IQ compatibility
		relaxed_iq_validation = true, -- Relaxed IQ validation
		allow_missing_id = true, -- Allow IQ without ID
		auto_generate_id = true, -- Auto-generate missing IDs

		-- IQ timeouts (extended for legacy)
		iq_timeout = 60, -- IQ timeout (1 minute)
		max_pending_iq = 50, -- Maximum pending IQ per connection
	},
}

-- Protocol Compatibility Configuration
-- General protocol compatibility settings
protocol_compatibility_config = {
	-- XML compatibility
	xml_compatibility = {
		relaxed_xml_parsing = true, -- Relaxed XML parsing
		allow_xml_entities = true, -- Allow XML entities
		preserve_whitespace = true, -- Preserve whitespace in content

		-- Error handling
		ignore_parse_errors = false, -- Don't ignore XML parse errors
		log_parse_warnings = true, -- Log XML parse warnings
	},

	-- Namespace compatibility
	namespace_compatibility = {
		support_legacy_namespaces = true, -- Support legacy namespaces
		namespace_aliases = { -- Namespace aliases for compatibility
			-- Example: ["jabber:iq:auth"] = "urn:ietf:params:xml:ns:xmpp-sasl"
		},
		auto_correct_namespaces = false, -- Auto-correct namespace errors
	},

	-- Stanza compatibility
	stanza_compatibility = {
		relaxed_stanza_validation = true, -- Relaxed stanza validation
		allow_unknown_stanza_types = false, -- Don't allow unknown stanza types
		preserve_unknown_attributes = true, -- Preserve unknown attributes

		-- Error handling
		generate_legacy_errors = true, -- Generate legacy-compatible errors
		include_legacy_error_codes = true, -- Include legacy error codes
	},

	-- Connection compatibility
	connection_compatibility = {
		support_legacy_connection_methods = true, -- Legacy connection methods
		extended_timeouts = true, -- Extended timeouts for legacy clients

		-- Buffer settings (larger for legacy compatibility)
		read_buffer_size = 16384, -- Read buffer size (16KB)
		write_buffer_size = 16384, -- Write buffer size (16KB)
	},
}

-- Security Warnings Configuration
-- Security warnings for legacy features
security_warnings_config = {
	-- Warning settings
	warning_settings = {
		log_security_warnings = true, -- Log security warnings
		warn_clients = false, -- Warn clients about security issues

		-- Warning levels
		warning_levels = {
			insecure_auth = "error", -- Insecure authentication
			deprecated_features = "warn", -- Deprecated features
			legacy_protocols = "info", -- Legacy protocol usage
		},
	},

	-- Monitoring
	monitoring_settings = {
		track_legacy_usage = true, -- Track legacy feature usage
		generate_usage_reports = false, -- Generate usage reports
		alert_on_insecure_usage = true, -- Alert on insecure usage
	},
}

-- Export configuration
return {
	modules = apply_legacy_config(),
	legacy_auth_config = legacy_auth_config,
	legacy_session_config = legacy_session_config,
	legacy_privacy_config = legacy_privacy_config,
	legacy_disco_config = legacy_disco_config,
	legacy_file_transfer_config = legacy_file_transfer_config,
	legacy_messaging_config = legacy_messaging_config,
	protocol_compatibility_config = protocol_compatibility_config,
	security_warnings_config = security_warnings_config,
}
