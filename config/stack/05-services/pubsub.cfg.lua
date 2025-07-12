-- ============================================================================
-- SERVICES LAYER: PUBLISH-SUBSCRIBE
-- ============================================================================
-- XEP-0060: Publish-Subscribe
-- XEP-0163: Personal Eventing Protocol
-- XEP-0248: PubSub Collection Nodes

-- Publish-Subscribe modules
services_pubsub_modules = {
	"pubsub", -- Publish-Subscribe core
	"pep", -- Personal Eventing Protocol
}

-- Merge with services modules
services_modules = services_modules or {}
for _, module in ipairs(services_pubsub_modules) do
	table.insert(services_modules, module)
end
