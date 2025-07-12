-- ============================================================================
-- PROSODY CONFIGURATION DIAGNOSTICS
-- ============================================================================
-- Provides comprehensive diagnostics for configuration issues and optimization
-- Includes performance analysis and troubleshooting capabilities

local lfs = require("lfs")
local diagnostics = {}

-- ============================================================================
-- DIAGNOSTIC FUNCTIONS
-- ============================================================================

-- Run comprehensive configuration diagnostics
function diagnostics.run_full_diagnostics(config_path)
	local results = {
		timestamp = os.date("%Y-%m-%d %H:%M:%S"),
		config_path = config_path,
		checks = {},
	}

	-- Configuration structure checks
	results.checks.structure = diagnostics.check_structure(config_path)

	-- Module analysis
	results.checks.modules = diagnostics.analyze_modules(config_path)

	-- Performance analysis
	results.checks.performance = diagnostics.analyze_performance(config_path)

	-- Security analysis
	results.checks.security = diagnostics.analyze_security(config_path)

	-- Resource usage analysis
	results.checks.resources = diagnostics.analyze_resources(config_path)

	-- Compatibility checks
	results.checks.compatibility = diagnostics.check_compatibility(config_path)

	-- Generate overall health score
	results.health_score = diagnostics.calculate_health_score(results.checks)

	return results
end

-- Check configuration structure integrity
function diagnostics.check_structure(config_path)
	local structure_check = {
		passed = true,
		issues = {},
		recommendations = {},
	}

	-- Check required directories exist
	local required_dirs = {
		"stack",
		"domains",
		"environments",
		"policies",
		"tools",
	}

	for _, dir in ipairs(required_dirs) do
		local dir_path = config_path .. "/" .. dir
		if not lfs.attributes(dir_path) then
			structure_check.passed = false
			table.insert(structure_check.issues, "Missing directory: " .. dir)
			table.insert(structure_check.recommendations, "Create missing directory: " .. dir_path)
		end
	end

	-- Check layer structure
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
		if not lfs.attributes(layer_path) then
			structure_check.passed = false
			table.insert(structure_check.issues, "Missing layer: " .. layer)
		end
	end

	return structure_check
end

-- Analyze module configuration
function diagnostics.analyze_modules(config_path)
	local module_analysis = {
		total_modules = 0,
		enabled_modules = {},
		disabled_modules = {},
		conflicts = {},
		missing_dependencies = {},
		recommendations = {},
	}

	-- Scan all configuration files for modules
	local all_modules = diagnostics.scan_all_modules(config_path)
	module_analysis.total_modules = #all_modules
	module_analysis.enabled_modules = all_modules

	-- Check for common issues
	local common_modules = {
		"roster",
		"saslauth",
		"tls",
		"dialback",
		"disco",
		"caps",
		"vcard",
		"private",
		"blocklist",
	}

	for _, module in ipairs(common_modules) do
		if not diagnostics.table_contains(all_modules, module) then
			table.insert(module_analysis.recommendations, "Consider enabling common module: " .. module)
		end
	end

	-- Check for mobile optimization
	local mobile_modules = { "smacks", "csi", "carbons" }
	local mobile_count = 0
	for _, module in ipairs(mobile_modules) do
		if diagnostics.table_contains(all_modules, module) then
			mobile_count = mobile_count + 1
		end
	end

	if mobile_count > 0 and mobile_count < #mobile_modules then
		table.insert(module_analysis.recommendations, "Enable complete mobile optimization stack")
	end

	return module_analysis
end

-- Analyze performance configuration
function diagnostics.analyze_performance(config_path)
	local performance_analysis = {
		score = 0,
		issues = {},
		optimizations = {},
	}

	-- Check for performance-critical settings
	local config = diagnostics.load_merged_config(config_path)

	-- Connection limits
	if not config.max_clients or config.max_clients > 10000 then
		table.insert(performance_analysis.issues, "Very high or unlimited client connections")
		table.insert(performance_analysis.optimizations, "Set reasonable max_clients limit (1000-5000)")
	end

	-- Timeout settings
	if not config.c2s_timeout or config.c2s_timeout > 300 then
		table.insert(performance_analysis.issues, "High client timeout may waste resources")
		table.insert(performance_analysis.optimizations, "Consider reducing c2s_timeout to 180-300 seconds")
	end

	-- Logging level
	if config.log_level == "debug" then
		table.insert(performance_analysis.issues, "Debug logging enabled (performance impact)")
		table.insert(performance_analysis.optimizations, "Set log_level to 'info' for production")
	end

	-- Storage backend
	if config.storage == "internal" then
		table.insert(performance_analysis.optimizations, "Consider SQL storage backend for better performance")
	end

	-- Calculate performance score (0-100)
	local total_checks = 4
	local passed_checks = total_checks - #performance_analysis.issues
	performance_analysis.score = math.floor((passed_checks / total_checks) * 100)

	return performance_analysis
end

-- Analyze security configuration
function diagnostics.analyze_security(config_path)
	local security_analysis = {
		score = 0,
		vulnerabilities = {},
		recommendations = {},
	}

	local config = diagnostics.load_merged_config(config_path)

	-- Encryption requirements
	if not config.c2s_require_encryption then
		table.insert(security_analysis.vulnerabilities, "Client connections do not require encryption")
		table.insert(security_analysis.recommendations, "Set c2s_require_encryption = true")
	end

	if not config.s2s_require_encryption then
		table.insert(security_analysis.vulnerabilities, "Server connections do not require encryption")
		table.insert(security_analysis.recommendations, "Set s2s_require_encryption = true")
	end

	-- TLS configuration
	if not config.ssl_protocols or diagnostics.table_contains(config.ssl_protocols, "tlsv1") then
		table.insert(security_analysis.vulnerabilities, "Weak TLS protocols enabled")
		table.insert(security_analysis.recommendations, "Disable TLS 1.0 and 1.1, use only TLS 1.2+")
	end

	-- Registration security
	if config.allow_registration and not config.registration_whitelist then
		table.insert(security_analysis.vulnerabilities, "Open registration without restrictions")
		table.insert(security_analysis.recommendations, "Enable registration whitelist or captcha")
	end

	-- Admin access
	if not config.admins or #config.admins == 0 then
		table.insert(security_analysis.vulnerabilities, "No administrators configured")
		table.insert(security_analysis.recommendations, "Configure at least one administrator account")
	end

	-- Calculate security score
	local total_checks = 5
	local passed_checks = total_checks - #security_analysis.vulnerabilities
	security_analysis.score = math.floor((passed_checks / total_checks) * 100)

	return security_analysis
end

-- Analyze resource usage patterns
function diagnostics.analyze_resources(config_path)
	local resource_analysis = {
		memory_estimate = 0,
		cpu_estimate = "low",
		disk_usage = {},
		recommendations = {},
	}

	-- Estimate memory usage based on enabled modules
	local modules = diagnostics.scan_all_modules(config_path)
	local base_memory = 50 -- MB base usage

	local memory_intensive_modules = {
		["mam"] = 20,
		["muc"] = 15,
		["http_upload"] = 10,
		["pubsub"] = 10,
		["pep"] = 8,
	}

	for _, module in ipairs(modules) do
		if memory_intensive_modules[module] then
			base_memory = base_memory + memory_intensive_modules[module]
		else
			base_memory = base_memory + 2 -- Average module overhead
		end
	end

	resource_analysis.memory_estimate = base_memory

	-- CPU usage estimation
	local cpu_intensive_modules = { "firewall", "spam_reporting", "mam", "http_upload" }
	local cpu_modules_count = 0

	for _, module in ipairs(modules) do
		if diagnostics.table_contains(cpu_intensive_modules, module) then
			cpu_modules_count = cpu_modules_count + 1
		end
	end

	if cpu_modules_count > 3 then
		resource_analysis.cpu_estimate = "high"
	elseif cpu_modules_count > 1 then
		resource_analysis.cpu_estimate = "medium"
	end

	-- Disk usage recommendations
	if diagnostics.table_contains(modules, "mam") then
		table.insert(
			resource_analysis.recommendations,
			"Configure message archive retention policy to manage disk usage"
		)
	end

	if diagnostics.table_contains(modules, "http_upload") then
		table.insert(resource_analysis.recommendations, "Set file upload size limits and cleanup policies")
	end

	return resource_analysis
end

-- Check compatibility with different clients and environments
function diagnostics.check_compatibility(config_path)
	local compatibility = {
		client_support = {},
		environment_readiness = {},
		warnings = {},
	}

	local modules = diagnostics.scan_all_modules(config_path)

	-- Mobile client compatibility
	local mobile_features = { "smacks", "csi", "carbons", "mam" }
	local mobile_support = 0
	for _, feature in ipairs(mobile_features) do
		if diagnostics.table_contains(modules, feature) then
			mobile_support = mobile_support + 1
		end
	end
	compatibility.client_support.mobile = math.floor((mobile_support / #mobile_features) * 100)

	-- Web client compatibility
	local web_features = { "bosh", "websocket", "http_upload" }
	local web_support = 0
	for _, feature in ipairs(web_features) do
		if diagnostics.table_contains(modules, feature) then
			web_support = web_support + 1
		end
	end
	compatibility.client_support.web = math.floor((web_support / #web_features) * 100)

	-- Desktop client compatibility
	local desktop_features = { "carbons", "mam", "vcard", "roster" }
	local desktop_support = 0
	for _, feature in ipairs(desktop_features) do
		if diagnostics.table_contains(modules, feature) then
			desktop_support = desktop_support + 1
		end
	end
	compatibility.client_support.desktop = math.floor((desktop_support / #desktop_features) * 100)

	return compatibility
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Scan all modules from configuration files
function diagnostics.scan_all_modules(config_path)
	local all_modules = {}
	local seen_modules = {}

	-- Recursively scan configuration files
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
				elseif file:match("%.cfg%.lua$") then
					local success, config = pcall(dofile, file_path)
					if success and config and config.modules_enabled then
						for _, module in ipairs(config.modules_enabled) do
							if not seen_modules[module] then
								table.insert(all_modules, module)
								seen_modules[module] = true
							end
						end
					end
				end
			end
		end
	end

	scan_directory(config_path)
	return all_modules
end

-- Load merged configuration (simplified)
function diagnostics.load_merged_config(config_path)
	local merged = {}

	-- This is a simplified version - in practice, would use the merger tool
	local main_config_path = config_path .. "/../prosody.cfg.lua"
	if lfs.attributes(main_config_path) then
		local success, config = pcall(dofile, main_config_path)
		if success and config then
			merged = config
		end
	end

	return merged
end

-- Check if table contains value
function diagnostics.table_contains(table, value)
	for _, v in ipairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

-- Calculate overall health score
function diagnostics.calculate_health_score(checks)
	local scores = {}

	if checks.structure and checks.structure.passed then
		table.insert(scores, 100)
	else
		table.insert(scores, 0)
	end

	if checks.performance and checks.performance.score then
		table.insert(scores, checks.performance.score)
	end

	if checks.security and checks.security.score then
		table.insert(scores, checks.security.score)
	end

	-- Calculate average
	local total = 0
	for _, score in ipairs(scores) do
		total = total + score
	end

	return math.floor(total / #scores)
end

-- Generate diagnostic report
function diagnostics.generate_report(diagnostic_results)
	local report = {}

	table.insert(report, "=== PROSODY CONFIGURATION DIAGNOSTIC REPORT ===")
	table.insert(report, "")
	table.insert(report, "Timestamp: " .. diagnostic_results.timestamp)
	table.insert(report, "Configuration Path: " .. diagnostic_results.config_path)
	table.insert(report, "Overall Health Score: " .. diagnostic_results.health_score .. "/100")
	table.insert(report, "")

	-- Structure check
	if diagnostic_results.checks.structure then
		table.insert(report, "STRUCTURE CHECK:")
		if diagnostic_results.checks.structure.passed then
			table.insert(report, "  ✅ Configuration structure is valid")
		else
			table.insert(report, "  ❌ Structure issues found:")
			for _, issue in ipairs(diagnostic_results.checks.structure.issues) do
				table.insert(report, "    - " .. issue)
			end
		end
		table.insert(report, "")
	end

	-- Module analysis
	if diagnostic_results.checks.modules then
		local modules = diagnostic_results.checks.modules
		table.insert(report, "MODULE ANALYSIS:")
		table.insert(report, "  Total Modules: " .. modules.total_modules)
		if #modules.recommendations > 0 then
			table.insert(report, "  Recommendations:")
			for _, rec in ipairs(modules.recommendations) do
				table.insert(report, "    💡 " .. rec)
			end
		end
		table.insert(report, "")
	end

	-- Performance analysis
	if diagnostic_results.checks.performance then
		local perf = diagnostic_results.checks.performance
		table.insert(report, "PERFORMANCE ANALYSIS:")
		table.insert(report, "  Score: " .. perf.score .. "/100")
		if #perf.issues > 0 then
			table.insert(report, "  Issues:")
			for _, issue in ipairs(perf.issues) do
				table.insert(report, "    ⚠️  " .. issue)
			end
		end
		if #perf.optimizations > 0 then
			table.insert(report, "  Optimizations:")
			for _, opt in ipairs(perf.optimizations) do
				table.insert(report, "    🚀 " .. opt)
			end
		end
		table.insert(report, "")
	end

	-- Security analysis
	if diagnostic_results.checks.security then
		local sec = diagnostic_results.checks.security
		table.insert(report, "SECURITY ANALYSIS:")
		table.insert(report, "  Score: " .. sec.score .. "/100")
		if #sec.vulnerabilities > 0 then
			table.insert(report, "  Vulnerabilities:")
			for _, vuln in ipairs(sec.vulnerabilities) do
				table.insert(report, "    🔓 " .. vuln)
			end
		end
		if #sec.recommendations > 0 then
			table.insert(report, "  Recommendations:")
			for _, rec in ipairs(sec.recommendations) do
				table.insert(report, "    🔒 " .. rec)
			end
		end
		table.insert(report, "")
	end

	-- Resource analysis
	if diagnostic_results.checks.resources then
		local res = diagnostic_results.checks.resources
		table.insert(report, "RESOURCE ANALYSIS:")
		table.insert(report, "  Estimated Memory Usage: " .. res.memory_estimate .. " MB")
		table.insert(report, "  Estimated CPU Usage: " .. res.cpu_estimate)
		if #res.recommendations > 0 then
			table.insert(report, "  Recommendations:")
			for _, rec in ipairs(res.recommendations) do
				table.insert(report, "    📊 " .. rec)
			end
		end
		table.insert(report, "")
	end

	-- Compatibility check
	if diagnostic_results.checks.compatibility then
		local compat = diagnostic_results.checks.compatibility
		table.insert(report, "COMPATIBILITY CHECK:")
		if compat.client_support then
			table.insert(report, "  Client Support:")
			table.insert(report, "    Mobile: " .. compat.client_support.mobile .. "%")
			table.insert(report, "    Web: " .. compat.client_support.web .. "%")
			table.insert(report, "    Desktop: " .. compat.client_support.desktop .. "%")
		end
		table.insert(report, "")
	end

	table.insert(report, "=== END OF DIAGNOSTIC REPORT ===")

	return table.concat(report, "\n")
end

return diagnostics
