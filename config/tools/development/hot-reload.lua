-- ============================================================================
-- PROSODY HOT RELOAD UTILITY
-- ============================================================================
-- Enables hot reloading of configuration files during development
-- Monitors file changes and automatically reloads affected modules

local lfs = require("lfs")
local hot_reload = {}

-- ============================================================================
-- HOT RELOAD FUNCTIONS
-- ============================================================================

-- Initialize hot reload monitoring
function hot_reload.initialize(config_path, reload_callback)
	local monitor = {
		config_path = config_path,
		callback = reload_callback or hot_reload.default_reload_callback,
		file_timestamps = {},
		monitoring = false,
	}

	-- Build initial file timestamp cache
	hot_reload.build_timestamp_cache(monitor)

	return monitor
end

-- Start monitoring for file changes
function hot_reload.start_monitoring(monitor, interval)
	interval = interval or 2 -- Check every 2 seconds
	monitor.monitoring = true

	-- Start monitoring loop
	while monitor.monitoring do
		hot_reload.check_for_changes(monitor)
		os.execute("sleep " .. interval)
	end
end

-- Stop monitoring
function hot_reload.stop_monitoring(monitor)
	monitor.monitoring = false
end

-- Check for file changes
function hot_reload.check_for_changes(monitor)
	local changes = {}

	-- Check all monitored files
	for file_path, old_timestamp in pairs(monitor.file_timestamps) do
		local attr = lfs.attributes(file_path)
		if attr then
			local new_timestamp = attr.modification
			if new_timestamp > old_timestamp then
				table.insert(changes, {
					file = file_path,
					old_timestamp = old_timestamp,
					new_timestamp = new_timestamp,
				})
				monitor.file_timestamps[file_path] = new_timestamp
			end
		else
			-- File was deleted
			table.insert(changes, {
				file = file_path,
				deleted = true,
			})
			monitor.file_timestamps[file_path] = nil
		end
	end

	-- Check for new files
	hot_reload.scan_for_new_files(monitor, changes)

	-- Process changes if any
	if #changes > 0 then
		monitor.callback(changes, monitor)
	end
end

-- Build timestamp cache for all configuration files
function hot_reload.build_timestamp_cache(monitor)
	monitor.file_timestamps = {}

	local function scan_directory(dir_path)
		if not lfs.attributes(dir_path) then
			return
		end

		for file in lfs.dir(dir_path) do
			if file ~= "." and file ~= ".." then
				local file_path = dir_path .. "/" .. file
				local attr = lfs.attributes(file_path)

				if attr.mode == "directory" then
					scan_directory(file_path)
				elseif file:match("%.cfg%.lua$") or file:match("%.lua$") then
					monitor.file_timestamps[file_path] = attr.modification
				end
			end
		end
	end

	scan_directory(monitor.config_path)
end

-- Scan for new files
function hot_reload.scan_for_new_files(monitor, changes)
	local function scan_directory(dir_path)
		if not lfs.attributes(dir_path) then
			return
		end

		for file in lfs.dir(dir_path) do
			if file ~= "." and file ~= ".." then
				local file_path = dir_path .. "/" .. file
				local attr = lfs.attributes(file_path)

				if attr.mode == "directory" then
					scan_directory(file_path)
				elseif
					(file:match("%.cfg%.lua$") or file:match("%.lua$")) and not monitor.file_timestamps[file_path]
				then
					-- New file found
					table.insert(changes, {
						file = file_path,
						new_file = true,
						new_timestamp = attr.modification,
					})
					monitor.file_timestamps[file_path] = attr.modification
				end
			end
		end
	end

	scan_directory(monitor.config_path)
end

-- Default reload callback
function hot_reload.default_reload_callback(changes, monitor)
	print("Configuration changes detected:")

	for _, change in ipairs(changes) do
		if change.deleted then
			print("  🗑️  Deleted: " .. change.file)
		elseif change.new_file then
			print("  ➕ New: " .. change.file)
		else
			print("  📝 Modified: " .. change.file)
		end
	end

	-- Determine what needs to be reloaded
	local reload_actions = hot_reload.determine_reload_actions(changes)

	for _, action in ipairs(reload_actions) do
		print("  🔄 " .. action.description)
		if action.command then
			os.execute(action.command)
		end
	end
end

-- Determine what needs to be reloaded based on changes
function hot_reload.determine_reload_actions(changes)
	local actions = {}
	local affected_layers = {}
	local affected_domains = {}
	local affected_policies = {}

	for _, change in ipairs(changes) do
		local file_path = change.file

		-- Categorize the change
		if file_path:match("/stack/") then
			local layer = file_path:match("/stack/([^/]+)/")
			if layer then
				affected_layers[layer] = true
			end
		elseif file_path:match("/domains/") then
			local domain = file_path:match("/domains/([^/]+)/")
			if domain then
				affected_domains[domain] = true
			end
		elseif file_path:match("/policies/") then
			local policy_type = file_path:match("/policies/([^/]+)/")
			if policy_type then
				affected_policies[policy_type] = true
			end
		elseif file_path:match("prosody%.cfg%.lua$") then
			table.insert(actions, {
				description = "Reload main configuration",
				command = "prosodyctl reload",
			})
		end
	end

	-- Generate layer-specific reload actions
	for layer, _ in pairs(affected_layers) do
		table.insert(actions, {
			description = "Reload layer: " .. layer,
			command = "prosodyctl reload-layer " .. layer,
		})
	end

	-- Generate domain-specific reload actions
	for domain, _ in pairs(affected_domains) do
		table.insert(actions, {
			description = "Reload domain: " .. domain,
			command = "prosodyctl reload-domain " .. domain,
		})
	end

	-- Generate policy-specific reload actions
	for policy_type, _ in pairs(affected_policies) do
		table.insert(actions, {
			description = "Reload policy: " .. policy_type,
			command = "prosodyctl reload-policy " .. policy_type,
		})
	end

	return actions
end

-- ============================================================================
-- DEVELOPMENT UTILITIES
-- ============================================================================

-- Validate configuration before reload
function hot_reload.validate_before_reload(file_path)
	local success, error_msg = pcall(loadfile, file_path)
	if not success then
		print("❌ Syntax error in " .. file_path .. ": " .. error_msg)
		return false
	end

	-- Additional validation can be added here
	return true
end

-- Create development-friendly reload callback
function hot_reload.create_dev_callback(options)
	options = options or {}

	return function(changes, monitor)
		print("\n" .. os.date("%H:%M:%S") .. " - Configuration changes detected:")

		local valid_changes = {}

		for _, change in ipairs(changes) do
			if change.deleted then
				print("  🗑️  Deleted: " .. change.file)
				table.insert(valid_changes, change)
			elseif change.new_file then
				print("  ➕ New: " .. change.file)
				if hot_reload.validate_before_reload(change.file) then
					table.insert(valid_changes, change)
				end
			else
				print("  📝 Modified: " .. change.file)
				if hot_reload.validate_before_reload(change.file) then
					table.insert(valid_changes, change)
				end
			end
		end

		if #valid_changes > 0 then
			if options.auto_reload then
				local actions = hot_reload.determine_reload_actions(valid_changes)
				for _, action in ipairs(actions) do
					print("  🔄 " .. action.description)
					if action.command and not options.dry_run then
						local result = os.execute(action.command)
						if result == 0 then
							print("    ✅ Success")
						else
							print("    ❌ Failed")
						end
					end
				end
			else
				print("  💡 Run 'prosodyctl reload' to apply changes")
			end
		end

		if options.show_stats then
			hot_reload.show_monitoring_stats(monitor)
		end
	end
end

-- Show monitoring statistics
function hot_reload.show_monitoring_stats(monitor)
	local file_count = 0
	for _ in pairs(monitor.file_timestamps) do
		file_count = file_count + 1
	end

	print("  📊 Monitoring " .. file_count .. " files in " .. monitor.config_path)
end

-- ============================================================================
-- CONFIGURATION TESTING
-- ============================================================================

-- Test configuration changes in isolation
function hot_reload.test_config_change(file_path, test_callback)
	print("Testing configuration change: " .. file_path)

	-- Validate syntax
	if not hot_reload.validate_before_reload(file_path) then
		return false
	end

	-- Run custom test if provided
	if test_callback then
		local success, result = pcall(test_callback, file_path)
		if not success then
			print("❌ Test failed: " .. result)
			return false
		end
	end

	print("✅ Configuration change test passed")
	return true
end

-- Create test environment for configuration changes
function hot_reload.create_test_environment(config_path, test_path)
	-- Copy configuration to test directory
	os.execute("mkdir -p " .. test_path)
	os.execute("cp -r " .. config_path .. "/* " .. test_path .. "/")

	print("Created test environment: " .. test_path)
	return test_path
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Get file extension
function hot_reload.get_file_extension(file_path)
	return file_path:match("^.+%.(.+)$")
end

-- Check if file is a configuration file
function hot_reload.is_config_file(file_path)
	local ext = hot_reload.get_file_extension(file_path)
	return ext == "lua" or file_path:match("%.cfg%.lua$")
end

-- Generate hot reload report
function hot_reload.generate_report(monitor, session_duration)
	local report = {}

	table.insert(report, "=== HOT RELOAD SESSION REPORT ===")
	table.insert(report, "")
	table.insert(report, "Session Duration: " .. session_duration .. " seconds")
	table.insert(report, "Configuration Path: " .. monitor.config_path)

	local file_count = 0
	for _ in pairs(monitor.file_timestamps) do
		file_count = file_count + 1
	end
	table.insert(report, "Files Monitored: " .. file_count)
	table.insert(report, "")

	table.insert(report, "Monitored File Types:")
	table.insert(report, "  - Layer configurations (*.cfg.lua)")
	table.insert(report, "  - Policy files (*.cfg.lua)")
	table.insert(report, "  - Tool scripts (*.lua)")
	table.insert(report, "  - Main configuration (prosody.cfg.lua)")
	table.insert(report, "")

	table.insert(report, "Hot reload features:")
	table.insert(report, "  ✅ Syntax validation before reload")
	table.insert(report, "  ✅ Automatic change detection")
	table.insert(report, "  ✅ Selective module reloading")
	table.insert(report, "  ✅ Development-friendly error reporting")

	return table.concat(report, "\n")
end

return hot_reload
