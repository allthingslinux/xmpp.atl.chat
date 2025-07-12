-- Layer 03: Stanza - Validation Configuration
-- XML schema validation, stanza structure validation, and security validation
-- RFC 6120: XMPP Core, RFC 6121: XMPP IM, XEP-0001: XMPP Extension Protocols
-- Comprehensive stanza validation and security checking

local validation_config = {
	-- Core Validation Modules
	-- Essential stanza validation
	core_validation = {
		"stanza_debug", -- Stanza debugging and inspection
		"xml_parser", -- XML parsing and validation
		"namespace_guard", -- Namespace validation
		"well_known_uris", -- Well-known URI validation
	},

	-- XML and Structure Validation
	-- XML schema and structure validation
	xml_validation = {
		"xmlrpc", -- XML-RPC validation
		"json_encode", -- JSON encoding validation
		"utf8_validate", -- UTF-8 validation
		"xml_escape", -- XML escaping validation
	},

	-- Security Validation
	-- Security-focused validation
	security_validation = {
		"s2s_auth_compat", -- S2S authentication compatibility
		"tls_policy", -- TLS policy enforcement
		"cert_verify", -- Certificate verification
		"secure_auth_only", -- Require secure authentication
	},

	-- Protocol Compliance Validation
	-- XMPP protocol compliance checking
	protocol_validation = {
		"conformance_restricted", -- Restricted conformance checking
		"strict_https", -- Strict HTTPS enforcement
		"require_encryption", -- Require encryption validation
		"validate_domain_part", -- Domain part validation
	},

	-- Content Validation
	-- Message and content validation
	content_validation = {
		"validate_modules", -- Module validation
		"syntax_check", -- Syntax checking
		"encoding_validation", -- Character encoding validation
		"size_limits", -- Size limit validation
	},

	-- Advanced Validation Features
	-- Sophisticated validation capabilities
	advanced_validation = {
		"debug_traceback", -- Debug tracebacks for validation errors
		"error_reporting", -- Enhanced error reporting
		"validation_cache", -- Validation result caching
		"performance_monitor", -- Validation performance monitoring
	},
}

-- Apply validation configuration based on environment
local function apply_validation_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core validation modules (always enabled)
	local core_modules = {}

	-- Essential validation
	for _, module in ipairs(validation_config.core_validation) do
		table.insert(core_modules, module)
	end

	-- XML validation (always enabled)
	for _, module in ipairs(validation_config.xml_validation) do
		table.insert(core_modules, module)
	end

	-- Security validation (always enabled)
	for _, module in ipairs(validation_config.security_validation) do
		table.insert(core_modules, module)
	end

	-- Protocol validation (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(validation_config.protocol_validation) do
			table.insert(core_modules, module)
		end
	end

	-- Content validation (always enabled)
	for _, module in ipairs(validation_config.content_validation) do
		table.insert(core_modules, module)
	end

	-- Advanced validation (development and staging for debugging)
	if env_type ~= "production" then
		for _, module in ipairs(validation_config.advanced_validation) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- XML Validation Configuration
-- XML parsing and structure validation
xml_validation_config = {
	-- Basic XML settings
	strict_xml = true, -- Strict XML parsing
	validate_namespaces = true, -- Validate XML namespaces

	-- Parser settings
	parser_settings = {
		max_depth = 50, -- Maximum XML nesting depth
		max_attributes = 100, -- Maximum attributes per element
		max_namespace_declarations = 20, -- Maximum namespace declarations

		-- Size limits
		max_element_name_length = 256, -- Maximum element name length
		max_attribute_name_length = 256, -- Maximum attribute name length
		max_attribute_value_length = 4096, -- Maximum attribute value length
	},

	-- Character validation
	character_validation = {
		allow_restricted_chars = false, -- Allow XML restricted characters
		validate_utf8 = true, -- Validate UTF-8 encoding
		normalize_whitespace = true, -- Normalize whitespace
	},

	-- Error handling
	error_handling = {
		strict_mode = false, -- Strict error handling
		log_parse_errors = true, -- Log XML parse errors
		reject_malformed = true, -- Reject malformed XML
	},
}

-- Stanza Structure Validation
-- XMPP stanza structure and content validation
stanza_validation_config = {
	-- Basic stanza validation
	validate_structure = true, -- Validate stanza structure
	validate_addressing = true, -- Validate JID addressing

	-- Stanza type validation
	message_validation = {
		required_attributes = { "type" }, -- Required message attributes
		allowed_types = { "chat", "error", "groupchat", "headline", "normal" }, -- Allowed message types
		max_body_length = 65536, -- Maximum message body length
		validate_thread = true, -- Validate message threads
	},

	presence_validation = {
		allowed_types = {
			"",
			"error",
			"probe",
			"subscribe",
			"subscribed",
			"unavailable",
			"unsubscribe",
			"unsubscribed",
		}, -- Allowed presence types
		validate_show = true, -- Validate presence show values
		validate_status = true, -- Validate presence status
		max_status_length = 1024, -- Maximum status message length
	},

	iq_validation = {
		required_attributes = { "type", "id" }, -- Required IQ attributes
		allowed_types = { "get", "set", "result", "error" }, -- Allowed IQ types
		validate_id = true, -- Validate IQ ID format
		max_query_elements = 10, -- Maximum query elements per IQ
	},

	-- JID validation
	jid_validation = {
		validate_format = true, -- Validate JID format
		validate_length = true, -- Validate JID length limits
		max_localpart_length = 1023, -- Maximum localpart length
		max_domainpart_length = 1023, -- Maximum domainpart length
		max_resourcepart_length = 1023, -- Maximum resourcepart length

		-- Character validation
		validate_localpart_chars = true, -- Validate localpart characters
		validate_domainpart_chars = true, -- Validate domainpart characters
		validate_resourcepart_chars = true, -- Validate resourcepart characters
	},
}

-- Security Validation Configuration
-- Security-focused validation settings
security_validation_config = {
	-- TLS validation
	tls_validation = {
		require_tls = false, -- Require TLS for all connections
		validate_certificates = true, -- Validate TLS certificates
		check_certificate_chain = true, -- Check certificate chain
		verify_hostname = true, -- Verify hostname in certificates

		-- Certificate policies
		allow_self_signed = false, -- Allow self-signed certificates
		require_valid_ca = true, -- Require valid CA signature
		check_revocation = false, -- Check certificate revocation
	},

	-- Authentication validation
	auth_validation = {
		require_encryption = false, -- Require encrypted authentication
		validate_credentials = true, -- Validate authentication credentials
		check_password_strength = false, -- Check password strength

		-- SASL validation
		validate_sasl_mechanisms = true, -- Validate SASL mechanisms
		allowed_mechanisms = { -- Allowed SASL mechanisms
			"SCRAM-SHA-256",
			"SCRAM-SHA-1",
			"DIGEST-MD5",
			"PLAIN",
		},
	},

	-- S2S validation
	s2s_validation = {
		validate_dialback = true, -- Validate dialback authentication
		require_encryption = true, -- Require S2S encryption
		validate_certificates = true, -- Validate S2S certificates
		check_domain_verification = true, -- Check domain verification
	},

	-- Content security validation
	content_security = {
		validate_html = false, -- Validate HTML content
		strip_dangerous_tags = false, -- Strip dangerous HTML tags
		validate_urls = false, -- Validate URLs in content
		check_malicious_content = false, -- Check for malicious content
	},
}

-- Protocol Compliance Configuration
-- XMPP protocol compliance validation
protocol_compliance_config = {
	-- RFC 6120 compliance
	rfc6120_compliance = {
		strict_xml_compliance = true, -- Strict XML compliance
		validate_stream_features = true, -- Validate stream features
		check_namespace_declarations = true, -- Check namespace declarations
		validate_error_conditions = true, -- Validate error conditions
	},

	-- RFC 6121 compliance
	rfc6121_compliance = {
		validate_roster_operations = true, -- Validate roster operations
		check_presence_subscriptions = true, -- Check presence subscriptions
		validate_message_addressing = true, -- Validate message addressing
	},

	-- XEP compliance
	xep_compliance = {
		validate_xep_namespaces = true, -- Validate XEP namespaces
		check_feature_advertisements = true, -- Check feature advertisements
		validate_disco_responses = true, -- Validate service discovery responses
	},

	-- Backwards compatibility
	backwards_compatibility = {
		support_legacy_authentication = false, -- Support legacy auth
		allow_deprecated_features = false, -- Allow deprecated features
		warn_on_deprecated_usage = true, -- Warn on deprecated usage
	},
}

-- Performance and Monitoring Configuration
-- Validation performance and monitoring
performance_config = {
	-- Caching
	validation_cache = {
		enabled = true, -- Enable validation caching
		max_cache_size = 10000, -- Maximum cache entries
		cache_ttl = 3600, -- Cache TTL (1 hour)
		cache_hit_ratio_target = 0.8, -- Target cache hit ratio
	},

	-- Performance monitoring
	performance_monitoring = {
		enabled = false, -- Enable performance monitoring
		log_slow_validations = true, -- Log slow validations
		slow_validation_threshold = 100, -- Slow validation threshold (ms)

		-- Statistics
		collect_statistics = false, -- Collect validation statistics
		statistics_interval = 300, -- Statistics collection interval (5 minutes)
	},

	-- Resource limits
	resource_limits = {
		max_validation_time = 1000, -- Maximum validation time (ms)
		max_memory_usage = 10485760, -- Maximum memory usage (10MB)
		max_cpu_usage = 50, -- Maximum CPU usage (percentage)
	},
}

-- Error Reporting Configuration
-- Enhanced error reporting and debugging
error_reporting_config = {
	-- Error logging
	error_logging = {
		log_validation_errors = true, -- Log validation errors
		log_level = "warn", -- Error log level
		include_stack_trace = false, -- Include stack traces

		-- Error details
		include_stanza_content = false, -- Include stanza content in errors
		include_validation_context = true, -- Include validation context
		max_error_message_length = 1024, -- Maximum error message length
	},

	-- Error responses
	error_responses = {
		send_detailed_errors = false, -- Send detailed error responses
		include_error_codes = true, -- Include error codes
		localize_error_messages = false, -- Localize error messages

		-- Error stanza configuration
		include_original_stanza = false, -- Include original stanza in error
		add_error_extensions = false, -- Add error extensions
	},

	-- Debugging
	debugging = {
		enable_debug_mode = false, -- Enable debug mode
		debug_validation_steps = false, -- Debug validation steps
		trace_validation_path = false, -- Trace validation path
		dump_invalid_stanzas = false, -- Dump invalid stanzas
	},
}

-- Export configuration
return {
	modules = apply_validation_config(),
	xml_validation_config = xml_validation_config,
	stanza_validation_config = stanza_validation_config,
	security_validation_config = security_validation_config,
	protocol_compliance_config = protocol_compliance_config,
	performance_config = performance_config,
	error_reporting_config = error_reporting_config,
}
