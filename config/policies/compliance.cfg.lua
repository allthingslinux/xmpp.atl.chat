-- ===============================================
-- COMPLIANCE POLICY CONFIGURATION
-- Data protection and compliance settings
-- ===============================================

-- Compliance mode from environment variable
local compliance_mode = os.getenv("PROSODY_COMPLIANCE") or "basic"

-- Basic compliance settings
if compliance_mode then
	-- Enable audit logging
	modules_enabled = modules_enabled or {}
	table.insert(modules_enabled, "audit")

	-- Data retention settings
	if compliance_mode == "gdpr" then
		-- GDPR compliance
		archive_expires_after = "7y" -- 7 years retention
		table.insert(modules_enabled, "data_export")
		table.insert(modules_enabled, "gdpr_compliance")
	elseif compliance_mode == "minimal" then
		-- Minimal data retention
		archive_expires_after = "30d" -- 30 days only
	else
		-- Standard retention
		archive_expires_after = "1y" -- 1 year default
	end
end

print("Compliance policy loaded: " .. (compliance_mode or "none"))
