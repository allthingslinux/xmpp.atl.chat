-- ============================================================================
-- SERVICES LAYER: GROUP CHAT (MUC)
-- ============================================================================
-- XEP-0045: Multi-User Chat
-- XEP-0313: Message Archive Management for MUC
-- XEP-0249: Direct MUC Invitations

-- Multi-User Chat modules
services_groupchat_modules = {
	"muc", -- Multi-User Chat core
	"muc_mam", -- MUC Message Archive Management
	"muc_unique", -- Unique room names
}

-- Merge with services modules
services_modules = services_modules or {}
for _, module in ipairs(services_groupchat_modules) do
	table.insert(services_modules, module)
end
