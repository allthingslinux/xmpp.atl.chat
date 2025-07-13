-- ===============================================
-- PRIMARY DOMAIN FEATURE CONFIGURATION
-- Domain-specific feature toggles and settings
-- ===============================================

-- Primary domain features
primary_domain_features = {
	-- Core messaging features
	"roster", -- RFC 6121: Contact lists
	"saslauth", -- SASL authentication
	"tls", -- TLS encryption
	"dialback", -- Server dialback

	-- Modern messaging
	"carbons", -- XEP-0280: Message Carbons
	"mam", -- XEP-0313: Message Archive Management
	"smacks", -- XEP-0198: Stream Management
	"csi_simple", -- XEP-0352: Client State Indication

	-- Presence and identity
	"pep", -- XEP-0163: Personal Eventing Protocol
	"vcard_legacy", -- XEP-0054: vcard-temp
	"vcard4", -- XEP-0292: vCard4 Over XMPP
	"avatar", -- XEP-0084: User Avatar

	-- Privacy and security
	"privacy", -- XEP-0016: Privacy Lists
	"blocklist", -- XEP-0191: Blocking Command (core)
	"limits", -- Rate limiting

	-- File sharing
	"http_file_share", -- XEP-0363: HTTP File Upload (core, recommended)

	-- Administration
	"admin_adhoc", -- Administrative commands
	"admin_telnet", -- Telnet administration
}

-- Apply features to modules list
modules_enabled = modules_enabled or {}
for _, feature in ipairs(primary_domain_features) do
	table.insert(modules_enabled, feature)
end

-- Domain-specific settings
archive_expires_after = "1y" -- Keep messages for 1 year
max_archive_query_results = 1000
http_file_share_size_limit = 50 * 1024 * 1024 -- 50MB
http_file_share_expire_after = 60 * 60 * 24 * 7 -- 7 days

print("Primary domain features configured: " .. #primary_domain_features .. " modules")
