-- ============================================================================
-- PROSODY LAYER-BASED CONFIGURATION LOADER
-- ============================================================================
-- Utilities for managing the layer-based configuration system
-- Provides debugging, validation, and management tools

local lfs = require("lfs")

-- ============================================================================
-- CONFIGURATION VALIDATION UTILITIES
-- ============================================================================

local config_loader = {}

-- Validate that all required layers are present
function config_loader.validate_layers(config_path)
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

	local layer_files = {
		"ports.cfg.lua",
		"tls.cfg.lua",
		"compression.cfg.lua",
		"connections.cfg.lua",
		"authentication.cfg.lua",
		"encryption.cfg.lua",
		"management.cfg.lua",
		"negotiation.cfg.lua",
		"routing.cfg.lua",
		"filtering.cfg.lua",
		"validation.cfg.lua",
		"processing.cfg.lua",
		"core.cfg.lua",
		"extensions.cfg.lua",
		"legacy.cfg.lua",
		"experimental.cfg.lua",
		"messaging.cfg.lua",
		"presence.cfg.lua",
		"groupchat.cfg.lua",
		"pubsub.cfg.lua",
		"backends.cfg.lua",
		"archiving.cfg.lua",
		"caching.cfg.lua",
		"migration.cfg.lua",
		"http.cfg.lua",
		"websocket.cfg.lua",
		"bosh.cfg.lua",
		"components.cfg.lua",
		"ldap.cfg.lua",
		"oauth.cfg.lua",
		"webhooks.cfg.lua",
		"apis.cfg.lua",
	}

	local missing_files = {}
	local file_index = 1

	for _, layer in ipairs(layers) do
		local layer_path = config_path .. "/stack/" .. layer

		-- Check if layer directory exists
		if not lfs.attributes(layer_path) then
			table.insert(missing_files, "Layer directory: " .. layer)
		else
			-- Check each file in the layer
			for i = 1, 4 do
				local file_path = layer_path .. "/" .. layer_files[file_index]
				if not lfs.attributes(file_path) then
					table.insert(missing_files, file_path)
				end
				file_index = file_index + 1
			end
		end
	end

	return missing_files
end

-- Check module conflicts and dependencies
function config_loader.check_module_conflicts(all_modules)
	local conflicts = {}
	local module_counts = {}

	-- Count module occurrences
	for _, module in ipairs(all_modules) do
		module_counts[module] = (module_counts[module] or 0) + 1
	end

	-- Find duplicates
	for module, count in pairs(module_counts) do
		if count > 1 then
			table.insert(conflicts, {
				module = module,
				count = count,
				type = "duplicate",
			})
		end
	end

	-- Check for known incompatible modules
	local incompatible_pairs = {
		{ "carbons", "carbon_copy" }, -- Different implementations
		{ "mam", "mod_archive" }, -- Different archive implementations
		{ "smacks", "stream_management" }, -- Different stream management
	}

	for _, pair in ipairs(incompatible_pairs) do
		local has_first = false
		local has_second = false

		for _, module in ipairs(all_modules) do
			if module == pair[1] then
				has_first = true
			end
			if module == pair[2] then
				has_second = true
			end
		end

		if has_first and has_second then
			table.insert(conflicts, {
				modules = pair,
				type = "incompatible",
			})
		end
	end

	return conflicts
end

-- ============================================================================
-- LAYER INFORMATION UTILITIES
-- ============================================================================

-- Get information about loaded layers
function config_loader.get_layer_info(layer_configs)
	local info = {}

	for layer_name, modules in pairs(layer_configs) do
		info[layer_name] = {
			module_count = #modules,
			modules = modules,
		}
	end

	return info
end

-- Generate configuration summary
function config_loader.generate_summary(all_modules, layer_configs)
	local summary = {
		total_modules = #all_modules,
		total_layers = 0,
		layers = {},
	}

	for layer_name, modules in pairs(layer_configs) do
		summary.total_layers = summary.total_layers + 1
		summary.layers[layer_name] = {
			module_count = #modules,
			modules = modules,
		}
	end

	return summary
end

-- ============================================================================
-- ENVIRONMENT DETECTION UTILITIES
-- ============================================================================

-- Detect environment from various sources
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

	-- Check for systemd environment
	if os.getenv("SYSTEMD_EXEC_PID") then
		return "systemd"
	end

	-- Check for development indicators
	if lfs.attributes("./prosody.cfg.lua") or os.getenv("PROSODY_DEV") then
		return "development"
	end

	-- Default to production
	return "production"
end

-- ============================================================================
-- CONFIGURATION TESTING UTILITIES
-- ============================================================================

-- Test configuration loading without applying
function config_loader.test_config(config_path)
	local test_results = {
		success = true,
		errors = {},
		warnings = {},
		layer_info = {},
	}

	-- Test layer loading
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
		local layer_path = config_path .. "/stack/" .. layer

		if lfs.attributes(layer_path) then
			test_results.layer_info[layer] = { loaded = true, files = {} }

			-- Test each file in the layer
			for file in lfs.dir(layer_path) do
				if file:match("%.cfg%.lua$") then
					local file_path = layer_path .. "/" .. file

					-- Try to load the file in a protected environment
					local chunk, err = loadfile(file_path)
					if chunk then
						test_results.layer_info[layer].files[file] = "OK"
					else
						test_results.layer_info[layer].files[file] = "ERROR: " .. err
						test_results.success = false
						table.insert(test_results.errors, layer .. "/" .. file .. ": " .. err)
					end
				end
			end
		else
			test_results.layer_info[layer] = { loaded = false }
			table.insert(test_results.warnings, "Layer directory missing: " .. layer)
		end
	end

	return test_results
end

-- ============================================================================
-- BACKUP AND MIGRATION UTILITIES
-- ============================================================================

-- Create configuration backup
function config_loader.backup_config(config_path, backup_path)
	local backup_info = {
		timestamp = os.date("%Y%m%d_%H%M%S"),
		success = true,
		files_backed_up = 0,
		errors = {},
	}

	-- Create backup directory
	local backup_dir = backup_path .. "/prosody_config_" .. backup_info.timestamp
	local success, err = lfs.mkdir(backup_dir)

	if not success then
		backup_info.success = false
		table.insert(backup_info.errors, "Failed to create backup directory: " .. err)
		return backup_info
	end

	-- Backup function
	local function backup_file(source, dest)
		local source_file = io.open(source, "rb")
		if not source_file then
			return false, "Cannot open source file"
		end

		local dest_file = io.open(dest, "wb")
		if not dest_file then
			source_file:close()
			return false, "Cannot create destination file"
		end

		local content = source_file:read("*all")
		dest_file:write(content)

		source_file:close()
		dest_file:close()

		return true
	end

	-- Backup all configuration files
	local function backup_directory(source_dir, dest_dir)
		lfs.mkdir(dest_dir)

		for file in lfs.dir(source_dir) do
			if file ~= "." and file ~= ".." then
				local source_path = source_dir .. "/" .. file
				local dest_path = dest_dir .. "/" .. file
				local attr = lfs.attributes(source_path)

				if attr.mode == "directory" then
					backup_directory(source_path, dest_path)
				elseif attr.mode == "file" and file:match("%.cfg%.lua$") then
					local success, err = backup_file(source_path, dest_path)
					if success then
						backup_info.files_backed_up = backup_info.files_backed_up + 1
					else
						table.insert(backup_info.errors, "Failed to backup " .. source_path .. ": " .. err)
					end
				end
			end
		end
	end

	backup_directory(config_path, backup_dir)
	backup_info.backup_path = backup_dir

	return backup_info
end

-- ============================================================================
-- DEBUGGING UTILITIES
-- ============================================================================

-- Print configuration debug information
function config_loader.debug_info(all_modules, layer_configs)
	print("=== PROSODY LAYER-BASED CONFIGURATION DEBUG ===")
	print("Total modules loaded: " .. #all_modules)
	print("Total layers: " .. (layer_configs and table.getn(layer_configs) or 0))
	print()

	if layer_configs then
		for layer_name, modules in pairs(layer_configs) do
			print("Layer: " .. layer_name)
			print("  Modules (" .. #modules .. "): " .. table.concat(modules, ", "))
			print()
		end
	end

	-- Check for potential issues
	local conflicts = config_loader.check_module_conflicts(all_modules)
	if #conflicts > 0 then
		print("=== POTENTIAL ISSUES ===")
		for _, conflict in ipairs(conflicts) do
			if conflict.type == "duplicate" then
				print("DUPLICATE: " .. conflict.module .. " (appears " .. conflict.count .. " times)")
			elseif conflict.type == "incompatible" then
				print("INCOMPATIBLE: " .. table.concat(conflict.modules, " + "))
			end
		end
		print()
	end

	print("=== END DEBUG INFO ===")
end

-- ============================================================================
-- EXPORT UTILITIES
-- ============================================================================

return config_loader
