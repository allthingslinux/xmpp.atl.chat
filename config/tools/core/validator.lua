-- ============================================================================
-- PROSODY CONFIGURATION VALIDATOR
-- ============================================================================
-- Validates configuration files for syntax, module conflicts, and best practices
-- Provides comprehensive validation for the layer-based architecture

local lfs = require("lfs")
local validator = {}

-- ============================================================================
-- VALIDATION FUNCTIONS
-- ============================================================================

-- Validate syntax of all configuration files
function validator.validate_syntax(config_path)
	local errors = {}

	-- Recursively check all .cfg.lua files
	local function check_directory(dir_path)
		for file in lfs.dir(dir_path) do
			if file ~= "." and file ~= ".." then
				local file_path = dir_path .. "/" .. file
				local attr = lfs.attributes(file_path)

				if attr.mode == "directory" then
					check_directory(file_path)
				elseif file:match("%.cfg%.lua$") then
					-- Test syntax by loading file
					local success, error_msg = pcall(loadfile, file_path)
					if not success then
						table.insert(errors, {
							file = file_path,
							type = "syntax_error",
							message = error_msg,
						})
					end
				end
			end
		end
	end

	check_directory(config_path)
	return errors
end

-- Check for module conflicts and incompatibilities
function validator.check_module_conflicts()
	local conflicts = {}
	local all_modules = {}
	local module_sources = {}

	-- Collect all enabled modules from all layers
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
		local layer_path = "config/stack/" .. layer
		if lfs.attributes(layer_path) then
			for file in lfs.dir(layer_path) do
				if file:match("%.cfg%.lua$") then
					local file_path = layer_path .. "/" .. file
					local success, config = pcall(dofile, file_path)
					if success and config and config.modules_enabled then
						for _, module in ipairs(config.modules_enabled) do
							table.insert(all_modules, module)
							module_sources[module] = module_sources[module] or {}
							table.insert(module_sources[module], file_path)
						end
					end
				end
			end
		end
	end

	-- Check for duplicate modules
	for module, sources in pairs(module_sources) do
		if #sources > 1 then
			table.insert(conflicts, {
				type = "duplicate_module",
				module = module,
				sources = sources,
			})
		end
	end

	-- Check for known incompatible modules
	local incompatible_pairs = {
		{ "carbons", "carbon_copy" },
		{ "mam", "mod_archive" },
		{ "smacks", "stream_management" },
		{ "bosh", "http_bind" },
		{ "websocket", "websocket_server" },
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
				type = "incompatible_modules",
				modules = pair,
			})
		end
	end

	return conflicts
end

-- Validate layer structure integrity
function validator.validate_layer_structure()
	local issues = {}
	local required_layers = {
		"01-transport",
		"02-stream",
		"03-stanza",
		"04-protocol",
		"05-services",
		"06-storage",
		"07-interfaces",
		"08-integration",
	}

	local required_files = {
		["01-transport"] = { "ports.cfg.lua", "tls.cfg.lua", "compression.cfg.lua", "connections.cfg.lua" },
		["02-stream"] = { "authentication.cfg.lua", "encryption.cfg.lua", "management.cfg.lua", "negotiation.cfg.lua" },
		["03-stanza"] = { "routing.cfg.lua", "filtering.cfg.lua", "validation.cfg.lua", "processing.cfg.lua" },
		["04-protocol"] = { "core.cfg.lua", "extensions.cfg.lua", "legacy.cfg.lua", "experimental.cfg.lua" },
		["05-services"] = { "messaging.cfg.lua", "presence.cfg.lua", "groupchat.cfg.lua", "pubsub.cfg.lua" },
		["06-storage"] = { "backends.cfg.lua", "archiving.cfg.lua", "caching.cfg.lua", "migration.cfg.lua" },
		["07-interfaces"] = { "http.cfg.lua", "websocket.cfg.lua", "bosh.cfg.lua", "components.cfg.lua" },
		["08-integration"] = { "ldap.cfg.lua", "oauth.cfg.lua", "webhooks.cfg.lua", "apis.cfg.lua" },
	}

	-- Check each layer
	for _, layer in ipairs(required_layers) do
		local layer_path = "config/stack/" .. layer

		if not lfs.attributes(layer_path) then
			table.insert(issues, {
				type = "missing_layer",
				layer = layer,
				path = layer_path,
			})
		else
			-- Check required files in layer
			for _, file in ipairs(required_files[layer]) do
				local file_path = layer_path .. "/" .. file
				if not lfs.attributes(file_path) then
					table.insert(issues, {
						type = "missing_file",
						layer = layer,
						file = file,
						path = file_path,
					})
				end
			end
		end
	end

	return issues
end

-- Validate environment configurations
function validator.validate_environments()
	local issues = {}
	local required_envs = { "local", "docker", "kubernetes", "production" }

	for _, env in ipairs(required_envs) do
		local env_path = "config/environments/" .. env .. ".cfg.lua"
		if not lfs.attributes(env_path) then
			table.insert(issues, {
				type = "missing_environment",
				environment = env,
				path = env_path,
			})
		end
	end

	return issues
end

-- Validate policy configurations
function validator.validate_policies()
	local issues = {}

	-- Check security policies
	local security_levels = { "baseline", "enhanced", "paranoid" }
	for _, level in ipairs(security_levels) do
		local policy_path = "config/policies/security/" .. level .. ".cfg.lua"
		if not lfs.attributes(policy_path) then
			table.insert(issues, {
				type = "missing_security_policy",
				level = level,
				path = policy_path,
			})
		end
	end

	-- Check performance policies
	local performance_tiers = { "small", "medium", "large" }
	for _, tier in ipairs(performance_tiers) do
		local policy_path = "config/policies/performance/" .. tier .. ".cfg.lua"
		if not lfs.attributes(policy_path) then
			table.insert(issues, {
				type = "missing_performance_policy",
				tier = tier,
				path = policy_path,
			})
		end
	end

	-- Check compliance policies
	local compliance_types = { "gdpr", "audit" }
	for _, comp_type in ipairs(compliance_types) do
		local policy_path = "config/policies/compliance/" .. comp_type .. ".cfg.lua"
		if not lfs.attributes(policy_path) then
			table.insert(issues, {
				type = "missing_compliance_policy",
				compliance = comp_type,
				path = policy_path,
			})
		end
	end

	return issues
end

-- Validate domain configurations
function validator.validate_domains()
	local issues = {}
	local domain_types = { "primary", "conference", "upload", "proxy" }

	for _, domain_type in ipairs(domain_types) do
		local domain_path = "config/domains/" .. domain_type .. "/domain.cfg.lua"
		if not lfs.attributes(domain_path) then
			table.insert(issues, {
				type = "missing_domain",
				domain_type = domain_type,
				path = domain_path,
			})
		end
	end

	return issues
end

-- Run comprehensive validation
function validator.validate_all()
	local results = {
		syntax_errors = validator.validate_syntax("config"),
		module_conflicts = validator.check_module_conflicts(),
		layer_issues = validator.validate_layer_structure(),
		environment_issues = validator.validate_environments(),
		policy_issues = validator.validate_policies(),
		domain_issues = validator.validate_domains(),
	}

	-- Calculate summary
	local total_issues = 0
	for _, category in pairs(results) do
		total_issues = total_issues + #category
	end

	results.summary = {
		total_issues = total_issues,
		has_errors = total_issues > 0,
	}

	return results
end

-- Generate validation report
function validator.generate_report(validation_results)
	local report = {}

	table.insert(report, "=== PROSODY CONFIGURATION VALIDATION REPORT ===")
	table.insert(report, "")
	table.insert(report, "Total Issues Found: " .. validation_results.summary.total_issues)
	table.insert(report, "")

	-- Syntax errors
	if #validation_results.syntax_errors > 0 then
		table.insert(report, "SYNTAX ERRORS:")
		for _, error in ipairs(validation_results.syntax_errors) do
			table.insert(report, "  ❌ " .. error.file .. ": " .. error.message)
		end
		table.insert(report, "")
	end

	-- Module conflicts
	if #validation_results.module_conflicts > 0 then
		table.insert(report, "MODULE CONFLICTS:")
		for _, conflict in ipairs(validation_results.module_conflicts) do
			if conflict.type == "duplicate_module" then
				table.insert(report, "  ⚠️  Duplicate module '" .. conflict.module .. "' found in:")
				for _, source in ipairs(conflict.sources) do
					table.insert(report, "     - " .. source)
				end
			elseif conflict.type == "incompatible_modules" then
				table.insert(report, "  ❌ Incompatible modules: " .. table.concat(conflict.modules, ", "))
			end
		end
		table.insert(report, "")
	end

	-- Layer structure issues
	if #validation_results.layer_issues > 0 then
		table.insert(report, "LAYER STRUCTURE ISSUES:")
		for _, issue in ipairs(validation_results.layer_issues) do
			if issue.type == "missing_layer" then
				table.insert(report, "  ❌ Missing layer: " .. issue.layer)
			elseif issue.type == "missing_file" then
				table.insert(report, "  ❌ Missing file: " .. issue.path)
			end
		end
		table.insert(report, "")
	end

	-- Environment issues
	if #validation_results.environment_issues > 0 then
		table.insert(report, "ENVIRONMENT ISSUES:")
		for _, issue in ipairs(validation_results.environment_issues) do
			table.insert(report, "  ⚠️  Missing environment: " .. issue.environment)
		end
		table.insert(report, "")
	end

	-- Policy issues
	if #validation_results.policy_issues > 0 then
		table.insert(report, "POLICY ISSUES:")
		for _, issue in ipairs(validation_results.policy_issues) do
			table.insert(report, "  ⚠️  Missing policy: " .. issue.path)
		end
		table.insert(report, "")
	end

	-- Domain issues
	if #validation_results.domain_issues > 0 then
		table.insert(report, "DOMAIN ISSUES:")
		for _, issue in ipairs(validation_results.domain_issues) do
			table.insert(report, "  ⚠️  Missing domain: " .. issue.domain_type)
		end
		table.insert(report, "")
	end

	if validation_results.summary.total_issues == 0 then
		table.insert(report, "✅ All validation checks passed!")
	end

	return table.concat(report, "\n")
end

return validator
