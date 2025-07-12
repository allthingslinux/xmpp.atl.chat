-- ===============================================
-- SECURITY POLICY CONFIGURATION
-- Basic security settings for all environments
-- ===============================================

-- Security level from environment variable
local security_level = os.getenv("PROSODY_SECURITY_LEVEL") or "standard"

-- Basic security requirements
if security_level == "standard" or security_level == "enhanced" then
	-- Require encryption for all connections
	c2s_require_encryption = true
	s2s_require_encryption = true

	-- Modern TLS settings
	ssl_protocol = "tlsv1_2+"

	-- Strong authentication
	authentication = "internal_hashed"
end

-- Enhanced security mode
if security_level == "enhanced" then
	-- Stricter connection limits
	limits = {
		c2s = {
			rate = "10kb/s",
			burst = "2s",
		},
		s2s = {
			rate = "30kb/s",
			burst = "2s",
		},
	}

	-- Additional security modules
	modules_enabled = modules_enabled or {}
	table.insert(modules_enabled, "limits")
	table.insert(modules_enabled, "firewall")
end

print("Security policy loaded: " .. security_level)
