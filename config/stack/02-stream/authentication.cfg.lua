-- Layer 02: Stream - Authentication Configuration
-- SASL authentication mechanisms, multi-factor authentication, and security policies
-- XEP-0388: Extensible SASL Profile (SASL 2.0), XEP-0440: SASL Channel-Binding Type Capability
-- XEP-0175: Best Practices for Use of SASL ANONYMOUS

local authentication_config = {
	-- Core SASL Authentication
	-- Essential SASL mechanisms for secure authentication
	core_sasl = {
		"saslauth", -- Core SASL authentication (built-in)
	},

	-- Modern SASL Mechanisms
	-- Advanced authentication with modern security features
	modern_sasl = {
		-- Note: SASL 2.0 modules are experimental community modules
		-- "sasl2", -- XEP-0388: Extensible SASL Profile (community)
		-- "sasl2_bind2", -- Bind 2 integration with SASL2 (community)
		-- "sasl2_fast", -- Fast Authentication Streamlining Tokens (community)
		-- "sasl2_sm", -- XEP-0198 integration with SASL2 (community)
	},

	-- Anonymous Authentication
	-- Support for anonymous logins per XEP-0175
	anonymous_auth = {
		-- Note: Anonymous authentication is configured via authentication = "anonymous"
		-- No additional modules needed for basic anonymous support
	},

	-- External Authentication
	-- Integration with external authentication systems
	external_auth = {
		-- Note: These are community modules for external auth integration
		-- "auth_ldap", -- LDAP authentication (community)
		-- "auth_http", -- HTTP authentication (community)
		-- "auth_sql", -- SQL authentication (community)
	},

	-- Client Certificate Authentication
	-- X.509 certificate-based authentication
	cert_auth = {
		-- Note: Certificate auth is handled by core TLS implementation
		-- "client_certs", -- Client certificate management (community)
	},

	-- Registration and Account Management
	-- User registration and account management
	registration = {
		"register_ibr", -- In-band registration (core)
		"user_account_management", -- Password change support (core)
		"register_limits", -- Registration limits (core)
	},
}

-- Authentication Configuration Variables
-- Core authentication settings and policies
local auth_settings = {
	-- Authentication method (internal, anonymous, ldap, etc.)
	authentication = os.getenv("PROSODY_AUTH_METHOD") or "internal",

	-- Allow registration
	allow_registration = os.getenv("PROSODY_ALLOW_REGISTRATION") == "true",

	-- Registration limits
	registration_throttle_max = tonumber(os.getenv("PROSODY_REG_THROTTLE_MAX")) or 5,
	registration_throttle_period = tonumber(os.getenv("PROSODY_REG_THROTTLE_PERIOD")) or 300,

	-- Password policy
	password_policy = {
		length = tonumber(os.getenv("PROSODY_PASSWORD_MIN_LENGTH")) or 8,
	},

	-- SASL mechanisms
	sasl_mechanisms = {
		"SCRAM-SHA-256",
		"SCRAM-SHA-1",
		"DIGEST-MD5",
		"PLAIN",
	},

	-- Channel binding
	tls_channel_binding = os.getenv("PROSODY_TLS_CHANNEL_BINDING") ~= "false",
}

-- Apply authentication configuration
for category, modules in pairs(authentication_config) do
	for _, module in ipairs(modules) do
		table.insert(enabled_modules, module)
	end
end

-- Apply authentication settings
for setting, value in pairs(auth_settings) do
	_G[setting] = value
end

log("info", "Layer 02 Authentication: Loaded SASL authentication with modern security features")
log(
	"info",
	"Authentication method: %s, Registration: %s",
	auth_settings.authentication,
	tostring(auth_settings.allow_registration)
)
