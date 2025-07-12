-- ===============================================
-- PROSODY XMPP SERVER CONFIGURATION
-- Layer-Based Architecture
-- ===============================================

-- Core Configuration
daemonize = true
pidfile = "/var/run/prosody/prosody.pid"
user = "prosody"
group = "prosody"

-- ===============================================
-- ENVIRONMENT DETECTION
-- ===============================================

local function get_env_var(name, default)
	return os.getenv(name) or default
end

local function is_production()
	return get_env_var("PROSODY_ENV", "development") == "production"
end

-- ===============================================
-- LAYER-BASED CONFIGURATION LOADER
-- ===============================================

local function load_layer_configs()
	print("Loading layer-based configuration...")

	local layers = {
		"01-transport",
		"02-stream",
		"03-stanza",
		"04-protocol",
		"05-services",
		"06-storage",
		"07-interfaces",
		"08-integration",
	}

	for _, layer in ipairs(layers) do
		local layer_path = "/etc/prosody/stack/" .. layer .. "/"
		local configs = {
			"ports",
			"tls",
			"compression",
			"connections",
			"authentication",
			"management",
			"encryption",
			"negotiation",
			"routing",
			"filtering",
			"validation",
			"processing",
			"core",
			"extensions",
			"legacy",
			"experimental",
			"messaging",
			"presence",
			"groupchat",
			"pubsub",
			"backends",
			"archiving",
			"caching",
			"migration",
			"http",
			"websocket",
			"bosh",
			"components",
			"ldap",
			"oauth",
			"webhooks",
			"apis",
		}

		for _, config in ipairs(configs) do
			local config_file = layer_path .. config .. ".cfg.lua"
			local file = io.open(config_file, "r")
			if file then
				file:close()
				print("Loading: " .. config_file)
				Include(config_file)
			end
		end
	end
end

-- ===============================================
-- DOMAIN CONFIGURATION LOADER
-- ===============================================

local function load_domain_configs()
	print("Loading domain configurations...")

	local domain_configs = {
		"/etc/prosody/domains/primary/domain.cfg.lua",
		"/etc/prosody/domains/primary/users.cfg.lua",
		"/etc/prosody/domains/primary/features.cfg.lua",
		"/etc/prosody/domains/conference/domain.cfg.lua",
		"/etc/prosody/domains/conference/rooms.cfg.lua",
		"/etc/prosody/domains/upload/domain.cfg.lua",
		"/etc/prosody/domains/upload/policies.cfg.lua",
		"/etc/prosody/domains/proxy/domain.cfg.lua",
	}

	for _, config in ipairs(domain_configs) do
		local file = io.open(config, "r")
		if file then
			file:close()
			print("Loading: " .. config)
			Include(config)
		end
	end
end

-- ===============================================
-- ENVIRONMENT CONFIGURATION LOADER
-- ===============================================

local function load_environment_config()
	local env = get_env_var("PROSODY_ENV", "development")
	local env_config = "/etc/prosody/environments/" .. env .. ".cfg.lua"

	local file = io.open(env_config, "r")
	if file then
		file:close()
		print("Loading environment config: " .. env_config)
		Include(env_config)
	else
		print("Warning: Environment config not found: " .. env_config)
	end
end

-- ===============================================
-- POLICY CONFIGURATION LOADER
-- ===============================================

local function load_policy_configs()
	print("Loading policy configurations...")

	-- Load policies based on environment variables
	local security_level = get_env_var("PROSODY_SECURITY_LEVEL", "baseline")
	local performance_tier = get_env_var("PROSODY_PERFORMANCE_TIER", "medium")
	local compliance_mode = get_env_var("PROSODY_COMPLIANCE", "")

	local policy_configs = {
		"/etc/prosody/policies/security/" .. security_level .. ".cfg.lua",
		"/etc/prosody/policies/performance/" .. performance_tier .. ".cfg.lua",
	}

	-- Add compliance policy if specified
	if compliance_mode ~= "" then
		table.insert(policy_configs, "/etc/prosody/policies/compliance/" .. compliance_mode .. ".cfg.lua")
	end

	for _, config in ipairs(policy_configs) do
		local file = io.open(config, "r")
		if file then
			file:close()
			print("Loading: " .. config)
			Include(config)
		else
			print("Warning: Policy file not found: " .. config)
		end
	end
end

-- ===============================================
-- CONFIGURATION ORCHESTRATION
-- ===============================================

print("=== PROSODY LAYER-BASED CONFIGURATION ===")
print("Environment: " .. get_env_var("PROSODY_ENV", "development"))
print("Production Mode: " .. tostring(is_production()))

-- Load all configurations in proper order
load_layer_configs()
load_domain_configs()
load_environment_config()
load_policy_configs()

-- Load configuration tools
local tools_config = "/etc/prosody/tools/loader.cfg.lua"
local file = io.open(tools_config, "r")
if file then
	file:close()
	Include(tools_config)
end

print("=== CONFIGURATION LOADING COMPLETE ===")

-- ===============================================
-- RUNTIME INFORMATION
-- ===============================================

log = {
	{ levels = { min = is_production() and "warn" or "debug" }, to = "console" },
	{ levels = { min = "info" }, to = "file", filename = "/var/log/prosody/prosody.log" },
}

-- Configuration validation
if is_production() then
	print("Production mode: Enhanced security and performance settings active")
else
	print("Development mode: Debug logging and relaxed settings active")
end
