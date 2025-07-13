-- ============================================================================
-- PROSODY CONFIGURATION MERGER
-- ============================================================================
-- Merges configurations from multiple layers, environments, and policies
-- Handles conflicts and provides intelligent configuration composition

local merger = {}

-- ============================================================================
-- MERGING FUNCTIONS
-- ============================================================================

-- Deep merge two tables, with second table taking precedence
function merger.deep_merge(table1, table2)
	local result = {}

	-- Copy all values from table1
	for key, value in pairs(table1) do
		if type(value) == "table" then
			result[key] = merger.deep_merge(value, {})
		else
			result[key] = value
		end
	end

	-- Merge values from table2, overriding table1
	for key, value in pairs(table2) do
		if type(value) == "table" and type(result[key]) == "table" then
			result[key] = merger.deep_merge(result[key], value)
		else
			result[key] = value
		end
	end

	return result
end

-- Merge module lists intelligently
function merger.merge_modules(modules_list)
	local merged_modules = {}
	local seen_modules = {}

	for _, module_set in ipairs(modules_list) do
		if type(module_set) == "table" then
			for _, module in ipairs(module_set) do
				if not seen_modules[module] then
					table.insert(merged_modules, module)
					seen_modules[module] = true
				end
			end
		end
	end

	return merged_modules
end

-- Merge configurations with priority handling
function merger.merge_configs(configs, priorities)
	local merged = {}
	priorities = priorities or {}

	-- Sort configs by priority (higher number = higher priority)
	local sorted_configs = {}
	for i, config in ipairs(configs) do
		table.insert(sorted_configs, {
			config = config,
			priority = priorities[i] or 0,
		})
	end

	table.sort(sorted_configs, function(a, b)
		return a.priority < b.priority
	end)

	-- Merge in priority order
	for _, config_item in ipairs(sorted_configs) do
		merged = merger.deep_merge(merged, config_item.config)
	end

	return merged
end

-- Merge environment-specific overrides
function merger.apply_environment_overrides(base_config, environment_config)
	local merged = merger.deep_merge(base_config, environment_config)

	-- Handle special environment cases
	if environment_config.environment_type then
		if environment_config.environment_type == "development" then
			-- Development-specific merging
			merged.log_level = environment_config.log_level or "debug"
			merged.console_enabled = true
		elseif environment_config.environment_type == "production" then
			-- Production-specific merging
			merged.log_level = environment_config.log_level or "info"
			merged.console_enabled = false
		end
	end

	return merged
end

-- Apply policy constraints
function merger.apply_policy_constraints(config, policies)
	local constrained = merger.deep_merge({}, config)

	for _, policy in ipairs(policies) do
		if policy.type == "security" then
			constrained = merger.apply_security_policy(constrained, policy)
		elseif policy.type == "performance" then
			constrained = merger.apply_performance_policy(constrained, policy)
		elseif policy.type == "compliance" then
			constrained = merger.apply_compliance_policy(constrained, policy)
		end
	end

	return constrained
end

-- Apply security policy constraints
function merger.apply_security_policy(config, security_policy)
	local secured = merger.deep_merge(config, {})

	-- Force security settings based on policy level
	if security_policy.level == "paranoid" then
		secured.ssl_protocols = { "tlsv1_3" }
		secured.ssl_ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!SHA1:!AESCCM"
		secured.c2s_require_encryption = true
		secured.s2s_require_encryption = true
	elseif security_policy.level == "enhanced" then
		secured.ssl_protocols = { "tlsv1_2", "tlsv1_3" }
		secured.c2s_require_encryption = true
		secured.s2s_require_encryption = true
	end

	return secured
end

-- Apply performance policy constraints
function merger.apply_performance_policy(config, performance_policy)
	local optimized = merger.deep_merge(config, {})

	if performance_policy.tier == "large" then
		optimized.max_clients = 10000
		optimized.max_connections_per_ip = 20
		optimized.c2s_timeout = 300
	elseif performance_policy.tier == "medium" then
		optimized.max_clients = 1000
		optimized.max_connections_per_ip = 10
		optimized.c2s_timeout = 180
	elseif performance_policy.tier == "small" then
		optimized.max_clients = 100
		optimized.max_connections_per_ip = 5
		optimized.c2s_timeout = 120
	end

	return optimized
end

-- Apply compliance policy constraints
function merger.apply_compliance_policy(config, compliance_policy)
	local compliant = merger.deep_merge(config, {})

	if compliance_policy.standard == "gdpr" then
		compliant.data_retention_days = 365
		compliant.require_consent = true
		compliant.anonymize_logs = true
	end

	return compliant
end

-- ============================================================================
-- CONFLICT RESOLUTION
-- ============================================================================

-- Resolve configuration conflicts
function merger.resolve_conflicts(config, conflict_resolution_rules)
	local resolved = merger.deep_merge({}, config)
	conflict_resolution_rules = conflict_resolution_rules or {}

	-- Default conflict resolution rules
	local default_rules = {
		-- Security: always take the most restrictive
		security_precedence = "most_restrictive",
		-- Performance: take the most conservative
		performance_precedence = "most_conservative",
		-- Modules: merge all unless explicitly conflicting
		module_precedence = "merge_all",
	}

	local rules = merger.deep_merge(default_rules, conflict_resolution_rules)

	-- Apply conflict resolution
	if rules.security_precedence == "most_restrictive" then
		resolved = merger.apply_most_restrictive_security(resolved)
	end

	return resolved
end

-- Apply most restrictive security settings
function merger.apply_most_restrictive_security(config)
	local secured = merger.deep_merge({}, config)

	-- If any layer requires encryption, require it everywhere
	if config.c2s_require_encryption or config.s2s_require_encryption then
		secured.c2s_require_encryption = true
		secured.s2s_require_encryption = true
	end

	-- Use the most restrictive SSL protocols
	if config.ssl_protocols then
		local protocols = config.ssl_protocols
		if type(protocols) == "table" then
			-- Only allow TLS 1.3 if it's in the list
			if merger.table_contains(protocols, "tlsv1_3") then
				secured.ssl_protocols = { "tlsv1_3" }
			elseif merger.table_contains(protocols, "tlsv1_2") then
				secured.ssl_protocols = { "tlsv1_2", "tlsv1_3" }
			end
		end
	end

	return secured
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Check if table contains value
function merger.table_contains(table, value)
	for _, v in ipairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

-- Validate merged configuration
function merger.validate_merged_config(merged_config)
	local issues = {}

	-- Check for required fields
	local required_fields = {
		"VirtualHost",
		"modules_enabled",
		"log",
	}

	for _, field in ipairs(required_fields) do
		if not merged_config[field] then
			table.insert(issues, {
				type = "missing_required_field",
				field = field,
			})
		end
	end

	-- Check for conflicting settings
	if merged_config.c2s_require_encryption == false and merged_config.security_level == "high" then
		table.insert(issues, {
			type = "conflicting_settings",
			description = "High security level conflicts with disabled encryption",
		})
	end

	return issues
end

-- Generate merge report
function merger.generate_merge_report(original_configs, merged_config, conflicts_resolved)
	local report = {}

	table.insert(report, "=== CONFIGURATION MERGE REPORT ===")
	table.insert(report, "")
	table.insert(report, "Input Configurations: " .. #original_configs)
	table.insert(report, "Conflicts Resolved: " .. #conflicts_resolved)
	table.insert(report, "")

	-- List merged modules
	if merged_config.modules_enabled then
		table.insert(report, "Merged Modules (" .. #merged_config.modules_enabled .. "):")
		for _, module in ipairs(merged_config.modules_enabled) do
			table.insert(report, "  - " .. module)
		end
		table.insert(report, "")
	end

	-- List resolved conflicts
	if #conflicts_resolved > 0 then
		table.insert(report, "Resolved Conflicts:")
		for _, conflict in ipairs(conflicts_resolved) do
			table.insert(report, "  - " .. conflict.description)
		end
		table.insert(report, "")
	end

	table.insert(report, "✅ Configuration merge completed successfully")

	return table.concat(report, "\n")
end

return merger
