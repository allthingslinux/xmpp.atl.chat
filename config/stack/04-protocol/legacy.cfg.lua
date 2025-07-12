-- Layer 04: Protocol - Legacy Configuration
-- Backwards compatibility with older XMPP implementations
-- Deprecated features and legacy protocol support

local legacy_config = {
	-- Legacy Authentication
	-- Deprecated authentication methods for old clients
	legacy_auth = {
		"legacyauth", -- XEP-0078: Non-SASL Authentication (core)
		-- Note: auth_internal_plain and auth_internal_hashed are not real modules
		-- Authentication storage is configured via authentication = "internal" setting
	},

	-- Legacy Messaging
	-- Deprecated messaging features for compatibility
	legacy_messaging = {
		-- XEP-0091: Legacy Delayed Delivery (deprecated in 0.12.0)
		-- XEP-0090: Legacy Entity Time (deprecated in 13.0.0)
		-- These are handled automatically by core for compatibility
	},

	-- Legacy Privacy
	-- Deprecated privacy features (replaced by XEP-0191)
	legacy_privacy = {
		-- "privacy", -- XEP-0016: Privacy Lists (deprecated in 0.10)
		-- Note: Privacy lists are deprecated, use blocking (XEP-0191) instead
	},

	-- Legacy Compression
	-- Deprecated stream compression (deprecated in 0.10)
	legacy_compression = {
		-- "compression", -- XEP-0138: Stream Compression (deprecated)
		-- Note: Stream compression is deprecated due to security concerns
	},
}

-- Legacy Configuration Variables
-- Settings for backwards compatibility
local legacy_settings = {
	-- Legacy SSL ports (now called c2s_direct_tls_ports)
	legacy_ssl_ports = { 5223 },

	-- Legacy authentication warnings
	warn_legacy_auth = os.getenv("PROSODY_WARN_LEGACY_AUTH") ~= "false",

	-- Compatibility mode for older clients
	compatibility_mode = os.getenv("PROSODY_COMPATIBILITY_MODE") == "true",
}

-- Apply legacy configuration
for category, modules in pairs(legacy_config) do
	for _, module in ipairs(modules) do
		table.insert(enabled_modules, module)
	end
end

-- Apply legacy settings
for setting, value in pairs(legacy_settings) do
	_G[setting] = value
end

log("info", "Layer 04 Legacy: Loaded legacy compatibility features")
log("warn", "Legacy features are deprecated and should be migrated to modern alternatives")
