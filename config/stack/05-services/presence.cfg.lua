-- ============================================================================
-- SERVICES LAYER: PRESENCE MANAGEMENT
-- ============================================================================
-- XEP-0030: Service Discovery
-- XEP-0115: Entity Capabilities
-- XEP-0237: Roster Versioning
-- XEP-0321: Remote Roster Management

-- Presence management modules
services_presence_modules = {
	"presence", -- Core presence handling
	"roster", -- Contact list management
	"pep", -- Personal Eventing Protocol
	"vcard4", -- vCard4 support
	"vcard_legacy", -- Legacy vCard support
	"lastactivity", -- Last activity tracking
}

-- Merge with services modules
services_modules = services_modules or {}
for _, module in ipairs(services_presence_modules) do
	table.insert(services_modules, module)
end
