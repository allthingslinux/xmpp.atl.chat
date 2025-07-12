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

-- Initialize module collection system
local all_modules = {}
local layer_configs = {}

-- Function to collect modules from layers
local function collect_layer_modules(layer_name, layer_modules)
	if layer_modules then
		layer_configs[layer_name] = layer_modules
		for _, module in ipairs(layer_modules) do
			table.insert(all_modules, module)
		end
	end
end

-- Layer-based configuration loading
-- Load configuration in XMPP protocol stack order

-- Layer 01: Transport Layer
-- Network, ports, TLS, compression, connections
dofile(config_path .. "/stack/01-transport/ports.cfg.lua")
dofile(config_path .. "/stack/01-transport/tls.cfg.lua")
dofile(config_path .. "/stack/01-transport/compression.cfg.lua")
dofile(config_path .. "/stack/01-transport/connections.cfg.lua")
collect_layer_modules("transport", transport_modules)

-- Layer 02: Stream Layer
-- Authentication, encryption, stream management, negotiation
dofile(config_path .. "/stack/02-stream/authentication.cfg.lua")
dofile(config_path .. "/stack/02-stream/encryption.cfg.lua")
dofile(config_path .. "/stack/02-stream/management.cfg.lua")
dofile(config_path .. "/stack/02-stream/negotiation.cfg.lua")
collect_layer_modules("stream", stream_modules)

-- Layer 03: Stanza Layer
-- Routing, filtering, validation, processing
dofile(config_path .. "/stack/03-stanza/routing.cfg.lua")
dofile(config_path .. "/stack/03-stanza/filtering.cfg.lua")
dofile(config_path .. "/stack/03-stanza/validation.cfg.lua")
dofile(config_path .. "/stack/03-stanza/processing.cfg.lua")
collect_layer_modules("stanza", stanza_modules)

-- Layer 04: Protocol Layer
-- Core XMPP features, extensions, legacy support
dofile(config_path .. "/stack/04-protocol/core.cfg.lua")
dofile(config_path .. "/stack/04-protocol/extensions.cfg.lua")
dofile(config_path .. "/stack/04-protocol/legacy.cfg.lua")
dofile(config_path .. "/stack/04-protocol/experimental.cfg.lua")
collect_layer_modules("protocol", protocol_modules)

-- Layer 05: Services Layer
-- Messaging, presence, groupchat, pubsub
dofile(config_path .. "/stack/05-services/messaging.cfg.lua")
dofile(config_path .. "/stack/05-services/presence.cfg.lua")
dofile(config_path .. "/stack/05-services/groupchat.cfg.lua")
dofile(config_path .. "/stack/05-services/pubsub.cfg.lua")
collect_layer_modules("services", services_modules)

-- Layer 06: Storage Layer
-- Backends, archiving, caching, migration
dofile(config_path .. "/stack/06-storage/backends.cfg.lua")
dofile(config_path .. "/stack/06-storage/archiving.cfg.lua")
dofile(config_path .. "/stack/06-storage/caching.cfg.lua")
dofile(config_path .. "/stack/06-storage/migration.cfg.lua")
collect_layer_modules("storage", storage_modules)

-- Layer 07: Interfaces Layer
-- HTTP, WebSocket, BOSH, components
dofile(config_path .. "/stack/07-interfaces/http.cfg.lua")
dofile(config_path .. "/stack/07-interfaces/websocket.cfg.lua")
dofile(config_path .. "/stack/07-interfaces/bosh.cfg.lua")
dofile(config_path .. "/stack/07-interfaces/components.cfg.lua")
collect_layer_modules("interfaces", interfaces_modules)

-- Layer 08: Integration Layer
-- LDAP, OAuth, webhooks, APIs
dofile(config_path .. "/stack/08-integration/ldap.cfg.lua")
dofile(config_path .. "/stack/08-integration/oauth.cfg.lua")
dofile(config_path .. "/stack/08-integration/webhooks.cfg.lua")
dofile(config_path .. "/stack/08-integration/apis.cfg.lua")
collect_layer_modules("integration", integration_modules)

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
-- Authentication method from stream layer
authentication = authentication_method or "internal_hashed"

-- Storage backend from storage layer
storage = storage_backend or "internal"

-- Module enablement from all layers
modules_enabled = all_modules

-- SSL/TLS certificate configuration
ssl = ssl_config
	or {
		key = "/etc/prosody/certs/" .. server_name .. ".key",
		certificate = "/etc/prosody/certs/" .. server_name .. ".crt",
	}

-- Component hosts from interfaces layer
-- Load component configurations if they exist
if muc_component_config then
	Component(muc_component_config.hostname)
	component_secret = muc_component_config.secret
	modules_enabled = muc_component_config.modules
end

if http_upload_component_config then
	Component(http_upload_component_config.hostname)
	component_secret = http_upload_component_config.secret
	modules_enabled = http_upload_component_config.modules
end

if pubsub_component_config then
	Component(pubsub_component_config.hostname)
	component_secret = pubsub_component_config.secret
	modules_enabled = pubsub_component_config.modules
end

-- Global configuration inheritance
-- Apply configurations from global.cfg.lua if it exists
local global_config_path = config_path .. "/global.cfg.lua"
if lfs and lfs.attributes(global_config_path) then
	dofile(global_config_path)
end

-- Legacy compatibility
-- Support for existing configuration patterns
legacy_ssl_ports = legacy_ssl_ports or {}
cross_domain_bosh = cross_domain_bosh or true
consider_bosh_secure = consider_bosh_secure or true

-- Logging configuration from global or layer configs
log = log
	or {
		info = data_path .. "/prosody.log",
		error = data_path .. "/prosody.err",
		{ levels = { "error" }, to = "console" },
	}

-- Performance tuning
gc = gc or {
	speed = 500, -- Garbage collection speed
}

-- Statistics and monitoring
statistics = statistics or "internal"
statistics_interval = statistics_interval or 60

-- Resource limits from layers
limits = limits or {}

-- Storage configuration from storage layer
default_storage = default_storage or "internal"
storage = storage or {}

-- Debug information (only in development)
if environment == "development" then
	-- Log layer loading information
	module:log("info", "Loaded %d modules across %d layers", #all_modules, 8)
	for layer_name, modules in pairs(layer_configs) do
		module:log("debug", "Layer %s: %d modules", layer_name, #modules)
	end
end
