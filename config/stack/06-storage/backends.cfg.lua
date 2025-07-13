-- Layer 06: Storage - Backends Configuration
-- Database backends, storage drivers, and data persistence
-- SQL, NoSQL, and file-based storage options for different deployment scenarios
-- Reference: https://prosody.im/doc/storage

local storage_backends = {
	-- Core Storage Backends (built into Prosody)
	-- These are the primary storage backends available
	core_backends = {
		"internal", -- Default file-based storage (built-in)
		"sql", -- SQL database support (built-in)
		"memory", -- Memory-only storage for testing (built-in)
		"null", -- Always fails to load/save data (built-in)
		"none", -- Always empty stores, saves always fail (built-in)
	},

	-- Archive Storage Backends
	-- Specialized storage for message archives with enhanced capabilities
	archive_backends = {
		-- "storage_xmlarchive", -- XML-based archive storage (community)
		-- "storage_mongodb", -- MongoDB storage backend (community)
		-- "storage_elasticsearch", -- Elasticsearch storage (community)
	},
}

-- Complete Store Configuration
-- All stores used by core modules as documented in Prosody storage documentation
local storage_stores = {
	-- Authentication and Account Management
	-- User accounts, passwords, and authentication data
	authentication = {
		accounts = "internal", -- Account details, hashed passwords | mod_auth_internal_plain, mod_auth_internal_hashed
		account_details = "internal", -- Extra account details | mod_register
		account_flags = "internal", -- Flagged accounts | mod_flags
		account_roles = "internal", -- Dynamically assigned roles | mod_authz_internal
		accounts_cleanup = "internal", -- Accounts scheduled for deletion | mod_user_account_management
		auth_tokens = "internal", -- Access tokens | mod_tokenauth
		invite_token = "internal", -- Invite tokens | mod_invites
		tombstones = "internal", -- Tombstones for deleted accounts | mod_tombstones
	},

	-- Contact and Social Features
	-- Roster management, vCards, and social features
	social = {
		roster = "internal", -- User contact lists | mod_roster, rostermanager
		vcard = "internal", -- Profile details and avatar (XEP-0054) | mod_vcard
		vcard_muc = "internal", -- MUC room avatars | mod_vcard
		private = "internal", -- Private XML storage (XEP-0049) | mod_private
		blocklist = "internal", -- Blocked JIDs (XEP-0191) | mod_blocklist
		privacy = "internal", -- Privacy lists (XEP-0016) | mod_privacy
		skeletons = "internal", -- Account lookalike tracking | mod_mimicking
	},

	-- Message Archiving and History
	-- Message archives, offline messages, and retention
	messaging = {
		archive = "internal", -- Message archives (XEP-0313 MAM) | mod_mam
		archive_cleanup = "internal", -- Message retention tracking | mod_mam
		archive_prefs = "internal", -- Message archiving preferences | mod_mam
		muc_log = "internal", -- MUC message archives | mod_muc_mam
		muc_log_cleanup = "internal", -- MUC retention tracking | mod_muc_mam
		offline = "internal", -- Offline messages (XEP-0160) | mod_offline
		smacks_h = "internal", -- Stanza counters for stream management | mod_smacks
	},

	-- Multi-User Chat (MUC)
	-- Conference rooms and group chat functionality
	muc = {
		persistent = "internal", -- Set of persistent MUC rooms | mod_muc
		config = "internal", -- Room configuration | mod_muc
		state = "internal", -- Room state during restarts | mod_muc
	},

	-- Publish-Subscribe (PubSub)
	-- PubSub nodes and Personal Eventing Protocol
	pubsub = {
		pubsub_nodes = "internal", -- PubSub node configuration (XEP-0060) | mod_pubsub
		pubsub_data = "internal", -- PubSub node data (archive type) | mod_pubsub
		pep = "internal", -- PEP node configuration (XEP-0163) | mod_pep
		pep_data = "internal", -- PEP node data (archive type) | mod_pep
	},

	-- File Transfer and Upload
	-- File sharing and upload management
	file_transfer = {
		upload_stats = "internal", -- Statistics about uploaded files | mod_http_file_share
		uploads = "internal", -- Records of uploaded files | mod_http_file_share
	},

	-- Push Notifications and Mobile
	-- Mobile push notifications and cloud services
	mobile = {
		cloud_notify = "internal", -- Device notification registrations (XEP-0357) | mod_cloud_notify
	},

	-- System and Maintenance
	-- System maintenance and scheduled tasks
	system = {
		cron = "internal", -- Record keeping for recurring jobs | mod_cron
	},
}

-- Storage Backend Configuration
-- Main storage configuration with environment-specific overrides
local storage_config = {
	-- Default storage backend for all stores
	default_storage = "internal",

	-- Consolidated storage configuration
	-- Combines all store categories into a single configuration
	storage = {},

	-- SQL Database Configuration
	-- Configuration for SQL storage backend
	sql = {
		driver = "SQLite3", -- Options: SQLite3, PostgreSQL, MySQL
		database = "prosody.sqlite", -- Database file/name
		-- For PostgreSQL/MySQL:
		-- host = "localhost",
		-- port = 5432, -- PostgreSQL: 5432, MySQL: 3306
		-- username = "prosody",
		-- password = "secure_password",
		-- ssl = {
		--     mode = "required", -- Options: disabled, allow, prefer, required
		--     cafile = "/path/to/ca-bundle.crt",
		-- },
	},

	-- Memory Storage Configuration
	-- Configuration for memory-only storage (testing/development)
	memory = {
		-- Memory storage is transient and requires no configuration
		-- Used for testing or high-performance temporary data
	},
}

-- Merge all store configurations into the main storage config
local function build_storage_configuration()
	local config = {}

	-- Merge all store categories
	for category, stores in pairs(storage_stores) do
		for store, backend in pairs(stores) do
			config[store] = backend
		end
	end

	return config
end

-- Environment-Specific Storage Overrides
-- Different storage strategies for different environments
local function get_environment_storage_overrides(environment)
	local overrides = {
		development = {
			-- Use internal storage for development
			default_storage = "internal",
			-- Optional: Use memory for some high-churn data
			-- caps = "memory",
			-- carbons = "memory",
		},

		production = {
			-- Use SQL for production scalability
			default_storage = "sql",
			storage = {
				-- Core user data in SQL
				accounts = "sql",
				roster = "sql",
				vcard = "sql",
				private = "sql",
				blocklist = "sql",

				-- Message archives in SQL for persistence
				archive = "sql",
				muc_log = "sql",

				-- PubSub in SQL for multi-server setups
				pubsub_nodes = "sql",
				pubsub_data = "sql",
				pep = "sql",

				-- File uploads in SQL for tracking
				upload_stats = "sql",
				uploads = "sql",

				-- Keep performance-critical data in memory
				caps = "memory",
				carbons = "memory",
			},
		},

		testing = {
			-- Use memory for testing (faster, ephemeral)
			default_storage = "memory",
			storage = {
				-- Keep some essential data in internal for test persistence
				accounts = "internal",
				roster = "internal",
			},
		},
	}

	return overrides[environment] or overrides.development
end

-- Storage Module Loading
-- Automatically load required storage modules based on configuration
local function get_required_storage_modules(config)
	local modules = {}
	local backends_used = {}

	-- Check default storage
	backends_used[config.default_storage or "internal"] = true

	-- Check per-store storage backends
	if config.storage then
		for store, backend in pairs(config.storage) do
			backends_used[backend] = true
		end
	end

	-- Load modules for SQL backend
	if backends_used.sql then
		-- SQL modules are built into Prosody core
		-- No additional modules needed
	end

	-- Load modules for community storage backends
	if backends_used.xmlarchive then
		table.insert(modules, "storage_xmlarchive")
	end

	return modules
end

-- Build the final storage configuration
storage_config.storage = build_storage_configuration()

-- Export configuration
return {
	-- Available storage backends
	backends = storage_backends,

	-- All available stores with descriptions
	stores = storage_stores,

	-- Main storage configuration
	config = storage_config,

	-- Environment-specific overrides
	get_environment_overrides = get_environment_storage_overrides,

	-- Required modules based on configuration
	get_required_modules = get_required_storage_modules,

	-- For backward compatibility
	modules = get_required_storage_modules(storage_config),
}
