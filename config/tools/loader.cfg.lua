-- ============================================================================
-- PROSODY CONFIGURATION TOOLS LOADER
-- ============================================================================
-- Bridge file to load the core configuration loader tools
-- This file is included by the main prosody.cfg.lua configuration

-- Load the core configuration loader
local config_loader = dofile("config/tools/core/loader.lua")

-- Load additional configuration tools
local merger = dofile("config/tools/core/merger.lua")
local resolver = dofile("config/tools/core/resolver.lua")
local validator = dofile("config/tools/core/validator.lua")

-- Development tools (only in development environment)
local env = os.getenv("PROSODY_ENV") or "production"
if env == "development" or env == "local" then
	local hot_reload = dofile("config/tools/development/hot-reload.lua")
end

-- Migration tools
local migrator = dofile("config/tools/migration/migrator.lua")

-- Monitoring tools
local diagnostics = dofile("config/tools/monitoring/diagnostics.lua")

-- Initialize configuration validation
if validator and validator.validate_configuration then
	local validation_result = validator.validate_configuration()
	if not validation_result.valid then
		module:log("error", "Configuration validation failed: %s", validation_result.error)
	else
		module:log("info", "Configuration validation passed")
	end
end

module:log("info", "Configuration tools loaded successfully")
