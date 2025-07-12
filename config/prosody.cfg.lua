-- Prosody XMPP Server Configuration
-- Layer-Based Architecture Implementation
-- Loads configuration in protocol stack order for optimal XMPP operation

-- Environment detection
local environment = os.getenv("PROSODY_ENVIRONMENT") or "production"
local data_path = os.getenv("PROSODY_DATA_PATH") or "/var/lib/prosody"
local config_path = os.getenv("PROSODY_CONFIG_PATH") or "/etc/prosody"

-- Basic server information
-- This will be overridden by domain-specific configuration
admins = { "admin@localhost" }
server_name = os.getenv("PROSODY_DOMAIN") or "localhost"

-- Data storage configuration
data_path = data_path
plugin_paths = { "/usr/local/lib/prosody/modules" }

-- Layer-based configuration loading
-- Load configuration in XMPP protocol stack order

-- Layer 01: Transport Layer
-- Network, ports, TLS, compression, connections
dofile(config_path .. "/stack/01-transport/ports.cfg.lua")
dofile(config_path .. "/stack/01-transport/tls.cfg.lua")
dofile(config_path .. "/stack/01-transport/compression.cfg.lua")
dofile(config_path .. "/stack/01-transport/connections.cfg.lua")

-- Layer 02: Stream Layer
-- Authentication, encryption, stream management, negotiation
dofile(config_path .. "/stack/02-stream/authentication.cfg.lua")
-- dofile(config_path .. "/stack/02-stream/encryption.cfg.lua")
dofile(config_path .. "/stack/02-stream/management.cfg.lua")
-- dofile(config_path .. "/stack/02-stream/negotiation.cfg.lua")

-- Layer 03: Stanza Layer (to be implemented)
-- Routing, filtering, validation, processing
-- dofile(config_path .. "/stack/03-stanza/routing.cfg.lua")
-- dofile(config_path .. "/stack/03-stanza/filtering.cfg.lua")
-- dofile(config_path .. "/stack/03-stanza/validation.cfg.lua")
-- dofile(config_path .. "/stack/03-stanza/processing.cfg.lua")

-- Layer 04: Protocol Layer (to be implemented)
-- Core XMPP features, extensions, legacy support
-- dofile(config_path .. "/stack/04-protocol/core.cfg.lua")
-- dofile(config_path .. "/stack/04-protocol/extensions.cfg.lua")
-- dofile(config_path .. "/stack/04-protocol/legacy.cfg.lua")
-- dofile(config_path .. "/stack/04-protocol/experimental.cfg.lua")

-- Layer 05: Services Layer (to be implemented)
-- Messaging, presence, groupchat, pubsub
-- dofile(config_path .. "/stack/05-services/messaging.cfg.lua")
-- dofile(config_path .. "/stack/05-services/presence.cfg.lua")
-- dofile(config_path .. "/stack/05-services/groupchat.cfg.lua")
-- dofile(config_path .. "/stack/05-services/pubsub.cfg.lua")

-- Layer 06: Storage Layer (to be implemented)
-- Backends, archiving, caching, migration
-- dofile(config_path .. "/stack/06-storage/backends.cfg.lua")
-- dofile(config_path .. "/stack/06-storage/archiving.cfg.lua")
-- dofile(config_path .. "/stack/06-storage/caching.cfg.lua")
-- dofile(config_path .. "/stack/06-storage/migration.cfg.lua")

-- Layer 07: Interfaces Layer (to be implemented)
-- HTTP, WebSocket, BOSH, components
-- dofile(config_path .. "/stack/07-interfaces/http.cfg.lua")
-- dofile(config_path .. "/stack/07-interfaces/websocket.cfg.lua")
-- dofile(config_path .. "/stack/07-interfaces/bosh.cfg.lua")
-- dofile(config_path .. "/stack/07-interfaces/components.cfg.lua")

-- Layer 08: Integration Layer (to be implemented)
-- LDAP, OAuth, webhooks, APIs
-- dofile(config_path .. "/stack/08-integration/ldap.cfg.lua")
-- dofile(config_path .. "/stack/08-integration/oauth.cfg.lua")
-- dofile(config_path .. "/stack/08-integration/webhooks.cfg.lua")
-- dofile(config_path .. "/stack/08-integration/apis.cfg.lua")

-- Domain configuration
-- Load domain-specific settings
local domain_config_path = config_path .. "/domains"
if lfs and lfs.attributes(domain_config_path) then
	for domain_file in lfs.dir(domain_config_path) do
		if domain_file:match("%.cfg%.lua$") then
			dofile(domain_config_path .. "/" .. domain_file)
		end
	end
end

-- Environment-specific overrides
-- Apply environment-specific configuration
local env_config_path = config_path .. "/environments/" .. environment .. ".cfg.lua"
if lfs and lfs.attributes(env_config_path) then
	dofile(env_config_path)
end

-- Policy application
-- Apply security, performance, and compliance policies
local policy_config_path = config_path .. "/policies"
if lfs and lfs.attributes(policy_config_path) then
	-- Apply security policies
	local security_level = os.getenv("PROSODY_SECURITY_LEVEL") or "standard"
	local security_policy = policy_config_path .. "/security/" .. security_level .. ".cfg.lua"
	if lfs.attributes(security_policy) then
		dofile(security_policy)
	end

	-- Apply performance policies
	local performance_tier = os.getenv("PROSODY_PERFORMANCE_TIER") or "medium"
	local performance_policy = policy_config_path .. "/performance/" .. performance_tier .. ".cfg.lua"
	if lfs.attributes(performance_policy) then
		dofile(performance_policy)
	end

	-- Apply compliance policies
	local compliance_mode = os.getenv("PROSODY_COMPLIANCE")
	if compliance_mode then
		local compliance_policy = policy_config_path .. "/compliance/" .. compliance_mode .. ".cfg.lua"
		if lfs.attributes(compliance_policy) then
			dofile(compliance_policy)
		end
	end
end

-- Virtual host configuration
-- Define the main virtual host
VirtualHost(server_name)
-- Domain-specific settings will be loaded from domain configuration files

-- Default authentication method
authentication = authentication_storage.default or "internal_hashed"

-- Default storage backend
storage = "internal"

-- Enable all loaded modules
-- Modules are defined in the layer configuration files

-- Component hosts (if needed)
-- These will be defined in the interfaces layer configuration

-- Global module enablement
-- Combine all modules from all layers
local all_modules = {}

-- Function to merge module lists
local function merge_modules(source_modules)
	if source_modules then
		for _, module in ipairs(source_modules) do
			table.insert(all_modules, module)
		end
	end
end

-- Merge modules from all layers (will be populated as layers are implemented)
if modules_enabled then
	merge_modules(modules_enabled)
end

-- Set the final module list
modules_enabled = all_modules

-- Legacy compatibility
-- Support for existing configuration patterns
legacy_ssl_ports = legacy_ssl_ports or {}
cross_domain_bosh = true
consider_bosh_secure = true

-- Logging configuration
-- Comprehensive logging setup
log = {
	-- Main log file
	info = data_path .. "/prosody.log",
	error = data_path .. "/prosody.err",

	-- Console logging for development
	{ levels = { "error" }, to = "console" },
}

-- Performance tuning
-- Optimize for the layer-based architecture
gc = {
	speed = 500, -- Garbage collection speed
}

-- Statistics and monitoring
-- Enable comprehensive statistics
statistics = "internal"
statistics_interval = 60 -- 1 minute statistics interval

-- Resource limits
-- Prevent resource exhaustion
limits = limits or {}

-- Default storage configuration
-- Will be overridden by storage layer configuration
default_storage = "internal"
storage = {
	archive2 = "sql", -- Use SQL for message archives
}

-- SQL configuration (if using SQL storage)
sql = {
	driver = "SQLite3",
	database = data_path .. "/prosody.sqlite",
}

-- Security defaults
-- Basic security configuration
security = {
	-- Require encryption
	c2s_require_encryption = true,
	s2s_require_encryption = true,

	-- Certificate verification
	s2s_secure_auth = false, -- Will be overridden by TLS configuration

	-- HTTPS redirect
	https_redirect = true,
}

-- Feature advertisement
-- Advertise server capabilities
disco_items = {
	{ "upload." .. server_name, "HTTP File Upload" },
	{ "conference." .. server_name, "Chatrooms" },
}

-- Cross-domain policy
-- For web clients
cross_domain_bosh = true
cross_domain_websocket = true

-- Welcome message for new users
welcome_message = "Welcome to " .. server_name .. "! For help, contact the administrators."

-- Message of the day
motd_text = [[Welcome to ]]
.. server_name
	.. [[

This server uses a layer-based architecture for optimal XMPP performance.
For support, please contact the administrators.
]]

-- Shutdown message
shutdown_message = "The server is being restarted for maintenance. Please reconnect in a few moments."
