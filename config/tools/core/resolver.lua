-- ============================================================================
-- PROSODY DEPENDENCY RESOLVER
-- ============================================================================
-- Resolves dependencies between modules, configurations, and layers
-- Ensures proper loading order and prevents circular dependencies

local resolver = {}

-- ============================================================================
-- DEPENDENCY TRACKING
-- ============================================================================

-- Module dependency definitions
local module_dependencies = {
	-- HTTP and web modules
	["http_upload"] = { "http" },
	["http_file_share"] = { "http" },
	["websocket"] = { "http" },
	["bosh"] = { "http" },

	-- Authentication dependencies
	["saslauth"] = { "auth_internal_hashed" },
	["auth_ldap"] = { "saslauth" },
	["auth_oauth_external"] = { "http" },

	-- Storage dependencies
	["mam"] = { "storage" },
	["pep"] = { "storage" },
	["private"] = { "storage" },
	["vcard"] = { "storage" },

	-- Security modules
	["firewall"] = { "blocklist" },
	["spam_reporting"] = { "firewall" },

	-- Mobile optimizations
	["cloud_notify"] = { "push_notification" },
	["smacks"] = { "carbons" },

	-- Group chat
	["muc_mam"] = { "muc", "mam" },
	["muc_limits"] = { "muc" },
	["muc_log"] = { "muc" },

	-- Advanced features
	["carbons"] = { "smacks" },
	["csi_battery_saver"] = { "csi" },
}

-- Layer dependencies (layers that must be loaded before others)
local layer_dependencies = {
	["02-stream"] = { "01-transport" },
	["03-stanza"] = { "02-stream" },
	["04-protocol"] = { "03-stanza" },
	["05-services"] = { "04-protocol" },
	["06-storage"] = { "01-transport" }, -- Storage can be loaded early
	["07-interfaces"] = { "01-transport", "06-storage" },
	["08-integration"] = { "07-interfaces" },
}

-- ============================================================================
-- DEPENDENCY RESOLUTION FUNCTIONS
-- ============================================================================

-- Resolve module dependencies
function resolver.resolve_module_dependencies(modules)
	local resolved = {}
	local visiting = {}
	local visited = {}

	local function visit(module)
		if visited[module] then
			return
		end

		if visiting[module] then
			error("Circular dependency detected involving module: " .. module)
		end

		visiting[module] = true

		-- Visit dependencies first
		local deps = module_dependencies[module] or {}
		for _, dep in ipairs(deps) do
			visit(dep)
		end

		visiting[module] = false
		visited[module] = true
		table.insert(resolved, module)
	end

	-- Visit all modules
	for _, module in ipairs(modules) do
		visit(module)
	end

	return resolved
end

-- Resolve layer loading order
function resolver.resolve_layer_order()
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

	local resolved = {}
	local visiting = {}
	local visited = {}

	local function visit(layer)
		if visited[layer] then
			return
		end

		if visiting[layer] then
			error("Circular dependency detected in layer: " .. layer)
		end

		visiting[layer] = true

		-- Visit dependencies first
		local deps = layer_dependencies[layer] or {}
		for _, dep in ipairs(deps) do
			visit(dep)
		end

		visiting[layer] = false
		visited[layer] = true
		table.insert(resolved, layer)
	end

	-- Visit all layers
	for _, layer in ipairs(layers) do
		visit(layer)
	end

	return resolved
end

-- Check for missing dependencies
function resolver.check_missing_dependencies(modules)
	local missing = {}
	local available = {}

	-- Build available modules set
	for _, module in ipairs(modules) do
		available[module] = true
	end

	-- Check each module's dependencies
	for _, module in ipairs(modules) do
		local deps = module_dependencies[module] or {}
		for _, dep in ipairs(deps) do
			if not available[dep] then
				table.insert(missing, {
					module = module,
					missing_dependency = dep,
				})
			end
		end
	end

	return missing
end

-- Suggest additional modules based on enabled modules
function resolver.suggest_modules(enabled_modules)
	local suggestions = {}
	local enabled_set = {}

	-- Build enabled modules set
	for _, module in ipairs(enabled_modules) do
		enabled_set[module] = true
	end

	-- Common module combinations
	local suggestions_map = {
		-- If HTTP is enabled, suggest web features
		["http"] = { "http_upload", "websocket", "bosh" },

		-- If MUC is enabled, suggest MUC extensions
		["muc"] = { "muc_mam", "muc_limits", "muc_log" },

		-- If MAM is enabled, suggest related features
		["mam"] = { "carbons", "smacks" },

		-- If mobile features are detected, suggest full mobile stack
		["smacks"] = { "csi", "cloud_notify", "carbons" },
		["csi"] = { "smacks", "cloud_notify", "csi_battery_saver" },

		-- If security modules are enabled, suggest comprehensive security
		["firewall"] = { "blocklist", "spam_reporting" },

		-- If authentication is customized, suggest related modules
		["auth_ldap"] = { "groups", "roster_allinall" },
	}

	for enabled_module, _ in pairs(enabled_set) do
		local suggested = suggestions_map[enabled_module] or {}
		for _, suggestion in ipairs(suggested) do
			if not enabled_set[suggestion] then
				table.insert(suggestions, {
					suggested_module = suggestion,
					reason = "Commonly used with " .. enabled_module,
				})
			end
		end
	end

	return suggestions
end

-- ============================================================================
-- CONFLICT DETECTION
-- ============================================================================

-- Check for module conflicts
function resolver.check_module_conflicts(modules)
	local conflicts = {}
	local enabled_set = {}

	-- Build enabled modules set
	for _, module in ipairs(modules) do
		enabled_set[module] = true
	end

	-- Known conflicting module pairs
	local conflict_pairs = {
		{ "carbons", "carbon_copy" },
		{ "mam", "mod_archive" },
		{ "smacks", "stream_management" },
		{ "bosh", "http_bind" },
		{ "websocket", "websocket_server" },
		{ "auth_internal_hashed", "auth_internal_plain" },
		{ "storage_sql", "storage_memory" }, -- Usually not both needed
	}

	for _, pair in ipairs(conflict_pairs) do
		if enabled_set[pair[1]] and enabled_set[pair[2]] then
			table.insert(conflicts, {
				type = "module_conflict",
				modules = { pair[1], pair[2] },
				recommendation = "Choose one of: " .. table.concat(pair, " or "),
			})
		end
	end

	return conflicts
end

-- Check for incompatible settings
function resolver.check_setting_conflicts(config)
	local conflicts = {}

	-- Check for logical conflicts
	if config.c2s_require_encryption == false and config.security_level == "high" then
		table.insert(conflicts, {
			type = "setting_conflict",
			description = "High security level requires encryption",
			recommendation = "Set c2s_require_encryption = true",
		})
	end

	if config.allow_registration == true and config.registration_whitelist then
		table.insert(conflicts, {
			type = "setting_conflict",
			description = "Open registration conflicts with whitelist",
			recommendation = "Choose either open registration or whitelist",
		})
	end

	return conflicts
end

-- ============================================================================
-- OPTIMIZATION SUGGESTIONS
-- ============================================================================

-- Suggest optimizations based on configuration
function resolver.suggest_optimizations(config, environment)
	local suggestions = {}

	-- Environment-specific suggestions
	if environment == "production" then
		if not config.log_level or config.log_level == "debug" then
			table.insert(suggestions, {
				type = "performance",
				description = "Set log level to 'info' or 'warn' for production",
				recommendation = "log_level = 'info'",
			})
		end

		if not config.max_clients or config.max_clients > 10000 then
			table.insert(suggestions, {
				type = "performance",
				description = "Consider setting reasonable client limits",
				recommendation = "max_clients = 5000",
			})
		end
	end

	if environment == "development" then
		if config.log_level ~= "debug" then
			table.insert(suggestions, {
				type = "development",
				description = "Enable debug logging for development",
				recommendation = "log_level = 'debug'",
			})
		end
	end

	-- Module-specific suggestions
	if config.modules_enabled then
		local modules = config.modules_enabled
		local has_http = resolver.table_contains(modules, "http")
		local has_upload = resolver.table_contains(modules, "http_upload")

		if has_http and not has_upload then
			table.insert(suggestions, {
				type = "feature",
				description = "Enable file upload for better user experience",
				recommendation = "Add 'http_upload' to modules_enabled",
			})
		end

		local has_muc = resolver.table_contains(modules, "muc")
		local has_muc_mam = resolver.table_contains(modules, "muc_mam")

		if has_muc and not has_muc_mam then
			table.insert(suggestions, {
				type = "feature",
				description = "Enable message archiving for group chats",
				recommendation = "Add 'muc_mam' to modules_enabled",
			})
		end
	end

	return suggestions
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Check if table contains value
function resolver.table_contains(table, value)
	for _, v in ipairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

-- Generate dependency report
function resolver.generate_dependency_report(modules, layers)
	local report = {}

	table.insert(report, "=== DEPENDENCY RESOLUTION REPORT ===")
	table.insert(report, "")

	-- Module dependencies
	local resolved_modules = resolver.resolve_module_dependencies(modules)
	table.insert(report, "Module Load Order:")
	for i, module in ipairs(resolved_modules) do
		table.insert(report, "  " .. i .. ". " .. module)
	end
	table.insert(report, "")

	-- Layer dependencies
	local resolved_layers = resolver.resolve_layer_order()
	table.insert(report, "Layer Load Order:")
	for i, layer in ipairs(resolved_layers) do
		table.insert(report, "  " .. i .. ". " .. layer)
	end
	table.insert(report, "")

	-- Missing dependencies
	local missing = resolver.check_missing_dependencies(modules)
	if #missing > 0 then
		table.insert(report, "Missing Dependencies:")
		for _, miss in ipairs(missing) do
			table.insert(report, "  ❌ " .. miss.module .. " requires " .. miss.missing_dependency)
		end
		table.insert(report, "")
	end

	-- Suggestions
	local suggestions = resolver.suggest_modules(modules)
	if #suggestions > 0 then
		table.insert(report, "Suggested Additional Modules:")
		for _, suggestion in ipairs(suggestions) do
			table.insert(report, "  💡 " .. suggestion.suggested_module .. " (" .. suggestion.reason .. ")")
		end
		table.insert(report, "")
	end

	table.insert(report, "✅ Dependency resolution completed")

	return table.concat(report, "\n")
end

return resolver
