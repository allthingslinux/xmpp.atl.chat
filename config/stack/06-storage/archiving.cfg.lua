-- Layer 06: Storage - Archiving Configuration
-- Message archiving, compliance logging, and data retention
-- XEP-0313: Message Archive Management, XEP-0136: Message Archiving (deprecated)
-- Compliance and legal requirements for message retention

local archiving_config = {
	-- Message Archive Management (XEP-0313)
	-- Modern message archiving with full-text search and retrieval
	mam = {
		"mam", -- XEP-0313: Message Archive Management (core)
	},

	-- Archive Storage and Indexing
	-- Enhanced archiving capabilities
	archive_storage = {
		"mam_muc", -- MUC message archiving (community)
		-- "mam_archive_size", -- Archive size management (community)
	},

	-- Compliance and Legal
	-- Compliance logging and legal requirements
	compliance = {
		-- "compliance_2023", -- Modern compliance features (community)
		-- "audit", -- Audit logging (community)
	},

	-- Data Export and Migration
	-- Tools for data export and migration
	export_tools = {
		-- "data_exporter", -- Export user data (community)
		-- "migrate", -- Data migration tools (community)
	},
}

-- Archive Configuration Settings
-- Configure message archiving behavior and policies
local archive_settings = {
	-- Global MAM settings
	default_archive_policy = "roster", -- Options: always, never, roster
	max_archive_query_results = 50,
	default_max_items = 20,

	-- Archive retention policy
	archive_expires_after = "1w", -- Keep archives for 1 week by default
	-- archive_expires_after = "never", -- Keep archives forever

	-- Storage quotas
	max_archive_size = 1000, -- Maximum number of messages per user

	-- MUC archiving settings
	muc_log_by_default = true, -- Enable MUC logging by default
	muc_log_all_rooms = false, -- Don't log all rooms automatically

	-- Privacy settings
	archive_private_messages = true,
	archive_groupchat_messages = true,

	-- Performance settings
	archive_compression = true, -- Compress archived messages
	archive_cleanup_interval = 86400, -- Clean up expired archives daily (seconds)
}

-- Per-Host Archive Configuration
-- Different archiving policies for different virtual hosts
local function configure_host_archiving(host)
	local config = {
		-- Enable MAM for this host
		modules_enabled = archiving_config.mam,

		-- Apply archive settings
		archive_expires_after = archive_settings.archive_expires_after,
		default_archive_policy = archive_settings.default_archive_policy,
		max_archive_query_results = archive_settings.max_archive_query_results,

		-- Storage configuration for archives
		storage = {
			archive = "internal", -- Can be "sql" for production
		},
	}

	return config
end

-- Archive Management Functions
-- Utility functions for archive management
local archive_management = {
	-- Cleanup expired archives
	cleanup_expired = function()
		-- This would be implemented by the cleanup modules
		-- Automatically handled by Prosody's built-in cleanup
	end,

	-- Export user archives
	export_user_data = function(username)
		-- This would be implemented by data export modules
		-- Manual process or via admin commands
	end,

	-- Migrate archives between storage backends
	migrate_archives = function(from_storage, to_storage)
		-- This would be implemented by migration modules
		-- Use prosodyctl for storage migration
	end,
}

-- Export configuration
return {
	modules = {
		-- Core archiving modules
		mam = archiving_config.mam,

		-- Additional archiving features (commented out by default)
		-- storage = archiving_config.archive_storage,
		-- compliance = archiving_config.compliance,
		-- export = archiving_config.export_tools,
	},

	settings = archive_settings,
	configure_host = configure_host_archiving,
	management = archive_management,
}
