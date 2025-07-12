-- ============================================================================
-- PROSODY CORE CONFIGURATION LOADER
-- ============================================================================
-- Dynamic configuration loading system for layer-based architecture
-- Supports features, clients, use-cases, environments, and policies

local lfs = require("lfs")
local config_loader = {}

-- ============================================================================
-- CORE LOADING FUNCTIONS
-- ============================================================================

-- Load all configuration files from a directory
function config_loader.load_directory(directory_path)
	local base_path = "config/" .. directory_path
	local loaded_modules = {}

	-- Check if directory exists
	if not lfs.attributes(base_path) then
		module:log("warn", "Directory not found: %s", base_path)
		return loaded_modules
	end

	-- Recursively load all .cfg.lua files
	for file in lfs.dir(base_path) do
		if file ~= "." and file ~= ".." then
			local file_path = base_path .. "/" .. file
			local attr = lfs.attributes(file_path)

			if attr.mode == "directory" then
				-- Recursively load subdirectories
				local sub_modules = config_loader.load_directory(directory_path .. "/" .. file)
				for _, module in ipairs(sub_modules) do
					table.insert(loaded_modules, module)
				end
			elseif file:match("%.cfg%.lua$") then
				-- Load configuration file
				local success, result = pcall(dofile, file_path)
				if success then
					module:log("info", "Loaded configuration: %s", file_path)
					if result and result.modules_enabled then
						for _, mod in ipairs(result.modules_enabled) do
							table.insert(loaded_modules, mod)
						end
					end
				else
					module:log("error", "Failed to load configuration %s: %s", file_path, result)
				end
			end
		end
	end

	return loaded_modules
end

-- Load client-specific optimizations
function config_loader.load_client_optimizations(client_list)
	local clients = {}
	for client in client_list:gmatch("[^,]+") do
		table.insert(clients, client:trim())
	end

	for _, client in ipairs(clients) do
		local client_path = "config/clients/" .. client .. ".cfg.lua"
		if lfs.attributes(client_path) then
			local success, result = pcall(dofile, client_path)
			if success then
				module:log("info", "Applied client optimization: %s", client)
			else
				module:log("error", "Failed to load client optimization %s: %s", client, result)
			end
		else
			module:log("warn", "Client optimization not found: %s", client_path)
		end
	end
end

-- Load use-case template
function config_loader.load_usecase(usecase_name)
	local usecase_path = "config/usecases/" .. usecase_name .. ".cfg.lua"
	if lfs.attributes(usecase_path) then
		local success, result = pcall(dofile, usecase_path)
		if success then
			module:log("info", "Applied use-case template: %s", usecase_name)
			prosody.use_case = usecase_name
		else
			module:log("error", "Failed to load use-case %s: %s", usecase_name, result)
		end
	else
		module:log("warn", "Use-case template not found: %s", usecase_path)
	end
end

-- Load environment-specific configuration
function config_loader.load_environment(environment)
	local env_path = "config/environments/" .. environment .. ".cfg.lua"
	if lfs.attributes(env_path) then
		local success, result = pcall(dofile, env_path)
		if success then
			module:log("info", "Applied environment configuration: %s", environment)
			prosody.environment = environment
		else
			module:log("error", "Failed to load environment %s: %s", environment, result)
		end
	else
		module:log("warn", "Environment configuration not found: %s", env_path)
	end
end

-- Apply policy configurations
function config_loader.apply_policies()
	local security_level = os.getenv("PROSODY_SECURITY_LEVEL") or "baseline"
	local performance_tier = os.getenv("PROSODY_PERFORMANCE_TIER") or "medium"
	local compliance = os.getenv("PROSODY_COMPLIANCE")

	-- Load security policy
	local security_path = "config/policies/security/" .. security_level .. ".cfg.lua"
	if lfs.attributes(security_path) then
		local success, result = pcall(dofile, security_path)
		if success then
			module:log("info", "Applied security policy: %s", security_level)
		else
			module:log("error", "Failed to load security policy %s: %s", security_level, result)
		end
	end

	-- Load performance policy
	local performance_path = "config/policies/performance/" .. performance_tier .. ".cfg.lua"
	if lfs.attributes(performance_path) then
		local success, result = pcall(dofile, performance_path)
		if success then
			module:log("info", "Applied performance policy: %s", performance_tier)
		else
			module:log("error", "Failed to load performance policy %s: %s", performance_tier, result)
		end
	end

	-- Load compliance policy if specified
	if compliance then
		local compliance_path = "config/policies/compliance/" .. compliance .. ".cfg.lua"
		if lfs.attributes(compliance_path) then
			local success, result = pcall(dofile, compliance_path)
			if success then
				module:log("info", "Applied compliance policy: %s", compliance)
			else
				module:log("error", "Failed to load compliance policy %s: %s", compliance, result)
			end
		end
	end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Helper function to trim whitespace
function string:trim()
	return self:match("^%s*(.-)%s*$")
end

-- Detect current environment
function config_loader.detect_environment()
	-- Check environment variable first
	local env = os.getenv("PROSODY_ENVIRONMENT")
	if env then
		return env
	end

	-- Check for Docker environment
	if os.getenv("DOCKER_CONTAINER") or lfs.attributes("/.dockerenv") then
		return "docker"
	end

	-- Check for Kubernetes environment
	if os.getenv("KUBERNETES_SERVICE_HOST") then
		return "kubernetes"
	end

	-- Check for development indicators
	if lfs.attributes("./prosody.cfg.lua") or os.getenv("PROSODY_DEV") then
		return "local"
	end

	-- Default to production
	return "production"
end

return config_loader
