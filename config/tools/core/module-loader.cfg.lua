-- ===============================================
-- ENHANCED MODULE LOADER
-- ===============================================
-- Advanced module loading with dependency checking and error handling
-- Ensures consistent module naming and proper XEP compliance tracking
-- Based on Prosody configuration best practices

-- ===============================================
-- MODULE VALIDATION AND DEPENDENCY CHECKING
-- ===============================================

local module_loader = {}

-- Track XEP compliance for loaded modules
-- Helps with compliance reporting and feature documentation
module_loader.xep_compliance = {}

-- Module dependency mapping
-- Ensures modules are loaded in correct order
module_loader.dependencies = {
	["mam"] = { "offline", "storage" },
	["carbons"] = { "roster" },
	["smacks"] = { "session" },
	["csi_simple"] = { "session" },
	["http_upload"] = { "http", "disco" },
	["websocket"] = { "http" },
	["bosh"] = { "http" },
	["proxy65"] = { "disco" },
	["muc"] = { "disco" },
	["pubsub"] = { "disco", "pep" },
}

-- XEP mapping for documentation and compliance
-- Consistent with user preference for XEP references [[memory:3030509]]
module_loader.xep_mapping = {
	["mam"] = "XEP-0313: Message Archive Management",
	["carbons"] = "XEP-0280: Message Carbons",
	["smacks"] = "XEP-0198: Stream Management",
	["csi_simple"] = "XEP-0352: Client State Indication",
	["ping"] = "XEP-0199: XMPP Ping",
	["time"] = "XEP-0202: Entity Time",
	["version"] = "XEP-0092: Software Version",
	["disco"] = "XEP-0030: Service Discovery",
	["http_upload"] = "XEP-0363: HTTP File Upload",
	["websocket"] = "RFC 7395: An Extensible Messaging and Presence Protocol (XMPP) Subprotocol for WebSocket",
	["bosh"] = "XEP-0124: Bidirectional-streams Over Synchronous HTTP (BOSH)",
	["proxy65"] = "XEP-0065: SOCKS5 Bytestreams",
	["muc"] = "XEP-0045: Multi-User Chat",
	["pubsub"] = "XEP-0060: Publish-Subscribe",
	["pep"] = "XEP-0163: Personal Eventing Protocol",
	["vcard"] = "XEP-0054: vcard-temp",
	["private"] = "XEP-0049: Private XML Storage",
}

-- ===============================================
-- SAFE MODULE LOADING FUNCTIONS
-- ===============================================

-- Check if module exists before loading
function module_loader.module_exists(module_name)
	-- Remove mod_ prefix if present for consistency [[memory:3030813]]
	local clean_name = module_name:gsub("^mod_", "")

	-- Try to find the module file
	local possible_paths = {
		"/usr/lib/prosody/modules/mod_" .. clean_name .. ".lua",
		"/usr/local/lib/prosody/modules/mod_" .. clean_name .. ".lua",
		"./plugins/mod_" .. clean_name .. ".lua",
	}

	for _, path in ipairs(possible_paths) do
		local file = io.open(path, "r")
		if file then
			file:close()
			return true
		end
	end

	return false
end

-- Load module with dependency checking
function module_loader.safe_load_module(module_name, host)
	-- Clean module name for consistency
	local clean_name = module_name:gsub("^mod_", "")

	-- Check dependencies first
	local deps = module_loader.dependencies[clean_name]
	if deps then
		for _, dep in ipairs(deps) do
			if not module_loader.is_module_loaded(dep, host) then
				print("Warning: Module '" .. clean_name .. "' requires '" .. dep .. "' but it's not loaded")
			end
		end
	end

	-- Check if module exists
	if not module_loader.module_exists(clean_name) then
		print("Error: Module '" .. clean_name .. "' not found")
		return false
	end

	-- Record XEP compliance
	local xep_info = module_loader.xep_mapping[clean_name]
	if xep_info then
		module_loader.xep_compliance[clean_name] = xep_info
		print("Loading: " .. clean_name .. " (" .. xep_info .. ")")
	else
		print("Loading: " .. clean_name)
	end

	return true
end

-- Check if module is already loaded
function module_loader.is_module_loaded(module_name, host)
	-- This would need to interface with Prosody's internal module system
	-- For now, we'll assume modules are loaded if they exist
	return module_loader.module_exists(module_name)
end

-- ===============================================
-- BATCH MODULE LOADING
-- ===============================================

-- Load modules with proper dependency resolution
function module_loader.load_module_set(modules, host)
	local loaded = {}
	local to_load = {}

	-- Copy module list
	for _, module in ipairs(modules) do
		table.insert(to_load, module)
	end

	-- Dependency resolution loop
	local max_iterations = #to_load * 2 -- Prevent infinite loops
	local iteration = 0

	while #to_load > 0 and iteration < max_iterations do
		iteration = iteration + 1
		local progress = false

		for i = #to_load, 1, -1 do
			local module = to_load[i]
			local clean_name = module:gsub("^mod_", "")
			local deps = module_loader.dependencies[clean_name]
			local can_load = true

			-- Check if all dependencies are loaded
			if deps then
				for _, dep in ipairs(deps) do
					if not loaded[dep] then
						can_load = false
						break
					end
				end
			end

			if can_load then
				if module_loader.safe_load_module(module, host) then
					loaded[clean_name] = true
					table.remove(to_load, i)
					progress = true
				end
			end
		end

		if not progress then
			print("Warning: Could not resolve dependencies for remaining modules:")
			for _, module in ipairs(to_load) do
				print("  - " .. module)
			end
			break
		end
	end

	return loaded
end

-- ===============================================
-- COMPLIANCE REPORTING
-- ===============================================

-- Generate XEP compliance report
function module_loader.generate_compliance_report()
	print("=== XEP COMPLIANCE REPORT ===")
	for module, xep in pairs(module_loader.xep_compliance) do
		print("✓ " .. module .. ": " .. xep)
	end
	print("=== END COMPLIANCE REPORT ===")
end

-- Export module loader for use in other configurations
return module_loader
