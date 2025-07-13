-- ===============================================
-- STREAM LAYER: SECURITY ENHANCEMENTS
-- ===============================================
-- Prosody 13.0+ Security Features
-- DANE support, SASL channel binding, modern TLS features
-- RFC 9525 compliance, RFC 9266 TLS exporter channel binding

local security_config = {
	-- DANE Support (New in 13.0)
	-- DNS-based Authentication of Named Entities
	dane_support = {
		"s2s_auth_dane_in", -- DANE authentication for incoming s2s (core)
		-- Note: Outgoing DANE is built into core s2s handling
	},

	-- SASL Channel Binding (Enhanced in 13.0)
	-- XEP-0440: SASL Channel-Binding Type Capability
	-- RFC 9266: 'tls-exporter' channel binding with TLS 1.3
	channel_binding = {
		-- Channel binding is built into core SASL implementation
		-- Configured via channel_binding_* settings
	},

	-- Modern TLS Features (Enhanced in 13.0)
	-- RFC 9525 compliance and modern certificate handling
	modern_tls = {
		-- Modern TLS features are built into core
		-- No longer check certificate Common Names per RFC 9525
	},

	-- Enhanced Flags System (New in 13.0)
	-- mod_flags for enhanced metadata and state tracking
	flags_system = {
		"flags", -- mod_flags: Enhanced state and metadata tracking
	},
}

-- Apply security enhancements configuration
local function apply_security_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	local core_modules = {}

	-- DANE support (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(security_config.dane_support) do
			table.insert(core_modules, module)
		end
	end

	-- Flags system (always enabled)
	for _, module in ipairs(security_config.flags_system) do
		table.insert(core_modules, module)
	end

	return core_modules
end

-- DANE Configuration
-- DNS-based Authentication of Named Entities
dane_config = {
	-- Enable DANE authentication
	enabled = true,

	-- DANE policy enforcement
	dane_required_for = {}, -- List of domains requiring DANE
	dane_optional_for = {}, -- List of domains with optional DANE

	-- DNSSEC validation
	dnssec_validation = true,

	-- Fallback behavior when DANE fails
	dane_fallback = "strict", -- strict, permissive, disabled

	-- DANE record types to check
	dane_record_types = {
		"TLSA", -- TLSA records for certificate constraints
	},

	-- Logging and monitoring
	dane_logging = {
		success = "info",
		failure = "warn",
		validation_error = "error",
	},
}

-- SASL Channel Binding Configuration
-- Enhanced authentication security
sasl_channel_binding_config = {
	-- Enable channel binding support
	enabled = true,

	-- Supported channel binding types (Prosody 13.0+)
	supported_types = {
		"tls-exporter", -- RFC 9266: TLS 1.3 exporter channel binding
		"tls-server-end-point", -- TLS server end-point channel binding
		-- "tls-unique", -- Legacy TLS unique channel binding (deprecated)
	},

	-- Channel binding enforcement
	enforce_for_mechanisms = {
		"SCRAM-SHA-256-PLUS",
		"SCRAM-SHA-1-PLUS",
	},

	-- Client capability advertisement
	advertise_support = true, -- XEP-0440: Advertise supported types

	-- Security policy
	channel_binding_policy = {
		require_for_admin = true, -- Require for admin accounts
		require_for_external = false, -- Require for external domains
		log_binding_usage = true, -- Log channel binding usage
	},
}

-- Modern TLS Configuration (Enhanced in 13.0)
-- RFC 9525 compliance and security improvements
modern_tls_config = {
	-- Certificate validation (RFC 9525)
	certificate_validation = {
		-- No longer check Common Names (RFC 9525 compliance)
		check_common_names = false,

		-- Enhanced SAN validation
		strict_san_validation = true,

		-- Certificate transparency
		require_sct = false, -- Signed Certificate Timestamps

		-- OCSP stapling
		ocsp_stapling = true,
	},

	-- TLS protocol versions
	protocol_versions = {
		min_version = "1.2", -- Minimum TLS 1.2
		preferred_version = "1.3", -- Prefer TLS 1.3
		disable_sslv3 = true,
		disable_tlsv1 = true,
		disable_tlsv11 = true,
	},

	-- Cipher suite preferences
	cipher_preferences = {
		-- Use Mozilla security guidelines
		security_profile = "intermediate", -- modern, intermediate, old

		-- Forward secrecy
		require_forward_secrecy = true,

		-- AEAD ciphers preferred
		prefer_aead = true,
	},

	-- HSTS and security headers (for HTTP interfaces)
	security_headers = {
		hsts_enabled = true,
		hsts_max_age = 31536000, -- 1 year
		hsts_include_subdomains = true,
		hsts_preload = false,
	},
}

-- Flags System Configuration (New in 13.0)
-- Enhanced metadata and state tracking
flags_config = {
	-- Enable flags system
	enabled = true,

	-- Flag categories
	categories = {
		"user", -- User account flags
		"session", -- Session flags
		"message", -- Message flags
		"security", -- Security-related flags
		"moderation", -- Moderation flags
	},

	-- Persistent flags
	persistent_flags = true,

	-- Flag expiration
	default_expiration = "30d", -- 30 days default

	-- Admin access to flags
	admin_access = true,

	-- Flag storage
	storage_backend = "internal", -- internal, sql, file
}

-- Enhanced Administration Commands (13.0+)
-- New prosodyctl commands for security management
admin_commands = {
	-- DANE management
	"s2s:show_dane <domain>", -- Show DANE status for domain
	"s2s:test_dane <domain>", -- Test DANE configuration

	-- TLS management
	"tls:show_config", -- Show TLS configuration
	"tls:test_connection <host>", -- Test TLS connection

	-- Channel binding
	"auth:show_bindings", -- Show channel binding status
	"auth:test_binding <user>", -- Test channel binding

	-- Flags management
	"flags:list [category]", -- List flags
	"flags:set <target> <flag> [expiry]", -- Set flag
	"flags:unset <target> <flag>", -- Remove flag

	-- Feature checking (New in 13.0)
	"check:features", -- Check configuration for improvements
	"check:security", -- Security configuration check
	"check:compliance", -- Compliance suite check
}

-- Sub-second Timestamp Precision (New in 13.0)
-- Enhanced timestamp handling
timestamp_config = {
	-- Enable sub-second precision
	sub_second_precision = true,

	-- Timestamp format
	precision = "milliseconds", -- milliseconds, microseconds

	-- Archive timestamp precision
	archive_precision = "milliseconds",

	-- Log timestamp precision
	log_precision = "milliseconds",
}

-- Apply configuration
local modules = apply_security_config()

-- Export modules for layer loading
security_enhancement_modules = modules

-- Merge with stream modules if it exists
if stream_modules then
	for _, module in ipairs(modules) do
		table.insert(stream_modules, module)
	end
end

print("Security enhancements configuration loaded (Prosody 13.0+ features)")

-- Configuration notes for administrators
print("Note: DANE support requires proper DNSSEC and TLSA records")
print("Note: Channel binding enhances authentication security")
print("Note: Use 'prosodyctl check:features' for configuration recommendations")
print("Note: TLS configuration now follows RFC 9525 (no Common Name checking)")
