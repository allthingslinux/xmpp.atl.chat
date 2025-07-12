-- ============================================================================
-- PROSODY CONFIGURATION MIGRATOR
-- ============================================================================
-- Handles migration between different configuration versions and structures
-- Supports upgrading from old modular system to layer-based system

local lfs = require("lfs")
local migrator = {}

-- ============================================================================
-- MIGRATION FUNCTIONS
-- ============================================================================

-- Migrate from old modular structure to layer-based structure
function migrator.migrate_modular_to_layers(old_config_path, new_config_path)
	local migration_log = {}

	table.insert(migration_log, "Starting migration from modular to layer-based structure...")

	-- Map old module categories to new layers
	local category_to_layer = {
		["core"] = "04-protocol",
		["stable"] = { "05-services", "07-interfaces" },
		["beta"] = { "06-storage", "08-integration" },
		["alpha"] = "08-integration",
		["community"] = { "05-services", "07-interfaces" },
	}

	-- Read old configuration structure
	local old_modules = migrator.read_old_modular_config(old_config_path .. "/modules.d")

	-- Migrate modules to appropriate layers
	for category, modules in pairs(old_modules) do
		local target_layers = category_to_layer[category] or { "05-services" }
		if type(target_layers) == "string" then
			target_layers = { target_layers }
		end

		for _, layer in ipairs(target_layers) do
			migrator.add_modules_to_layer(new_config_path, layer, modules, category)
			table.insert(migration_log, "Migrated " .. #modules .. " modules from " .. category .. " to " .. layer)
		end
	end

	-- Migrate global settings
	migrator.migrate_global_settings(old_config_path, new_config_path)
	table.insert(migration_log, "Migrated global settings")

	-- Migrate security settings
	migrator.migrate_security_settings(old_config_path, new_config_path)
	table.insert(migration_log, "Migrated security settings")

	-- Migrate database settings
	migrator.migrate_database_settings(old_config_path, new_config_path)
	table.insert(migration_log, "Migrated database settings")

	table.insert(migration_log, "Migration completed successfully")
	return migration_log
end

-- Read old modular configuration
function migrator.read_old_modular_config(modules_d_path)
	local modules = {}

	if not lfs.attributes(modules_d_path) then
		return modules
	end

	-- Read core modules
	local core_path = modules_d_path .. "/core"
	if lfs.attributes(core_path) then
		modules.core = migrator.extract_modules_from_directory(core_path)
	end

	-- Read community modules
	local community_path = modules_d_path .. "/community"
	if lfs.attributes(community_path) then
		modules.stable = migrator.extract_modules_from_directory(community_path .. "/stable")
		modules.beta = migrator.extract_modules_from_directory(community_path .. "/beta")
		modules.alpha = migrator.extract_modules_from_directory(community_path .. "/alpha")
	end

	return modules
end

-- Extract modules from configuration files in directory
function migrator.extract_modules_from_directory(dir_path)
	local modules = {}

	if not lfs.attributes(dir_path) then
		return modules
	end

	for file in lfs.dir(dir_path) do
		if file:match("%.cfg%.lua$") then
			local file_path = dir_path .. "/" .. file
			local success, config = pcall(dofile, file_path)
			if success and config and config.modules_enabled then
				for _, module in ipairs(config.modules_enabled) do
					table.insert(modules, module)
				end
			end
		end
	end

	return modules
end

-- Add modules to specific layer
function migrator.add_modules_to_layer(config_path, layer, modules, source_category)
	local layer_path = config_path .. "/stack/" .. layer

	-- Determine appropriate file within layer based on module type
	local file_mapping = {
		["01-transport"] = "connections.cfg.lua",
		["02-stream"] = "management.cfg.lua",
		["03-stanza"] = "processing.cfg.lua",
		["04-protocol"] = "extensions.cfg.lua",
		["05-services"] = "messaging.cfg.lua",
		["06-storage"] = "backends.cfg.lua",
		["07-interfaces"] = "http.cfg.lua",
		["08-integration"] = "apis.cfg.lua",
	}

	local target_file = layer_path .. "/" .. file_mapping[layer]

	-- Create migration comment block
	local migration_block = {
		"",
		"-- ============================================================================",
		"-- MIGRATED FROM " .. string.upper(source_category) .. " CATEGORY",
		"-- ============================================================================",
		"-- Modules migrated from old modular structure",
		"",
	}

	-- Add modules to migration block
	table.insert(migration_block, "-- Migrated modules:")
	for _, module in ipairs(modules) do
		table.insert(migration_block, "-- - " .. module)
	end
	table.insert(migration_block, "")

	-- Add modules to enabled list
	table.insert(migration_block, "-- Add migrated modules to existing list")
	table.insert(migration_block, "local migrated_modules = {")
	for _, module in ipairs(modules) do
		table.insert(migration_block, '    "' .. module .. '",')
	end
	table.insert(migration_block, "}")
	table.insert(migration_block, "")
	table.insert(migration_block, "-- Merge with existing modules")
	table.insert(migration_block, "for _, module in ipairs(migrated_modules) do")
	table.insert(migration_block, "    table.insert(modules_enabled, module)")
	table.insert(migration_block, "end")
	table.insert(migration_block, "")

	-- Append to target file
	local file = io.open(target_file, "a")
	if file then
		file:write(table.concat(migration_block, "\n"))
		file:close()
	end
end

-- Migrate global settings
function migrator.migrate_global_settings(old_path, new_path)
	local old_global = old_path .. "/global.cfg.lua"
	if lfs.attributes(old_global) then
		local success, config = pcall(dofile, old_global)
		if success and config then
			-- Migrate to appropriate layer files
			migrator.migrate_to_transport_layer(new_path, config)
			migrator.migrate_to_protocol_layer(new_path, config)
		end
	end
end

-- Migrate security settings
function migrator.migrate_security_settings(old_path, new_path)
	local old_security = old_path .. "/security.cfg.lua"
	if lfs.attributes(old_security) then
		local success, config = pcall(dofile, old_security)
		if success and config then
			-- Create security policy file
			local policy_path = new_path .. "/policies/security/migrated.cfg.lua"
			migrator.create_security_policy_from_config(policy_path, config)
		end
	end
end

-- Migrate database settings
function migrator.migrate_database_settings(old_path, new_path)
	local old_database = old_path .. "/database.cfg.lua"
	if lfs.attributes(old_database) then
		local success, config = pcall(dofile, old_database)
		if success and config then
			-- Migrate to storage layer
			local storage_path = new_path .. "/stack/06-storage/backends.cfg.lua"
			migrator.append_database_config(storage_path, config)
		end
	end
end

-- ============================================================================
-- VERSION MIGRATION
-- ============================================================================

-- Migrate configuration to newer version
function migrator.migrate_version(from_version, to_version, config_path)
	local migration_log = {}

	table.insert(migration_log, "Migrating from version " .. from_version .. " to " .. to_version)

	-- Version-specific migrations
	if from_version == "1.0" and to_version == "2.0" then
		migrator.migrate_1_0_to_2_0(config_path, migration_log)
	elseif from_version == "2.0" and to_version == "3.0" then
		migrator.migrate_2_0_to_3_0(config_path, migration_log)
	end

	-- Update version file
	migrator.update_version_file(config_path, to_version)
	table.insert(migration_log, "Updated version to " .. to_version)

	return migration_log
end

-- Migrate from version 1.0 to 2.0
function migrator.migrate_1_0_to_2_0(config_path, log)
	-- Example: Add new security features
	table.insert(log, "Adding new security features for v2.0")

	-- Add new modules to security layer
	local security_modules = { "firewall", "blocklist", "spam_reporting" }
	migrator.add_modules_to_layer(config_path, "03-stanza", security_modules, "security_v2")
end

-- Migrate from version 2.0 to 3.0
function migrator.migrate_2_0_to_3_0(config_path, log)
	-- Example: Add mobile optimization features
	table.insert(log, "Adding mobile optimization features for v3.0")

	-- Add mobile modules
	local mobile_modules = { "smacks", "csi", "cloud_notify" }
	migrator.add_modules_to_layer(config_path, "05-services", mobile_modules, "mobile_v3")
end

-- ============================================================================
-- BACKUP AND RESTORE
-- ============================================================================

-- Create backup of current configuration
function migrator.create_backup(config_path, backup_name)
	local backup_path = config_path .. "/../backups/" .. backup_name

	-- Create backup directory
	os.execute("mkdir -p " .. backup_path)

	-- Copy configuration files
	os.execute("cp -r " .. config_path .. "/* " .. backup_path .. "/")

	-- Create backup metadata
	local metadata = {
		backup_date = os.date("%Y-%m-%d %H:%M:%S"),
		original_path = config_path,
		backup_name = backup_name,
	}

	local metadata_file = io.open(backup_path .. "/backup_metadata.lua", "w")
	if metadata_file then
		metadata_file:write("return " .. migrator.serialize_table(metadata))
		metadata_file:close()
	end

	return backup_path
end

-- Restore configuration from backup
function migrator.restore_backup(backup_path, target_path)
	-- Verify backup exists
	if not lfs.attributes(backup_path) then
		error("Backup not found: " .. backup_path)
	end

	-- Create target directory
	os.execute("mkdir -p " .. target_path)

	-- Restore files
	os.execute("cp -r " .. backup_path .. "/* " .. target_path .. "/")

	-- Remove backup metadata from restored config
	os.remove(target_path .. "/backup_metadata.lua")

	return true
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Serialize table to string
function migrator.serialize_table(t, indent)
	indent = indent or 0
	local result = "{\n"

	for k, v in pairs(t) do
		result = result .. string.rep("  ", indent + 1)

		if type(k) == "string" then
			result = result .. '["' .. k .. '"] = '
		else
			result = result .. "[" .. k .. "] = "
		end

		if type(v) == "table" then
			result = result .. migrator.serialize_table(v, indent + 1)
		elseif type(v) == "string" then
			result = result .. '"' .. v .. '"'
		else
			result = result .. tostring(v)
		end

		result = result .. ",\n"
	end

	result = result .. string.rep("  ", indent) .. "}"
	return result
end

-- Update version file
function migrator.update_version_file(config_path, version)
	local version_file = io.open(config_path .. "/VERSION", "w")
	if version_file then
		version_file:write(version)
		version_file:close()
	end
end

-- Generate migration report
function migrator.generate_migration_report(migration_log, backup_path)
	local report = {}

	table.insert(report, "=== CONFIGURATION MIGRATION REPORT ===")
	table.insert(report, "")
	table.insert(report, "Migration Date: " .. os.date("%Y-%m-%d %H:%M:%S"))
	if backup_path then
		table.insert(report, "Backup Created: " .. backup_path)
	end
	table.insert(report, "")

	table.insert(report, "Migration Steps:")
	for i, step in ipairs(migration_log) do
		table.insert(report, "  " .. i .. ". " .. step)
	end
	table.insert(report, "")

	table.insert(report, "✅ Migration completed successfully")
	table.insert(report, "")
	table.insert(report, "Next Steps:")
	table.insert(report, "1. Review migrated configuration files")
	table.insert(report, "2. Test configuration with 'prosodyctl check config'")
	table.insert(report, "3. Restart Prosody service")

	return table.concat(report, "\n")
end

return migrator
