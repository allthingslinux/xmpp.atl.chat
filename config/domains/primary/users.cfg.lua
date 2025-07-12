-- ===============================================
-- PRIMARY DOMAIN USER POLICIES
-- User management and policies for main domain
-- ===============================================

local domain = os.getenv("PROSODY_DOMAIN") or "localhost"

-- User registration policies
allow_registration = os.getenv("PROSODY_ALLOW_REGISTRATION") == "true"
registration_throttle_max = 5
registration_throttle_period = 300

-- User limits and quotas
user_limits = {
	-- Connection limits per user
	c2s_connections = 10,

	-- Message rate limits
	message_rate = "10/minute",

	-- Roster size limits
	roster_size = 1000,

	-- Storage quotas
	storage_quota = "100MB",
}

-- Password policies
password_policy = {
	length = 8,
	characters = {
		upper = 1,
		lower = 1,
		digit = 1,
		special = 0,
	},
}

-- User features
user_features = {
	-- Allow password changes
	password_change = true,

	-- Allow account deletion
	account_deletion = true,

	-- Allow data export
	data_export = true,

	-- Enable user avatars
	avatars = true,

	-- Enable user mood/activity
	rich_presence = true,
}

print("Primary domain user policies loaded for: " .. domain)
