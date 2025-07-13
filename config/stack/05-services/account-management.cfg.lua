-- ===============================================
-- SERVICES LAYER: ACCOUNT MANAGEMENT
-- ===============================================
-- Prosody 13.0+ Account Management and Activity Tracking
-- mod_account_activity: Records last login/logout times
-- mod_user_account_management: Enhanced account management
-- Role and permissions framework integration

local account_config = {
	-- Account Activity Tracking (New in 13.0)
	-- Records user login/logout times and activity
	activity_tracking = {
		"account_activity", -- mod_account_activity: Last login/logout tracking
	},

	-- User Account Management (Enhanced in 13.0)
	-- Password changes, account state management
	account_management = {
		"user_account_management", -- Enhanced account management (core)
		"register", -- User registration (core)
		"register_limits", -- Registration rate limiting (core)
	},

	-- Account State Management (New in 13.0)
	-- Disable/enable user accounts
	state_management = {
		-- Account state features are built into core
		-- Controlled via prosodyctl commands and admin interfaces
	},

	-- Registration Grace Period (New in 13.0)
	-- Deletion requests with grace period support
	deletion_management = {
		-- Grace period features are built into mod_user_account_management
		-- Configured via grace_period settings
	},
}

-- Apply account management configuration
local function apply_account_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	local core_modules = {}

	-- Activity tracking (always enabled)
	for _, module in ipairs(account_config.activity_tracking) do
		table.insert(core_modules, module)
	end

	-- Account management (always enabled)
	for _, module in ipairs(account_config.account_management) do
		table.insert(core_modules, module)
	end

	return core_modules
end

-- Account Activity Configuration
-- mod_account_activity settings
account_activity_config = {
	-- Enable activity tracking
	enabled = true,

	-- Activity retention period
	activity_retention = "1y", -- Keep activity records for 1 year

	-- Track login events
	track_login = true,

	-- Track logout events
	track_logout = true,

	-- Track last seen information
	track_last_seen = true,

	-- Storage backend for activity data
	activity_storage = "internal", -- internal, sql, file

	-- Admin access to activity data
	admin_access = true,
}

-- User Account Management Configuration
-- Enhanced account management settings
user_account_config = {
	-- Enable account management
	enabled = true,

	-- Password change settings
	password_change = {
		enabled = true,
		require_current_password = true,
		min_password_length = 8,
		complexity_requirements = true,
	},

	-- Account deletion settings
	deletion = {
		enabled = true,
		grace_period = "7d", -- 7 day grace period before actual deletion
		admin_notification = true,
		backup_before_deletion = true,
	},

	-- Account disable/enable
	account_state = {
		admin_can_disable = true,
		user_can_request_disable = false,
		disabled_account_cleanup = "30d", -- Clean up disabled accounts after 30 days
	},
}

-- Registration Configuration (Enhanced in 13.0)
-- Updated registration features and limits
registration_config = {
	-- Basic registration settings
	enabled = false, -- Disabled by default for security

	-- Registration limits (Enhanced in 13.0)
	limits = {
		-- Rate limiting
		rate_limit = "3/hour", -- 3 registrations per hour per IP
		burst_limit = 5, -- Allow burst of 5 registrations

		-- Total limits
		max_registrations_per_ip = 5,
		max_registrations_per_day = 100,

		-- Blacklist/whitelist
		ip_whitelist = {}, -- Allowed IPs
		ip_blacklist = {}, -- Blocked IPs
		domain_blacklist = {}, -- Blocked email domains
	},

	-- Registration requirements
	requirements = {
		email_verification = true,
		captcha_verification = false, -- Requires external captcha service
		admin_approval = false,
		invitation_only = false,
	},

	-- Welcome messages
	welcome = {
		enabled = true,
		message = "Welcome to our XMPP service! Please read our terms of service.",
		motd_on_first_login = true,
	},
}

-- Shell Commands for Account Management
-- Enhanced prosodyctl commands for account management
shell_commands = {
	-- Account activity commands
	"user:activity <jid>", -- Show user activity
	"user:last_seen <jid>", -- Show last seen time
	"user:login_history <jid>", -- Show login history

	-- Account state commands
	"user:disable <jid>", -- Disable user account
	"user:enable <jid>", -- Enable user account
	"user:delete <jid> [grace_period]", -- Delete with optional grace period

	-- Bulk operations
	"user:cleanup_inactive <period>", -- Clean up inactive accounts
	"user:export_activity", -- Export activity data
}

-- Roles and Permissions (New Framework in 13.0)
-- Configure the new roles and permissions system
roles_permissions = {
	-- Default roles
	default_roles = {
		"prosody:user", -- Standard user role
		"prosody:admin", -- Administrator role
		"prosody:operator", -- Operator role
	},

	-- Custom roles
	custom_roles = {
		-- Example custom roles
		moderator = {
			permissions = {
				"muc:kick",
				"muc:ban",
				"muc:moderate",
			},
		},
		support = {
			permissions = {
				"user:view_activity",
				"user:reset_password",
			},
		},
	},

	-- Permission inheritance
	role_inheritance = {
		["prosody:admin"] = { "prosody:operator", "prosody:user" },
		["prosody:operator"] = { "prosody:user" },
	},
}

-- Apply configuration
local modules = apply_account_config()

-- Export modules for layer loading
account_management_modules = modules

-- Merge with services modules if it exists
if services_modules then
	for _, module in ipairs(modules) do
		table.insert(services_modules, module)
	end
end

print("Account management configuration loaded (Prosody 13.0+ features)")

-- Configuration notes for administrators
print("Note: Use 'prosodyctl user:activity <jid>' to view user activity")
print("Note: Account deletion now supports grace periods via 'prosodyctl user:delete <jid> 7d'")
print("Note: New roles framework available - see roles_permissions configuration")
